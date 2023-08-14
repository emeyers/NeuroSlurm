# NeuroSlurm

Automatically runs submits R scripts to a slurm cluster and organizes the results based on whether the job successfully completes or fails. Based on code written by William Zhu. 

### Initial setup 

To automatically submit jobs to a slurm schedule one needs to copy the following files to the cluster that has the slurm scheduler: 

1. Copy the file `run_analyses.sh`
2. Copy the file `slurm_parameters.txt`
3. One the cluster, make `run_analyses.sh` executable by runnig `chmod 700 run_analyses.sh`


### Automatically submitting jobs to the cluster

One can run jobs automatically on the cluster, using `./run_analyses.sh` as follows: 

1. Call `./run_analyses.sh analyses/project_name/` to create an initial set of directories, where `analyses/project_name/` is the name of a directory where you would like to save your results. This code will create a directory, `analyses/project_name/analyses_to_run` that you can put code in to be submitted to the cluster. 

2. Put `.r` or `.Rmd` in the directory `analyses/project_name/analyses_to_run/` that you would like run. 
  
3. Call the function `./run_analyses.sh analyses/project_name/` again to run all the files in the `analyses/project_name/`.

4. Once the jobs have finished running, one should again call `./run_analyses.sh analyses/project_name/` to move the code that has been run to the appropriate folders

5. One can repeat steps 2-5 to continue to submit jobs to the cluster and organize the results.

   
### Output

The output files after `./run_analyses.sh analyses/project_name/` has been called twice (i.e., to submit jobs and move completed job files) is:  

1. Files that are successfully executed will be in a folder `analyses/project_name/analyses_running_or_completed/Completed/`
2. Files that fail will be in a folder `analyses/project_name/analyses_running_or_completed/Failed/` 


### Using different cluster parameters

One can change cluster parameter settings (e.g., the number of CPUs, RAM, etc.) by modifying the `slurm_parameters.txt` file. 

Alternatively, one can specify a second argument to `./run_analyses.sh` that is a file that has particular slurm arguments (in the format of `sluerm_parameters.txt`). For example, one could use the following to specify specific parameters:  `./run_analyses.sh analyses/project_name/ my_parameters.txt` 

