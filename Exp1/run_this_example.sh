#!/bin/bash

source parameter

echo "Run this example ..."
echo 'will take 10 m ...'

rm -rf submit_job

mkdir submit_job

cp -r $package_path/scripts/submit.sh submit_job/
cp -r DATA submit_job/
cp -r parameter submit_job/
cp -r SU_process submit_job/

echo 'cd submit_job/'
echo './submit.sh'
