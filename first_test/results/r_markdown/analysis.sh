#!/bin/bash -i
#SBATCH -J 10neurons
#SBATCH -c 16
#SBATCH -p bigmem
#SBATCH --constraint cascadelake
#SBATCH --mem=1500G
module load R/4.1.0-foss-2020b
module load Pandoc/2.10
Rscript -e "rmarkdown::render('Pending/NeuroShiny_Script_ID_20230326_161419_61744_em_try_05.Rmd')"
