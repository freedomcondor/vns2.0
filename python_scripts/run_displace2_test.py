import os
import sys

testfolder = sys.argv[1]
print("testfolder = " + testfolder)

def generate_argos_file(i, len):
	len = len / 5
	#read in the file
	with open('data/' + testfolder + '/vns_template.argos', 'r') as file :
		filedata = file.read()

	# Replace the target string
	filedata = filedata.replace('RANDOM_SEED', str(i))
	filedata = filedata.replace('TEST_LENGTH', str(len))

	# Write the file out again
	with open('data/' + testfolder + '/vns_test.argos', 'w') as file:
		file.write(filedata)

os.system("mkdir data/" + testfolder + "/random")

len1 = 1499
len = 3500
test_number = 100

#for i in range(80, 101):
for i in range(1, test_number + 1):
	print("running test" + str(i))
	generate_argos_file(i, len)
	os.system("argos3 -c data/" + testfolder + "/vns_test.argos")

	os.system("mkdir data/" + testfolder + "/random/run" + str(i))

	os.system("./data/" + testfolder + "/error_calculator/build/main " + str(len1) + " ./")
	os.system("mv result.txt data/" + testfolder + "/random/run" + str(i) + "/result1.txt")
	os.system("./data/" + testfolder + "/error_calculator/build/main " + str(len) + " ./")
	os.system("mv result.txt data/" + testfolder + "/random/run" + str(i) + "/result2.txt")

	os.system("mv *.csv data/" + testfolder + "/random/run" + str(i))
	os.system("mv data/" + testfolder + "/vns_test.argos data/" + testfolder + "/random/run" + str(i))
