#!/bin/bash
#SBATCH --job-name=wwww
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=miaosun@bio.au.dk
#SBATCH --partition short
#SBATCH --mem-per-cpu=gggg
#SBATCH --cpus-per-task 1
#SBATCH --nodes 1
#SBATCH --time 12:00:00
#SBATCH --output=wwww_%j.out
#SBATCH --error=wwww_%j.err

date
raxml-ng --all --msa wwww.raxml.rba --tip-inner --prefix ./wwww/wwww --threads $SLURM_CPUS_PER_TASK -seed ${RANDOM} --tree rand{25},pars{25} --bs-metric fbp,tbe
date