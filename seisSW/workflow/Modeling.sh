#!/bin/bash

source parameter

if [ $system == 'slurm' ]; then
    # Submit directory
    export SUBMIT_DIR=$SLURM_SUBMIT_DIR
    echo "$SLURM_JOB_NODELIST"  >  ./job_info/NodeList
    echo "$SLURM_JOBID"  >  ./job_info/JobID
elif [ $system == 'pbs' ]; then
    # Submit directory
    export SUBMIT_DIR=$PBS_O_WORKDIR
    echo "$PBS_NODEFILE"  >  ./job_info/NodeList
    echo "$PBS_JOBID"  >  ./job_info/JobID
fi
cd $SUBMIT_DIR

#################### input parameters ###################################################
# directories
export SCRIPTS_DIR="$package_path/scripts"
export WORKING_DIR="$working_path/$Job_title"    # directory on local nodes, where specfem runs
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/$result_path/Scale${Wscale}"     # final results


echo 
echo "Submit job <<$Job_title>> in : $SUBMIT_DIR  "
echo "Working directory: $WORKING_DIR"
echo "FINAL results in :  $SUBMIT_RESULT"
echo 

#########################################################################################


echo
STARTTIME=$(date +%s)
echo "start time is :  $(date +"%T")"


if $ReStart; then
echo
echo "Re-Launch job ..." 
echo "Clean up result/working directories ..."
rm -rf $SUBMIT_RESULT $WORKING_DIR
else
echo
echo "Continue with current job ..."
fi
mkdir -p $SUBMIT_RESULT  $WORKING_DIR

echo
echo "Prepare data ...... "

if [ $system == 'slurm' ]; then
    srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
elif [ $system == 'pbs' ]; then
    pbsdsh -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
fi
echo "Finish data preparation"
echo "READY for inversion  .... "


ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")" 
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."


cp -r $SUBMIT_DIR/job_info/output $SUBMIT_RESULT/

echo
echo " clean up local nodes (wait) ...... "
rm -rf $WORKING_DIR

echo
echo "******************well done*******************************"

