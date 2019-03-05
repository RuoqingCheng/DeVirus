g1 = open("GCF_000715135.1_Ntab-TN90_cds_from_genomic.fna", 'r')
g2 = open("GCF_000715135.1_Ntab-TN90_rna.fna", 'r')

f1 = open("result_Deseq2_assembly.txt", 'r')
f2 = open("result_Deseq2_reference.txt", 'r')

genome = {}
genomeReverse = {}
rna = {}

line = g1.readline().strip()
count = 0
while line != "":
	if line[0] != ">":
		line = g1.readline().strip()
		continue
	temp = line.split("|")
	temp1 = temp[1].split("_cds")
	key = temp1[0]
	temp2 = temp[1].split("gene=")
	try:
		value = temp2[1].split("]")[0]
	except Exception as e:
		pass
	
	genome[key] = value
	genomeReverse[value] = key
	line = g1.readline().strip()

line = g2.readline().strip()
while line != "":
	if line[0] != ">":
		line = g2.readline().strip()
		continue
	temp = line.split()
	key = temp[0][1:]
	temp = line.split("(")
	value = temp[1].split(")")[0]
	rna[key] = value
	line = g2.readline().strip()

dic1 = {}
dic2 = {}

line = f1.readline().strip()
line = f1.readline().strip()

while line != "":
	temp = line.split()
	gene = temp[0][1:-1]
	if gene in genome:
		filt = genome[gene]
	else:
		filt = gene
	dic1[filt] = 1
	line = f1.readline().strip()

line = f2.readline().strip()
line = f2.readline().strip()

while line != "":
	temp = line.split()
	gene = temp[0][1:-1]
	if gene in rna:
		filt = rna[gene]
	else:
		filt = gene
	dic2[filt] = 1
	line = f2.readline().strip()

count1 = 0
multi = 0
multiDic = []

for key in dic1:
	if key not in dic2:
		count1 += 1
	else:
		multi += 1
		del dic2[key]
		multiDic.append(key)

for i in range(len(multiDic)):
	multiDic[i] = genomeReverse[multiDic[i]] + "\n"

f3 = open("intersection.txt", 'w')
f3.writelines(multiDic)
f3.close()

count2 = len(dic2)

print count1
print count2
print multi