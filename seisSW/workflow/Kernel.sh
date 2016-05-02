#!/bin/bash

ulimit -s unlimited

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
export WORKING_DIR="$working_path/$Job_title/"  # directory on local nodes, where specfem runs
export SUBMIT_RESULT="$result_path/$job/Scale${Wscale}_${misfit_type}"     # final results

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
if [ $system == 'slurm' ]; then
    srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
elif [ $system == 'pbs' ]; then
    pbsdsh  -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
fi
echo "Finish data preparation"
echo "READY for inversion  .... "


echo
echo "********************************************************************************************************"
echo "           Welcome Scale $Wscale ${misfit_type} $job"
echo "********************************************************************************************************"
echo

 echo "Forward/Adjoint simulation for current model ...... "
 ## prepare models 
export current_velocity_file=$WORKING_DIR/model_current.dat
export current_attenuation_file=$initial_attenuation_file
export current_anisotropy_file=$initial_anisotropy_file
export compute_adjoint=true
if [ $system == 'slurm' ]; then
    srun -n $NSRC -W 0 $SCRIPTS_DIR/CurrentForwardAdjoint.sh 2> ./job_info/error_current_simulation
elif [ $system == 'pbs' ]; then
    pbsdsh -n $NSRC -W 0 $SCRIPTS_DIR/CurrentForwardAdjoint.sh 2> ./job_info/error_current_simulation
fi
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

