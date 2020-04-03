import os

stage = [212, 1151, 1392, 2280]

for i in range(1, 5):
	os.system("./data/obstacle2/error_calculator/build/main " + str(stage[i-1]) + " data/obstacle2/case/ " + str(i))
	os.system("mv result.txt data/obstacle2/case/result" + str(i) + ".txt")
