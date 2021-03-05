#!/bin/bash
date

# define data and results directory
path="/home/cactus/faststorage/PhyloSynth/PhyloSynth_progress/BackBone/"

cd ${path}data && mkdir -p 1kp_blast 1kp_blast/1kp2-353fasta

#For BLAST: (evalue 1e-5; this is hybpiper's default setting)
#cd 1kp-SOAPdenovo-Trans-assembly

# loop through fa files
for z in `ls ./1kp_raw/*.fa`; do
#z=$1
	ref=$(basename $z .fa)
	code=$(basename $z -SOAPdenovo-Trans-assembly.fa)
	echo -e "\n\n working on $ref \n\n"
	#buiding the database in the same directory as the data located
	makeblastdb -in $z -dbtype nucl -parse_seqids
	for gene in `ls ./ref_353genes/*.fasta`; do
		name=$(basename $gene .fasta)
		echo -e "\n\n working on $name \n\n"
		blastn -db $z -query $gene -evalue 1e-5  -outfmt "6 qseqid qlen sseqid slen qstart qend sstart send length mismatch gapopen evalue bitscore" -out ./1kp_blast/${name}_${code}.blast.out
		#check if no results from the blast
		# then skip the R test
		line=$(wc -l ./1kp_blast/${name}_${code}.blast.out|cut -f1 -d' ')
		if [ "$line" -eq 0 ]; then
			continue
		else
			#using R to select the best sequence based in bitscore, evalue, align length and the subject length
			#sed "s/XXXX/${name}_${code}/g" ../script/1kp_script/Select_best_hit.R >tmp.Select_best_hit.R
			sed -i '1 i\qseqid\tqlen\tsseqid\tslen\tqstart\tqend\tsstart\tsend\tlength\tmismatch\tgapopen\tevalue\tbitscore' ./1kp_blast/${name}_${code}.blast.out
			Rscript ../script/1kp_script/Select_best_hit.R ${path}data/1kp_blast/${name}_${code}.blast.out
			blastdbcmd -db $z -dbtype nucl -entry_batch ./1kp_blast/${name}_${code}.blast.seq.txt -outfmt %f -out tmp.fasta
			grep ">" tmp.fasta |sed 's/>//g' >old_name.txt
			grep ">" tmp.fasta |sed 's/Smilax_bona-nox/Smilax_bona_nox/g'|awk -F '-' '{print $NF}'|sed 's/$/_1kp/g' >new_name.txt
			pxrls -s tmp.fasta -c old_name.txt -n new_name.txt >>./1kp_blast/1kp2-353fasta/${name}_1kp.fasta
			rm tmp.* new_name.txt old_name.txt
		fi
	done
done
date
