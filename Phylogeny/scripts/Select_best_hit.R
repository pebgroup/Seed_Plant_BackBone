# this R script will choose one of the best hits based on the alignment length
# and smallest evalue
# pass blast out file from upstream
library("dplyr", quietly = TRUE)

ff <- commandArgs(TRUE)

outname <- gsub(".out", "", ff)
table <- read.table(ff, sep="\t", header=TRUE)
best_id <- table %>% select(-c(qstart,qend,sstart,send)) %>% slice(which.min(evalue)) %>% select(sseqid) %>% unlist() %>% as.character()
#best_id <- unlist(table[which(min(table$V11) && max(table$V9)),]$V3)
cat(best_id, "\n", file=paste0(outname, ".seq.txt", sep=""))
#print(best_id)
