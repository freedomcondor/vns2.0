import matplotlib.pyplot as plt
import numpy as np
import sys


testfolder = sys.argv[1]
print("testfolder = " + testfolder)

test_number = 100

threshold = 1502

time = []
distance = []

for i in range(1,test_number + 1):
	file = open("data/" + testfolder + "/random/run" + str(i) + "/result.txt","r")
	j = 0
	flag = 0;
	for line in file:
		j = j + 1
		if j > threshold and float(line) < 0.05 :
			time.append(j - threshold)
			flag = 1
			break
	if flag == 0 :
		print("too much", i)
	file.close()

	file = open("data/" + testfolder + "/random/run" + str(i) + "/distance.csv","r")
	for line in file:
		distance.append(line)
		break
	file.close()

plt.scatter(distance, time)
plt.show()

