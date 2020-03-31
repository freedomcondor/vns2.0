import os
import sys

testfolder = "data/test2"

len = 2500
test_number = 100
for i in range(1, test_number+1) :
#for i in range(1, 2) :
	print("calculating test" + str(i))
	os.system("./" + testfolder + "/merge_calculator/build/main " + str(len) +
	          " ./" + testfolder + "/random/run" + str(i) + "/"
			)
	os.system("mv merge_robots_number.txt " + testfolder + "/random/run" + str(i) + "/")
	os.system("mv merge_vns_number.txt " + testfolder + "/random/run" + str(i) + "/")
