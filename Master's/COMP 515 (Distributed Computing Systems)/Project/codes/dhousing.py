"""
COMP515 Project
Housing Price Prediction - distributed
Name : Shukhrat Khuseynov
ID   : 0070495
"""

from pyspark import SparkContext
from pyspark.sql import SQLContext
import time

from pyspark.ml import Pipeline
from pyspark.ml.feature import MinMaxScaler
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.regression import LinearRegression
from pyspark.ml.regression import RandomForestRegressor

# creating Spark context
sc = SparkContext("local")
spark = SQLContext(sc)

# measuring start time
start = time.time()

# reading the data
df = spark.read.format('com.databricks.spark.csv').options(header='true', inferschema='true').load('flats_moscow.csv')

# showing first 5 lines
df.show(5)

# showing one representative row
#print(df.take(1))

# printing schema (description) of data 
#print(df.printSchema())

# printing the columns
print(df.columns)

# printing number of rows
print(df.count())

# dropping the id variable
df = df.drop('_c0')

# dropping the null values, if any
df = df.dropna()
#print(df.count())

# splitting the data into train and test sets
(train, test) = df.randomSplit([0.8, 0.2], seed = 0)

# assigning features
features = VectorAssembler(inputCols = df.columns[1:], outputCol = 'features')

# assigning the scaling
scaler = MinMaxScaler(inputCol="features", outputCol="scaledFeatures")

# Models:

# Linear regression
print("\nLinear regression")

reg0 = LinearRegression(featuresCol = 'scaledFeatures', labelCol = 'price')
pipeline1 = Pipeline(stages = [features, scaler, reg0])

reg = pipeline1.fit(train)
predictions1 = reg.transform(test)

eval1a = RegressionEvaluator(labelCol = 'price', predictionCol="prediction", metricName="r2")
print("Correlation: " + str(eval1a.evaluate(predictions1) ** 0.5))

eval1b = RegressionEvaluator(labelCol = 'price', predictionCol="prediction", metricName="rmse")
print("RMSE: " + str(eval1b.evaluate(predictions1)))

# Random Forest regression
print("\nRandom Forest regression")

rf0 = RandomForestRegressor(featuresCol = 'scaledFeatures', labelCol = 'price', numTrees=115, seed = 0)
pipeline2 = Pipeline(stages = [features, scaler, rf0])

rf = pipeline2.fit(train)
predictions2 = rf.transform(test)

eval2a = RegressionEvaluator(labelCol = 'price', predictionCol="prediction", metricName="r2")
print("Correlation: " + str(eval2a.evaluate(predictions2) ** 0.5))

eval2b = RegressionEvaluator(labelCol = 'price', predictionCol="prediction", metricName="rmse")
print("RMSE: " + str(eval2b.evaluate(predictions2)))

# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.