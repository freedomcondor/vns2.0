import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib.image as mpimg
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

	plt.set_ylim(0, 2.5)
	plt.set_xlabel("time")
	plt.set_ylabel("error")


fig = plt.figure(tight_layout=True)
gs = gridspec.GridSpec(3, 6)

'''
ax = fig.add_subplot(gs[2, 5])
readdata("test1", ax)
ax = fig.add_subplot(gs[1, 5])
readdata("test2", ax)
ax = fig.add_subplot(gs[0, 5])
readdata("test3", ax)

ax = fig.add_subplot(gs[2, 4])
readdata("test4", ax)
ax = fig.add_subplot(gs[1, 4])
readdata("test5", ax)
ax = fig.add_subplot(gs[0, 4])
readdata("test6", ax)

ax = fig.add_subplot(gs[2, 3])
readdata("test7", ax)
ax = fig.add_subplot(gs[1, 3])
readdata("test8", ax)
ax = fig.add_subplot(gs[0, 3])
readdata("test9", ax)
'''

ax = fig.add_subplot(gs[:, 0:2])
img1 = mpimg.imread('../pics/3_9_morphologies/drawing.png')
ax.imshow(img1)

plt.show()
#for i in range(1, 10):
#plt.subplot("33"+str(i))
#	readdata("test"+str(i), plt)
#fig = plt.figure(constrained_layout=True)
#gs = fig.add_gridspec(6, 3)

#f_ax1 = fig.add_subplot(gs[6, 3])
#readdata("test9", plt)

#plt.subplot("331")
#readdata("test9", plt)
#plt.subplot("332")
#readdata("test6", plt)
#plt.subplot("333")
#readdata("test3", plt)
#plt.subplot("334")
#readdata("test8", plt)
#plt.subplot("335")
#readdata("test5", plt)
#plt.subplot("336")
#readdata("test2", plt)
#plt.subplot("337")
#readdata("test7", plt)
#plt.subplot("338")
#readdata("test4", plt)
#plt.subplot("339")
#readdata("test1", plt)

fig.show()
