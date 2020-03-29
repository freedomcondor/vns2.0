import matplotlib.pyplot as plt
import numpy as np
import sys

testfolder = sys.argv[1]
print("testfolder = " + testfolder)

data = []
length = 2500
test_number = int(sys.argv[2])


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
for i in range(1, divide + 1):
	showindex.append(i * length / divide)
	showdata.append(data[length / divide * i - 1])

#plt.plot(data)  # Plot some data on the axes.
#plt.boxplot([[1,2,3],[4,5,6],[7,8,9]])  # Plot some data on the axes.
plt.boxplot(showdata, showindex)
plt.show()
