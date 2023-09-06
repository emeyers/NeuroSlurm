
# remove previous directories that have test files
rm -r analyses_test

# create initial directories
./../run_analyses.sh analyses_test/test_project1/


# copy the example script files into the analyses_to_run/ directory

cp example_test_fail_script.R example_test_working_script.R example_test_working_markdown.Rmd analyses_test/test_project1/analyses_to_run/




# submit the jobs and make sure everything worked
# output=$(./run_analyses.sh unit_tests/analyses/test_project1/)

output=$(./../run_analyses.sh analyses_test/test_project1/ ../slurm_parameters.txt)



job_ids=$(echo "$output" | awk '{print $NF}')

echo "Extracted job IDs:"
echo "$job_ids"




# call again to move the files to the appropriate directory after the code has completed running

while true; do

  counter=0
  for id in $job_ids; do
    if seff $id | grep -q COMPLETED; then
      ((counter++))
    fi
  done

  echo "$counter jobs completed. Will quit when this reaches 2 (should only take a couple of minutes)"

  if [[ $counter == 2 ]]; then
      break
  fi

  sleep 10  # Wait for 10 seconds before checking again


  ./../run_analyses.sh analyses_test/test_project1/

done



# move the outputs to the appropriate directories after they have been run
test_output=$(./../run_analyses.sh analyses_test/test_project1/)



# one job should fail and 2 should complete, so output should be: "fail complete complete"
#echo "If everything worked correctly the message after the colon should be 'failed completed completed' $test_output"


# check that expected files exist
# could check more files but just checking if example_test_working_markdown.pdf is in the right place for now


if [ -e "analyses_test/test_project1/analyses_running_or_completed/Completed/pdf_outputs/example_test_working_markdown.pdf" ]
then
    echo "ok: file example_test_working_markdown.pdf was created and is in the appropriate directory"
else
    echo "not ok: example_test_working_markdown.pdf is not in the appropriate place"
fi


log_file_name=analyses_test/test_project1/analyses_running_or_completed/slurm_management_files/slurm_completed_and_failed_log.csv

if [ -e "$log_file_name" ]
then
    echo "ok: log file exist at $log_file_name"
else
    echo "not ok: log file does not exist"
fi

