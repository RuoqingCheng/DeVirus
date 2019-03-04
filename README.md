# DeVirus
Many of plants diseases, which cause huge loss to agriculture, are caused by virus infection. System-level transcriptomic studies could help us to learn the differential expression gene (DEG)  in the response to the viral infection. Though the point of view from DEG, we could get a better understanding of how the virus affect the host plant and how the plant hosts response to viral infection. It could help us develop better strategies to control the diseases.  

Nicotiana tabacum is also known as cultivated tobacco, which leaves could be processed into tobacco. It is one of the most common cash crop all across the world. Cucumber mosaic virus (CMV) is a vital plant pathogenic virus. It has a wide range of plant hosts. As a result, studying the genome expression change in N. tabacum after CMV infection is quite meaningful. 

In our study, we will use de novo transcriptome assembly strategy to build the whole transcriptome, and use it as a reference to do DEG analysis. CMV is a kind of (+) RNA virus, so there won’t an insertion in plant genome during the infection. As a consequence, we can adopt mapping first strategy (use the reference from database directly rather than assembled by our self) to do DEG and compare the performances of the two different strategy. After the DEG analysis, we could compare the difference in the genome of N. tabacum with and without infection. 

In addition, with the help of de novo transcriptome assembly strategy, we can rebuild the viral mRNA to viral transcriptome and find the virus. Our pipeline is appropriate to find DEG and virus in any virus caused plant disease cases. 

## Pipeline

![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/Pipeline.jpeg)


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
