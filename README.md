# NeuroSlurm

Automatically runs submits R scripts to a slurm cluster and organizes the results based on whether the job successfully completes or fails. Based on code written by William Zhu. 

### Initial setup 

To automatically submit jobs to a slurm schedule one needs to copy the following files to the cluster that has the slurm scheduler: 

1. Copy the file `run_analyses.sh`
2. Copy the file `slurm_parameters.txt`


### Setting up initial directories and automatically submitting jobs to the cluster

Once this is done, one can do the following: 

1. Run `./run_analyses.sh analyses/project_name/` to create a directory `analyses/project_name/analyses_to_run`, where `analyses/project_name/` is the name of a directory where you would like to save your results.

2. One can then put `.r` or `.Rmd` in the directory `analyses/project_name/analyses_to_run/`.
  
3. Then call the function `./run_analyses.sh analyses/project_name/` again to run all the files in the `analyses/project_name/`.

4. Once the jobs have finished running, one should again call `./run_analyses.sh analyses/project_name/` to move the code that has been run to the appropriate folders

### Output

The output files after `./run_analyses.sh analyses/project_name/` has been called twice to submit jobs and move completed jobs is:  

1. Files that are successfully executed will be in a folder `analyses/project_name/analyses_running_or_completed/Completed/`
2. Files that fail will be in a folder `analyses/project_name/analyses_running_or_completed/Failed/` 


### Using different cluster parameters

One can change cluster parameter settings (e.g., the number of CPUs, RAM, etc.) by modifying the `slurm_parameters.txt` file. 

Alternatively, one can specify a second argument to `./run_analyses.sh` that is a file that has particular slurm arguments (in the format of `sluerm_parameters.txt`). For example, one could use the following to specify specific parameters:  `./run_analyses.sh analyses/project_name/ my_parameters.txt` 

