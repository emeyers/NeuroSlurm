# NeuroSlurm

Auotmatically runs submits R scripts to a slurm cluster and organizes the results based on whether the job successfully completes or fails. Based on code written by William Zhu. 

To automatically submit jobs to a slurm schedule one needs to do the following: 
1. Copy the file `run_analyses.sh`
2. Copy the file `slurm_parameters.txt`

Once this is done, one can run `./run_analyses.sh analyses/project_name/` to create a directory `analyses/project_name/analyses_to_run`, where `analyses/project_name/` is the name of a directory where you would like to save your results.

One can then put `.r` or `.Rmd` in the directory `analyses/project_name/analyses_to_run/`, and then call `./run_analyses.sh analyses/project_name/` again to run all the files in the `analyses/project_name/`. Files that are successfully executed will be in a folder `analyses/project_name/analyses_running_or_completed/Completed/` while files that fail will be in a folder `analyses/project_name/analyses_running_or_completed/Failed/`. 

One can change cluster parameter settings (e.g., the number of CPUs, RAM, etc.) by modifying the `slurm_parameters.txt` file. 

