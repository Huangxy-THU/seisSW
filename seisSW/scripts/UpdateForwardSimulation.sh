#!/bin/bash

[[ -n "${0}" ]] || { echo -e "\n### Usage ###\n./UpdateForwardSimulation iter\n"; exit 0 ; }
 
# pass parameter files
source parameter

# local id (from 0 to $ntasks-1)
if [ $system == 'slurm' ]; then
    iproc=$SLURM_PROCID
elif [ $system == 'pbs' ]; then
    iproc=$PBS_VNODENUM
fi

IPROC_WORKING_DIR=$( seq --format="$WORKING_DIR/%06.f/" $iproc $iproc )  

cd $IPROC_WORKING_DIR

## echo " link current model "
   cp $update_velocity_file ./DATA/model_velocity.dat
   if $attenuation; then
   cp $update_attenuation_file ./DATA/model_attenuation.dat
   fi
   if $anisotropy; then
   cp $update_anisotropy_file ./DATA/model_anisotropy.dat
   fi
   ./bin/prepare_model.exe

##echo " edit 'Par_file' "
   FILE="./DATA/Par_file"
   sed -e "s#^SIMULATION_TYPE.*#SIMULATION_TYPE = 1 #g"  $FILE > temp; mv temp $FILE
   sed -e "s#^SAVE_FORWARD.*#SAVE_FORWARD = .false. #g"  $FILE > temp; mv temp $FILE
   sed -e "s#^SU_FORMAT.*#SU_FORMAT = .true.#g"  $FILE > temp; mv temp $FILE

   # cleans output files
   rm -rf ./OUTPUT_FILES/*
   ##### stores setup
   cp ./DATA/Par_file ./OUTPUT_FILES/
   cp ./DATA/SOURCE ./OUTPUT_FILES/


   ##### forward simulation (data) #####
   ./bin/xmeshfem2D > OUTPUT_FILES/output_mesher.txt
   ./bin/xspecfem2D > OUTPUT_FILES/output_solver.txt

# save 
cp OUTPUT_FILES/*_file_single.su            DATA_syn/

# process & stores output
  if ${XCOMP}; then
  sh ./SU_process/syn_process.sh DATA_syn/Ux_file_single.su DATA_syn/Ux_file_single_processed.su
  fi
  if ${YCOMP}; then
  sh ./SU_process/syn_process.sh DATA_syn/Uy_file_single.su DATA_syn/Uy_file_single_processed.su
  fi
  if ${ZCOMP}; then
  sh ./SU_process/syn_process.sh DATA_syn/Uz_file_single.su DATA_syn/Uz_file_single_processed.su
  fi
  if ${PCOMP}; then
  sh ./SU_process/syn_process.sh DATA_syn/Up_file_single.su DATA_syn/Up_file_single_processed.su
  fi

#echo "finish forward simulation"
  # save adjoint source or not 
      compute_adjoint=.false.
     ./bin/misfit_adjoint.exe $compute_adjoint 


