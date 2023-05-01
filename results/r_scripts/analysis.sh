#!/bin/bash -i
#SBATCH -J 10neurons
#SBATCH -c 16
#SBATCH -p bigmem
#SBATCH --constraint cascadelake
#SBATCH --mem=1500G
module load R/4.1.0-foss-2020b
Rscript Pending/"test_william_run_ANOVA_try_03.R"
