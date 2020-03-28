import matplotlib.pyplot as plt
import numpy as np

data = []
length = 2500
for i in range(length):
	data.append([])

for i in range(1, 270):
	file = open("data/test1/random/run" + str(i) + "/result.txt","r")
	j = 0
	for line in file:
		data[j].append(float(line))
		j = j + 1
		if j == 2000 and float(line) > 1 :
			print("error case")
			print(i)
	file.close()

divide = 20
showdata = []
showindex = []
for i in range(1, divide + 1):
	showindex.append(i * length / divide)
	showdata.append(data[length / divide * i - 1])

#plt.plot(data)  # Plot some data on the axes.
#plt.boxplot([[1,2,3],[4,5,6],[7,8,9]])  # Plot some data on the axes.
plt.boxplot(showdata, showindex)  # Plot some data on the axes.
plt.show()
