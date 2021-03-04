#!/bin/bash
#SBATCH --job-name=wwww
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=miaosun@bio.au.dk
#SBATCH --partition normal
#SBATCH --mem-per-cpu=gggg
#SBATCH --cpus-per-task xxxx
#SBATCH --time 24:00:00
#SBATCH --output=wwww_%j.out
#SBATCH --error=wwww_%j.err
#SBATCH -C "gen2|gen3|gen4"

date

raxml-ng-mpi --all --msa wwww.raxml.rba --extra thread-nopin --tip-inner --prefix ./wwww/wwww --threads $SLURM_CPUS_PER_TASK -seed ${RANDOM} --tree rand{25},pars{25} --bs-metric fbp,tbe

date