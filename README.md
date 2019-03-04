# DeVirus

## Introduction
#### Background
Many of plants diseases, which cause huge loss to agriculture, are caused by virus infection. System-level transcriptomic studies could help us to learn the differential expression gene (DEG)  in the response to the viral infection. Though the point of view from DEG, we could get a better understanding of how the virus affect the host plant and how the plant hosts response to viral infection. It could help us develop better strategies to control the diseases.  

Nicotiana tabacum is also known as cultivated tobacco, which leaves could be processed into tobacco. It is one of the most common cash crop all across the world. Cucumber mosaic virus (CMV) is a vital plant pathogenic virus. It has a wide range of plant hosts. As a result, studying the genome expression change in N. tabacum after CMV infection is quite meaningful. 

In our study, we will use de novo transcriptome assembly strategy to build the whole transcriptome, and use it as a reference to do DEG analysis. CMV is a kind of (+) RNA virus, so there won’t an insertion in plant genome during the infection. As a consequence, we can adopt mapping first strategy (use the reference from database directly rather than assembled by our self) to do DEG and compare the performances of the two different strategy. After the DEG analysis, we could compare the difference in the genome of N. tabacum with and without infection. 

In addition, with the help of de novo transcriptome assembly strategy, we can rebuild the viral mRNA to viral transcriptome and find the virus. Our pipeline is appropriate to find DEG and virus in any virus caused plant disease cases. 

#### Workflow

![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/Pipeline.jpeg)

## Packages
#### Trinity
Required Data: (trimmed) fastq file
Output: the collection of contigs in fasta file
Description: Trinity is a software using greedy algorithm and de Brujin graph to align trimmed RNA reads to several contigs. Each contigs is a part of or just the unigene. 
Link: https://github.com/trinityrnaseq/trinityrnaseq/wiki

#### BLAST
Required Data: fasta file
Output: a fasta file for reference
Description: Comparing the contigs from Trinity to the novel gene database and give annotation to each contigs if the contigs belong to some known gene. After that, maybe we need our own coding work to build our own reference according to the Blast work.
Link: https://blast.ncbi.nlm.nih.gov/Blast.cgi

#### BWA MEM
Required Data: fastq file for reads and fasta file for reference
Output: sam file
Description: BWA MEM aligns the reads to the reference and gives a sam file that contains each read whether they are aligned to the reference or not.
Link: http://bio-bwa.sourceforge.net/

#### DESeq2
Required Data: bam files or sam files
Output: p-value for each gene
Link: https://bioconductor.org/packages/release/bioc/html/DESeq2.html



## Running Pipeline

#### Usage:
```sbatch ./AssemblyAnalysis.sbatch <experimental group1 (SRR id) > <experimental group2 (SRR id)> <experimental group3 (SRR id)> <control group4 (SRR id)> <control group5 (SRR id)> <control group6 (SRR id)> <reference genome (filename)>```

```sbatch ./ReferenceAnalysis.sbatch <experimental group1 (SRR id) > <experimental group2 (SRR id)> <experimental group3 (SRR id)> <control group4 (SRR id)> <control group5 (SRR id)> <control group6 (SRR id)> <reference genome (filename)>```

#### Command Line Example:
```sbatch ./AssemblyAnalysis.sbatch SRR6374506 SRR6374507 SRR6374508 SRR6374511 SRR6374513 SRR6374514 GCF_000715135.1_Ntab-TN90_genomic.fna```

```sbatch ./ReferenceAnalysis.sbatch SRR6374506 SRR6374507 SRR6374508 SRR6374511 SRR6374513 SRR6374514 GCF_000715135.1_Ntab-TN90_genomic.fna```

#### Required Input Files:

1. 3 raw RNA reads fastq files from 3 experimental groups and 3 raw RNA reads fastq files from 3 control groups: To build de novo transcriptome for differential expression analysis.

2. Reference genome fasta/fna file: To create a database for gene annotation. Can be downloaded from NCBI: https://www.ncbi.nlm.nih.gov/



## Getting Started with the Pipeline
The difference between pipeline 1 in AssemblyAnalysis.bash and pipeline2 ReferenceAnalysis.bash is that there is no assembly part and annotation part in pipeline 1 and pipeline 2. 

#### Assembly(Trinity)
Trinity will generate Trinity.fasta (.fasta file) in ./trinity_test_out from 6 input fastq files. In this assembly part, Trinity will automatically check the quality of raw RNA-seq reads, generate trimmed reads and assemble transcriptome from these clean data.

#### Annotation and Picking up the Possible Virus Sequences (BLAST)
The assembled transcriptome will be aligned against a small database created with BLASTNusing the input reference genome (.fasta file). We only annotate those input sequences with e-value lower than 1e-10. Also in this step we will generate a fasta file named virus.fasta. For those hits with high e-value (>1e-10) in the blast result, we construe that they are resulted from possible virus sequences due to infection samples and save them into virus.fasta.

#### Mapping and Getting Expression Information (BWA MEM, countxpression.py)
BWA MEM will generate .bam files and .sam files. In pipeline 1 with AssemblyAnalysis.bash, we are mapping RNA-seq reads to the generated transcriptome assembly. While in pipeline 2 running ReferenceAnalysis.bash, RNA-seq reads are mapped to reference genome. 
We use countxpression.py after mapping [1]. This python script is to collect all the statistics we need from the generated .sam files and generate several * counts.txt. Later command lines are used to adjust these * counts.txt files into allcountsdata.txt which recording the expression of each contig in different samples . 


#### Citation:
1.De Wit P, Pespeni MH, Ladner JT, Barshis DJ, Seneca F, Jaris H, Overgaard Therkildsen N, Morikawa M and Palumbi SR (2012) The simple fool's guide to population genomics via RNA-Seq: an introduction to high-throughput sequencing data analysis.  Molecular Ecology Resources 12, 1058-1067.
