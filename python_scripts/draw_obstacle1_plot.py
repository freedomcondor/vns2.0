import matplotlib.pyplot as plt
import numpy as np
import sys

def readdata(testfolder, robot_file_name, plt):
	data = []
	length = 11000

	file = open("data/" + testfolder + "/case/" + robot_file_name, "r")
	for line in file:
		data.append(float(line))
	file.close()

	plt.plot(data[10:])

folder = "obstacle1"
readdata(folder, "drone2.txt", plt)
readdata(folder, "pipuck1.txt", plt)
readdata(folder, "pipuck2.txt", plt)
readdata(folder, "pipuck3.txt", plt)
readdata(folder, "pipuck4.txt", plt)
readdata(folder, "pipuck5.txt", plt)
readdata(folder, "pipuck6.txt", plt)

#plt.xlabel("time")
#plt.ylabel("error of each robot")
plt.xticks([])
plt.yticks([])
plt.savefig("plot.pdf")

plt.show()
