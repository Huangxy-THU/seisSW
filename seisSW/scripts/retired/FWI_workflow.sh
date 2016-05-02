#!/bin/bash
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=16
#SBATCH --time=60
#SBATCH --error=job_info/error
#SBATCH --output=job_info/output
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=yanhuay@princeton.edu

ulimit -s unlimited

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

echo " "
echo " Submit job $Job_title in $SLURM_SUBMIT_DIR  "
echo " Local directory: $LOCAL_DIR"
echo " RESULTS saved in $RESULTS_DIR"
echo " FINAL models can be found in $SLURM_SUBMIT_DIR/result"
echo " "
mkdir -p $SLURM_SUBMIT_DIR/result
#########################################################################################


echo " ------------------------------------ Start job $Job_title -----------------------------"
echo
echo "start time is "
 date +"%T"

# total iterations
ttiter=0

# loop over scale 
for iscale in 9 8 7 6 5 0 ;
do
if [ "$iscale" -eq 9 ]; then
let NA=5622
let smooth_x=20
let smooth_z=20
fi

if [ "$iscale" -eq 8 ]; then
let NA=2806
let smooth_x=20
let smooth_z=20
fi
if [ "$iscale" -eq 7 ]; then
let NA=1398
let smooth_x=15
let smooth_z=15
fi
if [ "$iscale" -eq 6 ]; then
let NA=694
let smooth_x=10
let smooth_z=10
fi
if [ "$iscale" -eq 5 ]; then
let NA=342
let smooth_x=8
let smooth_z=8
fi
if [ "$iscale" -eq 0 ]; then
let NA=0
let smooth_x=6
let smooth_z=6
fi

# loop over window 
for itaper in 1 2 3 4 5 6 ;
do
let offset_near=`(expr $(($itaper)) \* 100)`

if [ "$itaper" -ne 6 ]; then
let is_near=1
else
let is_near=0
fi


# loop over kernel type 
for kernel in 2;
do

echo
echo
echo "******************Welcome scale $iscale itaper $itaper kernel $kernel ****************************"
echo
echo
echo "--- RE-edit parameter file ......"
echo "ReStart=$ReStart;Wscale=$iscale;NA=$NA;smooth_x=$smooth_x;smooth_z=$smooth_z;is_near=$is_near;offset_near=$offset_near;kernel=$kernel"
   FILE="parameter"
   sed -e "s#^ReStart=.*#ReStart=$ReStart #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^Wscale=.*#Wscale=$iscale #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^NA=.*#NA=$NA #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^smooth_x=.*#smooth_x=${smooth_x} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^smooth_z=.*#smooth_z=${smooth_z} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^is_near=.*#is_near=${is_near} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^offset_near=.*#offset_near=${offset_near} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^kernel=.*#kernel=$kernel #g"  $FILE > temp;  mv temp $FILE
 
echo 
echo "--- Re source paramater ......"     
source parameter

echo
echo "--- prepare data/model/file ...... "
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/result/Scale${Wscale}_Kernel${kernel}_w${itaper}"
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

# default Restart
let ReStart=0
fi

elif [ $ReStart -eq 0 ]; then
echo
echo " Continue with current job ..."
mkdir -p $RESULTS_DIR $SAVE_DIR $SUBMIT_RESULT
fi

if [ $ExistDATA -eq 0 ]; then
echo
echo " model misfit ...... "
   ./bin/model_misfit.exe $RESULTS_DIR 2> ./job_info/error_model_misfit
   mv $RESULTS_DIR/model_misfit.dat $SAVE_DIR/model_misfit_0.dat
fi

echo
echo "Forward simulation for target model ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/TargetForwardSimulation_srun 2> ./job_info/error_target
    echo "finish forward simulation for target model"

# kernel loop

if [ "$DD" -eq 1 ]; then
echo
echo "*************Welcome cross station (double difference) method *********************************************"
else
echo 
echo "*************Welcome single station method ********************************************"
fi

echo
echo "***************************************************************************************"
echo "Start FWI using kernel $kernel from iteration $iter_start to $iter_end "
echo

# iteration loop
for (( iter=$iter_start;iter<=$iter_end;iter++ ))
do

echo 
echo "***************************************************************************************"
echo "********************* Welcome iteration $iter *****************************************"
echo

let reset=`(expr $(($iter-$iter_start)) % $reset_rate)`
echo "reset= $reset"

echo " Forward/Adjoint simulation for current model ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/CurrentForwardAdjoint_srun 2> ./job_info/error_current_simulation_$iter
    echo "finish Forward/Adjoint simulation for current model"

echo
echo " misfit for current model ...... "
   ./bin/data_misfit.exe $RESULTS_DIR 2> ./job_info/error_misfit_current
   cp $RESULTS_DIR/data_misfit.dat $SAVE_DIR/data_misfit_$((iter-1)).dat
   mv $RESULTS_DIR/data_misfit.dat $RESULTS_DIR/data_misfit_current.dat
   mv $RESULTS_DIR/misfit_category.dat $SAVE_DIR/misfit_category_$((iter-1)).dat

echo 
echo " misfit kernel and gradient for current model ...... "
STARTTIME=$(date +%s)
   ./bin/combine_kernel.exe $RESULTS_DIR $smooth_x $smooth_z 2> ./job_info/error_kernel
   cp $RESULTS_DIR/misfit_kernel.dat $SAVE_DIR/misfit_kernel_$((iter-1)).dat
   cp $RESULTS_DIR/g_new.dat $SAVE_DIR/gradient_$((iter-1)).dat

   echo "finish misfit kernel for current model"
ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo "$(($Ttaken / 60)) minutes and $(($Ttaken % 60)) seconds elapsed for combining/smooth kernel."


 if [ ${SAVE_DATA} -eq 1 -a  $iter -eq 1 ]; then
 cp  $RESULTS_DIR/g_new.dat $SUBMIT_RESULT/kernel.dat
 fi


echo
echo " ######################  model update ##########################################"
echo " First step : decide update direction ......"
    ./bin/update_direction.exe $CG $reset $RESULTS_DIR 2> ./job_info/error_update_direction
   echo "  obtained update direction .... "

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
   let linearsearch_direction=2
   let step_loop=0
   let step_back=0

# line search
   while [ $linearsearch_direction -ne 3 ]
   do

  echo
  echo " Try update model ......"
   ./bin/model_update.exe $step_back $RESULTS_DIR 2> ./job_info/error_model_update
   echo "  finish updating model"


echo 
echo " Forward simulation for update model ...... "
 srun -n $NSRC -W 0 $SCRIPTS_DIR/UpdateForwardSimulation_srun 2> ./job_info/error_update_simulation
    echo "finish Forward simulation for update model"

echo
echo " misfit for update model ......"
   ./bin/data_misfit.exe $RESULTS_DIR 2> ./job_info/error_misfit_update
   cp $RESULTS_DIR/data_misfit.dat $RESULTS_DIR/data_misfit_update.dat
   echo "finish misfit calculation for update model"

echo
echo " check misfit ...... "
    ./bin/comp_misfit.exe $linearsearch_direction $step_loop $step_back $RESULTS_DIR  2> ./job_info/error_comp

     linearsearch_direction=`cat $RESULTS_DIR/search_direction`

    if [ $linearsearch_direction -eq 0 ]; then
            break
    fi

    if [ $linearsearch_direction -eq 1 ]; then
          let step_back=$step_back+1
    fi

    if [ $linearsearch_direction -eq 2 ]; then
            let step_loop=$step_loop+1
            echo " remember to update current model and misfit "
   mv $RESULTS_DIR/data_misfit_update.dat $RESULTS_DIR/data_misfit_current.dat
   mv $RESULTS_DIR/model_update.dat $RESULTS_DIR/model_current.dat 
    fi
    if [ $linearsearch_direction -eq 3 ];then
            break
    fi
    if [ $linearsearch_direction -eq 4 ];then
            let step_back=$step_back+1
            let step_loop=$step_loop+1
            echo " remember to update current model and misfit ...... "
            echo " "
               mv $RESULTS_DIR/data_misfit_update.dat $RESULTS_DIR/data_misfit_current.dat
               mv $RESULTS_DIR/model_update.dat $RESULTS_DIR/model_current.dat 
            break
    fi

     echo
     echo " line search status .... "
     echo "search direction is $linearsearch_direction, step_loop=$step_loop step_back=$step_back"
     echo 

  done  # end of line search

    if [ $linearsearch_direction -eq 0 ]; then
       echo 
       echo " Terminate all iterations in FWI"
            break
    fi

if [ $ExistDATA -eq 0 ]; then
echo 
echo " model misfit ...... "
   ./bin/model_misfit.exe $RESULTS_DIR 2> ./job_info/error_model_misfit
   mv $RESULTS_DIR/model_misfit.dat $SAVE_DIR/model_misfit_$iter.dat
fi

echo 
echo " prepare for next iteration ..."
mv $RESULTS_DIR/g_new.dat $RESULTS_DIR/g_old.dat
mv $RESULTS_DIR/p_new.dat $RESULTS_DIR/p_old.dat
# save result
cp $RESULTS_DIR/model_current.dat   $SUBMIT_RESULT/model_$iter.dat
cp $RESULTS_DIR/data_misfit_current.dat $SAVE_DIR/data_misfit_$iter.dat
let ttiter=$ttiter+1
# clean up
#rm -rf $RESULTS_DIR/event_kernel*
#rm -rf $RESULTS_DIR/misfit*
#rm -rf $RESULTS_DIR/data*
#rm -rf $RESULTS_DIR/search_direction
echo 
echo "******************finish iteration $iter*******************************"
done  # end of iterative updates
echo
echo "******************finish all iterations for kernel $kernel*************"
echo "SAVE results for scale $Wscale kernel $kernel...."
cp -r $SAVE_DIR  $RESULTS_DIR/Result_${Wscale}_${kernel}_w${itaper}
rm $SAVE_DIR/*  

done # kernel

done # itaper

echo
echo "******************finish all for scale $Wscale **************"

done # iscale
echo
echo "******************finish all scales*******************************"

echo
echo " total of iterations = $ttiter "

cp -r $SUBMIT_DIR/job_info/output $SUBMIT_RESULT/

echo
echo "finish time is "
 date +"%T"

echo
echo " clean up local nodes (wait) ...... "
srun -n $NSRC $SCRIPTS_DIR/Clean_srun 2> ./job_info/error_clean 

echo
echo "******************well done*******************************"

