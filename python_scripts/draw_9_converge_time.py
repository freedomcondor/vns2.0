import matplotlib.pyplot as plt
import numpy as np
import sys

length = 2500
test_number = 100


time_scatter_time = []
time_scatter_density = []

def readdata(testfolder, data, robot_number, area):
	time_spend[robot_number-1] = []
	for i in range(1,test_number + 1):
		file = open("data/" + testfolder + "/random/run" + str(i) + "/result.txt","r")
		j = 0
		flag = 0
		for line in file:
			data[j].append(float(line))

			j = j + 1
			if j == length and float(line) > 0.06 :
				print("error case")
				print(i)

			if flag == 0 and float(line) < 0.06 :
				flag = 1
#time_spend[robot_number-1].append(j / robot_number)
				time_spend[robot_number-1].append(j)
				time_scatter_time.append(j / robot_number)
#time_scatter_density.append(area / robot_number)
				time_scatter_density.append(robot_number / area)

		file.close()


data = []
for i in range(length):
	data.append([])
	
########################
time_spend = []
for i in range(0, 21) :
	time_spend.append([])

readdata("test1", data, 20, 2 * 2)
readdata("test2", data, 14, 1.2 * 1.3)
readdata("test3", data, 8, 1 * 1)

color = "blue"
flierprops = dict(marker='.', markeredgecolor=color, markersize=2, color=color,
			                  linestyle='none')

#plt.subplot("121")
plt.boxplot(time_spend, boxprops = dict(color=color), 
		                flierprops = flierprops,
						medianprops = dict(color=color),
						capprops=dict(color=color),
						whiskerprops=dict(color=color)
						)

########################
time_spend = []
for i in range(0, 21) :
	time_spend.append([])

readdata("test4", data, 12, 1.5 * 1.5)
readdata("test5", data, 6, 1 * 1)
readdata("test6", data, 3, 0.8 * 0.8)

color = "red"
flierprops = dict(marker='.', markeredgecolor=color, markersize=2, color=color,
			                  linestyle='none')

#plt.subplot("121")
plt.boxplot(time_spend, boxprops = dict(color=color), 
		                flierprops = flierprops,
						medianprops = dict(color=color),
						capprops=dict(color=color),
						whiskerprops=dict(color=color)
						)

########################
time_spend = []
for i in range(0, 21) :
	time_spend.append([])

readdata("test7", data, 11, 1.5 * 2.1)
readdata("test8", data, 7, 1 * 1)
readdata("test9", data, 5, 1 * 1)

color = "green"
flierprops = dict(marker='.', markeredgecolor=color, markersize=2, color=color,
			                  linestyle='none')

#plt.subplot("121")
plt.boxplot(time_spend, boxprops = dict(color=color), 
		                flierprops = flierprops,
						medianprops = dict(color=color),
						capprops=dict(color=color),
						whiskerprops=dict(color=color)
						)
#
#
#plt.subplot("122")
#plt.scatter(time_scatter_density, time_scatter_time)

#plt.ylim(0, 3.0)
#plt.xticks([])
#plt.yticks([])

plt.xlabel("robot_number")
plt.ylabel("time_per_robot")
plt.savefig("plot.pdf")
plt.show()
