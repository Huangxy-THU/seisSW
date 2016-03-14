#!/bin/bash
#SBATCH --nodes=1
#SBATCG --mem=8000
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
export LOCAL_DIR="/scratch/network/$user/$Job_title"   # directory on local nodes, where specfem runs
export RESULTS_DIR="/tigress/$user/RESULTS/$Job_title" # directory on global nodes to save return results from local nodes
export SAVE_DIR="$RESULTS_DIR/result"
export CWP_DIR=$CWPROOT
export WT_DIR="$package_path/WT_basis"
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/result/image/"
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
echo "Prepare initial model ..."
cp $SUBMIT_DIR/bin/DATA/model_initial.dat   $RESULTS_DIR/model_current.dat
cp $SUBMIT_DIR/bin/DATA/model_initial.dat $SUBMIT_RESULT/model_0.dat
if [ $ExistDATA -eq 0 ]; then
cp $SUBMIT_DIR/bin/DATA/model_target.dat   $RESULTS_DIR/model_target.dat
cp $SUBMIT_DIR/bin/DATA/model_target.dat   $SUBMIT_RESULT/model_target.dat
fi

elif [ $ReStart -eq 0 ]; then
echo
echo " Continue with current job ..."
mkdir -p $RESULTS_DIR $SAVE_DIR $SUBMIT_RESULT
fi


echo
echo "******************Welcome scale $Wscale ************************************************"

echo
echo "Forward simulation for target model ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation_srun 2> ./job_info/error_target
    echo "finish forward simulation for target model"

echo
echo "***************************************************************************************"
echo " Migration ..."
echo


echo " Forward/Adjoint simulation for current model ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/CurrentForwardAdjoint_srun 2> ./job_info/error_current_simulation
    echo "finish Forward/Adjoint simulation for current model"


echo 
echo " misfit kernel and gradient for current model ...... "
   ./bin/combine_kernel.exe $RESULTS_DIR 2> ./job_info/error_kernel
   cp $RESULTS_DIR/misfit_kernel.dat $SUBMIT_RESULT/image.dat
   cp $RESULTS_DIR/g_new.dat $SUBMIT_RESULT/image_smoothed.dat
   echo "finish misfit kernel for current model"


rm -rf $SAVE_DIR/*  

echo

echo
echo "finish time is "
 date +"%T"

echo
echo " clean up local nodes"
#srun -n $NSRC $SCRIPTS_DIR/Clean_srun 2> ./job_info/error_clean 

echo
echo "******************well done*******************************"

cp -r $SUBMIT_DIR/job_info/output $SUBMIT_RESULT/
