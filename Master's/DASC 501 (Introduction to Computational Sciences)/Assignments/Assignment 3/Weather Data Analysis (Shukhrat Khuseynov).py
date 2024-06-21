# -*- coding: UTF-8 -*-

"""
Weather Data Analysis.


@author: Shukhrat Khuseynov
Student ID: 0070495

Course: DASC 501
Assignment 3 / Weather Data Analysis

Version 1.0

Created on Sat Nov 30 2019
"""

import pandas as pd

def main():
    """ Asking the part for implementation. """
    Part = int(input("Which part of the Assignment do you want to choose?\n(enter 1 or 2)\n"))

    if Part == 1:
        """ Reading the data from the memory. """
        file = open("oxforddata.txt", "r") # data includes the entries until October 2019, downloaded from official site.

        """ Skipping the first 7 lines and saving the labels. """
        for i in range(7):
            if i == 5:
                labels = file.readline().split()
            else: file.readline()
        """ Initializing the nested list and the indices. """
        data  = [[[] for j in range(12)] for i in range(170)]
        i = 0 # index for year, meaning 1853+i
        j = 0 # index for month, meaning 1+j
        
        """ Cleansing the table line by line and saving as a nested list. """
        for l in file:
            line = l.split()

            if line[-1] == "Provisional":
                del line[-1] # saved as -1

            for k in range(2,len(line)):
                line[k] = line[k].rstrip('*')
                #line[k] = line[k].rstrip('#')     # can be also used, if needed
                if line[k] == "---":
                    data[i][j].append(-1)
                else: data[i][j].append(float(line[k]))
            
            j+=1
            if j==12:
                i = i+1
                j = 0
        file.close()
        years = i + 1
        lastmonth = j
        
        """ Calculating the average min temperature for each month discarding the provisional data (=last year is excluded). """
        minavg = [0]*12
        for i in range(years - 1): 
            for j in range(12):
                minavg[j] += data[i][j][1]
        for j in range(12):
            minavg[j] = minavg[j] / (years - 1)

        print("Average minimum temperature for each month:")
        print ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec", sep=".\t")
        print("----\t"*12)
        for j in range(12):
            print(round(minavg[j], 2), end='\t')
        print("\nMaximum: ", round(max(minavg), 2), sep='')
        
        """ Calculating the average of mean daily minimum temperature for each month in each decade including the provisional data. """
        print("\nAverage of mean daily minimum temperature for each month in each decade:")
        for decade in range(years//10 + 1):
            if decade == 0:
                avg = 0
                for i in range(7 + decade*10):
                    for j in range(12):
                        avg+=data[i][j][1]
                
                avg = avg/(7*12)
                print("%d - %d : %.2f" % (1853, 1860 + decade*10 - 1, avg))
                
            elif decade == (years//10):
                extrayears = 7 + decade*10 - years + 1
                avg = 0
                for i in range(-3 + decade*10, 7 + decade*10 - extrayears):
                    for j in range(12):
                        avg+=data[i][j][1]
                        
                """ Including last months of the last year (provisional data). """       
                i = 7 + decade*10 - extrayears
                for j in range(lastmonth):
                        avg+=data[i][j][1]
                        
                avg = avg/((10-extrayears)*12 + lastmonth)
                lastyear = 1853 + years - 1
                print("%d - %d : %.2f" % (1850 + decade*10, lastyear, avg))
                
            else:
                avg = 0
                for i in range(-3 + decade*10, 7 + decade*10):
                    for j in range(12):
                        avg+=data[i][j][1]
                        
                avg = avg/(10*12)
                print("%d - %d : %.2f" % (1850 + decade*10, 1860 + decade*10 - 1, avg))
                
    elif Part == 2:
        """ Reading the data from the memory. """
        file = open("oxforddata.txt", "r") # data includes the entries until October 2019, downloaded from official site.

        """ Skipping the first 7 lines and saving the labels. """
        for i in range(7):
            if i == 5:
                labels = file.readline().split()
            else: file.readline()

        """ Initializing the list of lines. """
        lines  = [[] for i in range((170)*12)]
        
        """ Cleansing the table line by line and saving as a data frame. """
        i = 0
        for l in file:
            lines[i] = l.split()

            if lines[i][-1] == "Provisional":
                del lines[i][-1] # saved as -1

            for k in range(len(lines[i])):
                lines[i][k] = lines[i][k].rstrip('*')
                #lines[i][k] = lines[i][k].rstrip('#')     # can be also used, if needed
                if lines[i][k] == "---":
                    lines[i][k] = -1
                else: lines[i][k] = float(lines[i][k])
            
            i+=1

        df = pd.DataFrame(lines, columns=labels)
        df = df.dropna()
        file.close()
        """ Calculating the average number of sunshine hours for each month discarding the provisional data (=last year is excluded). """
        sunavg = [0]*12
        for j in range(12):
            sunavg[j] = df.sun[(df.sun!=-1) & (df.mm==(j+1))].mean()

        print("Average number of sunshine hours for each month:")
        print ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec", sep=".\t")
        print("-----\t"*12)
        for j in range(12):
            print(round(sunavg[j],2), end='\t')
        print("\nMaximum: ", round(max(sunavg), 2), sep='')
        
        """ Calculating the average of sunshine hours for each month in each decade including the provisional data. """
        years = int(max(df.yyyy)-1853+1)
        print("\nAverage of sunshine hours for each month in each decade:")
        # 1929 is in 7th decade since 1850s
        for decade in range(7, years//10 + 1):
            if decade == 7:
                avg = df.sun[(df.yyyy>=1929) & (df.yyyy<(1860 + decade*10))].mean()
                print("%d - %d : %.2f" % (1929, 1860 + decade*10 - 1, avg))
                
            else:
                avg = df.sun[(df.yyyy>=(1850 + decade*10)) & (df.yyyy<(1860 + decade*10))].mean()
                print("%d - %d : %.2f" % (1850 + decade*10, min(1860 + decade*10 - 1, max(df.yyyy)), avg)) 
        
    else:
        print("Wrong input!")
        exit()

if __name__ == '__main__':
    main()

""" The end. """
