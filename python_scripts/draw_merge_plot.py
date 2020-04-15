import matplotlib.pyplot as plt
import numpy as np

testfolder = "data/test2"

def show_example_case():
	data_vns = []
	data_robots = []
	length = 500
	test_number = 100
	example_case = 10

	file = open(testfolder + "/random/run" + str(example_case) + "/merge_vns_number.txt", "r")
	for line in file:
		data_vns.append(int(line))
	file.close()

	file = open(testfolder + "/random/run"  + str(example_case) + "/merge_robots_number.txt", "r")
	for line in file:
		data_robots.append(int(line))
	file.close()

	plt.plot(data_vns[1:length], label="number of MNSs")
	plt.plot(data_robots[1:length], label="number of robots in the bigget MNSs")
#plt.plot(data_vns[1:length], label="           ")
#	plt.plot(data_robots[1:length], label="            ")
#plt.xlabel("time")
#plt.ylabel("number")
	plt.xticks([])
	plt.yticks([])
	plt.legend(loc="right")

def show_all_case(file_to_read):
	data = []
	length = 2500
	test_number = 100

	for i in range(length) : 
		data.append([])

	for i in range(1, test_number + 1):
		file = open(testfolder + "/random/run" + str(i) + "/" + file_to_read, "r")
		j = 0
		for line in file:
			data[j].append(int(line))
			j = j + 1
		file.close()

	divide = 30
	showdata = []
	showindex = []
	for i in range(1, divide + 1):
		showdata.append(data[1500 / divide * (i-1)])

	plt.boxplot(showdata, showindex)
#plt.xlabel("time")
#plt.ylabel("number")
	plt.xticks([])
	plt.yticks([])


#show_example_case()

#plt.subplot("131")
#show_example_case()

#plt.subplot("121")
#show_all_case("merge_robots_number.txt")
#plt.subplot("122")
show_all_case("merge_vns_number.txt")
plt.savefig('plot.pdf') 

plt.show()
