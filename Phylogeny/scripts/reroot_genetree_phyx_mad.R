# Author: Miao Sun
# This script one step in the automatic pipeline
# that it takes one argument as gene; then it will find the gene tree
# check if the outgroup present; if not the use mad to root the tree by minimal ancestor deviation
# see [Tria et al. (2017)](https://www.nature.com/articles/s41559-017-0193)

rm(list=ls())
library("ape")
suppressWarnings(suppressMessages(library("phytools")))
source("~/apps/mad.R")

gene <- commandArgs(TRUE)

Outgroup <- c("Selaginella_apoda_1kp", "Isoetes_tegetiformans_1kp")

tree.tbe <- read.tree(paste0("../RAxML/", gene, "/", gene, ".raxml.rba.raxml.supportTBE", sep=""))
tree.fbp <- read.tree(paste0("../RAxML/", gene, "/", gene, ".raxml.rba.raxml.supportFBP", sep=""))

if(sum(Outgroup %in% tree.tbe$tip.label) != 0){
# if outgroup present reroot use outgroup via phyx function 'pxrr'
	system(paste0("pxrr -t ../RAxML/", gene, "/", gene, ".raxml.rba.raxml.supportTBE -r -g ", Outgroup[1], ",", Outgroup[2], " -o ./genetree_reroot/", gene, ".supportTBE.rt.tre", sep=""))

	system(paste0("pxrr -t ../RAxML/", gene, "/", gene, ".raxml.rba.raxml.supportFBP -r -g ", Outgroup[1], ",", Outgroup[2], " -o ./genetree_reroot/", gene, ".supportFBP.rt.tre", sep=""))
	print(paste0("Done with rerooting ", gene, " gene tree using phyx...", sep=""))
} else {
# otherwise use MAD see [Tria et al. (2017)](https://www.nature.com/articles/s41559-017-0193)
	cat(mad(tree.tbe), file=paste0("./genetree_reroot/", gene, ".supportTBE.rt.tre", sep=""))
	cat(mad(tree.fbp), file=paste0("./genetree_reroot/", gene, ".supportFBP.rt.tre", sep=""))
	print(paste0("Done with rerooting ", gene, " gene tree using MAD...", sep=""))
}