#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=10
#SBATCH --error=job_info/error
#SBATCH --output=job_info/output
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=yanhuay@princeton.edu

cd $SLURM_SUBMIT_DIR

echo "  $SLURM_JOB_NODELIST"  >  ./job_info/NodeList
echo "  $SLURM_JOB_ID"  >  ./job_info/JobID
export user=$(whoami)

#################### input parameters ###################################################
source parameter
echo " "
echo " Request nodes is $SLURM_NNODES, Request tasks per node is $SLURM_NTASKS_PER_NODE"
echo " "

# directories
export SUBMIT_DIR=$SLURM_SUBMIT_DIR
export SCRIPTS_DIR="$package_path/scripts" 
export LOCAL_DIR="/scratch/gpfs/$user/$Job_title"   # directory on local nodes, where specfem runs
export RESULTS_DIR="/tigress/$user/RESULTS/$Job_title" # directory on global nodes to save return results from local nodes
export SAVE_DIR="$RESULTS_DIR/result"
export CWP_DIR=$CWPROOT
export WT_DIR="$package_path/WT_basis"
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/result/Scale${Wscale}"

echo " "
echo " Submit job $Job_title in $SLURM_SUBMIT_DIR  "
echo " Local directory: $LOCAL_DIR"
echo " RESULTS saved in $RESULTS_DIR"
echo " FINAL models can be found in $SUBMIT_RESULT"
echo " "

#########################################################################################


echo " ------------------------------------ Start job $Job_title -----------------------------"
echo
echo "start time is "
 date +"%T"

if [ $ReStart -eq 1 ]; then
echo
echo " Re-Launch job ..." 
echo " Clean up result directories ..."
rm -rf $RESULTS_DIR $SAVE_DIR $SUBMIT_RESULT
echo " Make result directories ..."
mkdir -p $RESULTS_DIR $SAVE_DIR $SUBMIT_RESULT

echo
echo "Prepare for target and initial model ..."
cp $SUBMIT_DIR/bin/DATA/model_target.dat   $RESULTS_DIR/model_target.dat

# to see models
cp $SUBMIT_DIR/bin/DATA/model_target.dat   $SUBMIT_RESULT/model_target.dat

elif [ $ReStart -eq 0 ]; then
echo
echo " Continue with current job ..."
fi

echo
echo "******************Welcome misfit contour for scale $Wscale ************************************************"

echo "loop over the first paramter "
for (( iloop1=0;iloop1<${N1sample};iloop1++ ))
do
echo 
echo " Misfit Estimation for iloop1= $iloop1"
 srun -n $N2sample -W 0 $SCRIPTS_DIR/MisfitEstimation_srun $iloop1  2> ./job_info/error_current_simulation
done

echo
echo "finish time is "
 date +"%T"

echo
echo " clean up local nodes"
 srun -n $N2sample $SCRIPTS_DIR/Clean_srun 2> ./job_info/error_clean 

echo
echo "******************well done*******************************"


