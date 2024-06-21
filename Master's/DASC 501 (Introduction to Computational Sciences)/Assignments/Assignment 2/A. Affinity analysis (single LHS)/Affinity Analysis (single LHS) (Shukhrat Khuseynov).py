"""
Affinity analysis.


@author: Shukhrat Khuseynov
Student ID: 0070495

Course: DASC 501
Assignment 2A / Affinity analysis (single LHS)

Version 1.0

Created on Fri Nov 1 2019
"""

import numpy as np
from collections import defaultdict

""" Reading the data from the memory. """
with open("Affinity_dataset.txt", "r") as f:
    dataset = [[int(num) for num in line.split()] for line in f]

""" Converting the matrix to numpy type to make use of its vectorization property. """
transactions = np.array(dataset)

""" Saving the matrix parameters. """
T = transactions.shape[0] # number of transactions
N = transactions.shape[1] # number of products

""" Saving the product names represented in each column of transaction matrix. """
labels = np.array(["bread", "milk", "cheese", "apples", "bananas"])

print("The transactions:", labels, transactions, sep='\n')

""" Asking the part for implementation. """
Part = int(input("Which part of the Assignment do you want to choose?\n(enter 1 or 2)\n"))

if Part == 1:
    """ Proposing 5 rules saved as a list of tuples. """
    rules = [(2,3), (0,2), (1,0), (4,1), (3,4)]
    """ cheese -> apples, bread -> cheese, milk -> bread, bananas -> milk, apples -> bananas. """

    """ Counting frequency, support, confidence and lift for each rule. """
    freq = defaultdict(int) # frequency
    supp = defaultdict(int) # support
    conf = defaultdict(int) # confidence
    lift = defaultdict(int) # lift
    for r in rules:
        for t in transactions:
            if t[r[0]]==t[r[1]]==1: freq[r]+=1 
        supp[r] = freq[r]/T
        conf[r] = freq[r]/sum(transactions)[r[0]]
        lift[r] = supp[r]/((sum(transactions)[r[0]]/T)*(sum(transactions)[r[1]]/T))
        
    """ Printing the output for each rule in a suitable format. """
    print("The rules:")
    i = 1
    for r in rules:
        print("%d. %s -> %s:\tSupport = %.2f Confidence = %.2f Lift = %.2f" % (i, labels[r[0]], labels[r[1]], supp[r], conf[r], lift[r]))
        i+=1
        if conf[r]>=0.5 and lift[r]>1: print("\t\t   acceptable & interesting\n")
        elif conf[r]>=0.5 and lift[r]<=1: print("\t\t   acceptable\n")
        elif conf[r]<0.5 and lift[r]>1: print("\t\t   interesting\n")
        else: print("")
    print("  (acceptable: confidence > 50% & interesting: positively associated)")

elif Part == 2:
    """ Generating rules saved as a list of tuples, such that x -> y (single LHS). """
    rules = [(x,y) for x in range(N) for y in range(N) if y!=x]

    #print(*rules, sep='\n')
    
    """ Initializing frequency, support, confidence as dictionary variables. """
    freq = defaultdict(int) # frequency
    supp = defaultdict(int) # support
    conf = defaultdict(int) # confidence
    lift = defaultdict(int) # lift

    """ Counting frequency and support beforehand for product x left alone (in a tuple format). """
    for x in range(N):
        freq[(x,)] = sum(transactions)[x]
        supp[(x,)] = freq[(x,)]/T

    """ Computing frequency, support, confidence and lift for each rule. """
    for r in rules:
        for t in transactions:
            for i in range(len(r)):
                if t[r[i]]==1 and i+1<len(r): continue
                elif t[r[i]]==1: freq[r]+=1
                else: break
                
        supp[r] = freq[r]/T
        
        """ Checking the validity of the rule to avoid Zero Division Error. """
        if supp[r]==0:
            continue

        """ Calculating the confidence and lift (using frequency that has been calculated beforehand). """
        conf[r] = freq[r]/freq[r[:-1]]
        lift[r] = supp[r]/(supp[r[:-1]]*supp[r[-1:]])
        
    """ Printing the output for every rule generated and in a suitable format. """
    print("The rules:")
    i = 1
    for r in rules:
        print("%d. " %i, end="")
        i+=1
        
        for j in range(len(r)-1):
            if j>0: print(", ", end="")
            print(labels[r[j]], end="")
        print(" -> %s:" %labels[r[-1]])
        
        if supp[r]==0:
            print("\tinvalid!\n")
            continue
        
        print("   Support = %.2f Confidence = %.2f Lift = %.2f" % (supp[r], conf[r], lift[r]), end="   ")

        if conf[r]>=0.5 and lift[r]>1: print("acceptable & interesting\n")
        elif conf[r]>=0.5 and lift[r]<=1: print("\tacceptable\n")
        elif conf[r]<0.5 and lift[r]>1: print("\tinteresting\n")
        else: print("\n")
    print("  (acceptable: confidence > 50% & interesting: positively associated)")
    
    """ Saving the output in a txt file since it is long. """
    f = open("Rules.txt", "w")
    f.write("DASC501\t   Affinity analysis (single LHS)\t@author: Shukhrat Khuseynov\n\n")
    f.write("The rules:\n")
    i = 1
    for r in rules:
        f.write("%d. " %i)
        i+=1
        
        for j in range(len(r)-1):
            if j>0: f.write(", ")
            f.write(str(labels[r[j]]))
        f.write(" -> %s:\n" %labels[r[-1]])
        
        if supp[r]==0:
            f.write("\tinvalid!\n\n")
            continue
        
        f.write("   Support = %.2f Confidence = %.2f Lift = %.2f   " % (supp[r], conf[r], lift[r]))

        if conf[r]>=0.5 and lift[r]>1: f.write("acceptable & interesting\n\n")
        elif conf[r]>=0.5 and lift[r]<=1: f.write("\tacceptable\n\n")
        elif conf[r]<0.5 and lift[r]>1: f.write("\tinteresting\n\n")
        else: f.write("\n\n")
    f.write("  (acceptable: confidence > 50% & interesting: positively associated)\n")    
    f.close()
    print("\nThe output is saved in the Rules.txt file.")
else:
    print("Wrong input!")
    exit()

""" The end. """
