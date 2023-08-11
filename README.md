# NeuroSlurm

Auotmatically runs submits R scripts to a slurm cluster and organizes the results based on whether the job successfully completes or fails. Based on code written by William Zhu. 

To automatically submit jobs to a slurm schedule one needs to do the following: 
1. Copy the file `run_analyses.sh`
2. Copy the file `slurm_parameters.txt`
3. Create a directory `called analyses/`

Once this is done, one can put .R and .Rmd files in the `analysis/` folder, and then run the analysis script by typing `./run_analyses.sh` on the command line. 

This will cause all the .R and .Rmd files to be submitted to the cluster. Files that are successfully executed will be in a folder `analyses/Completed` while files that fail will be in a folder `analyses/Failed`. 

One can change cluster parameter settings (e.g., the number of CPUs, RAM, etc.) by modifying the `slurm_parameters.txt` file. 

