#!/usr/bin/bash

echo -e "\n Step I: Concatenate all gene trees ...\n"

mkdir -p genetree_reroot

while read -r gene; do
	Rscript reroot_genetree_phyx_mad.R $gene
done <gene_list

cat ./genetree_reroot/*.supportTBE.rt.tre >>Backbone351genetreesTBE.tre
cat ./genetree_reroot/*.supportFBP.rt.tre >>Backbone351genetreesFBP.tre
	
echo -e "\n Step II: Collaps all the nodes that BS support <10% within all gene trees ...\n"

nw_ed Backbone351genetreesTBE.tre 'i & b<=0.1' o >Backbone351genetrees_TBE10.tre
nw_ed Backbone351genetreesFBP.tre 'i & b<=10' o >Backbone351genetrees_FBP10.tre

# the main input is just a file that contains all the input gene trees in Newick format. The input gene trees are treated as unrooted, whether or not they have a root. 
# Note that the output of ASTRAL should also be treated as an unrooted tree.

echo -e	"\n Step III: running astral for species tree ...\n"

java -jar /home/cactus/apps/ASTRAL/Astral/astral.5.7.4.jar -i Backbone351genetrees_TBE10.tre -o Backbone351TBE10_species.tre 2> Backbone351TBE10_species.log
java -jar /home/cactus/apps/ASTRAL/Astral/astral.5.7.4.jar -i Backbone351genetrees_FBP10.tre -o Backbone351FBP10_species.tre 2> Backbone351FBP10_species.log

echo -e "\n****************\nDone!!!\n****************\n"

# reroot and ladderize
nw_reroot Backbone351FBP10_species.tre Isoetes_tegetiformans_1kp Selaginella_apoda_1kp|nw_order -c n - >Backbone351FBP10_species.rt.tre
nw_reroot Backbone351TBE10_species.tre Isoetes_tegetiformans_1kp Selaginella_apoda_1kp|nw_order -c n - >Backbone351TBE10_species.rt.tre
