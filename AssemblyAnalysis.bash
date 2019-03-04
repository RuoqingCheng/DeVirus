#!/bin/bash
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load bowtie2/2.2.7
module load samtools/1.3
module load jellyfish2/2.2.6
module load salmon/0.9.1
module load blat/v35
module load trinity/2.8.4
module load sra-toolkit/2.8.1-2
module load fastx/0.0.14
module load bwa/0.7.13
module load blast/2.7.1
module load R/3.5.2-mkl
#

for x in "$1" "$2" "$3" "$4" "$5" "$6";
do
cat "$x"_1.fastq | perl -lane 's/_forward//; print;' > "$x"_1.adj.fastq;
cat "$x"_2.fastq | perl -lane 's/_reverse//; print;' > "$x"_2.adj.fastq;
done

touch forward.fastq
touch reverse.fastq

for x in "$1" "$4";
do
cat "$x"_1.adj.fastq >> forward.fastq;
echo >> forward.fastq
cat "$x"_2.adj.fastq >> reverse.fastq;
echo >> reverse.fastq
done

#Trinity

rm -rf trinity_out_test
mkdir trinity_out_test

Trinity --no_version_check --trimmomatic --seqType fq --max_memory 80G --CPU 26 \
  --workdir $SCRATCH/trinity_local \
  --output ./trinity_out_test \
  --left ./forward.fastq \
  --right ./reverse.fastq

#bwa

bwa index ./trinity_out_test/Trinity.fasta
bwa mem ./trinity_out_test/Trinity.fasta "$1"_1.adj.fastq "$1"_2.adj.fastq > cmv1.sam
bwa mem ./trinity_out_test/Trinity.fasta "$2"_1.adj.fastq "$2"_2.adj.fastq > cmv2.sam
bwa mem ./trinity_out_test/Trinity.fasta "$3"_1.adj.fastq "$3"_2.adj.fastq > cmv3.sam
bwa mem ./trinity_out_test/Trinity.fasta "$4"_1.adj.fastq "$4"_2.adj.fastq > mock1.sam
bwa mem ./trinity_out_test/Trinity.fasta "$5"_1.adj.fastq "$5"_2.adj.fastq > mock2.sam
bwa mem ./trinity_out_test/Trinity.fasta "$6"_1.adj.fastq "$6"_2.adj.fastq > mock3.sam

python countxpression.py 5 15 countstatssummary.txt cmv1.sam cmv2.sam cmv3.sam mock1.sam mock2.sam mock3.sam

for filename in *counts.txt; do
    myShort=`echo $filename | cut -c1-11` 
    echo "$myShort" > $myShort"_uniqmaps.txt"    
    cut -f 2 "$filename" > $myShort"_uniqmaps.txt"  
done 

for filename in *_uniqmaps.txt; do
    tail -n +2 -- "$filename" > $filename"_uniqmapsNH.txt"  
done 

for filename in *_uniqmapsNH.txt; do (myShort=`echo $filename | cut -c1-11`;echo "$myShort"; cat $filename) > tmp; mv tmp $filename; done

paste *_uniqmapsNH.txt > allcountsdata.txt

cut -f 1 cmv_counts.txt | paste - allcountsdata.txt > allcountsdataRN.txt

mv allcountsdataRN.txt allcountsdata.txt

rm *uniqmaps*

#Blast

rm -rf blast_test
mkdir blast_test

makeblastdb -in  "$7" -dbtype nucl -out blast_test/NicotianaTabacum -parse_seqids

blastn -query trinity_test_small/Trinity.fasta -db blast_test/NicotianaTabacum -outfmt 6 -out blast_test/smallvalue.out -evalue 1e-10

cp blast_test/smallvalue.out result_smallvalue.out

cut -f 1 blast_test/smallvalue.out > blast_test/smalltitle.ids

sort blast_test/smalltitle.ids | uniq > blast_test/smallevalue_sorted_uniq.ids

cat trinity_test_small/Trinity.fasta |grep ">" > blast_test/all.ids

sed 's/.//' blast_test/all.ids > blast_test/all_0.ids

cat blast_test/all_0.ids |cut -d' ' -f1 > blast_test/all_1.ids

cat blast_test/all_1.ids blast_test/smallevalue_sorted_uniq.ids > blast_test/combined.ids

sort blast_test/combined.ids |uniq -u > blast_test/virus.ids

cat trinity_test_small/Trinity.fasta | grep -A1 -f blast_test/virus.ids > blast_test/virus.fasta

cp blast_test/virus.fasta result_virus.fasta

#Deseq2

python DeseqTreat.py result_smallvalue.out allcountsdata.txt tmp.txt

Rscript Deseq2.r tmp.txt result.txt result_graph.pdf

python pick.py result.txt result_Deseq2.txt 0.05