#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=60
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
export CWP_DIR=$CWPROOT
export WT_DIR="$package_path/WT_basis"
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/result/Scale$Wscale"
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

echo 
echo "Set up directory for results ..."
rm -rf $RESULTS_DIR  $SUBMIT_RESULT
mkdir -p $RESULTS_DIR $SUBMIT_RESULT

echo
echo "Prepare for target model ..."
cp $SUBMIT_DIR/bin/DATA/model_target.dat   $RESULTS_DIR/model_target.dat

echo
echo "******************Welcome scale $Wscale ************************************************"

echo
echo "Forward simulation for target model ...... "
srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation_srun 2> ./job_info/error_target
    echo "finish forward simulation for target model"

echo
echo "******************finish all for scale $Wscale **************"

echo
echo "finish time is "
 date +"%T"

echo
echo " clean up local nodes"
# srun -n $NSRC $SCRIPTS_DIR/Clean_srun 2> ./job_info/error_clean 

echo
echo "******************well done*******************************"


