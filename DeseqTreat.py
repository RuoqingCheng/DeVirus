import sys
import math

inputfileName1 = sys.argv[1]
inputfileName2 = sys.argv[2]
outputfileName = sys.argv[3]

dic = {}

f1 = open(inputfileName1, 'r')
f2 = open(inputfileName2, 'r')
f3 = open(outputfileName, 'w')

line = f1.readline().strip()
while(line != ""):
	temp = line.split("\t")
	if temp[0] not in dic:
		dic[temp[0]] = [temp[1]]
	else:
		if temp[1] not in dic[temp[0]]:
			dic[temp[0]].append(temp[1])
	line = f1.readline().strip()

line = f2.readline().strip()

f3.write(line + "\n")

freq = {}

line = f2.readline().strip()
while(line != ""):
	temp = line.split("\t")
	if temp[0] not in dic:
		f3.write(temp[0])
		for i in range(1, len(temp)):
			f3.write("\t" + temp[i])
		f3.write("\n")
	else:
		for gene in dic[temp[0]]:
			n = len(dic[temp[0]])
			t = []
			for item in temp[1:]:
				t.append(float(int(item)) / n)
			if gene not in freq:
				freq[gene] = t
			else:
				for i in range(len(freq[gene])):
					freq[gene][i] = freq[gene][i] + t[i]
	line = f2.readline().strip()

for gene in freq:
	f3.write(gene)
	for item in freq[gene]:
		f3.write("\t" + str(int(math.ceil(item))))
	f3.write("\n")

f1.close()
f2.close()
f3.close()