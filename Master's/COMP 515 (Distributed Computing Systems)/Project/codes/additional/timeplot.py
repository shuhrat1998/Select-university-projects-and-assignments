# -*- coding: utf-8 -*-
"""
COMP515 Project
Time comparison plot
Name : Shukhrat Khuseynov
ID   : 0070495
"""

import matplotlib.pyplot as plt
fig = plt.figure()
cases = ['Churn', 'Prices', 'Sentiment', 'dChurn', 'dPrices', 'dSentiment']
time = [12.61, 0.99, 54.06, 126.64, 23.57, 82.95]
plt.bar(cases, time, color=['blue', 'blue', 'blue', 'green', 'green', 'green'])

plt.xlabel("Cases")
plt.ylabel("Time elapsed (seconds)")
plt.title("Time comparison")
plt.savefig('timing.png')
plt.show()

# The end.