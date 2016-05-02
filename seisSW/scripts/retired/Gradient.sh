#!/bin/bash


   ./bin/gradient.exe $SUBMIT_RESULT 2> ./job_info/error_kernel
  # cp $RESULTS_DIR/misfit_kernel.dat $SAVE_DIR/misfit_kernel_$((iter-1)).dat

   echo "finish gradient evaluation for current model"

