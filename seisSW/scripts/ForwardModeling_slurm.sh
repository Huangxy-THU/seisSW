#!/bin/bash
#SBATCH -p rdhpc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH -- cpu-per-task=4
#SBATCH --time=60
#SBATCH --error=job_info/error
#SBATCH --output=job_info/output
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=yanhuay@princeton.edu


ulimit -s unlimited

cd $SLURM_SUBMIT_DIR

echo "$SLURM_JOB_NODELIST"  >  ./job_info/NodeList
echo "$SLURM_JOB_ID"  >  ./job_info/JobID
export user=$(whoami)

#################### input parameters ###################################################
source parameter
echo 
echo "Request nodes is $SLURM_NNODES, Request tasks per node is $SLURM_NTASKS_PER_NODE"
echo 

# directories
export SUBMIT_DIR=$SLURM_SUBMIT_DIR
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
 srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation_srun 2> ./job_info/error_target
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
#srun -n $NSRC $SCRIPTS_DIR/Clean_srun 2> ./job_info/error_clean 

echo
echo "******************well done*******************************"

