#!/bin/bash
#SBATCH -p serial
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=60
#SBATCH --error=job_info/error
#SBATCH --output=job_info/output


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
export SUBMIT_RESULT="$result_path/Scale${Wscale}_${misfit_type}"     # final results

echo 
echo "Submit job << $Job_title >> in : $SUBMIT_DIR  "
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
rm -rf $SUBMIT_RESULT  $WORKING_DIR
else
echo
echo "Continue with current job ..."
fi
mkdir -p $SUBMIT_RESULT  $WORKING_DIR

echo
echo "Prepare initial model ..."
cp $initial_velocity_file   $WORKING_DIR/model_current.dat
cp $initial_velocity_file    $SUBMIT_RESULT/model_0.dat

if  ! $ExistDATA ; then
cp   $target_velocity_file    $WORKING_DIR/model_target.dat
cp   $target_velocity_file    $SUBMIT_RESULT/model_target.dat
fi

echo
echo "Prepare data ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation_srun 2> ./job_info/error_target
echo "Finish data preparation"
echo "READY for inversion  .... "


echo
echo "********************************************************************************************************"
echo "           Welcome Scale $Wscale ${misfit_type}  kernel"
echo "********************************************************************************************************"
echo

 echo "Forward/Adjoint simulation for current model ...... "
 ## prepare models 
export current_velocity_file=$WORKING_DIR/model_current.dat
export current_attenuation_file=$initial_attenuation_file
export current_anisotropy_file=$initial_anisotropy_file
export compute_adjoint=true
 srun -n $NSRC -W 0 $SCRIPTS_DIR/CurrentForwardAdjoint_srun 2> ./job_info/error_current_simulation
 echo "Finish Forward/Adjoint simulation for current model"


echo 
echo "(new) gradient for current model ...... "
STARTTIME_grad=$(date +%s)
   ./bin/gradient.exe $WORKING_DIR $mask_file 2> ./job_info/error_kernel
   cp $WORKING_DIR/misfit_kernel.dat $SUBMIT_RESULT/misfit_kernel.dat
ENDTIME_grad=$(date +%s)
Ttaken=$(($ENDTIME_grad - $STARTTIME_grad))
echo "$(($Ttaken / 60)) minutes and $(($Ttaken % 60)) seconds elapsed for gradient."
echo "Finish gradient evaluation for current model"



echo
echo "******************finish all for scale $Wscale **************"
echo
echo "******************finish all scales*******************************"

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")" 
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."


cp -r $SUBMIT_DIR/job_info/output $SUBMIT_RESULT/
cp -r $SUBMIT_DIR/parameter $SUBMIT_RESULT/

echo
echo " clean up local nodes (wait) ...... "
rm -rf $WORKING_DIR

echo
echo "******************well done*******************************"

