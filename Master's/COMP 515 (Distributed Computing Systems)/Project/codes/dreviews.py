"""
COMP515 Project
Sentiment Analysis - distributed
Name : Shukhrat Khuseynov
ID   : 0070495
"""

from pyspark import SparkContext
from pyspark.sql import SQLContext
import time

from pyspark.ml import Pipeline
from pyspark.sql.functions import col, lower, regexp_replace
from pyspark.ml.feature import Tokenizer, StopWordsRemover
from pyspark.ml.feature import IDF, CountVectorizer
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from sklearn.metrics import confusion_matrix
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.classification import LinearSVC
from pyspark.ml.classification import NaiveBayes

# creating Spark context
sc = SparkContext("local")
spark = SQLContext(sc)

# measuring start time
start = time.time()

# reading the data
df = spark.read.format('com.databricks.spark.csv').options(header='true', inferschema='true', multiLine=True, escape="\"").load('reviews.csv')

# observing the initial columns
#print(df.columns)

# keeping the needed columns
df = df.select(df.columns[4:7])

# dropping the null values
df = df.dropna()

# showing first 20 lines
df.show()

# printing number of rows
print(df.count())

# renaming columns
df = df.select(col("Review Text").alias("review"), col("Rating").alias("rating"), col("Recommended IND").alias("recommend"))

# observing the columns
print(df.columns)

# preprocessing (cleaning text)
df = df.select('recommend', (lower(regexp_replace('review', "[^A-Za-z]+", " ")).alias('text')))
df.show()

# tokenizing text
tokenizer = Tokenizer(inputCol='text', outputCol='tokens')
dftoken = tokenizer.transform(df).select('recommend', 'tokens')

# removing stop words
remover = StopWordsRemover(inputCol='tokens', outputCol='words')
dftoken = remover.transform(dftoken).select('recommend', 'words')
dftoken.show()

# splitting the data into train and test sets
(train, test) = dftoken.randomSplit([0.8, 0.2], seed = 0)

# applying measures
cv = CountVectorizer(inputCol="words", outputCol='cv')
idf = IDF(inputCol='cv', outputCol="features")


# Models:

# Logistic Regression
print("\nLogistic Regression")

reg0 = LogisticRegression(featuresCol = 'cv', labelCol = 'recommend', maxIter=500)
pipeline1 = Pipeline(stages = [cv, reg0])

reg = pipeline1.fit(train)
predictions1 = reg.transform(test)

ytest = predictions1.select(['recommend']).collect()
ypredict = predictions1.select(['prediction']).collect()
print("\nConfusion matrix:")
print(confusion_matrix(ytest, ypredict))

accuracy1 = predictions1.filter(predictions1.recommend == predictions1.prediction).count() / float(test.count())
print("Accuracy: " + str(accuracy1))

eval1 = BinaryClassificationEvaluator(labelCol = 'recommend', rawPredictionCol="rawPrediction")
print("AUROC: " + str(eval1.evaluate(predictions1, {eval1.metricName: "areaUnderROC"})))

# Linear Support Vector Machines classifier
print("\nLinear Support Vector Machines classifier")

svc0 = LinearSVC(featuresCol = 'cv', labelCol = 'recommend', regParam=0.01, maxIter=5)
pipeline2 = Pipeline(stages = [cv, svc0])

svc = pipeline2.fit(train)
predictions2 = svc.transform(test)

ytest = predictions2.select(['recommend']).collect()
ypredict = predictions2.select(['prediction']).collect()
print("\nConfusion matrix:")
print(confusion_matrix(ytest, ypredict))

accuracy2 = predictions2.filter(predictions2.recommend == predictions2.prediction).count() / float(test.count())
print("Accuracy: " + str(accuracy2))

eval2 = BinaryClassificationEvaluator(labelCol = 'recommend', rawPredictionCol="rawPrediction")
print("AUROC: " + str(eval2.evaluate(predictions2,  {eval2.metricName: "areaUnderROC"})))

# Naive Bayes classifier
#print("\nNaive Bayes classifier")

#nb0 = NaiveBayes(featuresCol = 'cv', labelCol = 'recommend')
#pipeline3 = Pipeline(stages = [cv, nb0])

#nb = pipeline3.fit(train)
#predictions3 = nb.transform(test)

#ytest = predictions3.select(['recommend']).collect()
#ypredict = predictions3.select(['prediction']).collect()
#print("\nConfusion matrix:")
#print(confusion_matrix(ytest, ypredict))

#accuracy3 = predictions3.filter(predictions3.recommend == predictions3.prediction).count() / float(test.count())
#print("Accuracy: " + str(accuracy3))

#eval3 = BinaryClassificationEvaluator(labelCol = 'recommend', rawPredictionCol="rawPrediction")
#print("AUROC: " + str(eval3.evaluate(predictions3,  {eval3.metricName: "areaUnderROC"})))


# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.