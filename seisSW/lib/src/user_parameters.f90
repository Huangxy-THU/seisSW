  module user_parameters
 
  !===================================================================
  ! filter parameters for xapiir subroutine (filter type is BP)
  double precision, parameter :: TRBDNDW = 0.3
  double precision, parameter :: APARM = 30.0
  integer, parameter :: IORD = 5
  integer, parameter :: PASSES = 2

  ! -------------------------------------------------------------
  ! array dimensions
  ! note that some integer arrays (iM,iL,iR) are NWINDOWS * NWINDOWS
  ! THESE SHOULD PROBABLY BE USER PARAMETERS, SINCE THEY WILL AFFECT
  ! THE SPEED OF THE PROGRAM (ALTHOUGH NOT THE OUTPUT).
  integer, parameter :: NDIM = 10000
  integer, parameter :: NWINDOWS = 2500

  ! -------------------------------------------------------------
  ! miscellaneous - do not modify!
  ! -------------------------------------------------------------

  ! mathematical constants
  double precision, parameter :: PI = 3.1415926535897
  double precision, parameter :: E  = 2.7182818284590

  ! filter types
  integer, parameter :: HANNING = 1
  integer, parameter :: HAMMING = 2
  integer, parameter :: COSINE  = 3


  ! modified constants 

  ! add by YY
  ! constants
  double precision, parameter :: TWOPI = 2.0 * PI
  complex*16, parameter :: CCI = cmplx(0.,1.)
  double precision, parameter :: LARGE_VAL = 1.0d8
  ! phase correction control parameters, set this between (PI, 2PI),
  ! use a higher value for conservative phase wrapping
  double precision, parameter :: PHASE_STEP = 1.5 * PI
  ! FFT parameters
  integer, parameter :: LNPT = 13, NPT = 2**LNPT
  double precision, parameter :: FORWARD_FFT = 1.0
  double precision, parameter :: REVERSE_FFT = -1.0
  ! CUTOFF for phase unwrapping 
  double precision, parameter :: CUTOFF = PI
  ! water level for effective spectrum 
  double precision, parameter :: WTR = 0.05
  ! water level for mtm 
  double precision, parameter ::  wtr_mtm = 1.e-10
  ! multitaper
  double precision, parameter :: mt_threshold = 0.9  ! eigenvalue threshold
!  integer, parameter :: MW = 10 ! number of segments of uncorrelated frequency points 
  double precision, parameter :: NW = 3
  integer, parameter :: NTAPER =  int(2*NW-1)
  ! error estimation 
  logical :: USE_ERROR_CC = .false.
 ! minimum error for dt and dlnA
  double precision, parameter :: DT_SIGMA_MIN = 1.0
  double precision, parameter :: DLNA_SIGMA_MIN = 0.5
  logical :: USE_ERROR_MT = .false.
  ! taper power 
  integer :: ipwr_w =10 
  ! CG orhtogonality threshold for conscutive gradients
  double precision, parameter :: CG_threshold = 0.1

  ! WT parameters 
  integer, parameter :: nvm = 6
  character(len=500) :: WT_directory='./WT_basis'
 
  ! gradient rho, Vp, Vs dim 
  integer, parameter :: gdim_rho = 3
  integer, parameter :: gdim_vp = 4
  integer, parameter :: gdim_vs = 5
  ! model rho, Vp, Vs dim 
  integer, parameter :: mdim_rho = 4
  integer, parameter :: mdim_vp = 5
  integer, parameter :: mdim_vs = 6

  ! Display 
  logical :: DISPLAY_DETAILS = .false.
  character(len=500) :: output_dir='OUTPUT_FILES' 
  ! -------------------------------------------------------------

  end module user_parameters

