import matplotlib.pyplot as plt

'''
6.0     61
3.0     62
15.0    62
16.0    62
2.0     63
13.0    63
14.0    63
1       64
5.0     64
4.0     64
11.0    64
12.0    64
8.0     65
7.0     65
17.0    65
9.0     65
10.0    65
20.0    65
18.0    65
19.0    65
'''
inputx = [6,  3,  15,  16,  2,  13, 14,  1,  5,  4, 11, 12,  8,  7, 17,  9, 10, 20, 18, 19]
inputy = [61, 62, 62,  62,  63, 63, 63, 64, 64, 64, 64, 64, 65, 65, 65, 65, 65, 65, 65, 65]
base = 61

distance = []
for i in range(21):
	distance.append(0)
distance[1] = 3
distance[2] = 2
distance[3] = 1
distance[4] = 3
distance[5] = 3
distance[6] = 0

distance[7] = 4
distance[8] = 4
distance[9] = 4
distance[10] = 4
distance[11] = 3
distance[12] = 3
distance[13] = 2
distance[14] = 2
distance[15] = 1
distance[16] = 1

distance[17] = 4
distance[18] = 4
distance[19] = 4
distance[20] = 4

dis_x = []
time_y = []
for i in range(20):
	dis_x.append(distance[inputx[i]])
	time_y.append(inputy[i]-base)
	
plt.plot(dis_x, time_y)
plt.xticks([])
plt.yticks([])
plt.savefig("plot.pdf")
plt.show()

