"""
COMP515 Project
Churn Estimation - distributed
Name : Shukhrat Khuseynov
ID   : 0070495
"""

from pyspark import SparkContext
from pyspark.sql import SQLContext
import time

from pyspark.ml import Pipeline
from pyspark.ml.feature import MinMaxScaler
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from sklearn.metrics import confusion_matrix
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.classification import RandomForestClassifier

# creating Spark context
sc = SparkContext("local")
spark = SQLContext(sc)

# measuring start time
start = time.time()

# reading the data
df = spark.read.format('com.databricks.spark.csv').options(header='true', inferschema='true').load('mobile-churn-data.csv')

# showing first 5 lines
#df.show(5)

# showing one representative row
#print(df.take(1))

# printing schema (description) of data 
#print(df.printSchema())

# printing the columns
#print(df.columns)

# printing number of rows
print(df.count())

# dropping the id variable
df = df.drop('user_account_id')

# dropping the null values, if any
df = df.dropna()
#print(df.count())

# splitting the data into train and test sets
(train, test) = df.randomSplit([0.8, 0.2], seed = 0)

# assigning features
features = VectorAssembler(inputCols = df.columns[:-1], outputCol = 'features')

# assigning the scaling
scaler = MinMaxScaler(inputCol="features", outputCol="scaledFeatures")

# Models:

# Logistic Regression
print("\nLogistic Regression")

reg0 = LogisticRegression(featuresCol = 'scaledFeatures', labelCol = 'churn', maxIter=500)
pipeline1 = Pipeline(stages = [features, scaler, reg0])

reg = pipeline1.fit(train)
predictions1 = reg.transform(test)

ytest = predictions1.select(['churn']).collect()
ypredict = predictions1.select(['prediction']).collect()
print("\nConfusion matrix:")
print(confusion_matrix(ytest, ypredict))

accuracy1 = predictions1.filter(predictions1.churn == predictions1.prediction).count() / float(test.count())
print("Accuracy: " + str(accuracy1))

eval1 = BinaryClassificationEvaluator(labelCol = 'churn', rawPredictionCol="rawPrediction")
print("AUROC: " + str(eval1.evaluate(predictions1, {eval1.metricName: "areaUnderROC"})))

# Random Forest classifier
print("\nRandom Forest classifier")

rf0 = RandomForestClassifier(featuresCol = 'scaledFeatures', labelCol = 'churn', numTrees=50, seed = 0)
pipeline2 = Pipeline(stages = [features, scaler, rf0])

rf = pipeline2.fit(train)
predictions2 = rf.transform(test)

ytest = predictions2.select(['churn']).collect()
ypredict = predictions2.select(['prediction']).collect()
print("\nConfusion matrix:")
print(confusion_matrix(ytest, ypredict))

accuracy2 = predictions2.filter(predictions2.churn == predictions2.prediction).count() / float(test.count())
print("Accuracy: " + str(accuracy2))

eval2 = BinaryClassificationEvaluator(labelCol = 'churn', rawPredictionCol="rawPrediction")
print("AUROC: " + str(eval2.evaluate(predictions2,  {eval2.metricName: "areaUnderROC"})))

# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.