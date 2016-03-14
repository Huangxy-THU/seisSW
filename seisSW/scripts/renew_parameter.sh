#!/bin/bash

# pass parameter 
source parameter

# directory
currentdir=`pwd`
EXE_DIR="$currentdir/bin"        # exacutable files directory

############################# parameter files ############################################################### 
   FILE="$EXE_DIR/seismo_parameters.f90"
   sed -e "s#^Job_title=.*#Job_title=$Job_title #g"  $FILE > temp;  mv temp $FILE

## machine setting
   sed -e "s#^CHARACTER (LEN=20) :: endian=.*#CHARACTER (LEN=20) :: endian='$endian'#g"  $FILE > temp;  mv temp $FILE

## model type
   sed -e "s#^LOGICAL :: isotropy=.*#LOGICAL :: isotropy=.$isotropy.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: attenuation=.*#LOGICAL :: attenuation=.$attenuation.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: anisotropy=.*#LOGICAL :: anisotropy=.$anisotropy.#g"  $FILE > temp;  mv temp $FILE


### FORWARD MODELNG INFO 
   sed -e "s#^INTEGER, PARAMETER :: NSTEP=.*#INTEGER, PARAMETER :: NSTEP=$NSTEP #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: NX=.*#INTEGER, PARAMETER :: NX=$NX #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: deltat=.*#DOUBLE PRECISION, PARAMETER :: deltat=$deltat #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: t0=.*#DOUBLE PRECISION, PARAMETER :: t0=$t0 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: f0=.*#DOUBLE PRECISION, PARAMETER :: f0=$f0 #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: NREC=.*#INTEGER, PARAMETER :: NREC=$NREC #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: NSRC=.*#INTEGER, PARAMETER :: NSRC=$NSRC #g"  $FILE > temp;  mv temp $FILE

### ADJOINT INFO
   # PRE-PROCESSING
#   sed -e "s#^DOUBLE PRECISION, PARAMETER :: tshift=.*#DOUBLE PRECISION, PARAMETER :: tshift=${tshift} #g"  $FILE > temp;  mv temp $FILE
#   sed -e "s#^DOUBLE PRECISION, PARAMETER :: scaler=.*#DOUBLE PRECISION, PARAMETER :: scaler=${scaler} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: src_est=.*#LOGICAL :: src_est=.$src_est.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: scaling=.*#LOGICAL :: scaling=.$scaling.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: Wscale=.*#INTEGER, PARAMETER :: Wscale=$Wscale #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: is_window=.*#INTEGER, PARAMETER :: is_window=$is_window #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: window_type=.*#INTEGER, PARAMETER :: window_type=$window_type#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: V_fast=.*#DOUBLE PRECISION, PARAMETER :: V_fast=${V_fast} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: V_slow=.*#DOUBLE PRECISION, PARAMETER :: V_slow=${V_slow} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: is_laplace=.*#INTEGER, PARAMETER :: is_laplace=$is_laplace #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: S_x=.*#DOUBLE PRECISION, PARAMETER :: S_x=${S_x} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: S_t=.*#DOUBLE PRECISION, PARAMETER :: S_t=${S_t} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: mute_near=.*#INTEGER, PARAMETER :: mute_near=$mute_near #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: offset_near=.*#DOUBLE PRECISION, PARAMETER :: offset_near=${offset_near} #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: mute_far=.*#INTEGER, PARAMETER :: mute_far=$mute_far #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: offset_far=.*#DOUBLE PRECISION, PARAMETER :: offset_far=${offset_far} #g"  $FILE > temp;  mv temp $FILE

   # MISFIT
   sed -e "s#^LOGICAL :: sensitivity=.*#LOGICAL :: sensitivity=.$sensitivity.#g"  $FILE > temp;  mv temp $FILE 
   sed -e "s#^INTEGER, PARAMETER :: NC=.*#INTEGER, PARAMETER :: NC=$NC #g"  $FILE > temp;  mv temp $FILE 
   sed -e "s#^LOGICAL :: XCOMP=.*#LOGICAL :: XCOMP=.$XCOMP.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: YCOMP=.*#LOGICAL :: YCOMP=.$YCOMP.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: ZCOMP=.*#LOGICAL :: ZCOMP=.$ZCOMP.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: PCOMP=.*#LOGICAL :: PCOMP=.$PCOMP.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=2) :: misfit_type=.*#CHARACTER (LEN=2) :: misfit_type='$misfit_type'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: SU_adjoint=.*#LOGICAL :: SU_adjoint=.$SU_adjoint.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=2) :: misfit_type=.*#CHARACTER (LEN=2) :: misfit_type='$misfit_type'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: Nmisfit=.*#INTEGER, PARAMETER :: Nmisfit=$Nmisfit #g"  $FILE > temp;  mv temp $FILE


   # INVERSION
   sed -e "s#^LOGICAL :: model_Vp=.*#LOGICAL :: model_Vp=.$model_Vp.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: model_Vs=.*#LOGICAL :: model_Vs=.$model_Vs.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: model_Rho=.*#LOGICAL :: model_Rho=.$model_Rho.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: scale_Rho_Vp=.*#LOGICAL :: scale_Rho_Vp=.$scale_Rho_Vp.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL ::use_rho_kappa_mu_kernel=.*#LOGICAL :: use_rho_kappa_mu_kernel=.$use_rho_kappa_mu_kernel.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: use_rhop_alpha_beta_kernel=.*#LOGICAL :: use_rhop_alpha_beta_kernel=.$use_rhop_alpha_beta_kernel.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: use_rhop_phip_betap_kernel=.*#LOGICAL :: use_rhop_phip_betap_kernel=.$use_rhop_phip_betap_kernel.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=2) :: opt_scheme=.*#CHARACTER (LEN=2) :: opt_scheme='$opt_scheme'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: CGSTEPMAX=.*#INTEGER, PARAMETER :: CGSTEPMAX=$CGSTEPMAX #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^CHARACTER (LEN=2) :: CG_scheme=.*#CHARACTER (LEN=2) :: CG_scheme='$CG_scheme'#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: BFGS_STEPMAX=.*#INTEGER, PARAMETER :: BFGS_STEPMAX=$BFGS_STEPMAX #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: initial_step_length=.*#DOUBLE PRECISION, PARAMETER :: initial_step_length=$initial_step_length #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: min_step_length=.*#DOUBLE PRECISION, PARAMETER :: min_step_length=$min_step_length #g" $FILE > temp;  mv temp $FILE                                                                                            
   sed -e "s#^INTEGER, PARAMETER :: max_step=.*#INTEGER, PARAMETER :: max_step=$max_step#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: backtracking=.*#LOGICAL :: backtracking=.$backtracking.#g"  $FILE > temp;  mv temp $FILE

   # POST-PROCESSING
   sed -e "s#^LOGICAL :: smooth=.*#LOGICAL :: smooth=.$smooth.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: smooth_x=.*#DOUBLE PRECISION, PARAMETER :: smooth_x=$smooth_x #g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^DOUBLE PRECISION, PARAMETER :: smooth_z=.*#DOUBLE PRECISION, PARAMETER :: smooth_z=$smooth_z #g"  $FILE > temp;  mv temp $FILE   
   sed -e "s#^LOGICAL :: precond=.*#LOGICAL :: precond=.$precond.#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^INTEGER, PARAMETER :: precond_type=.*#INTEGER, PARAMETER :: precond_type=$precond_type#g"  $FILE > temp;  mv temp $FILE
   sed -e "s#^LOGICAL :: mask_source=.*#LOGICAL :: mask_source=.$mask_source.#g"  $FILE > temp;  mv temp $FILE

### DISPLAY
   sed -e "s#^LOGICAL :: DISPLAY_DETAILS=.*#LOGICAL :: DISPLAY_DETAILS=.$DISPLAY_DETAILS.#g"  $FILE > temp;  mv temp $FILE

 
