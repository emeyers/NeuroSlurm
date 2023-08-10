#!/bin/bash -i
#SBATCH -J NeuroSlurm_analysis
#SBATCH -c 16
#SBATCH -p bigmem
#SBATCH --constraint cascadelake
#SBATCH --mem=1500G
module load R/4.1.0-foss-2020b
module load Pandoc/2.10
Rscript -e "rmarkdown::render('Pending/fail.Rmd')"
