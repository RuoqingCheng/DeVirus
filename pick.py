import sys

inputFile = sys.argv[1]
outputFile = sys.argv[2]
threshold = float(sys.argv[3])

f1 = open(inputFile, 'r')
f2 = open(outputFile, 'w')
line = f1.readline().strip()
f2.write(line + "\n")

line = f1.readline().strip()

while (line != ""):
	temp = line.split("\t")
	if temp[6] != "NA":
		p = float(temp[6])
		if p < threshold:
			for i in range(len(temp)):
				f2.write(temp[i] + "\t")
			f2.write("\n")
	line = f1.readline().strip()

f1.close()
f2.close()
