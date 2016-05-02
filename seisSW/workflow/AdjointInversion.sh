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
export WORKING_DIR="$working_path/specfem/$Job_title"    # directory on local nodes, where specfem runs
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
rm -rf $SUBMIT_RESULT $WORKING_DIR
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
echo
echo "Prepare target model ..."
echo " model misfit ...... "
let iter=$iter_start-1
   ./bin/model_misfit.exe $WORKING_DIR $iter 2> ./job_info/error_model_misfit
fi

echo
echo "Prepare data ...... "
if [ $system == 'slurm' ]; then
    srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
elif [ $system == 'pbs' ]; then
    pbsdsh -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation.sh 2> ./job_info/error_target
fi
 
echo "Finish data preparation"
echo "READY for inversion  .... "

echo
echo "********************************************************************************************************"
echo "           Welcome Scale $Wscale ${misfit_type} $job from iteration $iter_start to $iter_end"
echo "********************************************************************************************************"
echo

# iteration loop
for (( iter=$iter_start;iter<=$iter_end;iter++ ))
do
echo "          *********************"
echo "          ** iteration $iter **"
echo "          *********************"


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
echo "data misfit for current model ...... "
   ./bin/data_misfit.exe $iter 0 $WORKING_DIR $compute_adjoint 2> ./job_info/error_misfit_current

echo 
echo "(new) gradient for current model ...... "
STARTTIME_grad=$(date +%s)
   ./bin/gradient.exe $WORKING_DIR $mask_file 2> ./job_info/error_kernel
   cp $WORKING_DIR/misfit_kernel.dat $SUBMIT_RESULT/misfit_kernel_$((iter-1)).dat
ENDTIME_grad=$(date +%s)
Ttaken=$(($ENDTIME_grad - $STARTTIME_grad))
echo "$(($Ttaken / 60)) minutes and $(($Ttaken % 60)) seconds elapsed for gradient."
echo "Finish gradient evaluation for current model"


echo
echo "          ....................."
echo "           model update ...."
echo "           ....................."

echo "optimization: (new) update direction ......"
   ./bin/update_direction.exe $iter $WORKING_DIR 2> ./job_info/error_update_direction
   echo "obtained update direction"

echo
echo 'line search along the update direction ......'
    # linearsearch_direction=0: stop all iterations without saving
## misfit for current model
    # linearsearch_direction=1: search by halving current step length: backward
    # linearsearch_direction=2: search by doubling current step length: forward
    # linearsearch_direction=3: stop searching for current iteration wth saving
    # linearsearch_direction=4: stop searching for current iteration without saving
  ### 'step_loop': successful iteration steps

  # initialization
   let is_cont=1 
   let is_done=0
   let is_brak=0
   step_length=$initial_step_length
# line search
  while [ $is_done -eq 0 -o $is_brak -eq 0 -o $is_cont -eq 1 ]
   do

   echo
   ./bin/model_update.exe $step_length $WORKING_DIR 2> ./job_info/error_model_update
   echo "Finish updating model"

echo 
echo "Forward simulation for update model ...... "
 ## prepare models 
export update_velocity_file=$WORKING_DIR/model_update.dat
export update_attenuation_file=$initial_attenuation_file
export update_anisotropy_file=$initial_anisotropy_file
export compute_adjoint=false
if [ $system == 'slurm' ]; then
    srun -n $NSRC -W 0 $SCRIPTS_DIR/UpdateForwardSimulation.sh 2> ./job_info/error_update_simulation
elif [ $system == 'pbs' ]; then
    pbsdsh -n $NSRC -W 0 $SCRIPTS_DIR/UpdateForwardSimulation.sh 2> ./job_info/error_update_simulation
fi

echo "Finish Forward simulation for update model"

echo
echo "misfit for update model and search status ......"
   ./bin/data_misfit.exe $iter $step_length $WORKING_DIR $compute_adjoint 2> ./job_info/error_misfit_update

file=$WORKING_DIR/search_status.dat
export is_cont=$(awk -v "line=1" 'NR==line { print $1 }' $file)
export is_done=$(awk -v "line=2" 'NR==line { print $1 }' $file)
export is_brak=$(awk -v "line=3" 'NR==line { print $1 }' $file)
export step_length=$(awk -v "line=4" 'NR==line { print $1 }' $file)
export optimal_step_length=$(awk -v "line=5" 'NR==line { print $1 }' $file)
echo " is_cont=$is_cont; is_done=$is_done; is_brak=$is_brak"
echo

    if [ $is_brak -eq 1 ]; then
            break
    fi

    if [ $is_done -eq 1 ]; then
    echo 
    echo "final model optimal_step_length=$optimal_step_length"
      ./bin/model_update.exe $optimal_step_length $WORKING_DIR 2> ./job_info/error_model_update
      cp $WORKING_DIR/model_update.dat $WORKING_DIR/model_current.dat  
      break 
    fi

done  # end of line search

    if [ $is_brak -eq 1 ]; then
       echo 
       echo "Terminate all iterations in $job"
            break
    fi

if  ! $ExistDATA ; then
echo 
echo "model misfit ...... "
   ./bin/model_misfit.exe $WORKING_DIR $iter 2> ./job_info/error_model_misfit
fi

echo 
echo "prepare for next iteration ..."
mv $WORKING_DIR/g_new.dat $WORKING_DIR/g_old.dat
mv $WORKING_DIR/p_new.dat $WORKING_DIR/p_old.dat
mv $WORKING_DIR/m_new.dat $WORKING_DIR/m_old.dat 

# save result
cp $WORKING_DIR/model_current.dat   $SUBMIT_RESULT/model_$iter.dat
cp $WORKING_DIR/data_misfit_hist_iter$iter   $SUBMIT_RESULT/
echo 
echo "******************finish iteration $iter for ${misfit_type} $job ************"
done  # end of iterative updates
echo
echo "******************finish all iterations for ${misfit_type} $job *************"

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
cp  $WORKING_DIR/data_misfit_hist.dat $SUBMIT_RESULT/
if  ! $ExistDATA ; then
cp  $WORKING_DIR/model_misfit_hist.dat $SUBMIT_RESULT/
fi

echo
echo " clean up local nodes (wait) ...... "
rm -rf $WORKING_DIR

echo
echo "******************well done*******************************"

