import os

def generate_argos_file(i, len):
	len = len / 5
	#read in the file
	with open('data/test1/vns_template.argos', 'r') as file :
		filedata = file.read()

	# Replace the target string
	filedata = filedata.replace('RANDOM_SEED', str(i))
	filedata = filedata.replace('TEST_LENGTH', str(len))

	# Write the file out again
	with open('data/test1/vns_test.argos', 'w') as file:
		file.write(filedata)

os.system("mkdir data/test1/random")
len = 2500
for i in range(1, 500): # 1 to 10
	print("running test" + str(i))
	generate_argos_file(i+1, len)
	os.system("argos3 -c data/test1/vns_test.argos")
	os.system("./error_calculator/build/main " + str(len) + " ./")
	os.system("mkdir data/test1/random/run" + str(i))
	os.system("mv *.csv data/test1/random/run" + str(i))
	os.system("mv result.txt data/test1/random/run" + str(i))
