import matplotlib.pyplot as plt
import numpy as np
import sys


testfolder = sys.argv[1]
print("testfolder = " + testfolder)

test_number = int(sys.argv[2])
threshold = 1650
time = []
distance = []

for i in range(1,test_number + 1):
	file = open("data/" + testfolder + "/random/run" + str(i) + "/result2.txt","r")
	j = 0
	flag = 0;
	for line in file:
		j = j + 1
		if j > threshold and float(line) < 0.07 :
			time.append(j - threshold)
			flag = 1
			break
	if flag == 0 :
		print("too much", i)
		time.append(0)
	file.close()

	file = open("data/" + testfolder + "/random/run" + str(i) + "/distance.csv","r")
	for line in file:
		distance.append(float(line))
		break
	file.close()

plt.subplot(122)
plt.scatter(distance, time)

data = []
length = 3500

for i in range(length):
	data.append([])

for i in range(1,test_number + 1):
	file = open("data/" + testfolder + "/random/run" + str(i) + "/result2.txt","r")
	j = 0
	for line in file:
		data[j].append(float(line))
		j = j + 1
		if j == length and float(line) > 0.1 :
			print("error case")
			print(i)
	file.close()

	file = open("data/" + testfolder + "/random/run" + str(i) + "/result1.txt","r")
	j = 0
	for line in file:
		data[j][i-1] = float(line)
		j = j + 1
		if j == 1499 :
			break

	file.close()



divide = 30
showdata = []
showindex = []
for i in range(30 * 1400 / 3500 , divide + 1):
	showindex.append(i * length / divide)
	showdata.append(data[length / divide * i - 1])

plt.subplot(121)
flierprops = dict(marker='.', markersize=2,
			                  linestyle='none')
plt.boxplot(showdata, flierprops = flierprops)
plt.show()

