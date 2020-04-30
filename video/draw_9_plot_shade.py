import matplotlib.pyplot as plt
import numpy as np
import sys

length = 2500

def readdata(testfolder, data, run_number) :
	data = []
	file = open("data/" + testfolder + "/random/run" + str(run_number) + "/result.txt","r")
	for line in file:
		data.append(float(line))
	file.close()

	plt.clf()
	plt.plot(data, linewidth=4)
	plt.ylabel("error", fontsize=18)
	plt.xlabel("time", fontsize=18)
	plt.savefig(testfolder + ".png")

data = []
readdata("test1", data, 5)
readdata("test2", data, 3)
readdata("test3", data, 1)

readdata("test4", data, 4)
readdata("test5", data, 3)
readdata("test6", data, 1)

readdata("test7", data, 3)
readdata("test8", data, 2)
readdata("test9", data, 1)

plt.ylim(0, 3.0)
#plt.xticks([])
#plt.yticks([])
#plt.savefig('plot.pdf') 

plt.show()
