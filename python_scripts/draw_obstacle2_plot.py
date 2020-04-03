import matplotlib.pyplot as plt
import numpy as np
import sys

data = []
def readdata(testfolder, robot_file_name, plt):

	file = open("data/" + testfolder + "/case/" + robot_file_name, "r")
	i = 0
	for line in file:
		if robot_file_name == "result4.txt":
			data.append(float(line))
		else:
			data[i] = float(line)
		i = i + 1
	file.close()


folder = "obstacle2"
readdata(folder, "result4.txt", plt)
readdata(folder, "result3.txt", plt)
readdata(folder, "result2.txt", plt)
readdata(folder, "result1.txt", plt)

plt.plot(data)
plt.xlabel("time")
plt.ylabel("error")

plt.show()
