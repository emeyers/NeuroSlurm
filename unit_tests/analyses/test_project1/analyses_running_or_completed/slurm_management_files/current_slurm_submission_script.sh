#!/bin/bash -i
#SBATCH -J NeuroSlurm_analysis
#SBATCH -c 16
#SBATCH -p bigmem
#SBATCH --constraint cascadelake
#SBATCH --mem=1500G
module load R/4.1.0-foss-2020b
Rscript unit_tests/analyses/test_project1//analyses_running_or_completed/Pending/"example_test_working_script.R"
