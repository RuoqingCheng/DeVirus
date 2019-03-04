library(DESeq2)
library(geneplotter)

Args <- commandArgs()

mydata <- read.table(Args[6], header = TRUE, quote = "\t")

countMatrix <- as.matrix(mydata[2:7])
rownames(countMatrix) <- mydata$ContigName

table2 <- data.frame(name = colnames(countMatrix), condition = c("EG", "EG", "EG", "CG", "CG", "CG"))
dds <- DESeqDataSetFromMatrix(countMatrix, colData = table2, rowData = mydata$ContigName, design = ~ condition)

dds <- dds[ rowSums(counts(dds)) > 1, ]
dds <- DESeq(dds)

res <- results(dds)
write.table(res, Args[7], sep = "\t", row.names = TRUE)

pdf(Args[8], width = 8, height = 9)
plotMA(res, main="DESeq2", ylim=c(-2,2))
dev.off()