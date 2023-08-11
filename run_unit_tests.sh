
# remove previous directories that have test files
rm -r unit_tests/analyses

# create initial directories
./run_analyses.sh unit_tests/analyses/test_project1/


# copy the example script files into the analyses_to_run/ directory
cp unit_tests/example_test_fail_script.R unit_tests/example_test_working_script.R unit_tests/example_test_working_markdown.Rmd unit_tests/analyses/test_project1/analyses_to_run/

#cp unit_tests/example_test_working_markdown.Rmd unit_tests/analyses/test_project1/analyses_to_run/


# submit the jobs and make sure everything worked
output=$(./run_analyses.sh unit_tests/analyses/test_project1/)

job_ids=$(echo "$output" | awk '{print $NF}')

echo "Extracted job IDs:"
echo "$job_ids"


for id in $job_ids; do
    
    if seff $id | grep -q COMPLETED; then
      break
    fi
    
done



# call again to move the files to the appropriate directory after the code has completed running

while true; do

  counter=0
  for id in $job_ids; do
    if seff $id | grep -q COMPLETED; then
      ((counter++))
    fi
  done

  echo $counter

  if [[ $counter == 2 ]]; then
      break
  fi

  sleep 10  # Wait for 10 seconds before checking again

done


./run_analyses.sh unit_tests/analyses/test_project1/
