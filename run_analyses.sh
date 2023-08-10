


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
if test -f files2.txt; then
     rm files2.txt
fi

touch files2.txt
numlines=$(wc -l < submitted_job_info.txt)
for i in $( seq 1 $numlines ); do
   
   line=$(sed "${i}q;d" submitted_job_info.txt)
   filename=${line% *}
   id=${line##* }
   extension=${filename##*.}
   
   # If we want to include Rmd files, then each line should include a third token denoting if it is .R or .Rmd
   # Alternatively, could just check the filename extension, which actually now sounds easier
   # then we move the file into a DIFFERENT Completed or Failed folder, along with the slurm out files
   # remember, the slurm output files are in another directory, NOT this one!
   # the files themselves are also not in this directory; they are under r_markdown!
   # if the job is pending, put its name into files2.txt
   
   if seff $id | grep -q PENDING; then
      echo "pending"
      echo $line >> files2.txt
   
   
   # If the job is running, put its name into files2.txt
   elif seff $id | grep -q RUNNING; then
      echo "running"
      echo $line >> files2.txt
   
   
   # If the job is completed, move it to the COMPLETED folder along with the corresponding slurm output file
   elif seff $id | grep -q COMPLETED; then
      
      echo "completed"
      
      # check if these directories exist, and if not create them
      mkdir Completed
      mkdir Completed/completed_scripts
      mkdir Completed/slurm_outputs
      mkdir Completed/pdf_outputs
      
      
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
      mkdir Failed
      mkdir Failed/failed_scripts
      mkdir Failed/slurm_outputs
      mkdir Failed/pdf_outputs
      
      mv Pending/"${filename}" Failed/failed_scripts
      mv "slurm-${id}.out" "slurm-${filename}.out"
      mv "slurm-${filename}.out" Failed/slurm_outputs
      
      
      # move the Rscript to the failed folder
      if [[ "Rmd" == "$extension" ]]; then
         mv Pending/"${filename::-3}pdf" Failed/pdf_outputs
      fi
   fi
done


rm submitted_job_info.txt
mv files2.txt submitted_job_info.txt






# This block of code will go through the analysis/ directory and create a submission script for each .R file
# each of these scripts will then be submitted, and the submitted file names are added to submitted_job_info.txt
# only up to 200 files are allowed to be in submitted_job_info.txt (submitted to slurm) at a time
readarray -t filenames < <(ls -a | grep '.R$')
numlines=$(wc -l < submitted_job_info.txt)
newfiles=$(( 200 - $numlines ))
for idx in ${!filenames[@]}; do
   if [ $idx -lt $newfiles ]; then
      filename=${filenames[$idx]}
      # make sure to check filename and create a different analysis file depending on if it is .R or .Rmd
      # also remember to put it in the r_markdown Pending folder, NOT this one
      echo $filename
      touch analysis.sh
      # all of these echo statements create the analysis.sh file
      echo "#!/bin/bash -i" > analysis.sh
      echo "#SBATCH -J 10neurons" >> analysis.sh
      echo "#SBATCH -c 16" >> analysis.sh
      echo "#SBATCH -p bigmem" >> analysis.sh
      echo "#SBATCH --constraint cascadelake" >> analysis.sh
      echo "#SBATCH --mem=1500G" >> analysis.sh
      echo "module load R/4.1.0-foss-2020b" >> analysis.sh
      echo "Rscript Pending/\"${filename}\"" >> analysis.sh
      # move the Rscript to the in progress folder
      mkdir Pending
      mv "${filename}" Pending
      message=$(sbatch analysis.sh)
      id=$(echo $message | cut -c 21-)
      echo $filename $id >> submitted_job_info.txt
   fi
done




# This code is totally redundant with the above code and should be deleted
# but need to change the grep line to work with both .R and .Rmd files

readarray -t filenames < <(ls -a | grep '.Rmd$')
numlines=$(wc -l < submitted_job_info.txt)
newfiles=$(( 200 - $numlines ))
for idx in ${!filenames[@]}; do
   if [ $idx -lt $newfiles ]; then
      filename=${filenames[$idx]}
      # make sure to check filename and create a different analysis file depending on if it is .R or .Rmd
      # also remember to put it in the r_markdown Pending folder, NOT this one
      echo $filename
      touch analysis.sh
      # all of these echo statements create the analysis.sh file
      echo "#!/bin/bash -i" > analysis.sh
      echo "#SBATCH -J 10neurons" >> analysis.sh
      echo "#SBATCH -c 16" >> analysis.sh
      echo "#SBATCH -p bigmem" >> analysis.sh
      echo "#SBATCH --constraint cascadelake" >> analysis.sh
      echo "#SBATCH --mem=1500G" >> analysis.sh
      echo "module load R/4.1.0-foss-2020b" >> analysis.sh
      echo "module load Pandoc/2.10" >> analysis.sh
      echo "Rscript -e \"rmarkdown::render('Pending/$filename')\"" >> analysis.sh
      # move the Rscript to the in progress folder
      mkdir Pending
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


