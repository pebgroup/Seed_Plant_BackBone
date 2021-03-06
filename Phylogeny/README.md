# ReadMe

A phylogeny for seed plants was estimated that incorporated at least one sample for each order. The final phylogeny comprised 103 tips, [101 species](./data/BackBone_sampling101.csv) representing 69 orders plus two Lycophyte outgroups (_Isoetes tegetiformans_ and _Selaginella apoda_).  

The Angiosperms353 exon sequences of 42 samples were collected from Johnson et al. [(2019)](https://academic.oup.com/sysbio/article/68/4/594/5237557) and the rest were using [`blastn`](./scripts/blastn_353ref.sh) extracted the SOAPdenovo assemblies of [One Thousand Plants Transcriptome Initiative (1KP) public database](http://www.onekp.com/public_data.html) against the Angiosperms353 probe sequences based a similarity threshold of `e = 1e-5` from Johnson et al. [(2019)](https://academic.oup.com/sysbio/article/68/4/594/5237557). The resultant sequence data gathered and combined based on each gene id, and the matrix was aligned using [MAFFT](https://mafft.cbrc.jp/alignment/software/) and cleaned using [trimAl](https://vicfero.github.io/trimal/) with portions of gaps potentially introduced by 1KP data and the `-cons 60` option (Salvador et al. 2009) (see script [here](./scripts/mafft_clean_trimal.sbatch)). Two genes [(`g6514` and `g6886`)](./data/gene_undersampled) were excluded because of low taxon coverage (< 20%), hence 351 genes remained.  

  All aligned and cleaned sequences are located at `./data/mafft_clean_trimal_aln/`. `raxml-ng_launch.sh` launch either `raxml-ng1T.sbatch` (one thread) or `raxml-ng-NT.sbatch` (n threads) to run analysis using [RAxML Next Generation](https://github.com/amkozlov/raxml-ng), depends on the alignment size and computation resource request (if more threads or memory needed, then it will use `raxml-ng-NT.sbatch` submit a job to SLURM).  

  After the RAxML analysis has done, run `astral.sh` will collect all the best ML trees of each of 351 gene trees, and using `reroot_genetree_phyx_mad.R` and `mad.R` to reroot the gene tree, then run [ASTRAL-III](https://github.com/smirarab/ASTRAL) to summarise gene tree as a single species tree.  
  

+ `raxml-ng_launch.sh`  
	_Main scripts submit RAxML-ng jobs to SLURM. It has three features: 1). checking [alignment size](./data/mafft_clean_trimal_aln/) and grap information about computational resources; 2). raxml-ng use `AutoMRE` option [use MRE-based bootstrap convergence criterion, otherwise will run 1000 replicates as default; 3). distinguish SLURM jobs based on how many threads needed._  
	- `raxml-ng1T.sbatch`  
		One thread SLURM job script.  
	- `raxml-ng-NT.sbatch`  
		Multiple threads SLURM job script.  
		
+ `astral.sh`  
	_`astral.sh` will first reroot the each of [gene trees](./data/gene\_tree/) generated by RAxML-ng above using either [phyx](https://github.com/FePhyFoFum/phyx) function `pxrr` or [Minimal Ancestor Deviation (MAD)](https://www.nature.com/articles/s41559-017-0193), then it will concatenate all the rerooted gene trees into one single gene tree file, then collapse any node with BS <10%, then input it into astral to infer [the species tree](./data/species\_tree/Backbone\_species\_tree.tre)._  
	- `mad.R`  
		R script used for reroot the tree based on Minimal Ancestor Deviation.  
	- `reroot_genetree_phyx_mad.R`  
		R script used to extract Outgroup information for each gene tree then conditionally run either`pxrr` or `mad.R` for rerooting.  
	
_Last update: Fri Mar 5 2021_  
