#!/usr/bin/bash
# Usage: bash raxml-ng.sh aln_file.txt
# this script will allocate different sbatch configure files based on resources requests
date

# put all your alignment file name (including absolute path) into a txt file pass to the script
while read -r ALIGNMENT; do 
	Title=$(basename -s .mft.clean_trimal.fasta $ALIGNMENT)
	mkdir -p $Title
	#caclulate alignment total
	NN=$(grep -c ">" $ALIGNMENT)
	
	echo -e "\n      Buliding gene tree for $Title alignment including $NN sequences \n\n"
	echo -e "\n      Run raxml-ng checking for alignment:\n$ALIGNMENT\n"
	
	raxml-ng --parse --msa $ALIGNMENT --model GTR+G --prefix ./${Title}/${Title}.check
	
	#getting specific model and threds memerical configuration
	Model=$(grep "Model:" ./${Title}/${Title}.check.raxml.log|cut -f2 -d' ')
	TT=$(grep "MPI processes" ./${Title}/${Title}.check.raxml.log|cut -f2 -d':')
	# Mem=$(grep "memory requirements" ./${Title}/${Title}.check.raxml.log|cut -f2 -d':'|sed 's/ //g;s/./\L&/g')
	Mem=$(grep "memory requirements" ./${Title}/${Title}.check.raxml.log|cut -f2 -d':'|sed 's/ MB//g;s/ GB//g')
	
	mv ./${Title}/${Title}.check.raxml.rba ./${Title}/${Title}.raxml.rba
	
	if [[ $TT -eq 1 ]]; then
		sed "s/wwww/$Title/g;s/mmmm/$Model/g;s/gggg/1gb/g;s/xxxx/$TT/g" raxml-ng1T.sbatch >./${Title}/raxml_NG_${Title}.sbatch
	elif [[ $TT -gt 1 ]]; then
		if [[ $Mem -lt 512 ]]; then
			sed "s/wwww/$Title/g;s/gggg/512mb/g;s/xxxx/$TT/g" raxml-ng-NT.sbatch >./${Title}/raxml_NG_${Title}.sbatch
		else
			sed "s/wwww/$Title/g;s/gggg/1gb/g;s/xxxx/$TT/g" raxml-ng-NT.sbatch >./${Title}/raxml_NG_${Title}.sbatch
		fi
	else
		echo -e "$Title\t$Model\t$TT\t$Mem" >>failed_raxml_seq_log.txt
	fi
	cd ./${Title}/
	sbatch raxml_NG_${Title}.sbatch
	cd ..
done <aln_file.txt
date
