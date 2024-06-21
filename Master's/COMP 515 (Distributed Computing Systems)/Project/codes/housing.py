"""
COMP515 Project
Housing Price Prediction - serial
Name : Shukhrat Khuseynov
ID   : 0070495
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time

from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score

def report (ytest, ypredict):
    """ reporting scores """
    corr = np.corrcoef(ytest, ypredict)
    r2 = r2_score(ytest, ypredict)
    rmse = mean_squared_error(ytest, ypredict, squared=False)
    print("\nCorrelation:\n", corr)
    #print("\nR^2:\n", r2)
    print("RMSE:\n", rmse)
    return (corr, r2, rmse)

def gridsearch (model, param, Xtrain, ytrain):
    """ implementing the process of GridSearchCV """
    
    grid = GridSearchCV(model, param, cv=5, scoring = 'neg_mean_squared_error', refit=True, verbose=1)
    grid.fit(Xtrain, ytrain)

    print("\n", grid.best_score_)
    print("\n", grid.best_params_)
    print("\n", grid.best_estimator_)

# measuring start time
start = time.time()

# reading the data
df = pd.read_csv('flats_moscow.csv')

# checking variable types
print(df.info())

# checking whether there is any null element
print(df.isnull().values.any())

# detecting columns with diferent values for each row
print(df.loc[:, (df.nunique()==df.shape[0])].columns)

# dropping the id variable
df.drop(['Unnamed: 0'], axis=1, inplace=True)

# initiating variables for the models
X = df.loc[:, df.columns != 'price']
y = df.price
Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, test_size=0.20, random_state=0)

# scaling the data
scale = MinMaxScaler(feature_range=(0,1))
scale.fit(Xtrain)
Xtrain = scale.transform(Xtrain)
Xtest = scale.transform(Xtest)


# Models:

# Linear regression
print("\nLinear regression")
from sklearn.linear_model import LinearRegression

reg = LinearRegression(fit_intercept=True)
reg.fit(Xtrain, ytrain)
ypredict = reg.predict(Xtest)

reg_corr, reg_r2, reg_rmse = report (ytest, ypredict)

# Random Forest regression
print("\nRandom Forest regression")
from sklearn.ensemble import RandomForestRegressor

# param = {'n_estimators': [114, 115, 116]}
# gridsearch(RandomForestRegressor(random_state=0), param, Xtrain, ytrain)
# choosing 115, local extremum

rf = RandomForestRegressor(n_estimators=115, random_state=0)
rf.fit(Xtrain, ytrain) 
ypredict = rf.predict(Xtest)

rf_corr, rf_r2, rf_rmse = report (ytest, ypredict)


# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.