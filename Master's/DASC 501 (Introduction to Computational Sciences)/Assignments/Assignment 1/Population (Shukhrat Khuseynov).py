"""
Simulations of population growth.


@author: Shukhrat Khuseynov
Student ID: 0070495

Course: DASC 501
Assignment 1 / Population

Version 1.0

Created on Sat Oct 12 2019
"""
import random
from datetime import datetime

q1 = datetime.now() #measuring time of the code

""" Given parameters of the task. """

MR = 0.49 #Male-Population ratio
FR = 0.93 #Fertility rate
G = 9 #Maximum number of girls in a row
Gen = 10 #Default number of generations to be simulated

""" Initial population is asked since there are different simulations. """

N = int(input ("What is the initial population? (enter an integer > 0)\n"))

""" Some calculations for the first generation. """

M = int(N * MR) #Number of males in the population
F = int(N * (1-MR)) #Number of males in the population
Couples = min(M, F) #Number of couples
Parents = int(Couples * FR) #Number of parents

""" Policy and Cases are asked for different simulations. """

Policy = int(input("Which policy do you want to implement?\nPolicy 1 - 'One Child' or Policy 2 - 'One Son'? (enter 1 or 2)\n"))

if Policy == 1:
    Case = int(input("Which case should be chosen? (enter 1, 2 or 3)\n"))
    
    if Case == 1:
        print("Policy 1 - Case 1 will be implemented:\n")
        
        """ The total amount of children is calculated for the first generation. """

        Boys = int(MR * Parents)
        Girls = int((1-MR) * Parents)
        
        for i in range(Gen):
            print ("Generation", i+1)
            print ("Population Size:", N, "\tNo.of Couples:", Couples, "\tNo.of Parents:", Parents)
            print ("\t\t\tNo.of Males:", M, "\tNo.of Females:", F)
            print ("No.of babies Tot:", Boys+Girls, "\tNo.of baby girls:", Girls, "\tNo.of baby sons:", Boys, "\n")

            """ Assigning values for the next generation. """
            
            N = Boys + Girls
            M = Boys
            F = Girls
            Couples = min(M, F)
            Parents = int(Couples * FR)
            Boys = int(MR * Parents)
            Girls = int((1-MR) * Parents)
            
    elif Case == 2:
        print("Policy 1 - Case 2 will be implemented:\n")

        """ The total amount of children is calculated for the first generation. """

        Boys = int(MR * Parents)
        Girls = int((1-MR) * Parents)
        
        for i in range(Gen):
            print ("Generation", i+1)
            print ("Population Size:", N, "\tNo.of Couples:", Couples, "\tNo.of Parents:", Parents)
            print ("\t\t\tNo.of Males:", M, "\tNo.of Females:", F)
            print ("No.of babies Tot:", Boys+Girls, "\tNo.of baby girls:", Girls, "\tNo.of baby sons:", Boys, "\n")

            """ Assigning values for the next generation. """

            MR = M / N #New Male-Population ratio is calculated, making it different from Case 1
            N = Boys + Girls
            M = Boys
            F = Girls
            Couples = min(M, F)
            Parents = int(Couples * FR)
            Boys = int(MR * Parents)
            Girls = int((1-MR) * Parents)
        
    elif Case == 3:
        print("Policy 1 - Case 3 will be implemented:\n")
        
        for i in range(Gen):
            
            """ Calculating the number of children randomly. """
            Boys = 0
            Girls = 0
            for j in range(Parents):
                x = random.randint(0, 1)
                if x == 1: Boys+=1
                else: Girls+=1
                    
            print ("Generation", i+1)
            print ("Population Size:", N, "\tNo.of Couples:", Couples, "\tNo.of Parents:", Parents)
            print ("\t\t\tNo.of Males:", M, "\tNo.of Females:", F)           
            print ("No.of babies Tot:", Boys+Girls, "\tNo.of baby girls:", Girls, "\tNo.of baby sons:", Boys, "\n")

            """ Assigning values for the next generation. """

            N = Boys + Girls
            M = Boys
            F = Girls
            Couples = min(M, F)
            Parents = int(Couples * FR)
    else:
        print("Wrong input!")
        exit()

elif Policy == 2:
    print("Policy 2 - Case 3 will be implemented:\n")
    for i in range(Gen):
            
        """ Calculating the number of children randomly. """
        Boys = 0
        Girls = 0
        for j in range(Parents):
            for k in range(G):
                x = random.randint(0, 1)
                if x == 1:
                    Boys+=1
                    break
                else: Girls+=1
                
        print ("Generation", i+1)
        print ("Population Size:", N, "\tNo.of Couples:", Couples, "\tNo.of Parents:", Parents)
        print ("\t\t\tNo.of Males:", M, "\tNo.of Females:", F)           
        print ("No.of babies Tot:", Boys+Girls, "\tNo.of baby girls:", Girls, "\tNo.of baby sons:", Boys, "\n")

        """ Assigning values for the next generation. """

        N = Boys + Girls
        M = Boys
        F = Girls
        Couples = min(M, F)
        Parents = int(Couples * FR)

else:
    print("Wrong input!")
    exit()

q2 = datetime.now()
print(q2-q1) #used for time measurement of the code

# Since numbers in different simulations are different, the spacing format is not perfect.

""" The end. """
