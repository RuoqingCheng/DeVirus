# DeVirus

## Introduction
#### Background
Many of plants diseases, which cause huge loss to agriculture, are caused by virus infection. System-level transcriptomic studies could help us to learn the differential expression gene (DEG)  in the response to the viral infection. Though the point of view from DEG, we could get a better understanding of how the virus affect the host plant and how the plant hosts response to viral infection. It could help us develop better strategies to control the diseases.  

Nicotiana tabacum is also known as cultivated tobacco, which leaves could be processed into tobacco. It is one of the most common cash crop all across the world. Cucumber mosaic virus (CMV) is a vital plant pathogenic virus. It has a wide range of plant hosts. As a result, studying the genome expression change in N. tabacum after CMV infection is quite meaningful. 

In our study, we use de novo transcriptome assembly strategy to build the whole transcriptome, and use it as a reference to do DEG analysis. CMV is a kind of (+) RNA virus, so there won’t be an insertion in plant genome during the infection. As a consequence, we can adopt mapping first strategy (use the reference from database directly rather than assembled by our self) to do DEG and compare the performances of the two different strategy. After the DEG analysis, we could compare the difference in the genome of N. tabacum with and without infection. 

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

allcountsdata.txt: (samples name are presented in the first row after ContigName)
![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/allcountsdata.png)

#### Differential Expression Analysis (DeseqTreat.py, Deseq2.r, pick.py)
1. DeseqTreat.py
This python script is to get gene expression information from infected groups and controls by finding the corresponding gene of each contig according to the blast result.  The generated txt file is as following:
![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/NW.png)

2. Deseq2.r
Deseq2.r will give us p-value of each contigs according to contigs’ appearance in infected samples and controls respectively and a result plotting.

3. pick.py
This python script will generate result_Deseq2.txt by retrieving significantly differential expression sequence and related statistics by selecting the Deseq2 result with p-value higher than 0.5.

## Result
#### Sample output:

All the results are names with the format of result_* :

1. result_smallvalue.out: stored the pairs from Trinity contigs to genes with e-values lower than 1e-10.
![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/result_smallvalue.jpeg)

2. result_virus.fasta: stored the virus we found, coming from the Trinity contigs with e-value large than 1e-10.
![alt text](https://github.com/RuoqingCheng/DataForCSE185/blob/master/generatedtxt.jpeg)

3. result_graph.pdf: stored a scatter graph about reads count v.s. log2 fold change. The red points are the genes believed to be DEGs.

<div align=center><img src="https://github.com/RuoqingCheng/DataForCSE185/blob/master/deseq1.jpeg" width="50%" height="50%" />

Figure. Assembly first strategy result</div>

<div align=center><img src="https://github.com/RuoqingCheng/DataForCSE185/blob/master/deseq2.jpeg" width="50%" height="50%" />

Figure. Reference first strategy result</div>

#### Additional Venn Diagram:
<div align=center><img src="https://github.com/RuoqingCheng/DataForCSE185/blob/master/venn.jpeg" width="50%" height="50%" />

Figure. left: assembly pipeline, right: reference pipeline</div>

The sharing genes in the two results were only 328, which were only one of seven to nine of the whole result.

## Discussion
The goal of our pipeline is to provide a convenient and general pipeline of differential gene expression analysis based on plant transcriptome. We hope to present the expression levels among experimental groups and controls in a visualized form and retrieve the possible sequences related to infection from the de novo transcriptome assembly, thus getting better understanding of how such disease can affect the plant in the genome level.

Using the test data we provided, it outputted a collection of differentially expressed genes. Most of these differentially expressed genes in infected plants participate in basic life activities like transcription, translation and metabolism. There are genes such as plastocyanin B'/B' (NW_015792755.1) that perform in photosystem and genes like E3 ubiquitin-protein ligase UPL5-like(NW_015941793.1) protein that regulates leaf senescence through ubiquitination and subsequent degradation of WRKY5. And we also get genes regulates plants growth factors like cytochrome P450 734A1-like protein(NW_015901340.1) that involved in brassinosteroids (BRs) inactivation and regulation of BRs homeostasis. 
And we do find differentially expressed genes related to stress response. For example, ethylene-responsive transcription factor SHINE 3-like(NW_015855388.1) promotes cuticle formation by inducing the expression of enzymes involved in wax biosynthesis. It may be involved in the regulation of gene expression by stress factors and by components of stress signal transduction pathways. These proteins could be used for further study.

To start our pipeline, one part of the required inputs are six RNA sequencing files for transcriptome reconstruction using Trinity in the first step. As a short version, our pipeline is not integrated with data pre-processing toolkits for raw reads quality checking and filtration such as Fastqc and Trimmatic, instead of that we only included in Trinity which can reconstruct a transcriptome using reads cleaned by itself, that is Trinity conducted reads cleaning process before transcriptome assembling by automatically detecting and separating sequences of adaptor from the raw RNA-seq reads. However, this might cause some potential problems in two aspects:

First, Trinity is unable to remove other kinds of contaminated reads from input fastq files. Without a strict and standard quality checking and trimming process provided by other professional software, the transcriptome is generated from relatively clean reads compared with raw data instead of high-quality reads. So the quality of the generated transcriptome still has the chance to be significantly improved if we used better quality control strategies before reads reconstruction.

The second thing is about the reads mapping step after we get the targeted transcriptome. Trinity didn’t pass the trimmed reads used in the given assembly to the next step, which might have possible effects on following analysis steps requiring high-quality reads data. In the current pipeline, only raw RNA-seq reads data as the input at the beginning is applied to mapping process using generated assembly. With possible contamination and low quality sequencing reads remained in the mapping reads, probably the incorrect portion of the mapping results will increase. In all, it would be useful to get better mapping result if we included Fastqc and Trimmatic in the beginning of the pipeline.

In gene annotation after mapping, we set e-value = 1e-10 as a threshold to remove the contigs from other species from the targeted genome by aligning the generated assembly to reference genome using blastn and put those removed contigs into virus.fasta indicating this file contains the sequences probably belonged to viruses causing infection. This is aimed at storing more information for the convenience to check back this part when needed. It would be better if an gene annotation for these retrieved contigs with additional database is added after this part, thus giving users more information about these generated possible virus contigs.

To further improve the performance or the current pipeline, we also can create a friendly interface for the users to conduct the pipeline with more parameters and alignment database selection. For example, we can change the database used in the gene annotation part with a option of using NCBI remote nt database so that the pipeline has another function to compare the differential expression of two groups of samples in the different environment by releasing more details for each contigs.



## Citation:
1. Lu, Jie, et al. "Transcriptome analysis of Nicotiana tabacum infected by Cucumber mosaic virus during systemic symptom de
velopment." PLoS one 7.8 (2012): e43447.

2.De Wit P, Pespeni MH, Ladner JT, Barshis DJ, Seneca F, Jaris H, Overgaard Therkildsen N, Morikawa M and Palumbi SR (2012) The simple fool's guide to population genomics via RNA-Seq: an introduction to high-throughput sequencing data analysis.  Molecular Ecology Resources 12, 1058-1067.

3.Data analysis practice: Run DEG with DESeq2, mucun9548890, https://www.imooc.com/article/268908

