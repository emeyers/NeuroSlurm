#!/bin/bash


# helper function to write output from slurm to a .csv file
write_to_slurm_log_file () {
  
  current_job_ID=$1 
  curr_file_name=$2
  slurm_log_file_name=$3
  
  output=$(seff "$current_job_ID")
  
  
  # Declare arrays
  declare -a name
  declare -a value
  
  # Process output into arrays
  while IFS=':' read -r n v; do
      name+=("$n")
      value+=("$v")
  done <<< "$output"
  
  # Create strings from arrays
  names_string=$(IFS=, ; echo "${name[*]}")
  values_string=$(IFS=, ; echo "${value[*]}")
  
  
  # append the name of the file on to .csv file
  names_string="File,$names_string"
  values_string="$curr_file_name,$values_string"
  
  # Remove trailing commas
  names_string="${names_string%,}"
  values_string="${values_string%,}"
  
  
  # Add lines to the slurm log
  
  if [ -f "$slurm_log_file_name" ]; then
      
      # Append values_string to slurm_log_file
      echo "$values_string" >> $slurm_log_file_name
      # echo "Values appended to $slurm_log_file_name"
      
  else
  
      # If the slurm_log_file doesn't exist, 
      # write both names_string and values_string to slurm_log_file
      echo "$names_string" > $slurm_log_file_name
      echo "$values_string" >> $slurm_log_file_name
      # echo "Names and values written to $slurm_log_file_name"
  fi

}






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



# The name of the main directory that has the analysis files can be passed as an argument.
# If this is not passed as an argument, the analyses will be done in the directory analyses/default_project/

if [[ $1 == "" ]]; then
  base_analysis_dir=analyses/default_project/
else 
  base_analysis_dir=$1
fi 


# can pass an alternative file with slurm parameters as an argument
if [[ $2 == "" ]]; then
  slurm_parameters_file=slurm_parameters.txt
else 
  slurm_parameters_file=$2
fi 





# names of directories that will store scripts to be run, the results, etc.

if [ ! -d $base_analysis_dir ]; then
  mkdir -p $base_analysis_dir
fi 



analyses_to_run_dir=$base_analysis_dir/analyses_to_run
analyses_completed_dir=$base_analysis_dir/analyses_running_or_completed


management_files_dir=$analyses_completed_dir/slurm_management_files/
management_file_name=$management_files_dir/submitted_job_info.txt
temp_management_file_name=$management_files_dir/temp_backup_submitted_jobs.txt
curr_slurm_submission_script_name=$management_files_dir/current_slurm_submission_script.sh
slurm_completed_or_failed_log_file_name=$management_files_dir/slurm_completed_and_failed_log.csv
slurm_running_or_pending_log_file_name=$management_files_dir/slurm_running_and_pending_log.csv


if [ ! -d $analyses_to_run_dir ]; then
  mkdir $analyses_to_run_dir
fi 

if [ ! -d $analyses_completed_dir ]; then
  mkdir $analyses_completed_dir
fi 

if [ ! -d $management_files_dir ]; then
  mkdir $management_files_dir
fi

touch $management_file_name
if test -f $temp_management_file_name; then
     rm $temp_management_file_name
fi

touch $temp_management_file_name





# This block of code checks the files in $management_file_name to see their job progress.
# If the job is completed or failed, it moves to the corresponding folder and is removed from the list of files in $management_file_name
# If the job is still running, it remains in the Pending folder and stays in $management_file_name



# remove the log file for jobs in progress and recreate it for any jobs that are currently running
if [ -e $slurm_running_or_pending_log_file_name ]; then
    rm $slurm_running_or_pending_log_file_name
fi


numlines=$(wc -l < $management_file_name)
for i in $( seq 1 $numlines ); do
   
   line=$(sed "${i}q;d" $management_file_name)
   filename=${line% *}
   id=${line##* }
   extension=${filename##*.}
   
   
   if seff $id | grep -q PENDING; then
      
      echo "pending"
      echo $line >> $temp_management_file_name
  
      # writing to a log file that can track jobs in progress
      write_to_slurm_log_file $id ${filename} $slurm_running_or_pending_log_file_name  
      
      
   # If the job is running, put its name into $temp_management_file_name
   elif seff $id | grep -q RUNNING; then
      
      echo "running"
      echo $line >> $temp_management_file_name
   
      # writing to a log file that can track jobs in progress
      write_to_slurm_log_file $id ${filename} $slurm_running_or_pending_log_file_name

   
   # If the job is completed, move it to the COMPLETED folder along with the corresponding slurm output file
   elif seff $id | grep -q COMPLETED; then
      
      echo "completed"
      
      # check if these directories exist, and if not create them
      
      if [ ! -d "$analyses_completed_dir/Completed" ]; then
        mkdir "$analyses_completed_dir/Completed"
      fi
      if [ ! -d "$analyses_completed_dir/Completed/completed_scripts" ]; then
        mkdir "$analyses_completed_dir/Completed/completed_scripts"
      fi 
      if [ ! -d "$analyses_completed_dir/Completed/slurm_outputs" ]; then
        mkdir "$analyses_completed_dir/Completed/slurm_outputs"
      fi 
      if [ ! -d "$analyses_completed_dir/Completed/pdf_outputs" ]; then
        mkdir "$analyses_completed_dir/Completed/pdf_outputs"
      fi 
      
      
      mv $analyses_completed_dir/Pending/"${filename}" $analyses_completed_dir/Completed/completed_scripts
      #mv "slurm-${id}.out" "slurm-${filename}.out"
      #mv "slurm-${filename}.out" $analyses_completed_dir/Completed/slurm_outputs
      mv "$management_files_dir/slurm-${filename}.out" $analyses_completed_dir/Completed/slurm_outputs

      
      # move the Rscript to the completed folder
      if [[ "Rmd" == "$extension" ]]; then
         mv $analyses_completed_dir/Pending/"${filename::-3}pdf" $analyses_completed_dir/Completed/pdf_outputs
      fi
      
      
      # write the output to the slurm log file
      write_to_slurm_log_file $id ${filename} $slurm_completed_or_failed_log_file_name

      
   # If the job is failed, move it to the FAILED folder along with the corresponding slurm output file
   elif seff $id | grep -q FAILED; then
      
      echo "failed"
      
      # create these directories if they do not exist
      if [ !  -d $analyses_completed_dir/Failed ]; then
        mkdir $analyses_completed_dir/Failed
      fi
      if [ !  -d $analyses_completed_dir/Failed/failed_scripts ]; then
        mkdir $analyses_completed_dir/Failed/failed_scripts
      fi
      if [ !  -d $analyses_completed_dir/Failed/slurm_outputs ]; then
        mkdir $analyses_completed_dir/Failed/slurm_outputs
      fi
      
      
      mv $analyses_completed_dir/Pending/"${filename}" $analyses_completed_dir/Failed/failed_scripts
      
      #mv "slurm-${id}.out" "slurm-${filename}.out"
      #mv "slurm-${filename}.out" $analyses_completed_dir/Failed/slurm_outputs

      # could add the job ID to the file name as well...
      mv "$management_files_dir/slurm-${filename}.out" $analyses_completed_dir/Failed/slurm_outputs
      
      
      # I don't think there will be any pdf outputs if the job fails
      #mkdir Failed/pdf_outputs
      
      # move the Rscript to the failed folder
      # if [[ "Rmd" == "$extension" ]]; then
      #    mv Pending/"${filename::-3}pdf" Failed/pdf_outputs
      # fi
   
   
      # write the output to the slurm log file
      write_to_slurm_log_file $id ${filename} $slurm_completed_or_failed_log_file_name


   fi
   
done


rm $management_file_name
mv $temp_management_file_name $management_file_name






# This block of code will go through the analysis/ directory and create a submission script for each .R and .Rmd file
# Each of these scripts will then be submitted, and the submitted file names are added to $management_file_name
# Only up to 200 files are allowed to be in $management_file_name (submitted to slurm) at a time

#readarray -t filenames < <(ls -a | grep -E '.Rmd$|.R$')

readarray -t filenames < <(ls -a $analyses_to_run_dir | grep -E '.Rmd$|.R$')


numlines=$(wc -l < $management_file_name)
newfiles=$(( 200 - $numlines ))
for idx in ${!filenames[@]}; do


   if [ $idx -lt $newfiles ]; then
   
      filename=${filenames[$idx]}
   
      # make sure to check filename and create a different analysis file depending on if it is .R or .Rmd
      touch $curr_slurm_submission_script_name
   
   
      # reading in the slurm parameters from slurm_parameters.txt rather than hard coding them
      cat ./$slurm_parameters_file > $curr_slurm_submission_script_name
      echo "/n" >> $curr_slurm_submission_script_name
      
      # If running an R script
      if echo "$analyses_to_run_dir/$filename" | grep '.R$' >/dev/null 2>&1; then
        
        echo "Rscript $analyses_completed_dir/Pending/\"${filename}\"" >> $curr_slurm_submission_script_name
      
      
      # If running an RMarkdown document
      elif echo "$analyses_to_run_dir/$filename" | grep '.Rmd$' >/dev/null 2>&1; then
      
        echo "Rscript -e \"rmarkdown::render('$analyses_completed_dir/Pending/$filename')\"" >> $curr_slurm_submission_script_name

      fi
      
      
      # move the Rscript to the in progress folder
      if [ ! -d  $analyses_completed_dir/Pending ]; then
        mkdir  $analyses_completed_dir/Pending
      fi
      
      mv "$analyses_to_run_dir/${filename}" $analyses_completed_dir/Pending
      
      output_file_name="$management_files_dir/slurm-${filename}.out"
      message=$(sbatch --output $output_file_name $curr_slurm_submission_script_name)
      
      id=$(echo $message | cut -c 21-)
      echo $filename $id >> $management_file_name

      echo "$filename submitted with jobID $id"

   fi
   
done






# This code pushes data from GitHub. Could add it back later but can also run
# the code without it (could have a flag that specifies if this should be run). 

# cd ../..
# 
# git add .
# git commit -m "$commitmessage"
# git push https://$token@$link


