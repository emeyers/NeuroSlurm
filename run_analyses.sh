


# This code pulls data from GitHub. Could add it back later but can also run
# the code without it (could have a flag that specifies if this should be run). 

# # read in values from the login.txt file
# https=$(sed "1q;d" $1)
# https=${https:4}
# token=$(sed "2q;d" $1)
# token=${token:6}
# dir=$(sed "3q;d" $1)
# dir=${dir:10}
# commitmessage=$(sed "4q;d" $1)
# commitmessage=${commitmessage:8}
# link=$(echo $https | cut -c 9-)
# 
# cd $dir
# git pull https://$token@$link




cd analyses


# This block of code checks the files in submitted_job_info.txt to see their job progress.
# If the job is completed or failed, it moves to the corresponding folder and is removed from the list of files in submitted_job_info.txt
# If the job is still running, it remains in the Pending folder and stays in submitted_job_info.txt

touch submitted_job_info.txt
if test -f temp_backup_submitted_jobs.txt; then
     rm temp_backup_submitted_jobs.txt
fi

touch temp_backup_submitted_jobs.txt
numlines=$(wc -l < submitted_job_info.txt)
for i in $( seq 1 $numlines ); do
   
   line=$(sed "${i}q;d" submitted_job_info.txt)
   filename=${line% *}
   id=${line##* }
   extension=${filename##*.}
   
   
   if seff $id | grep -q PENDING; then
      echo "pending"
      echo $line >> temp_backup_submitted_jobs.txt
   
   
   # If the job is running, put its name into temp_backup_submitted_jobs.txt
   elif seff $id | grep -q RUNNING; then
      echo "running"
      echo $line >> temp_backup_submitted_jobs.txt
   
   
   # If the job is completed, move it to the COMPLETED folder along with the corresponding slurm output file
   elif seff $id | grep -q COMPLETED; then
      
      echo "completed"
      
      # check if these directories exist, and if not create them
      
      if [ !  -d "Completed" ]; then
        mkdir Completed
      fi
      if [ ! -d "Completed/completed_scripts" ]; then
        mkdir Completed/completed_scripts
      fi 
      if [ ! -d "Completed/slurm_outputs" ]; then
        mkdir Completed/slurm_outputs
      fi 
      if [ ! -d "Completed/pdf_outputs" ]; then
        mkdir Completed/pdf_outputs
      fi 
      
      
      mv Pending/"${filename}" Completed/completed_scripts
      mv "slurm-${id}.out" "slurm-${filename}.out"
      mv "slurm-${filename}.out" Completed/slurm_outputs
      
      
      # move the Rscript to the completed folder
      if [[ "Rmd" == "$extension" ]]; then
         mv Pending/"${filename::-3}pdf" Completed/pdf_outputs
      fi
      
      
      
   # If the job is failed, move it to the FAILED folder along with the corresponding slurm output file
   elif seff $id | grep -q FAILED; then
      
      echo "failed"
      
      # create these directories if they do not exist
      if [ !  -d "Failed" ]; then
        mkdir Failed
      fi
      if [ !  -d "Failed/failed_scripts" ]; then
        mkdir Failed/failed_scripts
      fi
      if [ !  -d "Failed/slurm_outputs" ]; then
        mkdir Failed/slurm_outputs
      fi
      
      
      mv Pending/"${filename}" Failed/failed_scripts
      mv "slurm-${id}.out" "slurm-${filename}.out"
      mv "slurm-${filename}.out" Failed/slurm_outputs
      
      
      # I don't think there will be any pdf outputs if the job fails
      #mkdir Failed/pdf_outputs
      
      # move the Rscript to the failed folder
      # if [[ "Rmd" == "$extension" ]]; then
      #    mv Pending/"${filename::-3}pdf" Failed/pdf_outputs
      # fi
   
      
   fi
   
done


rm submitted_job_info.txt
mv temp_backup_submitted_jobs.txt submitted_job_info.txt






# This block of code will go through the analysis/ directory and create a submission script for each .R and .Rmd file
# Each of these scripts will then be submitted, and the submitted file names are added to submitted_job_info.txt
# Only up to 200 files are allowed to be in submitted_job_info.txt (submitted to slurm) at a time

readarray -t filenames < <(ls -a | grep -E '.Rmd$|.R$')

numlines=$(wc -l < submitted_job_info.txt)
newfiles=$(( 200 - $numlines ))
for idx in ${!filenames[@]}; do


   if [ $idx -lt $newfiles ]; then
   
      filename=${filenames[$idx]}
   
      # make sure to check filename and create a different analysis file depending on if it is .R or .Rmd

      echo $filename
      touch analysis.sh
   
      # all of these echo statements create the analysis.sh file
      echo "#!/bin/bash -i" > analysis.sh
      echo "#SBATCH -J NeuroSlurm_analysis" >> analysis.sh
      echo "#SBATCH -c 16" >> analysis.sh
      echo "#SBATCH -p bigmem" >> analysis.sh
      echo "#SBATCH --constraint cascadelake" >> analysis.sh
      echo "#SBATCH --mem=1500G" >> analysis.sh
      echo "module load R/4.1.0-foss-2020b" >> analysis.sh
      
      # If running an R script
      if echo $filename | grep '.R$'; then
        
        echo "Rscript Pending/\"${filename}\"" >> analysis.sh
      
      
      
      # If running an RMarkdown document
      elif echo $filename | grep '.Rmd$'; then
      
        echo "module load Pandoc/2.10" >> analysis.sh
        echo "Rscript -e \"rmarkdown::render('Pending/$filename')\"" >> analysis.sh
      
      fi
      
      
      # move the Rscript to the in progress folder
      if [ ! -d "Pending" ]; then
        mkdir Pending
      fi
      
      mv "${filename}" Pending
      message=$(sbatch analysis.sh)
      id=$(echo $message | cut -c 21-)
      echo $filename $id >> submitted_job_info.txt
      
      
   fi
   
done








# This code pushes data from GitHub. Could add it back later but can also run
# the code without it (could have a flag that specifies if this should be run). 

# cd ../..
# 
# git add .
# git commit -m "$commitmessage"
# git push https://$token@$link


