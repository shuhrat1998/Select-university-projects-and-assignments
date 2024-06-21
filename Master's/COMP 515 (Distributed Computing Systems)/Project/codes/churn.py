"""
COMP515 Project
Churn Estimation - serial
Name : Shukhrat Khuseynov
ID   : 0070495
"""

import pandas as pd
import matplotlib.pyplot as plt
import time

from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_auc_score

def report (ytest, ypredict):
    """ reporting classification scores and details """
    
    accuracy = accuracy_score(ytest, ypredict)
    auroc = roc_auc_score(ytest, ypredict)
    conf = confusion_matrix(ytest, ypredict)
    
    print("\nAccuracy:", accuracy)
    print("AUROC:", auroc)
    print("Confusion matrix:")
    print(conf)
    
    return (accuracy, auroc, conf)

def gridsearch (model, param, Xtrain, ytrain):
    """ implementing the process of GridSearchCV """
    
    grid = GridSearchCV(model, param, cv=5, scoring = 'roc_auc', refit=True, verbose=1)
    grid.fit(Xtrain, ytrain)

    print("\n", grid.best_score_)
    print("\n", grid.best_params_)
    print("\n", grid.best_estimator_)

# measuring start time
start = time.time()

# reading the data
df = pd.read_csv('mobile-churn-data.csv')

# checking variable types
print(df.info())

# checking whether there is any null element
print(df.isnull().values.any())

# detecting columns with diferent values for each row
print(df.loc[:, (df.nunique()==df.shape[0])].columns)

# dropping the id variable
df.drop(['user_account_id'], axis=1, inplace=True)

# churn distribution (pie chart)
exited = sum(df.churn == 1)
stayed = sum(df.churn == 0)

plt.pie([exited, stayed], labels=['Exited', 'Retained'], autopct='%1.1f%%')
plt.title('Churn distribution')
plt.axis('equal')
plt.show()

# initiating variables for the models
X = df.loc[:, df.columns != 'churn']
y = df.churn
Xtrain, Xtest, ytrain, ytest = train_test_split(X, y, test_size=0.20, random_state=0)

# scaling the data
scale = MinMaxScaler(feature_range=(0,1))
scale.fit(Xtrain)
Xtrain = scale.transform(Xtrain)
Xtest = scale.transform(Xtest)


# Models:

# Logistic Regression
print("\nLogistic Regression")
from sklearn.linear_model import LogisticRegression

reg = LogisticRegression(solver='sag', max_iter=500)
reg.fit(Xtrain, ytrain)
ypredict = reg.predict(Xtest)

reg_accuracy, reg_auroc, reg_conf = report(ytest, ypredict)


# Random Forest classifier
print("\nRandom Forest classifier")
from sklearn.ensemble import RandomForestClassifier

#param = {'n_estimators': [10, 50, 100, 200]}
#gridsearch(RandomForestClassifier(), param, Xtrain, ytrain)
# choosing 50, more estimators do not improve the model significantly

rf = RandomForestClassifier(n_estimators=50, random_state=0)
rf.fit(Xtrain, ytrain) 
ypredict = rf.predict(Xtest)

rf_accuracy, rf_auroc, rf_conf = report(ytest, ypredict)


# Plotting parts are commented out in AWS demo versions for proper time measurement in comparison.

# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.
