   program misfit_adjoint
!!! to calculate adjoint source and misfit

use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! READ paramteres
! compute adjoint?
LOGICAL :: compute_adjoint

! modification to syn 
 double precision :: dotproduct,power_obs, power_syn, factor
 double precision, dimension(NSTEP) :: time, wavelet, wavelet_shift
 double precision :: trunk

 ! window
 double precision :: dis_sr1,dis_sr2,dis_sc,dis_rr,dis_rr_s
 integer, dimension(NREC) :: win_start,win_end
 integer :: ntstart,ntend
 integer :: ntstart_ref,ntend_ref
 integer :: nlen, nlen_ref 
 double precision, dimension(NSTEP) :: d,d_ref,s,s_ref,delete_syn
 double precision :: Sr, Sr_ref
 ! cluster analysis
 double precision :: cc_max,cc_max_obs,cc_max_syn
 double precision :: similarity
 integer, dimension(NREC,NREC) :: is_pair
 integer :: num_AD,num_DD

 ! misfit
 double precision :: misfit_output
 double precision :: sum_misfit,sum_misfit_DD
 double precision :: sumsum_misfit
 

 ! constants and indicies
 integer :: irec,jrec,itime,icomp,ios,i,j
 integer :: it, itime_shift, ishift
 ! SU data sets
 !! NOTE :: SU dataset is in single precision
 integer(kind=4),dimension(:,:),allocatable :: r4head 
 real(kind=4),dimension(:),allocatable :: obs,syn 
 double precision,dimension(:,:,:),allocatable :: seismic_obs,seismic_syn,seismic_shift
 character(len=150), dimension(NREC) :: station_name, network_name
 double precision, dimension(NREC) :: xr=0.0, zr=0.0
 double precision :: stele,stbur
 double precision :: xs=0.0, zs=0.0

! adjoint source
 double precision, dimension(NSTEP) :: adj, adj_ref
 double precision, dimension(:,:), allocatable :: adjoint,adjoint_DD
 
! component
character(len=2) :: comp_data(NC)
character(len=3) :: comp_adj(NC)

! filenames
character(len=512) :: filename,filename_obs,filename_syn
character(len=512) :: adj_source_file 
character(len=512) :: fname
logical :: ex1,ex2,ex
character(len=10)   :: arg


! get input parameters
    j=1; call getarg(j,arg); read(arg,*) compute_adjoint

! allocate resources
    allocate(seismic_obs(NSTEP,NREC,NC))
    allocate(seismic_syn(NSTEP,NREC,NC))
    allocate(seismic_shift(NSTEP,NREC,NC))
    allocate(obs(NSTEP))
    allocate(syn(NSTEP))
    allocate(r4head(60,NREC))
    allocate(adjoint(NSTEP,NREC))
    allocate(adjoint_DD(NSTEP,NREC))


! filename
   comp_data=(/"Ux","Uy","Uz","Up"/)
   comp_adj=(/"BXX","BXY","BXZ","PRE"/)


!! read source location 
    filename='DATA/for_information_SOURCE_actually_used'
    OPEN (UNIT=1,FILE= filename,STATUS='OLD',action='read',iostat=ios)
     if(ios>0) then
        print*,'Error opening file. File load status:', ios
        stop
     else
         read(1,*) xs,zs
     end if
      close(1)
 !  if(DISPLAY_DETAILS) print*, 'source location : ',xs,zs

!! read receiver location 
    filename='DATA/STATIONS'
    OPEN (UNIT=1,FILE= filename,STATUS='OLD',action='read',iostat=ios)
     if(ios>0) then
        print*,'Error opening file. File load status:', ios
        stop
     else
         do irec=1,NREC ! trace loop
         read(1,*) station_name(irec),network_name(irec),xr(irec),zr(irec),stele,stbur
         enddo
     end if
      close(1)
!   if(DISPLAY_DETAILS) print*, 'receiver location : ', xr,zr

    do itime=2,NSTEP
            time(itime)=(itime-1)*deltat-t0
    enddo  


!! load  data and preprocessing 
! intialization 
   seismic_obs(:,:,:)=0.0
   seismic_syn(:,:,:)=0.0
 ! loop over comp
 do icomp=1,NC
    obs(:)=0.0
    syn(:)=0.0
    d(:)=0.0
    s(:)=0.0

    ! open files
    filename_obs = 'DATA_obs/'//trim(comp_data(icomp))//'_file_single_processed.su'
    filename_syn = 'DATA_syn/'//trim(comp_data(icomp))//'_file_single_processed.su'

   ! if existence
   inquire (file=trim(filename_obs), exist=ex1)
   inquire (file=trim(filename_syn), exist=ex2)

   ! if file exist, then load and do preprocessing 
   if (ex1 .and. ex2) then

   if(DISPLAY_DETAILS .and. compute_adjoint) then
      print*
      print*,'>>>> load data/syn'
      print*, 'icomp --- ',comp_data(icomp)
   endif

   open(unit=1,file=trim(filename_obs),status='old',form='unformatted',&
         access='direct',recl=240+4*NSTEP,iostat = ios)
          if (ios /= 0)then
                 print*, 'file '//trim(filename_obs)//' does not exist'
                 stop
           endif
   open(unit=2,file=trim(filename_syn),status='old',form='unformatted',&
         access='direct',recl=240+4*NSTEP,iostat = ios)
          if (ios /= 0)then
                 print*, 'file '//trim(filename_syn)//' does not exist'
                 stop
           endif

 if(compute_adjoint) then
    write(fname,'(I2)') Wscale
    filename='DATA_obs/'//trim(comp_data(icomp))//'_scale'//trim(adjustl(fname))//'.bin'
    open(unit=1001,file=trim(filename),status='unknown',access='direct',recl=4*NSTEP)
    filename='DATA_syn/'//trim(comp_data(icomp))//'_scale'//trim(adjustl(fname))//'.bin'
    open(unit=1002,file=trim(filename),status='unknown',access='direct',recl=4*NSTEP)
 endif

   ! loop over trace
  do irec=1,NREC
     read(1,rec=irec,iostat=ios) r4head(:,irec),obs(:)
          if (ios /= 0)then
                 print*, 'fail to read '//trim(filename_obs)// ' -- irec=',irec
                ! stop
           endif
     read(2,rec=irec,iostat=ios) r4head(:,irec),syn(:)
          if (ios /= 0)then
                 print*, 'fail to read '//trim(filename_syn)//' -- irec=',irec
                 stop
           endif

  ! information from header 
  xs=r4head(19,irec)
  xr(irec)=r4head(21,irec)  

  if(DISPLAY_DETAILS) then
             print*,'irec -- ',irec
             print*,'xs / xr -- ', xs,xr(irec)
             print*,'min/max obs -- ', minval(obs),maxval(obs)
             print*,'min/max syn -- ', minval(syn),maxval(syn)
  endif 

  ! geometry
     dis_sr1 = sqrt((xr(irec)-xs)**2+(zr(irec)-zs)**2)

  ! get data 
    d(:)=dble(obs(:))
    s(:)=dble(syn(:))

!! preprocessing 
!! only non-null traces are processed
    if(sum(abs(d),1)>threshold) then
       ! do preprocessing to get processed d and s
       call preprocess(d,NSTEP,deltat,t0,f0,&
            is_laplace,dis_sr1,S_x,S_t, &
            is_window,window_type,V_slow,V_fast,&
            mute_near,offset_near,mute_far,offset_far,&
            Wscale,&
            ntstart,ntend)
       call preprocess(s,NSTEP,deltat,t0,f0,&
            is_laplace,dis_sr1,S_x,S_t, &
            is_window,window_type,V_slow,V_fast,&
            mute_near,offset_near,mute_far,offset_far,&
            Wscale,&
            ntstart,ntend)
            win_start(irec)=ntstart
            win_end(irec)=ntend

    endif !! threshold

  ! square-root compensation for 3D geometry spreading
  if(scaling)  d = d * sqrt(time)

  !! save 
  if(compute_adjoint) then
      write(1001,rec=irec) sngl(d)
      write(1002,rec=irec) sngl(s)
  endif
  seismic_obs(:,irec,icomp) = d(:)
  seismic_syn(:,irec,icomp) = s(:)

  enddo  ! irec

  ! close files
  close(1)
  close(2)  
  if(compute_adjoint)  close(1001)
  if(compute_adjoint)  close(1002)

 endif !  file exist

enddo  ! icomp
!! end of loading  data and preprocessing


!! source inversion  (find optimal shift and scale factor)
if(src_est .and. compute_adjoint) then
   if(DISPLAY_DETAILS) then
      print*
      print*,'>>>> source inversion'
   endif

  ! initialization
     ishift=0
     factor=1.0  
     cc_max=0.0
     ishift=0

  if (src_update_phase) then
! global shift and scale 
  do it = -600, 600, 10 ! find optimal it shift
     dotproduct=0.0
     seismic_shift(:,:,:)=0.0

   do itime=1,NSTEP
      itime_shift=itime-it
      if(itime_shift>=1 .and. itime_shift<=NSTEP) then
         seismic_shift(itime_shift,:,:)=seismic_syn(itime,:,:)
      endif
   enddo
 
 ! dot product
   do icomp=1,NC 
   do irec=1,NREC
     dotproduct=dotproduct+dot_product(seismic_shift(:,irec,icomp),seismic_obs(:,irec,icomp))
   enddo
   enddo

  if(dotproduct>cc_max) then
      cc_max=dotproduct
      ishift=it
       if(DISPLAY_DETAILS) write(*,'(a,I5,1x f15.5)') 'cc ', ishift,cc_max
   endif

 enddo ! it shift

! shift syn
   seismic_shift(:,:,:)=0.0
   do itime=1,NSTEP
      itime_shift=itime-ishift
      if(itime_shift>=1 .and. itime_shift<=NSTEP) then
         seismic_shift(itime_shift,:,:)=seismic_syn(itime,:,:)
      endif
   enddo
    seismic_syn = seismic_shift
 endif ! src_update_phase

  if (src_update_amp) then
  ! scale factor
   power_obs=0.0
   power_syn=0.0
  do icomp=1,NC
  do irec=1,NREC
     power_obs=power_obs+dot_product(abs(seismic_obs(:,irec,icomp)),abs(seismic_syn(:,irec,icomp))) ! +norm2(seismic_obs(:,irec,icomp))**2
     power_syn=power_syn+dot_product(abs(seismic_syn(:,irec,icomp)),abs(seismic_syn(:,irec,icomp)))
  enddo
  enddo  
  factor=power_obs/power_syn
  ! scale syn 
  seismic_syn= seismic_syn * factor
 endif  ! src_update_amp

  if (DISPLAY_DETAILS) then
     write(*,'(a,I5,1x,f15.5, 1x f15.5)') 'optimal time shift/scaleing is ', ishift,ishift*deltat,factor
  endif

  do icomp=1,NC
    !! only save non-zero shot gather 
    power_syn=0.0
    power_syn=sum(abs(seismic_syn(:,:,icomp)))
    if(power_syn>threshold) then
      filename='DATA_syn/'//trim(comp_data(icomp))//'_scale'//trim(adjustl(fname))//'_src.bin'
      open(unit=1002,file=trim(filename),status='unknown',access='direct',recl=4*NSTEP)
    
     do irec=1,NREC 
        write(1002,rec=irec) sngl(seismic_syn(:,irec,icomp))
     enddo
      close(1002)
    endif
  enddo 

! update source wavelet
 open(unit=1,file='DATA/wavelet.txt',status='old',iostat=ios)
 if (ios /= 0)then
      print*, 'fail to read DATA/wavelet.txt'
      stop
 endif
 do itime=1,NSTEP 
   read(1,*) trunk, wavelet(itime)
 enddo
 close(1) 

   ! shift and scale wavelet 
   wavelet_shift(:)=0.0
   do itime=1,NSTEP
      itime_shift=itime-ishift
      if(itime_shift>1 .and. itime_shift<=NSTEP) then
         wavelet_shift(itime_shift)=wavelet(itime)*factor
      endif
   enddo

  open(unit=1,file='DATA/src.txt')  
  do itime=1,NSTEP
     write(1,'(2e15.5)') time(itime), wavelet_shift(itime)
  enddo 
  close(1)

endif  ! src_est


!!!!!!!!!!!!!!!!!!!!! adjoint source calculation !!!!!!!!!!!!!!!!!!!!!!
  sumsum_misfit=0.d0 ! sum over all comp

  ! component loop
  do icomp = 1, NC
    ! initialization within component loop
    num_AD = 0
    num_DD = 0
    sum_misfit=0.0     ! sum over trace
    sum_misfit_DD=0.0  ! sum over trace for DD
    adjoint(:,:)=0.0
    adjoint_DD(:,:)=0.0

!! nonly consider non-zero shot gather 
power_obs=0.0
power_obs=sum(abs(seismic_obs(:,:,icomp)))
if(power_obs>threshold) then

!! read similarity file for DD
  if(DD) then 
    ! initialization
    cc_max_obs=0.0
    cc_max_syn=0.0 
    is_pair(:,:)=0

    filename = 'DATA_obs/'//trim(comp_data(icomp))//'.similarity.dat'
    
   ! if existence, read, otherwise, write 
    inquire (file=trim(filename), exist=ex)
    OPEN (UNIT=10, FILE=filename,iostat=ios)
    do while(ios==0)    
            read(10,*,iostat=ios) irec,jrec,cc_max_obs,is_pair(irec,jrec)
    enddo
  endif

!!!!!!!!!!!!!!!!!!!!!!!!! misfit and adjoint !!!!!!!!!!!!!!!!!!!!! 
 if(DISPLAY_DETAILS .and. compute_adjoint) then
   print*
   print*,'>>>> misfit and adjoint'
   print*, 'icomp --- ',comp_data(icomp)
   print*, 'DD  --- ', DD
   print*, 'wavelet scale --- ',Wscale
 endif

 ! loop over irec trace
  do irec = 1,NREC
  ! initialization within loop of irec
    d(:)=0.d0
    s(:)=0.d0
    misfit_output=0.d0
    adj(:)=0.d0
 
  ! get data 
    d(:)=seismic_obs(:,irec,icomp)
    s(:)=seismic_syn(:,irec,icomp)

     dis_sr1 = sqrt((xr(irec)-xs)**2+(zr(irec)-zs)**2)

    ! window info
    ntstart = win_start(irec)
    ntend= win_end(irec) 
    Sr=0.0
    if(ntstart<ntend)  then
      nlen=ntend-ntstart+1
      Sr=sum(abs(d(ntstart:ntend)),1)
    endif
      
!! only non-null traces are evaluated
if(Sr>threshold) then
! ----------------------------------------------------------------
!! single station adjoint method 
if (.not. DD) then
    ! number of absolute difference measurements
    num_AD = num_AD+1
    call misfit_adj_AD(misfit_type,d,s,NSTEP,deltat,f0,ntstart,ntend,&
           window_type,compute_adjoint, &
           misfit_output,adj)

      if(sensitivity .and. abs(misfit_output)>=threshold) then
            !adj(:)=(mod(irec,2)*2-1)*adj(:)/misfit_output
            adj(:)=adj(:)/misfit_output
      endif 
     if(DISPLAY_DETAILS .and. compute_adjoint) then
        print*,'irec=',irec
        print*,'window -- ', ntstart,ntend
        print*,misfit_type ,' absolute measurement =',misfit_output
     endif

    ! sum of misfit over all stations
      sum_misfit=sum_misfit+misfit_output**2

   if(compute_adjoint) then
   !! re-processing of adj 
!    call preprocess(adj,NSTEP,deltat,t0,f0,&
!            is_laplace,dis_sr1,S_x,S_t, &
!            is_window,window_type,V_slow,V_fast,&
!            mute_near,offset_near,mute_far,offset_far,&
!            Wscale,ntstart,ntend)
    ! sum of adjoint source 
      adjoint(:,irec) = adjoint(:,irec) + adj(:)
    endif
 

! ----------------------------------------------------------------
!! double difference adjoint method
elseif(DD) then

 !! hybrid
 if(HB) then
    ! number of absolute difference measurements
    num_AD = num_AD+1
    call misfit_adj_AD(misfit_type,d,s,NSTEP,deltat,f0,ntstart,ntend,&
           window_type,compute_adjoint, &
           misfit_output,adj)

   ! for sensitivity, remove measurement
    if(sensitivity .and. abs(misfit_output)>=threshold) then 
          adj(:)=adj(:)/misfit_output
    endif

     if(DISPLAY_DETAILS .and. compute_adjoint) then
        print*
        print*,'irec=',irec
        print*,'window -- ', ntstart,ntend
        print*,misfit_type ,' absolute measurement =',misfit_output
     endif

    ! sum of misfit over all stations
      sum_misfit=sum_misfit+misfit_output**2

   if(compute_adjoint) then
   !! re-processing of adj 
!    call preprocess(adj,NSTEP,deltat,t0,f0,&
!            is_laplace,dis_sr1,S_x,S_t, &
!            is_window,window_type,V_slow,V_fast,&
!            mute_near,offset_near,mute_far,offset_far,&
!            Wscale,ntstart,ntend)
    ! sum of adjoint source 
      adjoint(:,irec) = adjoint(:,irec) + adj(:)
   endif

  endif !! HB

! loop over reference station
   do jrec=irec+1,NREC
! initialization within loop
    d_ref(:)=0.d0
    s_ref(:)=0.d0
    adj(:)=0.d0
    adj_ref(:)=0.d0
    misfit_output=0.d0
    cc_max_obs=0.d0
    cc_max_syn=0.d0
    similarity=0.0 

    ! get data
     d_ref(:)=seismic_obs(:,jrec,icomp)
     s_ref(:)=seismic_syn(:,jrec,icomp)

    ! geometry info
     dis_rr=sqrt((xr(jrec)-xr(irec))**2+(zr(jrec)-zr(irec))**2)
     dis_sc=sqrt(((xr(jrec)+xr(irec))*0.5-xs)**2+((zr(jrec)+zr(irec))*0.5-zs)**2)
     dis_sr2 = sqrt((xr(jrec)-xs)**2+(zr(jrec)-zs)**2)

    ! window info
    ntstart_ref = win_start(jrec)
    ntend_ref= win_end(jrec)
    Sr_ref=0.0
    if(ntstart_ref<ntend_ref)  then
      nlen_ref=ntend_ref-ntstart_ref+1
      Sr_ref=sum(abs(d_ref(ntstart_ref:ntend_ref)),1)
    endif


 !  if(DISPLAY_DETAILS) then 
 !    print*
 !    print*, 'time-domain winodw for master trace -- ',irec
 !    print*, 'time window boundaries : ',ntstart,ntend
 !    print*, 'time window length : ', nlen*deltat, nlen
 !    print*, 'time-domain winodw for reference trace -- ',jrec
 !    print*, 'time window boundaries : ',ntstart_ref, ntend_ref
 !    print*, 'time window length : ', nlen_ref*deltat, nlen_ref
 !  endif

    !! only non-null reference traces are evaluated
  if(Sr_ref>threshold) then

     !! similarity
   if(.not. ex) then
   ! if(.not. ex .and. dis_rr>=lambda_min .and. dis_rr<=sqrt(lambda*dis_sc)) then
   ! if(.not. ex .and. dis_rr<=DD_max .and. dis_rr>=DD_min) then
   !  if(.not. ex .and. dis_rr<=sqrt(lambda*dis_sc)) then
   !  if(.not. ex  &                                
   !     .and. dis_rr<=DD_max .and. dis_rr<=2*sqrt(lambda*dis_sc) &             ! upper bound
   !     .and. dis_rr>=DD_min .and. dis_rr>=lambda_min) then                    ! lower bound
      call CC_similarity(d,d_ref,NSTEP,&
                ntstart,ntend,ntstart_ref,ntend_ref,window_type,cc_max_obs)
    !  call CC_similarity(s,s_ref,NSTEP,&
    !            ntstart,ntend,ntstart_ref,ntend_ref,window_type,cc_max_syn)
     ! similarity = cc_max_obs*cc_max_syn
      if(cc_max_obs>CC_threshold) then  !! second criterion
           is_pair(irec,jrec) = 1
      endif

         if(DISPLAY_DETAILS .and. compute_adjoint) then
           print*
           print*,'pair irec=',irec, ' jrec=',jrec
           print*,'window -- ', ntstart,ntend,ntstart_ref,ntend_ref
          ! print*,'receiver spacing : ', dis_rr
          ! print*,'lower bound DD_min/lambda_min/quater Fresnel : ', &
          !         DD_min,lambda_min,0.25*sqrt(lambda*dis_sc)
          ! print*,'upper bound DD_max/twice Fresnel : ',DD_max,2*sqrt(lambda*dis_sc)
          ! print*, 'time window length (irec,jrec) : ', nlen*deltat, nlen_ref*deltat
           print*, 'similarity : ', cc_max_obs
           print*, 'is_pair : ',is_pair(irec,jrec)
          endif
   endif !! compute similarity 

  !! do double-difference
  if(is_pair(irec,jrec)==1) then
    ! number of double difference measurements
    num_DD = num_DD+1
    call misfit_adj_DD(misfit_type,d,d_ref,s,s_ref,NSTEP,deltat,f0,&
           ntstart,ntend,ntstart_ref,ntend_ref,window_type,compute_adjoint,&
           misfit_output,adj,adj_ref)

  !!regularization 
!    adj(:)=adj(:) !*cc_max_obs
!    misfit_output = misfit_output !*cc_max_obs

   !! derivative double-difference
!     dis_weight=max(0,1-(dis_rr/c)**a)
!    adj(:)=adj(:)*(dis_weight**2)
!    adj_ref(:)=adj_ref(:)*(dis_weight**2) 
!    misfit_output = misfit_output*dis_weight

   ! for sensitivity, remove measurement
    if(sensitivity .and. abs(misfit_output)>=threshold) then 
          adj(:)=adj(:)/misfit_output
          adj_ref(:)=adj_ref(:)/misfit_output
    endif


     if(DISPLAY_DETAILS .and. compute_adjoint) then
        print* 
        print*,'pair irec=',irec, ' jrec=',jrec
        print*,misfit_type ,' relative (DD) measurement =',misfit_output
     endif

     ! sum of misfit over all stations
     sum_misfit_DD=sum_misfit_DD+ misfit_output**2
 
   if(compute_adjoint) then 
   !! re-processing of adj 
!    call preprocess(adj,NSTEP,deltat,t0,f0,&
!            is_laplace,dis_sr1,S_x,S_t, &
!            is_window,window_type,V_slow,V_fast,&
!            mute_near,offset_near,mute_far,offset_far,&
!            Wscale,&
!            ntstart,ntend)
!    call preprocess(adj_ref,NSTEP,deltat,t0,f0,&
!            is_laplace,dis_sr2,S_x,S_t, &
!            is_window,window_type,V_slow,V_fast,&
!            mute_near,offset_near,mute_far,offset_far,&
!            Wscale,&
!            ntstart,ntend)
     ! sum of adjoint source 
     adjoint_DD(:,irec) = adjoint_DD(:,irec) + adj(:)
     adjoint_DD(:,jrec) = adjoint_DD(:,jrec) + adj_ref(:)
     endif

   endif !! is_pair

!! save waveform similarity
if(.not. ex) write(10,'(2I5,1e15.5,I5)') irec,jrec,cc_max_obs,is_pair(irec,jrec)

  endif  ! non-zero reference trace
enddo ! jrec reference

endif  ! DD or not

endif  ! non-zero irec trace
! ----------------------------------------------------------------
enddo ! irec

if(DD) close(10)

!! normalization
sumsum_misfit = sumsum_misfit + sum_misfit/max(num_AD,1) + sum_misfit_DD/max(num_DD,1)
!sumsum_misfit = sumsum_misfit + sum_misfit + sum_misfit_DD*DD_weight

if(compute_adjoint .and. NSRC<=10) then
print*
if(.not. DD .or. HB)   print*, comp_data(icomp), ' comp: total number of AD measurements :', num_AD, num_AD*100/NREC,'%'
if(DD)   print*, comp_data(icomp), ' comp: total number of DD measurements :', num_DD, num_DD*100/(NREC*(NREC-1)/2),'%'
!   print*,' sum of misfit: sum_misfit + sum_misfit_DD = sumsum_misfit ',sum_misfit, sum_misfit_DD, sumsum_misfit
endif


if(compute_adjoint) then
!normalize
!   adjoint = adjoint/max(num_AD,1) + adjoint_DD/max(num_DD,1)
   adjoint = adjoint + adjoint_DD*DD_weight

! ----------------------------------------------------------------
! Save adjoint source in SU format 
  if(SU_adjoint) then 
  open(5,file='SEM/'//trim(comp_data(icomp))//'_file_single.bin.adj',&
           access='direct',recl=240+4*NSTEP)
    do irec=1,NREC 
      write(5,rec=irec,iostat=ios) r4head(:,irec),sngl(adjoint(:,irec))
    enddo
   close(5)

 else

   do irec=1,NREC
     !! SEM adjoint source
     adj_source_file = trim(network_name(irec))//'.'//trim(station_name(irec))
!     adj_source_file =trim(station_name(irec))//"."//trim(network_name(irec))
     filename = 'SEM/'//trim(adj_source_file) // '.'//trim(comp_adj(icomp))//'.adj'
!     print*, filename
     OPEN (UNIT=5, FILE=filename)
     do itime=1,NSTEP
          write(5,'(f15.5,e15.5)') time(itime),sngl(adjoint(itime,irec))
     end do ! end itime
     close(5)
 
    !! for display 
     if(DISPLAY_DETAILS) then
          ntstart=win_start(irec)
          ntend=win_end(irec) 
          if(ntstart<ntend) then
          print*
          print*,'adjoint source irec -- ',irec
          print*,'min/max adjoint -- ', minval(adjoint(ntstart:ntend,irec)),maxval(adjoint(ntstart:ntend,irec))
          filename = 'DATA_syn/'//trim(adj_source_file) //'.'//trim(comp_adj(icomp))//'.adj'
          OPEN (UNIT=5, FILE=filename)
          do itime=ntstart,ntend
          !do itime=1,NSTEP
              write(5,'(f15.5,3e15.5)') time(itime),&
              seismic_obs(itime,irec,icomp),seismic_syn(itime,irec,icomp),adjoint(itime,irec)
          end do ! end itime
          close(5)
          endif  ! ntstart
     endif  ! display 

    enddo ! end of receiver loop

  endif !SU_format


endif ! compute_adjoint

endif  ! non-zero shot gather

enddo ! end loop of component

! ----------------------------------------------------------------

! ----------------------------------------------------------------
!!save misfit 
     filename = 'misfit.dat'
     OPEN (UNIT=5, FILE=filename)
     write(5,'(e15.5)') sumsum_misfit
     close(5)

if(DISPLAY_DETAILS .and. compute_adjoint) then
   print*
   print*,'final misfit : ',sumsum_misfit
endif

    deallocate(seismic_obs)
    deallocate(seismic_syn)
    deallocate(seismic_shift)
    deallocate(obs)
    deallocate(syn)
    deallocate(adjoint)
    deallocate(adjoint_DD)
    deallocate(r4head)

end program misfit_adjoint

