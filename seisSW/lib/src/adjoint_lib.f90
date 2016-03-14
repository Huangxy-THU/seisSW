
!! main subroutines to evaluate misfit and ajoint source
!! created by Yanhua O. Yuan ( yanhuay@princeton.edu)
!! copyright

!----------------------------------------------------------------------
subroutine misfit_adj_AD(misfit_type,d,s,NSTEP,deltat,f0,ntstart,ntend,&
           window_type,compute_adjoint, &
           misfit_output,adj)
!! conventional way to do tomography, 
!! using absolute-difference measurements of data(d) and syn (s)

use user_parameters
implicit none

  ! inputs & outputs 
  character(len=2), intent(in) :: misfit_type
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat,f0
  integer, intent(in) :: NSTEP,ntstart,ntend,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj

  double precision, dimension(NSTEP) :: f_tw,fp_tw,fq_tw

  ! initialization within loop of irec
    f_tw(:)=0.d0
    fp_tw(:)=0.d0
    fq_tw(:)=0.d0
    misfit_output=0.d0
    adj(1:NSTEP)=0.d0

! misfit and adjoint
select case (misfit_type)
   case ("CC")
      if(DISPLAY_DETAILS) print*, 'CC (traveltime) misfit (s-d)'
      call CC_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
           window_type,compute_adjoint, &
           misfit_output, f_tw)
           adj(1:NSTEP)=f_tw(1:NSTEP)
   case ("WD")
      if(DISPLAY_DETAILS) print*, 'WD (waveform-difference) misfit (s-d)'
      call WD_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
           window_type,compute_adjoint,&
           misfit_output,f_tw)
           adj(1:NSTEP)=f_tw(1:NSTEP)
   case ("ET")
      if(DISPLAY_DETAILS) print*, 'ET (envelope cc-traveltime) misfit (s-d)'
     ! call ET_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
     !      window_type,compute_adjoint,&
     !      misfit_output,f_tw)
           adj(1:NSTEP)=f_tw(1:NSTEP)
   case ("ED")
      if(DISPLAY_DETAILS) print*, 'ED (envelope-difference) misfit (s-d)'
      call ED_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
           window_type,compute_adjoint,&
           misfit_output,f_tw)
           adj(1:NSTEP)=f_tw(1:NSTEP)      
   case ("IP")
       if(DISPLAY_DETAILS) print*, 'IP (instantaneous phase) misfit (s-d)'
      call IP_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
           window_type,compute_adjoint,&
           misfit_output,f_tw)
           adj(1:NSTEP)=f_tw(1:NSTEP)
   case ("MT")
      if(DISPLAY_DETAILS) print*, 'MT (multitaper traveltime) misfit (d-s)'
      call MT_misfit(d,s,NSTEP,deltat,f0,ntstart,ntend,&
           window_type,compute_adjoint,&
           misfit_output,fp_tw,fq_tw)
           adj(1:NSTEP)=fp_tw(1:NSTEP)
   case ("MA")
      if(DISPLAY_DETAILS) print*, 'MA (multitaper amplitude) misfit (d-s)'
      call MT_misfit(d,s,NSTEP,deltat,ntstart,ntend,&
           window_type,compute_adjoint,&
           misfit_output,fp_tw,fq_tw)
           adj(1:NSTEP)=fq_tw(1:NSTEP)
  case default
      print*, 'misfit_type must be among "CC"/"WD"/"ET"/"ED"/"IP"/"MT"/"MA"/...';
      stop
end select


end subroutine misfit_adj_AD
!------------------------------------------------------------------------
!------------------------------------------------------------------------
subroutine misfit_adj_DD(misfit_type,d,d_ref,s,s_ref,NSTEP,deltat,f0,&
           ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
           misfit_output,adj,adj_ref)
!! relative way to do tomography, 
!! using double-difference measurements of data(d) and ref data(d_ref);
!! syn (s) and ref syn(s_ref)
use user_parameters
implicit none

  ! inputs & outputs 
  character(len=2), intent(in) :: misfit_type
  double precision, dimension(*), intent(in) :: d,s,d_ref,s_ref
  double precision, intent(in) :: deltat,f0
  integer, intent(in) :: NSTEP,ntstart,ntend,ntstart_ref,ntend_ref,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj,adj_ref

  double precision, dimension(NSTEP) :: fp_tw,fp_ref_tw,fq_tw,fq_ref_tw
  double precision :: cc_max_obs,cc_max_syn

  ! initialization within loop of irec
    fp_tw(:)=0.d0
    fp_ref_tw(:)=0.d0
    fq_tw(:)=0.d0
    fq_ref_tw(:)=0.d0
    misfit_output=0.d0
    adj(1:NSTEP)=0.d0
    adj_ref(1:NSTEP)=0.d0

select case (misfit_type)
   case ("CC")
      if(DISPLAY_DETAILS) print*, '*** Double-difference CC (traveltime) misfit'
      call CC_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output,fp_tw,fp_ref_tw)
   case ("WD")
      if(DISPLAY_DETAILS) print*, '*** Double-difference WD (waveform) misfit'
      call WD_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output,fp_tw,fp_ref_tw)
   case ("MT")
      if(DISPLAY_DETAILS) print*, '*** Double-difference MT (multitaper) misfit'
      call MT_misfit_DD(d,d_ref,s,s_ref,NSTEP,deltat,f0,&
            ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output,fp_tw,fp_ref_tw,fq_ref_tw,fq_ref_tw)

  case default
      print*, 'misfit_type must be among "CC"/"WD"/"MT" ...';
      stop

end select

!! return 
adj(1:NSTEP)=fp_tw(1:NSTEP)
adj_ref(1:NSTEP)=fp_ref_tw(1:NSTEP)

end subroutine misfit_adj_DD
!------------------------------------------------------------------------

!----------------------------------------------------------------------
!---------------subroutines for misfit_adjoint-------------------------
!-----------------------------------------------------------------------
subroutine WD_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
           misfit_output, adj)
!! waveform difference between d and s
!! misfit_output = sqrt( \int (s-d)**2 dt )
!! adj = s-d
use user_parameters
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart, i_tend 
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj

  ! index 
  integer :: i

  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw
  ! adjoint
  double precision, dimension(npts) ::  adj_tw

!! window
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen
!nlen=npts
!d_tw(1:nlen)=d(1:npts)
!s_tw(1:nlen)=s(1:npts)

!! WD misfit
       misfit_output = sqrt(sum((s_tw(1:nlen)-d_tw(1:nlen))**2*deltat))
     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries : ',i_tstart,i_tend
     print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_syn',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        do  i = i_tstart,i_tend
            write(1,'(I5,2e15.5)') i, d(i),s(i)
        enddo
        do  i = 1,nlen
            write(2,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
        enddo
        close(1)
        close(2)
      endif

!! WD adjoint
  if(COMPUTE_ADJOINT) then
     adj_tw(1:nlen) =  s_tw(1:nlen)-d_tw(1:nlen)
    ! reverse window and taper again 
 call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)
!    adj(1:npts)=adj_tw(1:nlen)    !YY

   if( DISPLAY_DETAILS) then
    open(1,file=trim(output_dir)//'/adj_wd_win',status='unknown')
    do  i =  i_tstart,i_tend
    write(1,'(I5,e15.5)') i,adj(i)
    enddo
    close(1)
    endif

  endif

end subroutine WD_misfit

!-----------------------------------------------------------------------
subroutine CC_misfit(d,s,npts,deltat,i_tstart, i_tend,window_type,compute_adjoint,&
            misfit_output, adj)
!! CC traveltime shift between d and s
!! misfit_output = T(s)- T(d) 
!! adj = misfit_output * vel(s) / Mtr 

use user_parameters
implicit none 

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart, i_tend
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj

  ! index
  integer :: i

  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw 
  ! cc 
  integer :: ishift
  double precision :: tshift, dlnA, cc_max 
  ! adjoint
  double precision :: Mtr
  double precision, dimension(npts) :: s_tw_vel, adj_tw 

  
!! window
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check i_start,i_tend, nlen ',i_tstart,i_tend,nlen

!! cc misfit
call xcorr_calc(s_tw,d_tw,npts,1,nlen,ishift,dlnA,cc_max) ! T(s-d)

!if (cc_max<=0.8) then 
!    cc_max=0.0
!endif

       tshift = ishift*deltat  
       misfit_output = tshift * cc_max

     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries : ',i_tstart,i_tend
     print*, 'time window length (sample /  second) : ', nlen, nlen*deltat
     print*, 'cc ishift/tshift/dlnA of s-d : ', ishift,tshift,dlnA
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
        enddo
        close(1)
      endif

!! cc adjoint
  if(COMPUTE_ADJOINT) then
  ! computer velocity 
  call compute_vel(s_tw,npts,deltat,nlen,s_tw_vel)

    ! constant on the bottom 
    Mtr=-sum(s_tw_vel(1:nlen)*s_tw_vel(1:nlen))*deltat

    ! adjoint source
      adj_tw(1:nlen)=  tshift*s_tw_vel(1:nlen)/Mtr * cc_max**2
    ! reverse window and taper again 
 call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)


   if( DISPLAY_DETAILS) then
    open(1,file=trim(output_dir)//'/adj_cc_win',status='unknown')
    do  i =  i_tstart,i_tend
    write(1,'(I5,e15.5)') i,adj(i)
    enddo
    close(1)
    endif

endif

end subroutine CC_misfit

! -----------------------------------------------------------------------
subroutine ET_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
           misfit_output, adj)
!! Envelope time shift between d and s
!! misfit_output =  time_shift**2 
!! E_ratio = tshift / Mtr * s_vel / Es
!! adj = E_ratio *s - Hilbt(E_ratio*Hilbt(s))

use user_parameters
use m_hilbert_transform
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart,i_tend
  integer, intent(in) :: npts, window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj

  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw

  ! for hilbert transformation
  double precision :: epslon
  double precision, dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio,hilbt_d,hilbt_s
  
  ! adjoint
  integer :: i
  double precision, dimension(npts) :: adj_tw
  double precision, dimension(npts) :: seism_vel
  double precision :: Mtr

  ! cc 
  integer :: ishift
  double precision :: tshift, dlnA, cc_max


!! window
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen


!! Envelope time_shift misfit
       ! initialization 
       E_s(:) = 0.0
       E_d(:) = 0.0
       E_ratio(:) = 0.0
       hilbt_ratio (:) = 0.0
       hilbt_d(:) = 0.0
       hilbt_s(:) = 0.0

       ! hilbert transform of d
       hilbt_d(1:nlen) = d(1:nlen)
       call hilbert(hilbt_d,nlen)
       ! envelope
       E_d(1:nlen) = sqrt(d(1:nlen)**2+hilbt_d(1:nlen)**2)

       ! hilbert for s
       hilbt_s(1:nlen) = s(1:nlen)
       call hilbert(hilbt_s,nlen)
       ! envelope
       E_s(1:nlen) = sqrt(s(1:nlen)**2+hilbt_s(1:nlen)**2)

       ! misfit
       call xcorr_calc(E_s,E_d,nlen,1,nlen,ishift,dlnA,cc_max) ! T(Es-Ed)
        tshift = (ishift*deltat)
        misfit_output = tshift


     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries : ',i_tstart,i_tend
     print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_env',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
            write(2,'(I5,2e15.5)') i, E_d(i),E_s(i)
        enddo
        close(1)
        close(2)
      endif

!! Envelope time_shift adjoint
  if(COMPUTE_ADJOINT) then

     ! computer velocity 
     call compute_vel(E_s,npts,deltat,nlen,seism_vel)

     ! constant factor
       Mtr=-sum(seism_vel(1:nlen)*seism_vel(1:nlen))*deltat

       ! E_ratio
       epslon=0.05*maxval(abs(E_s(1:nlen)),1)
       E_ratio(1:nlen) =  tshift /Mtr*seism_vel(1:nlen)/(E_s(1:nlen)+epslon)

       ! hilbert transform for E_ratio*hilbt
       hilbt_ratio=E_ratio * hilbt_s
       call hilbert(hilbt_ratio,nlen)

       ! adjoint source
       adj_tw(1:nlen)=E_ratio(1:nlen)*s(1:nlen)-hilbt_ratio(1:nlen)

     if( DISPLAY_DETAILS) then
        open(1,file=trim(output_dir)//'/E_ratio',status='unknown')
        print*
        print*, 'water level for E_ratio is : ', epslon
        do  i = 1,nlen
            write(1,'(I5,2e15.5)') i,E_ratio(i),hilbt_ratio(i)
        enddo
        close(1)
      endif

    ! reverse window and taper again 
    call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

     if( DISPLAY_DETAILS) then
        open(1,file='OUTPUTS/adj_win',status='unknown')
        do  i = i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
        enddo
        close(1)
      endif

   endif

end subroutine ET_misfit

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
subroutine ED_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
           misfit_output, adj)
!! Envelope difference between d and s
!! misfit_output = sqrt(\int (Es-Ed)**2 dt ) 
!! E_ratio = (Es-Ed) / Es
!! adj = E_ratio *s - Hilbt(E_ratio*Hilbt(s))

use user_parameters
use m_hilbert_transform
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart,i_tend
  integer, intent(in) :: npts, window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj

  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw

  ! for hilbert transformation
  double precision :: epslon
  double precision, dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio,hilbt_d,hilbt_s

  ! adjoint
  integer :: i
  double precision, dimension(npts) :: adj_tw


!! window
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen
!! YY oct-2015: remove window
!nlen=npts
!d_tw(1:nlen)=d(1:npts)
!s_tw(1:nlen)=s(1:npts)

!! Envelope difference misfit
       ! initialization 
       E_s(:) = 0.0
       E_d(:) = 0.0
       E_ratio(:) = 0.0
       hilbt_ratio (:) = 0.0
       hilbt_d(:) = 0.0
       hilbt_s(:) = 0.0

       ! hilbert transform of d
       hilbt_d(1:nlen) = d_tw(1:nlen)
       call hilbert(hilbt_d,nlen)
       ! envelope
       E_d(1:nlen) = sqrt(d_tw(1:nlen)**2+hilbt_d(1:nlen)**2)

       ! hilbert for s
       hilbt_s(1:nlen) = s_tw(1:nlen)
       call hilbert(hilbt_s,nlen)
       ! envelope
       E_s(1:nlen) = sqrt(s_tw(1:nlen)**2+hilbt_s(1:nlen)**2) 

       ! misfit
       misfit_output = sqrt(sum((E_s(1:nlen)-E_d(1:nlen))**2*deltat))

     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries : ',i_tstart,i_tend
     print*, 'time window length : ', nlen
        open(1,file=trim(output_dir)//'/dat_env',status='unknown')
        open(2,file=trim(output_dir)//'/syn_env',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,2e15.5)') i, d_tw(i),E_d(i)
            write(2,'(I5,2e15.5)') i, s_tw(i),E_s(i)
        enddo
        close(1)
        close(2)
      endif

!! Envelope difference adjoint
  if(COMPUTE_ADJOINT) then

       ! E_ratio
       epslon=0.05*maxval(E_s,1)
       E_ratio(1:nlen)=(E_s(1:nlen)-E_d(1:nlen))/(E_s(1:nlen)+epslon)

       ! hilbert transform for E_ratio*hilbt
       hilbt_ratio=E_ratio * hilbt_s
       call hilbert(hilbt_ratio,nlen)

       ! adjoint source
       adj_tw(1:nlen)=E_ratio(1:nlen)*s_tw(1:nlen)-hilbt_ratio(1:nlen)

     if( DISPLAY_DETAILS) then
  !      open(1,file=trim(output_dir)//'/E_ratio',status='unknown')
  !      print*
  !      print*, 'water level for E_ratio is : ', epslon
  !      do  i = 1,nlen
  !          write(1,'(I5,2e15.5)') i,E_ratio(i),hilbt_ratio(i)
  !      enddo
  !      close(1)
      endif

    ! reverse window and taper again 
    call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)
! adj(1:npts)=adj_tw(1:nlen)
     if( DISPLAY_DETAILS) then
        open(1,file=trim(output_dir)//'/adj_win',status='unknown')
        do  i = i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
        enddo
        close(1)
      endif

   endif

end subroutine ED_misfit

!-----------------------------------------------------------------------
subroutine IP_misfit(d,s,npts,deltat,i_tstart,i_tend,window_type,compute_adjoint,&
           misfit_output, adj)
!! Instantaneous phase difference between d and s (need to be fixed)
!! misfit_output = sqrt(\int (Phi_diff)**2 dt ) 
!! E_ratio = Phi_diff / Es
!! adj = E_ratio * Hilbt(s) - Hilbt(E_ratio*s)

use user_parameters
use m_hilbert_transform
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart,i_tend
  integer, intent(in) :: npts, window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj


  ! index 
  integer :: i
 
  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw

  ! for hilbert transformation
  double precision :: epslon, wtr_d, wtr_s
  double precision, dimension(npts) :: E_d,E_s,E_ratio,hilbt_ratio
  double precision, dimension(npts) :: hilbt_d, hilbt_s, real_diff, imag_diff

  ! adjoint
  double precision, dimension(npts) :: adj_tw


!! window
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

!! Instantaneous phase misfit
       ! initialization 
       real_diff(:) = 0.0
       imag_diff(:) = 0.0
       E_d(:) = 0.0
       E_s(:) = 0.0 
       E_ratio(:) = 0.0
       hilbt_ratio (:) = 0.0
       hilbt_d(:)=0.0
       hilbt_s(:)=0.0


       !! be careful about phase measurement -- cycle-skipping

       !! hilbert for obs
       hilbt_d(1:nlen)=d_tw(1:nlen)
       call hilbert(hilbt_d,nlen)
       E_d(1:nlen)=sqrt(hilbt_d(1:nlen)**2+d_tw(1:nlen)**2)

       !! hilbert for syn
       hilbt_s(1:nlen)=s_tw(1:nlen)
       call hilbert(hilbt_s,nlen)
       E_s(1:nlen)=sqrt(hilbt_s(1:nlen)**2+s_tw(1:nlen)**2)


       !! removing amplitude info 
        wtr_d=0.05*maxval(E_d)
        wtr_s=0.05*maxval(E_s)

       !! diff for real & imag part 
       real_diff= s_tw(1:nlen)/(E_s(1:nlen)+wtr_s) - d_tw(1:nlen)/(E_d(1:nlen)+wtr_d)
       imag_diff= hilbt_s(1:nlen)/(E_s(1:nlen)+wtr_s) - hilbt_d(1:nlen)/(E_d(1:nlen)+wtr_d)


       ! misfit
       misfit_output = sqrt(sum((real_diff(1:nlen))**2*deltat) + sum((imag_diff(1:nlen))**2*deltat))

     if(DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries : ',i_tstart,i_tend
     print*, 'time window length : ', nlen
        open(1,file='OUTPUTS/dat_syn_win',status='unknown')
        open(2,file='OUTPUTS/phi_diff',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,2e15.5)') i, d_tw(i),s_tw(i)
            write(2,'(I5,2e15.5)') i, real_diff(i), imag_diff(i)
        enddo
        close(1)
        close(2)
      endif


!! Instantaneous phase adjoint
  if(COMPUTE_ADJOINT) then
       ! E_ratio
       epslon=0.05*maxval(E_s)
       E_ratio = real_diff*(E_s**2-s_tw**2)/(E_s+epslon)**3
       hilbt_ratio = imag_diff*(hilbt_s**2-E_s**2)/(E_s+epslon)**3 

       ! hilbert transform for hilbt_ratio
       call hilbert(hilbt_ratio,nlen)

       ! adjoint source
       adj_tw(1:nlen)=E_ratio(1:nlen) + hilbt_ratio

    ! reverse window and taper again 
    call cc_window_inverse(adj_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj)

     if(DISPLAY_DETAILS) then
        open(1,file='OUTPUTS/adj_win',status='unknown')
        do  i = i_tstart,i_tend
            write(1,'(I5,e15.5)') i,adj(i)
        enddo
        close(1)
      endif

   endif


end subroutine IP_misfit



!-----------------------------------------------------------------------
subroutine MT_misfit(d,s,npts,deltat,f0,i_tstart, i_tend,window_type,compute_adjoint,&
            misfit_output, adj_p, adj_q)
!! MT between d and s (d-s) 
use user_parameters
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d,s
  double precision, intent(in) :: deltat,f0
  integer, intent(in) :: i_tstart,i_tend
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj_p, adj_q

  ! index
  integer :: i,j
  ! window
  integer :: nlen
  double precision, dimension(npts) :: d_tw,s_tw, d_tw_cc
  ! cc 
  integer :: ishift
  double precision :: tshift, dlnA, cc_max
  double precision :: err_dt_cc=0.0,err_dlnA_cc=1.0

  ! FFT parameters
  double precision, dimension(NPT) :: wvec,fvec
  double precision :: df,df_new,dw

  ! mt 
  integer :: i_fstart, i_fend
!  double precision ::B,W, NW
!  integer :: ntaper,mtaper
!  double precision, dimension(NPT) :: eigens, ey2
!  double precision, dimension(:,:),allocatable :: tas
  double precision, dimension(NPT) :: dtau_w, dlnA_w,err_dtau_mt,err_dlnA_mt
  complex*16, dimension(NPT) :: trans_func

  ! adjoint
  double precision, dimension(npts) :: adj_p_tw,adj_q_tw


!! window
 ishift = 0 
 dlnA = 0.0
call cc_window(s,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,s_tw)
call cc_window(d,npts,window_type,i_tstart,i_tend,0,0.d0,nlen,d_tw)
if(nlen<1 .or. nlen>npts) print*,'check nlen ',nlen

!! cc correction
call xcorr_calc(d_tw,s_tw,npts,1,nlen,ishift,dlnA,cc_max) ! T(d-s)
tshift= ishift*deltat
     if( DISPLAY_DETAILS) then
     print*
     print*, 'xcorr_cal: d-s'
     print*, 'xcorr_calc: calculated ishift/tshift = ', ishift,tshift
     print*, 'xcorr_calc: calculated dlnA = ',dlnA
     print*, 'xcorr_calc: cc_max ',cc_max
     endif

!! cc_error
if(USE_ERROR_CC)  call cc_error(d_tw,s_tw,npts,deltat,nlen,ishift,dlnA,&
                                err_dt_cc,err_dlnA_cc)

! correction for d using negative cc
! fixed window for s, correct the window for d
dlnA =0.0
 call cc_window(d,npts,window_type,i_tstart,i_tend,-ishift,-dlnA,nlen,d_tw_cc)

     if( DISPLAY_DETAILS) then
     print*
     print*, 'CC corrections to data using negative ishift/tshift/dlnA: ',-ishift,-tshift,-dlnA
        open(1,file=trim(output_dir)//'/dat_syn_datcc',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,3e15.5)') i, d_tw(i),s_tw(i),d_tw_cc(i)
        enddo
        close(1)
      endif

d_tw = d_tw_cc

!! MT misfit
    !-----------------------------------------------------------------------------
    !  set up FFT for the frequency domain
    !----------------------------------------------------------------------------- 
     df = 1./(NPT*deltat)
     dw = TWOPI * df
    ! calculate frequency spacing of sampling points
    df_new = 1.0 / (nlen*deltat)
    ! assemble omega vector (NPT is the FFT length)
    wvec(:) = 0.
    do j = 1,NPT
      if(j > NPT/2+1) then
        wvec(j) = dw*(j-NPT-1)   ! negative frequencies in second half
      else
        wvec(j) = dw*(j-1)       ! positive frequencies in first half
      endif
    enddo
    fvec = wvec / TWOPI

 !!   find the relaible frequency limit
   call frequency_limit(s_tw,nlen,deltat,i_fstart,i_fend) ! limit from spectra
    i_fend = min(i_fend, floor(1.0/(2*deltat)/df)+1,floor(f0*2.5/df)+1)  ! not exceeding the sampling rate
    i_fstart = max(i_fstart,ceiling(3.0/(nlen*deltat)/df)+1,ceiling(f0/2.5/df)+1) ! include at least 5 cyles in window

   if( DISPLAY_DETAILS) then
    print*
    print*, 'find the spectral boundaries for reliable measurement'
    print*, 'min, max frequency limits : ', i_fstart, i_fend
    print*, 'frequency interval df= ', df, ' dw=', dw
    print*, 'effective bandwidth (Hz) : ',fvec(i_fstart), fvec(i_fend), fvec(i_fend)-fvec(i_fstart)
    print*, 'half time-bandwidth product : ', NW
    print*, 'number of tapers : ',ntaper
    print*, 'resolution of multitaper (Hz) : ', NW/(nlen*deltat)
    print*, 'number of segments of frequency bandwidth : ', ceiling((fvec(i_fend)-fvec(i_fstart))*nlen*deltat/NW)
    endif


     ! effective bandwidth 
!!     B = (i_fend-i_fstart)*dw 
   
 !! define multitaper parameters
     ! (half) frequency resolution (some fraction of B)
!!     W = 0.5 * B / MW
     
     ! half time-bandwidth product
!!     NW = nlen * deltat * W
     !NW = 2.5 
     !W = NW /(nlen*deltat)
 
     ! number of tapers (try)
!!     ntaper = int(2*NW)

    ! assign number of tapers
!!    allocate(tas(NPT,ntaper))

    ! calculate the tapers
!!     call staper(nlen, NW, ntaper, tas, NPT, eigens, ey2)

    ! find all tapers with eigenvalues greater than mt_threshold 
!!    mtaper = 0
!!   do i=1,ntaper
!!       if(eigens(i)>=mt_threshold) mtaper = i
!!    enddo


 !! mt phase and ampplitude measurement 
     call mt_measure(d_tw,s_tw,npts,deltat,nlen,tshift,dlnA,i_fstart,i_fend,&
                     wvec,&!mtaper,NW,&
                     trans_func,dtau_w,dlnA_w,err_dtau_mt,err_dlnA_mt) !d-s
     misfit_output=sqrt(sum((dtau_w(i_fstart:i_fend))**2*dw)) * cc_max

  if(DISPLAY_DETAILS) then
   !! write into file 
    open(1,file=trim(output_dir)//'/dtau_mtm',status='unknown')
    open(2,file=trim(output_dir)//'/dlnA_mtm',status='unknown')
    do  i = i_fstart,i_fend
    write(1,'(3e15.5)') fvec(i),dtau_w(i),tshift !err_dtau_mt(i)
    write(2,'(3e15.5)') fvec(i),dlnA_w(i),dlnA !err_dlnA_mt(i)
    enddo
    close(1)
    close(2)
   endif



!! MT adjoint
  if(COMPUTE_ADJOINT) then

   ! adjoint source
  call mtm_adj(s_tw,npts,deltat,nlen,df,i_fstart,i_fend,dtau_w,dlnA_w,&
             err_dt_cc,err_dlnA_cc,&
             err_dtau_mt,err_dlnA_mt, &
            ! mtaper,NW,&
             adj_p_tw,adj_q_tw)

     adj_p_tw(1:nlen) = adj_p_tw(1:nlen) * cc_max**2
     adj_q_tw(1:nlen) = adj_q_tw(1:nlen) * cc_max**2

    ! inverse window and taper again 
 call cc_window_inverse(adj_p_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj_p)
 call cc_window_inverse(adj_q_tw,npts,window_type,i_tstart,i_tend,0,0.d0,adj_q)

   if( DISPLAY_DETAILS) then
    open(1,file=trim(output_dir)//'/adj_p_win',status='unknown')
    open(2,file=trim(output_dir)//'/adj_q_win',status='unknown')
    do  i =  i_tstart,i_tend
    write(1,'(I5,e15.5)') i,adj_p(i)
    write(2,'(I5,e15.5)') i,adj_q(i)
    enddo
    close(1)
    close(2)
    endif

endif

!deallocate (tas)

end subroutine MT_misfit

! -----------------------------------------------------------------------

!-----------------------------------------------------------------------
subroutine CC_misfit_DD(d1,d2,s1,s2,npts,deltat,&
           i_tstart1,i_tend1,i_tstart2,i_tend2,&
            window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output, adj1,adj2)
!! CC traveltime shift between d and s
!! misfit_output = \Delta T(s1,s2) - \Delta T(d1,d2) 
!! \Delta T(s1,s2) = T(s1) - T(s2) 
!! \Delta T(d1,d2) = T(d1) - T(d2)
!! adj1 = misfit_output * vel(s2_cc) / Mtr 
!! adj2 = - misfit_output * vel(s1_cc) / Mtr 

use user_parameters
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d1,d2,s1,s2
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart1,i_tend1,i_tstart2,i_tend2
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: cc_max_syn,cc_max_obs
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj1,adj2

  ! index
  integer :: i

  ! window
  integer :: nlen1,nlen2,nlen
  double precision, dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
  ! cc 
  integer :: ishift_obs,ishift_syn
  double precision :: tshift_obs,tshift_syn
  double precision :: dlnA_obs,dlnA_syn
  double precision :: ddtshift_cc,ddlnA_cc
  ! adjoint
  double precision :: Mtr
  double precision, dimension(npts) :: s1_tw_cc,s2_tw_cc
  double precision, dimension(npts) :: s1_tw_vel,s2_tw_vel,s1_tw_cc_vel,s2_tw_cc_vel
  double precision, dimension(npts) :: adj1_tw,adj2_tw


!! window
call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
nlen = max(nlen1,nlen2)
!! DD cc-misfit
call xcorr_calc(d1_tw,d2_tw,npts,1,nlen,ishift_obs,dlnA_obs,cc_max_obs) ! T(d1-d2)
       tshift_obs= ishift_obs*deltat
call xcorr_calc(s1_tw,s2_tw,npts,1,nlen,ishift_syn,dlnA_syn,cc_max_syn) ! T(s1-s2)
       tshift_syn= ishift_syn*deltat
!! double-difference cc-measurement 
ddtshift_cc = tshift_syn - tshift_obs
ddlnA_cc = dlnA_syn - dlnA_obs
misfit_output = ddtshift_cc * cc_max_obs


     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
     print*, 'time window length for d1/s1 : ', nlen1
     print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
     print*, 'time window length for d2/s2 : ', nlen2
     print*, 'cc ishift/tsfhit/dlnA (d1-d2): ', ishift_obs,tshift_obs,dlnA_obs
     print*, 'cc ishift/tshift/dlnA (s1-s2): ', ishift_syn,tshift_syn,dlnA_syn
     print*, 'cc double-difference ddtshift/ddlnA of (s1-s2)-(d1-d2): ', ddtshift_cc,ddlnA_cc
     print*, 'cc_max_obs, cc_max_syn : ',cc_max_obs, cc_max_syn 
     print*
        open(1,file=trim(output_dir)//'/dat_syn_win',status='unknown')
        open(2,file=trim(output_dir)//'/dat_syn_ref_win',status='unknown')
        do  i = 1,nlen1
            write(1,'(I5,2e15.5)') i, d1_tw(i),s1_tw(i)
        enddo
        do i =1,nlen2
            write(2,'(I5,2e15.5)') i, d2_tw(i),s2_tw(i)
        enddo
        close(1)
        close(2)
    endif

!!DD cc-adjoint
  if(COMPUTE_ADJOINT) then
! initialization 
adj1_tw(:) = 0.0
adj2_tw(:) = 0.0
adj1(1:npts) = 0.0 
adj2(1:npts) = 0.0

  ! cc-shift s2
  call cc_window(s2,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,nlen2,s2_tw_cc)
  ! inverse cc-shift s1
  call cc_window(s1,npts,window_type,i_tstart1,i_tend1,-ishift_syn,0.d0,nlen1,s1_tw_cc)
     if( DISPLAY_DETAILS) then
        open(1,file=trim(output_dir)//'/syn1_cc',status='unknown')
        open(2,file=trim(output_dir)//'/syn2_cc',status='unknown')
        do  i = 1,nlen
            write(1,'(I5,3e15.5)') i,s2_tw(i),s1_tw(i),s1_tw_cc(i)
            write(2,'(I5,3e15.5)') i,s1_tw(i),s2_tw(i),s2_tw_cc(i)
        enddo
        close(1)
        close(2)
      endif


  ! computer velocity 
  call compute_vel(s1_tw,npts,deltat,nlen,s1_tw_vel)
!  call compute_vel(s2_tw,npts,deltat,nlen,s2_tw_vel)
  call compute_vel(s1_tw_cc,npts,deltat,nlen,s1_tw_cc_vel)
  call compute_vel(s2_tw_cc,npts,deltat,nlen,s2_tw_cc_vel)

  ! constant on the bottom 
  Mtr=-sum(s1_tw_vel(1:nlen)*s2_tw_cc_vel(1:nlen))*deltat
 ! Mtr=- sqrt(sum(s1_tw_vel(1:nlen)**2)*deltat) * sqrt(sum(s2_tw_vel(1:nlen)**2)*deltat)

    ! adjoint source
       adj1_tw(1:nlen)= ddtshift_cc * s2_tw_cc_vel(1:nlen)/Mtr * cc_max_obs * cc_max_obs
       adj2_tw(1:nlen)= -ddtshift_cc * s1_tw_cc_vel(1:nlen)/Mtr * cc_max_obs * cc_max_obs

 !      adj1_tw(1:nlen)= ddtshift_cc *  s1_tw_vel(1:nlen)/Mtr
 !      adj2_tw(1:nlen)= -ddtshift_cc * s2_tw_vel(1:nlen)/Mtr

    ! reverse window and taper again 
 call cc_window_inverse(adj1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
 call cc_window_inverse(adj2_tw,npts,window_type,i_tstart2,i_tend2,0,0.d0,adj2)

   if( DISPLAY_DETAILS) then
    open(1,file=trim(output_dir)//'/adj_win',status='unknown')
    open(2,file=trim(output_dir)//'/adj_ref_win',status='unknown')
    do  i =  i_tstart1,i_tend1
    write(1,*) i,adj1(i)
    enddo
    do  i =  i_tstart2,i_tend2
    write(2,*) i,adj2(i)
    enddo
    close(1)
    close(2)
    endif


endif


end subroutine CC_misfit_DD

!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
subroutine WD_misfit_DD(d1,d2,s1,s2,npts,deltat,&
           i_tstart1,i_tend1,i_tstart2,i_tend2,&
            window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output, adj1,adj2)
!! waveform difference between d and s

use user_parameters
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d1,d2,s1,s2
  double precision, intent(in) :: deltat
  integer, intent(in) :: i_tstart1,i_tend1,i_tstart2,i_tend2
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: cc_max_syn,cc_max_obs
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: adj1,adj2

  ! index
  integer :: i

  ! window
  integer :: nlen1,nlen2,nlen
  double precision, dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
  ! adjoint
  double precision, dimension(npts) :: adj1_tw,adj2_tw


!! window
call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
nlen = max(nlen1,nlen2)
!! DD wd-misfit
!! double-difference wd-measurement 
misfit_output = sqrt(sum(((s1_tw(1:nlen)-s2_tw(1:nlen)) - (d1_tw(1:nlen)-d2_tw(1:nlen)))**2*deltat))


     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
     print*, 'time window length for d1/s1 : ', nlen1
     print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
     print*, 'time window length for d2/s2 : ', nlen2
    endif

!!DD wd-adjoint
  if(COMPUTE_ADJOINT) then
! initialization 
adj1_tw(:) = 0.0
adj2_tw(:) = 0.0
adj1(1:npts) = 0.0
adj2(1:npts) = 0.0


    ! adjoint source
       adj1_tw(1:nlen)=  (s1_tw(1:nlen)-s2_tw(1:nlen)) -(d1_tw(1:nlen)-d2_tw(1:nlen))
       adj2_tw(1:nlen)=  - adj1_tw(1:nlen)


    ! reverse window and taper again 
 call cc_window_inverse(adj1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,adj1)
 call cc_window_inverse(adj2_tw,npts,window_type,i_tstart2,i_tend2,0,0.d0,adj2)

endif


end subroutine WD_misfit_DD

!----------------------------------------------------------------------



subroutine MT_misfit_DD(d1,d2,s1,s2,npts,deltat,f0,&
            i_tstart1,i_tend1,i_tstart2,i_tend2,&
            window_type,compute_adjoint,&
            cc_max_obs,cc_max_syn,misfit_output, fp1,fp2,fq1,fq2)
!! multitaper double-difference adjoint 
use user_parameters
implicit none

  ! inputs & outputs 
  double precision, dimension(*), intent(in) :: d1,d2,s1,s2
  double precision, intent(in) :: deltat,f0
  integer, intent(in) :: i_tstart1, i_tend1,i_tstart2,i_tend2
  integer, intent(in) :: npts,window_type
  logical, intent(in) :: compute_adjoint
  double precision, intent(out) :: cc_max_syn,cc_max_obs
  double precision, intent(out) :: misfit_output
  double precision, dimension(*),intent(out),optional :: fp1,fp2,fq1,fq2

  ! index
  integer :: i,j

  ! window
  integer :: nlen1,nlen2,nlen
  double precision, dimension(npts) :: d1_tw,d2_tw,s1_tw,s2_tw
  ! cc 
  integer :: ishift_obs,ishift_syn
  double precision :: tshift_obs,tshift_syn
  double precision :: dlnA_obs,dlnA_syn
  double precision :: ddtshift_cc,ddlnA_cc
  double precision :: err_dt_cc_obs=1.0,err_dt_cc_syn=1.0
  double precision :: err_dlnA_cc_obs=1.0,err_dlnA_cc_syn=1.0
  double precision, dimension(npts) :: d2_tw_cc,s2_tw_cc

  ! FFT parameters
  double precision, dimension(NPT) :: wvec,fvec
  double precision :: df,df_new,dw

  ! mt 
  integer :: i_fstart1, i_fend1,i_fstart2, i_fend2,i_fstart, i_fend
!  double precision, dimension(NPT) :: eigens, ey2
!  double precision, dimension(:,:),allocatable :: tas
  double precision, dimension(NPT) :: dtau_w_obs,dtau_w_syn
  double precision, dimension(NPT) :: dlnA_w_obs, dlnA_w_syn
  double precision, dimension(NPT) :: ddtau_w, ddlnA_w
  double precision, dimension(NPT) :: err_dtau_mt_obs,err_dtau_mt_syn
  double precision, dimension(NPT) :: err_dlnA_mt_obs, err_dlnA_mt_syn
  complex*16, dimension(NPT) :: trans_func_obs,trans_func_syn
  ! variance 
  !double precision, dimension(NPT) :: var_trans_obs, var_trans_syn

  ! adjoint
  double precision, dimension(npts) :: fp1_tw,fp2_tw,fq1_tw,fq2_tw


!! window
call cc_window(d1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,d1_tw)
call cc_window(s1,npts,window_type,i_tstart1,i_tend1,0,0.d0,nlen1,s1_tw)
call cc_window(d2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,d2_tw)
call cc_window(s2,npts,window_type,i_tstart2,i_tend2,0,0.d0,nlen2,s2_tw)
if(nlen1<1 .or. nlen1>npts) print*,'check nlen1 ',nlen1
if(nlen2<1 .or. nlen2>npts) print*,'check nlen2 ',nlen2
nlen =max(nlen1,nlen2)

!! cc correction
call xcorr_calc(d1_tw,d2_tw,npts,1,nlen,ishift_obs,dlnA_obs,cc_max_obs)
tshift_obs= ishift_obs*deltat 
call xcorr_calc(s1_tw,s2_tw,npts,1,nlen,ishift_syn,dlnA_syn,cc_max_syn) 
tshift_syn= ishift_syn*deltat
!! double-difference cc-measurement 
ddtshift_cc = tshift_syn - tshift_obs
ddlnA_cc = dlnA_syn - dlnA_obs


if(USE_ERROR_CC) then
!! cc_error 
call cc_error(d1_tw,d2_tw,npts,deltat,nlen,ishift_obs,dlnA_obs,err_dt_cc_obs,err_dlnA_cc_obs)
call cc_error(s1_tw,s2_tw,npts,deltat,nlen,ishift_syn,dlnA_syn,err_dt_cc_syn,err_dlnA_cc_syn)
endif

! correction for d2 using positive cc
! fixed window for d1, correct the window for d2
 dlnA_obs = 0.0
 dlnA_syn = 0.0
 call cc_window(d2,npts,window_type,i_tstart2,i_tend2,ishift_obs,dlnA_obs,nlen2,d2_tw_cc)
 call cc_window(s2,npts,window_type,i_tstart2,i_tend2,ishift_syn,dlnA_syn,nlen2,s2_tw_cc)
     if( DISPLAY_DETAILS) then
     print*
     print*, 'time-domain winodw'
     print*, 'time window boundaries for d1/s1: ',i_tstart1,i_tend1
     print*, 'time window length for d1/s1 : ', nlen1
     print*, 'time window boundaries for d2/s2: ',i_tstart2,i_tend2
     print*, 'time window length for d2/s2 : ', nlen2
     print*, 'combined window length nlen = ',nlen
     print*, 'cc ishift/tshift/dlnA of (d1-d2): ', ishift_obs,tshift_obs,dlnA_obs
     print*, 'cc ishift/tshift/dlnA of (s1-s2): ', ishift_syn,tshift_syn,dlnA_syn
     print*, 'cc double-difference ddtshift/ddlnA of (s1-s2)-(d1-d2): ' &
              ,ddtshift_cc, ddlnA_cc
     print* 
        open(2,file=trim(output_dir)//'/dat_datcc',status='unknown')
        open(3,file=trim(output_dir)//'/syn_syncc',status='unknown')
        do  i = 1,nlen
            write(2,'(I5,3e15.5)') i, d1_tw(i),d2_tw(i),d2_tw_cc(i)
            write(3,'(I5,3e15.5)') i, s1_tw(i),s2_tw(i),s2_tw_cc(i)
        enddo
        close(2)
        close(3)
      endif

!! DD multitaper-misfit

    !-----------------------------------------------------------------------------
    !  set up FFT for the frequency domain
    !----------------------------------------------------------------------------- 
     df = 1./(NPT*deltat)
     dw = TWOPI * df
    ! calculate frequency spacing of sampling points
    df_new = 1.0 / (nlen*deltat)
    ! assemble omega vector (NPT is the FFT length)
    wvec(:) = 0.
    do j = 1,NPT
      if(j > NPT/2+1) then
        wvec(j) = dw*(j-NPT-1)   ! negative frequencies in second half
      else
        wvec(j) = dw*(j-1)       ! positive frequencies in first half
      endif
    enddo
    fvec = wvec / TWOPI

 !!   find the relaible frequency limit
   call frequency_limit(s1_tw,nlen,deltat,i_fstart1,i_fend1)
   call frequency_limit(s2_tw,nlen,deltat,i_fstart2,i_fend2)
    i_fend = min(i_fend1,i_fend2,floor(1.0/(2*deltat)/df)+1,floor(f0*2.5/df)+1)
    i_fstart = max(i_fstart1,i_fstart2, ceiling(3.0/(nlen*deltat)/df)+1,ceiling(f0/2.5/df)+1)

     
   if( DISPLAY_DETAILS) then
    print*
    print*, 'find the spectral boundaries for reliable measurement'
    print*, 'min, max frequency limit for 1 : ', fvec(i_fstart2),fvec(i_fend1)
    print*, 'min, max frequency limit for 2 : ', fvec(i_fstart2),fvec(i_fend2)
    print*, 'effective bandwidth (Hz) : ',fvec(i_fstart),fvec(i_fend),fvec(i_fend)-fvec(i_fstart)
    print*, 'half time-bandwidth product : ', NW
    print*, 'number of tapers : ',ntaper
    print*, 'resolution of multitaper (Hz) : ', NW/(nlen*deltat)
    print*, 'number of segments of frequency bandwidth : ', ceiling((fvec(i_fend)-fvec(i_fstart))*nlen*deltat/NW)
    print*
    endif



 !! define multitaper parameters
     ! (half) frequency resolution (segments of B)
!!     W = 0.5 * B / MW

     ! half time-bandwidth product
!!     NW = nlen * deltat * W

     ! number of tapers (try)
!!     ntaper = int(2*NW)

    ! assign number of tapers
!!    allocate(tas(NPT,ntaper))

    ! calculate the tapers
!!     call staper(nlen, NW, ntaper, tas, NPT, eigens, ey2)

    ! find all tapers with eigenvalues greater than mt_threshold 
!!    mtaper = 0
!!    do i=1,ntaper
!!       if(eigens(i)>=mt_threshold) mtaper = i
!!   enddo


 !! mt phase and ampplitude measurement 
     call mt_measure(d1_tw,d2_tw_cc,npts,deltat,nlen,tshift_obs,dlnA_obs,i_fstart,i_fend,&
                     wvec,&
                     !mtaper,NW,&
                     trans_func_obs,dtau_w_obs,dlnA_w_obs,err_dtau_mt_obs,err_dlnA_mt_obs)
     call mt_measure(s1_tw,s2_tw_cc,npts,deltat,nlen,tshift_syn,dlnA_syn,i_fstart,i_fend,&
                     wvec,&
                     !mtaper,NW,&
                     trans_func_syn,dtau_w_syn,dlnA_w_syn,err_dtau_mt_syn,err_dlnA_mt_syn)
 ! double-difference measurement 
   ddtau_w = dtau_w_syn-dtau_w_obs
   ddlnA_w = dlnA_w_syn-dlnA_w_obs
 ! misfit
   misfit_output = sqrt(sum((ddtau_w(i_fstart:i_fend))**2*dw)) * cc_max_obs

  if(DISPLAY_DETAILS) then
   !! write into file 
    open(1,file=trim(output_dir)//'/trans_func_obs',status='unknown')
    open(2,file=trim(output_dir)//'/trans_func_syn',status='unknown')
    open(3,file=trim(output_dir)//'/ddtau_mtm',status='unknown')
    open(4,file=trim(output_dir)//'/ddlnA_mtm',status='unknown')
    open(5,file=trim(output_dir)//'/err_dtau_dlnA_mtm',status='unknown')
    do  i = i_fstart,i_fend
    write(1,'(f15.5,e15.5)') fvec(i),abs(trans_func_obs(i))
    write(2,'(f15.5,e15.5)') fvec(i),abs(trans_func_syn(i))
    write(3,'(f15.5,2e15.5)') fvec(i),ddtau_w(i),ddtshift_cc
    write(4,'(f15.5,2e15.5)') fvec(i),ddlnA_w(i),ddlnA_cc
    write(5,'(f15.5,2e15.5)') fvec(i),err_dtau_mt_obs(i)*err_dtau_mt_syn(i), &
                       err_dlnA_mt_obs(i)*err_dlnA_mt_syn(i)
    enddo
    close(1)
    close(2)
    close(3)
    close(4)
    close(5)
   endif


!!DD cc-adjoint
  if(COMPUTE_ADJOINT) then
! initialization 
fp1(1:npts) = 0.0
fp2(1:npts) = 0.0
fq1(1:npts) = 0.0
fq2(1:npts) = 0.0

call mtm_DD_adj(s1_tw,s2_tw_cc,NPTS,deltat,nlen,df,i_fstart,i_fend,ddtau_w,ddlnA_w,&
             err_dt_cc_obs,err_dt_cc_syn,err_dlnA_cc_obs,err_dlnA_cc_syn, &
             err_dtau_mt_obs,err_dtau_mt_syn,err_dlnA_mt_obs,err_dlnA_mt_syn, &
             !ntaper,NW,&
             fp1_tw,fp2_tw,fq1_tw,fq2_tw)
    ! adjoint source
       fp1_tw(1:nlen)= fp1_tw(1:nlen) * cc_max_obs *cc_max_obs
       fp2_tw(1:nlen)= fp2_tw(1:nlen) * cc_max_obs *cc_max_obs
       fq1_tw(1:nlen)= fq1_tw(1:nlen) * cc_max_obs *cc_max_obs
       fq2_tw(1:nlen)= fq2_tw(1:nlen) * cc_max_obs *cc_max_obs

    ! reverse window and taper again 
 call cc_window_inverse(fp1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,fp1)
 call cc_window_inverse(fp2_tw,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,fp2)
 call cc_window_inverse(fq1_tw,npts,window_type,i_tstart1,i_tend1,0,0.d0,fq1)
 call cc_window_inverse(fq2_tw,npts,window_type,i_tstart2,i_tend2,ishift_syn,0.d0,fq2)

   if( DISPLAY_DETAILS) then
    open(1,file=trim(output_dir)//'/adj_win',status='unknown')
    open(2,file=trim(output_dir)//'/adj_ref_win',status='unknown')
    do  i =  i_tstart1,i_tend1
    write(1,*) i,fp1(i)
    enddo
    do  i =  i_tstart2,i_tend2
    write(2,*) i,fp2(i)
    enddo
    close(1)
    close(2)
    endif

endif ! compute_adjoint 

!  deallocate(tas)

end subroutine MT_misfit_DD

!-----------------------------------------------------------------------
