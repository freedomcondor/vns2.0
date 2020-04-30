import matplotlib.pyplot as plt
import numpy as np
import sys

length = 2500
test_number = 100

time_spend = []

def readdata(testfolder, data, robot_number):
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
				time_spend.append(j / robot_number)

		file.close()


data = []
for i in range(length):
	data.append([])


readdata("test1", data, 20)
'''
readdata("test2", data, 14)
readdata("test3", data, 8)
readdata("test4", data, 12)
readdata("test5", data, 6)
readdata("test6", data, 3)
readdata("test7", data, 11)
readdata("test8", data, 7)
readdata("test9", data, 5)
'''

print("sum = ", sum(time_spend))
print("len = ", len(time_spend))
print("average = ", sum(time_spend) / len(time_spend))
print(np.mean(time_spend))
print(np.std(time_spend,ddof=1))

'''
divide = 30
showdata = []
showindex = []
for i in range(1, divide + 1):
	showdata.append(data[2000 / divide * i - 1])
#showdata[(length/divide * i - 1) * 0.2] = (data[length / divide * i - 1])
'''

maxdata = []
mindata = []
meandata = []
upstderr = []
downstderr = []
index = []
for i in range(1, 2000) :
	index.append(i)
	maxdata.append(max(data[i]))
	mindata.append(min(data[i]))
	mean = np.mean(data[i])
	stderr = np.std(data[i],ddof=1)
	upstderr.append(mean + stderr)
	downstderr.append(mean - stderr)
	meandata.append(mean)

#plt.plot(maxdata)
#plt.plot(mindata)
plt.plot(meandata)
#plt.plot(upstderr)
#plt.plot(downstderr)

plt.fill_between(index, maxdata, mindata, color='#888888', alpha=0.3)
plt.fill_between(index, upstderr, downstderr, color='#888888', alpha=0.5)

plt.ylim(0, 3.0)
#plt.xticks([])
#plt.yticks([])
plt.xlabel("time")
plt.ylabel("error")
plt.savefig('plot.png') 

#for i in range(1, 10):
#plt.subplot("33"+str(i))
#	readdata("test"+str(i), plt)
'''
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
'''

plt.show()
