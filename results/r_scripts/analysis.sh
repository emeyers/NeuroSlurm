#!/bin/bash -i
#SBATCH -J 10neurons
#SBATCH -c 16
#SBATCH -p bigmem
#SBATCH --constraint cascadelake
#SBATCH --mem=1500G
module load R/4.1.0-foss-2020b
Rscript Pending/"NeuroShiny_Script_ID_20230201_104106_07541.R"
