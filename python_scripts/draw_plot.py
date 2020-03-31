import matplotlib.pyplot as plt
import numpy as np
import sys

def readdata(testfolder, plt):
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
	for i in range(1, divide + 1):
		showindex.append(i * length / divide)
		showdata.append(data[length / divide * i - 1])
	
	flierprops = dict(marker='.', markersize=2,
				                  linestyle='none')

	plt.boxplot(showdata, flierprops = flierprops)

	plt.ylim(0, 2.5)
	plt.xlabel("time")
	plt.ylabel("error")

#for i in range(1, 10):
#plt.subplot("33"+str(i))
#	readdata("test"+str(i), plt)
plt.subplot("331")
readdata("test9", plt)
plt.subplot("332")
readdata("test6", plt)
plt.subplot("333")
readdata("test3", plt)

plt.subplot("334")
readdata("test8", plt)
plt.subplot("335")
readdata("test5", plt)
plt.subplot("336")
readdata("test2", plt)
plt.subplot("337")
readdata("test7", plt)
plt.subplot("338")
readdata("test4", plt)
plt.subplot("339")
readdata("test1", plt)

plt.show()
