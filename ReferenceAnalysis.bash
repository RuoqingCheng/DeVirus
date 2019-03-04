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
module load R/3.5.2-mkl
#

for x in "$1" "$2" "$3" "$4" "$5" "$6";
do
cat "$x"_1.fastq | perl -lane 's/_forward//; print;' > "$x"_1.adj.fastq;
cat "$x"_2.fastq | perl -lane 's/_reverse//; print;' > "$x"_2.adj.fastq;
done

bwa index ./"$7"
bwa mem ./"$7" "$1"_1.adj.fastq "$1"_2.adj.fastq > cmv1_rnaseq.sam
bwa mem ./"$7" "$2"_1.adj.fastq "$2"_2.adj.fastq > cmv2_rnaseq.sam
bwa mem ./"$7" "$3"_1.adj.fastq "$3"_2.adj.fastq > cmv3_rnaseq.sam
bwa mem ./"$7" "$4"_1.adj.fastq "$4"_2.adj.fastq > mock1_rnaseq.sam
bwa mem ./"$7" "$5"_1.adj.fastq "$5"_2.adj.fastq > mock2_rnaseq.sam
bwa mem ./"$7" "$6"_1.adj.fastq "$6"_2.adj.fastq > mock3_rnaseq.sam

python countxpression_rnaseq.py 5 15 countstatssummary_rnaseq.txt cmv1_rnaseq.sam cmv2_rnaseq.sam cmv3_rnaseq.sam mock1_rnaseq.sam mock2_rnaseq.sam mock3_rnaseq.sam

for filename in *cnts.txt; do
    myShort=`echo $filename | cut -c1-11` 
    echo "$myShort" > $myShort"_uniqmaps.txt"    
    cut -f 2 "$filename" > $myShort"_uniqmaps.txt"  
done 

for filename in *_uniqmaps.txt; do
    tail -n +2 -- "$filename" > $filename"_uniqmapsNH.txt"  
done 

for filename in *_uniqmapsNH.txt; do (myShort=`echo $filename | cut -c1-11`;echo "$myShort"; cat $filename) > tmp; mv tmp $filename; done

paste *_uniqmapsNH.txt > allcountsdata_rnaseq.txt

cut -f 1 cmv1_rnaseq_cnts.txt | paste - allcountsdata_rnaseq.txt > allcountsdataRN_rnaseq.txt

mv allcountsdataRN_rnaseq.txt allcountsdata_rnaseq.txt

rm *uniqmaps*

Rscript Deseq2.r allcountsdata_rnaseq.txt result.txt result_graph.pdf
python pick.py result.txt result_Deseq2.txt 0.05
