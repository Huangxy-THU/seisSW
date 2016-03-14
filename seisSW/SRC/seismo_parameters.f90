module seismo_parameters
  
  implicit none
 
!----------------------------------------------------------------------
DOUBLE PRECISION, PARAMETER :: threshold=1.0e-30
CHARACTER (LEN=20) :: endian='big_endian'

!! model 
LOGICAL :: isotropy=.true.
LOGICAL :: attenuation=.false.
LOGICAL :: anisotropy=.false.

!! FORWARD MODELNG INFO
INTEGER, PARAMETER :: NSTEP=4800 
INTEGER, PARAMETER :: NX=40000 
DOUBLE PRECISION, PARAMETER :: deltat=0.06 
DOUBLE PRECISION, PARAMETER :: t0=0.0 
DOUBLE PRECISION, PARAMETER :: f0=0.084 
DOUBLE PRECISION, PARAMETER :: fmax=f0*2.5
INTEGER, PARAMETER :: NREC=2 
INTEGER, PARAMETER :: NSRC=1 

!! ADJOINT INFO

! PRE-PROCESSING
!DOUBLE PRECISION, PARAMETER :: tshift=0.0
!DOUBLE PRECISION, PARAMETER :: scaler=1.0
LOGICAL :: scaling=.false.
LOGICAL :: src_est=.false.
LOGICAL :: src_update_phase=.false.
LOGICAL :: src_update_amp=.false.
INTEGER, PARAMETER :: Wscale=0 
INTEGER, PARAMETER :: is_window=0
INTEGER, PARAMETER :: window_type=3
DOUBLE PRECISION, PARAMETER :: V_fast=4000 
DOUBLE PRECISION, PARAMETER :: V_slow=3000 
INTEGER, PARAMETER :: is_laplace=0
DOUBLE PRECISION, PARAMETER :: S_x=0
DOUBLE PRECISION, PARAMETER :: S_t=0
INTEGER, PARAMETER :: mute_near=0
DOUBLE PRECISION, PARAMETER :: offset_near=0
INTEGER, PARAMETER :: mute_far=0
DOUBLE PRECISION, PARAMETER :: offset_far=0
DOUBLE PRECISION, PARAMETER :: lambda_min=V_slow/fmax
DOUBLE PRECISION, PARAMETER :: lambda=V_slow/min(f0,1/(2.0*deltat)/2**Wscale)

! MISFIT
LOGICAL :: sensitivity=.false.
INTEGER, PARAMETER :: NC=4 !! three components (Ux,Uy,Uz,Up)
LOGICAL :: XCOMP=.false.
LOGICAL :: YCOMP=.true.
LOGICAL :: ZCOMP=.false.
LOGICAL :: PCOMP=.false.
CHARACTER (LEN=2) :: misfit_type='CC'
LOGICAL :: DD=.false.
DOUBLE PRECISION, PARAMETER :: DD_min=0
DOUBLE PRECISION, PARAMETER :: DD_max=0
LOGICAL :: HB=.false.
DOUBLE PRECISION, PARAMETER :: DD_weight=1.0
DOUBLE PRECISION, PARAMETER :: cc_threshold=0.9
LOGICAL :: SU_adjoint=.false.
INTEGER, PARAMETER :: Nmisfit=1 

 ! INVERSION
LOGICAL :: model_Vp=.false.
LOGICAL :: model_Vs=.true.
LOGICAL :: model_Rho=.false.
LOGICAL :: scale_Rho_Vp=.false.
LOGICAL :: use_rho_kappa_mu_kernel=.false.
LOGICAL :: use_rhop_alpha_beta_kernel=.true.
LOGICAL :: use_rhop_phip_betap_kernel=.false.
CHARACTER (LEN=2) :: opt_scheme='QN'
INTEGER, PARAMETER :: CGSTEPMAX=10
CHARACTER (LEN=2) :: CG_scheme='PR'
INTEGER, PARAMETER :: BFGS_STEPMAX=4
DOUBLE PRECISION, PARAMETER :: initial_step_length=0.04
INTEGER, PARAMETER :: max_step=10 
DOUBLE PRECISION, PARAMETER :: min_step_length=0.001 
LOGICAL :: backtracking=.false.

 ! POST-PROCESSING
LOGICAL :: smooth=.true.
DOUBLE PRECISION, PARAMETER :: smooth_x=20000 
DOUBLE PRECISION, PARAMETER :: smooth_z=20000 
LOGICAL :: precond=.false.
INTEGER, PARAMETER :: precond_type=2
LOGICAL :: mask_source=.false.
!!!!!!!!!!!!!!!!! not change !!!!!!!!!!!!!!!!!!!!!!    
  ! kernel/gradient/update_diretion rho, Vp, Vs dim 
  integer, parameter :: gndim = 5
  integer, parameter :: gdim_x = 1    
  integer, parameter :: gdim_z = 2
  integer, parameter :: gdim_rho = 3
  integer, parameter :: gdim_vp = 4
  integer, parameter :: gdim_vs = 5
  ! model rho, Vp, Vs dim 
  integer, parameter :: mndim = 6
  integer, parameter :: mdim_index = 1
  integer, parameter :: mdim_x = 2
  integer, parameter :: mdim_z = 3   
  integer, parameter :: mdim_rho = 4
  integer, parameter :: mdim_vp = 5
  integer, parameter :: mdim_vs = 6
  integer, parameter :: mdim_QKappa = 1
  integer, parameter :: mdim_Qmu = 2
  integer, parameter :: mdim_epsilon = 1
  integer, parameter :: mdim_delta = 2



!! DISPLAY 
LOGICAL :: DISPLAY_DETAILS=.true.
!----------------------------------------------------------------------
end module seismo_parameters
