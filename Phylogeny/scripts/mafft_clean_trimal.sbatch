#!/usr/bin/bash
#SBATCH --job-name=trimal
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=miaosun@bio.au.dk
#SBATCH --partition normal
#SBATCH --mem-per-cpu 4G
#SBATCH --cpus-per-task 1
#SBATCH --nodes 1
#SBATCH --time 72:00:00
#SBATCH --output=trimal_%j.out
#SBATCH --error=trimal_%j.err

cd ../../data/backbone_matrix/ && mkdir mafft_clean_trimal gene_undersampled

for alig in `ls ./mafft_clean/*.fasta`; do
	nn=$(grep -c ">" $alig)
	n1kp=$(grep -c "_1kp" $alig)
	# calculate portion of gaps potentially introduced by 1kp
	portion=$(echo "($n1kp + 3 ) / $nn" | bc -l)
	name=$(basename $alig .fasta)
	
	if [ $nn -gt 20 ]; then
		trimal -in $alig -keepheader -gt $portion -cons 60 -out ./mafft_clean_trimal/${name}_trimal.fasta
	else
		mv $alig ./gene_undersampled
	fi
done

echo -e "\n\n TrimAL job is done!\n\n"

# make a combined matrix with cleaned alignments
Date=$(date|awk -F ' ' '{print $2"_"$3"_"$NF}')
ls ./mafft_clean_trimal/*.fasta >maftt_genes.txt 
pxcat -f maftt_genes.txt -p gene_partition.txt -o Backbone102_supermatrix.${Date}.fasta
pxclsq -s Backbone102_supermatrix.${Date}.fasta -p 0.3 -o Backbone102_supermatrix.${Date}_clean.fasta
