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
		distance.append(float(line))
		break
	file.close()

plt.subplot(122)
plt.scatter(distance, time)


data = []
length = 2500
test_number = 100

for i in range(length):
	data.append([])

for i in range(1,test_number + 1):
	file = open("data/" + testfolder + "/random/run" + str(i) + "/result.txt","r")
	j = 0
	for line in file:
		data[j].append(float(line))
		j = j + 1
		if j == length and float(line) > 0.1 :
			print("error case")
			print(i)
	file.close()

divide = 30
showdata = []
showindex = []
for i in range(30 * 1400 / 2500 , divide + 1):
	showindex.append(i * length / divide)
	showdata.append(data[length / divide * i - 1])

plt.subplot(121)
plt.boxplot(showdata, showindex)
plt.show()

