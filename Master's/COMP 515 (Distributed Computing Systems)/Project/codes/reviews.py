"""
COMP515 Project
Sentiment Analysis - serial
Name : Shukhrat Khuseynov
ID   : 0070495
"""

import pandas as pd
import matplotlib.pyplot as plt
import time
import re

from wordcloud import WordCloud, STOPWORDS
from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer
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

def plot_wordcloud(df, title = None):
    """ plotting the tag cloud of words """
    
    stopwords = set(STOPWORDS)
    
    wd = WordCloud(
        background_color='white',
        stopwords=stopwords,
        max_words=200,
        max_font_size=40, 
        scale=3,
        random_state=1 
    ).generate(" ".join(list(df)))

    fig = plt.figure(1, figsize=(12, 12))
    plt.axis('off')
    if title: 
        fig.suptitle(title, fontsize=20)
        fig.subplots_adjust(top=2.3)

    plt.imshow(wd)
    plt.show()

# measuring start time
start = time.time()

# reading the data
df = pd.read_csv('reviews.csv')

# checking variable types
#print(df.info())

# dropping unused columns
df = df.drop(df.columns[7:], axis=1)
df = df.drop(df.columns[:4], axis=1)

# rename columns
df.columns=['review', 'rating', 'recommend']
print(df.info())

# checking whether there is any null element
print(df.isnull().values.any())

# dropping the null values
df = df.dropna()
df.reset_index(drop=True, inplace=True)

# distribution of recommendations (pie chart)
pos = sum(df.recommend == 1)
neg = sum(df.recommend == 0)

plt.pie([pos, neg], labels=['Positive', 'Negative'], autopct='%1.1f%%')
plt.title('Recommendations')
plt.axis('equal')
#plt.savefig("Recom")
plt.show()

# preprocessing (cleaning)
for i in range(df.shape[0]):
    #if type(df.review[i]) == str:
    df.iloc[i,0] = re.sub('[^A-Za-z]+', ' ', df.iloc[i,0]).lower()

# plotting tag cloud
plot_wordcloud(df.review[df.recommend == 1], title = "Positive Reviews")
plot_wordcloud(df.review[df.recommend == 0], title = "Negative Reviews")

# unigram counts (BoW)
vec = CountVectorizer(ngram_range=(1, 1), stop_words = {'english'})
vec.fit(df.review)
# print(vec.get_feature_names())
bow = vec.transform(df.review)

# unigram TF-IDF
vec = TfidfTransformer()
#vec.fit(uni)
#tfidf = vec.transform(uni)

# target
y = df.recommend

# initiating variables for the models

Xtrain, Xtest, ytrain, ytest = train_test_split(bow, y, test_size=0.20, random_state=0)


# Models:

# Logistic Regression
print("\nLogistic Regression")
from sklearn.linear_model import LogisticRegression

reg = LogisticRegression(solver='sag', max_iter=500)
reg.fit(Xtrain, ytrain)
ypredict = reg.predict(Xtest)

reg_accuracy, reg_auroc, reg_conf = report(ytest, ypredict)


# Naive Bayes classifier
#print("\nNaive Bayes classifier")
#from sklearn.naive_bayes import GaussianNB

#nb = GaussianNB()
#nb.fit(Xtrain.toarray() , ytrain)
#ypredict = nb.predict(Xtest.toarray())

#nb_accuracy, nb_auroc, nb_conf = report(ytest, ypredict)


# Linear Support Vector Machines classifier
print("\nLinear Support Vector Machines classifier")
from sklearn.svm import LinearSVC

#param = {'C': [0.5, 0.01, 0.001]}
#gridsearch(LinearSVC(), param, Xtrain, ytrain)
# C=0.01 is chosen  

svm = LinearSVC(C=0.01, max_iter=5)
svm.fit(Xtrain, ytrain)
ypredict = svm.predict(Xtest)

svm_accuracy, svm_auroc, svm_conf = report(ytest, ypredict)


# Plotting parts are commented out in AWS demo versions for proper time measurement in comparison.

# measuring time
end = time.time()
time = end - start
print("\nElapsed time:", time, "seconds.")

# The end.
