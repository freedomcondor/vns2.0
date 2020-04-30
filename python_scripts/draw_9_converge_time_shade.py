import matplotlib.pyplot as plt
import numpy as np
import sys

length = 2500
test_number = 100

def readdata(testfolder, data, robot_number):
	time_scatter_index.append(robot_number)
	time_spend = []
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
#time_spend.append(j / robot_number)
				time_spend.append(j)

		file.close()

	max_time = max(time_spend)
	min_time = min(time_spend)
	mean = np.mean(time_spend)
	stderr = np.std(time_spend,ddof=1)

	time_scatter_time_mean.append(mean)
	time_scatter_time_max.append(max_time)
	time_scatter_time_min.append(min_time)
	time_scatter_time_up.append(mean + stderr)
	time_scatter_time_down.append(mean - stderr)


data = []
for i in range(length):
	data.append([])
	
####################################
time_scatter_time_mean = []
time_scatter_time_max= []
time_scatter_time_min = []
time_scatter_time_up = []
time_scatter_time_down = []
time_scatter_index = []

readdata("test6", data, 3)
readdata("test9", data, 5)
readdata("test5", data, 6)
readdata("test8", data, 7)
readdata("test3", data, 8)
readdata("test7", data, 11)
readdata("test4", data, 12)
readdata("test2", data, 14)
readdata("test1", data, 20)


#plt.plot(time_scatter_index, time_scatter_time_mean, color = "blue")
plt.fill_between(time_scatter_index, time_scatter_time_max, time_scatter_time_min, color='#888888', alpha=0.3)
plt.fill_between(time_scatter_index, time_scatter_time_up, time_scatter_time_down, color='#888888', alpha=0.5)

####################################
time_scatter_time_mean = []
time_scatter_time_max= []
time_scatter_time_min = []
time_scatter_time_up = []
time_scatter_time_down = []
time_scatter_index = []

readdata("test1", data, 20)
readdata("test2", data, 14)
readdata("test3", data, 8)

plt.plot(time_scatter_index, time_scatter_time_mean, color = "blue")

####################################
time_scatter_time_mean = []
time_scatter_time_max= []
time_scatter_time_min = []
time_scatter_time_up = []
time_scatter_time_down = []
time_scatter_index = []

readdata("test4", data, 12)
readdata("test5", data, 6)
readdata("test6", data, 3)

plt.plot(time_scatter_index, time_scatter_time_mean, color = "red")

####################################
time_scatter_time_mean = []
time_scatter_time_max= []
time_scatter_time_min = []
time_scatter_time_up = []
time_scatter_time_down = []
time_scatter_index = []

readdata("test7", data, 11)
readdata("test8", data, 7)
readdata("test9", data, 5)

plt.plot(time_scatter_index, time_scatter_time_mean, color = "green")

#plt.ylim(0, 3.0)
plt.xticks([])
plt.yticks([])

#for i in range(1, 10):
#plt.subplot("33"+str(i))
#	readdata("test"+str(i), plt)
#plt.xlabel("robot_number")
#plt.ylabel("time_per_robot")
#plt.ylabel("total_time")
plt.savefig("plot.pdf")
plt.show()
