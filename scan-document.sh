#!/bin/bash

JOB_NR=$($PWD/create-job.sh)
DONE=1

echo "Job Number is $JOB_NR"

while [ $DONE -eq 1 ]; do
  ./retrieve-image.sh $JOB_NR
  RESULT=$?
  if [[ $RESULT -eq 1 ]]; then
    DONE=0;
  fi
  sleep 1
done
