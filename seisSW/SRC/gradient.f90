program gradient
        ! This routine is used to calculate misfit kernel(sum up of all event
        ! kernels)
!! preconditioning -- sum of abs(p2)
!! smooth gradient kernel and preconditioner to remove small-scale sharp
!features, then apply preconditioning
 


use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
! index used
INTEGER :: itime, st, isrc,i,j
! event kernel, unsmoothed misfit kernel and smoothed misfit kernel
double precision :: event_kernel(NX,gndim)=0.d0, mkernel(NX,gndim)=0.d0,model(NX,mndim)
double precision :: h1(NX)=0.d0,h2(NX)=0.d0,hessian1(NX)=0.d0,hessian2(NX)=0.d0
double precision :: P(NX)=1.d0,sp(NX)=0.d0
double precision :: srho(NX)=0.0d0,svp(NX)=0.0d0,svs(NX)=0.0d0
double precision :: weight(NX)=0.0d0
double precision :: dis_x=0.0, dis_z=0.0 
double precision :: g_new(3*NX),m_new(3*NX)
double precision :: trunk
logical :: ex 
double precision :: mm 
double precision :: xs,zs,dis_source, factor_source
! filename
character(len=200) :: filename
character(len=6) :: source
character(len=200) :: directory
character(len=200) :: grad_file
character(len=512) :: mask_file

j=1; call getarg(j,directory)
j=2; call getarg(j,mask_file)

if (use_rhop_alpha_beta_kernel) grad_file='proc000000_rhop_alpha_beta_kernel.dat'
if (use_rhop_phip_betap_kernel) grad_file='proc000000_rhop_phip_betap_kernel.dat'
if (use_rho_kappa_mu_kernel) grad_file='proc000000_rho_kappa_mu_kernel.dat'
   

    do isrc=1, NSRC
        write(source, "(i6.6)") isrc-1
    !! sum of kernels
    filename &
     =''//trim(directory)//'/'//trim(source)//'/OUTPUT_FILES/'//trim(grad_file)
     OPEN (UNIT=1,FILE= filename,STATUS='OLD',action='read',iostat=st)

     if(st>0) then
        print*,'Error opening file: ', filename
        stop
     else
        !! mask source 
        if (mask_source) then
        !! read source location 
        filename &
        =''//trim(directory)//'/'//trim(source)//'/DATA/for_information_SOURCE_actually_used'
        OPEN (UNIT=2,FILE= filename,STATUS='OLD',action='read',iostat=st)
       if(st>0) then
          print*,'Error opening file. File load status:', st
          stop
       else
         read(2,*) xs,zs
         if(DISPLAY_DETAILS) then
         print*
         print*, 'masking source at ',xs,zs 
         endif
      end if
       close(2)
       endif

     !! load gradient kerenel
     do itime=1,NX
         read(1,*) event_kernel(itime,gdim_x),event_kernel(itime,gdim_z),&
           event_kernel(itime,gdim_rho),event_kernel(itime,gdim_vp),event_kernel(itime,gdim_vs)

           !! coordinate 
           mkernel(itime,gdim_x)=event_kernel(itime,gdim_x)
           mkernel(itime,gdim_z)=event_kernel(itime,gdim_z)

   !! source masking
   factor_source=1.0
   if (mask_source) then 
        dis_source=sqrt((mkernel(itime,gdim_x)-xs)**2+(mkernel(itime,gdim_z)-zs)**2)
        if(dis_source<=2*lambda)  factor_source=1-exp(-(dis_source/(1.414*lambda))**2)
    endif

 !! add up 
 if(model_RHO) mkernel(itime,gdim_rho)=mkernel(itime,gdim_rho)+event_kernel(itime,gdim_rho)*factor_source  ! rho
 if(model_Vp)  mkernel(itime,gdim_vp)=mkernel(itime,gdim_vp)+event_kernel(itime,gdim_vp)*factor_source  ! Vp
 if(model_Vs)  mkernel(itime,gdim_vs)=mkernel(itime,gdim_vs)+event_kernel(itime,gdim_vs)*factor_source  ! Vs
     
   end do !itime
  end if ! gradient file exist
  close(1)

   !!sum of absolute preconditioner
   if(precond) then
    !! wavefield related preconditioner
    if(precond_type==1 .or. precond_type==2) then
    filename &
     =''//trim(directory)//'/'//trim(source)//'/OUTPUT_FILES/proc000000_precond.dat'
     OPEN (UNIT=1,FILE= filename,STATUS='OLD',action='read',iostat=st)
     if(st>0) then
        print*,'Error opening file: ', filename
        stop
     else
     do itime=1,NX
         read(1,*) trunk,trunk,h1(itime),h2(itime) 
        !! sum of abs(precond)
         hessian1(itime) = hessian1(itime) + abs(h1(itime))
         hessian2(itime) = hessian2(itime) + abs(h2(itime)) 
     end do
     end if
     close(1)
     endif  !! precond_type

   endif  !! precond

  end do !! source loop

   if(precond .and. precond_type==1) P=1.0/(hessian1+20.d0/100.d0*maxval(hessian1))
   if(precond .and. precond_type==2) P=1.0/(hessian2+20.d0/100.d0*maxval(hessian2))

   !! save misfit_kernel
     filename=''//trim(directory)//'/misfit_kernel_raw.dat'
     OPEN (UNIT=1,FILE= filename)
     do itime=1,NX
         write(1,'(5e15.5)') mkernel(itime,gdim_x),mkernel(itime,gdim_z),&
           mkernel(itime,gdim_rho),mkernel(itime,gdim_vp),mkernel(itime,gdim_vs)
     end do
     close(1)
      print*
      print*,'Successfully write misfit kernel into ',filename
 if(model_RHO)  write(*,'(a,2e15.5)') ' gradient RHO min/max :',minval(mkernel(:,gdim_rho),1),maxval(mkernel(:,gdim_rho),1)
 if(model_Vp)   write(*,'(a,2e15.5)') ' gradient Vp min/max :', minval(mkernel(:,gdim_vp),1),maxval(mkernel(:,gdim_vp),1)
 if(model_Vs)   write(*,'(a,2e15.5)') ' gradient Vs min/max :', minval(mkernel(:,gdim_vs),1),maxval(mkernel(:,gdim_vs),1)

! smooth Vp and Vs kernel
if(smooth) then
print*
print*,'smooth kernels and preconditioner...'
print* 
   do i=1,NX
!    weight
     weight(:)=0.0
     do j=1,NX
        dis_x=abs(mkernel(i,gdim_x)-mkernel(j,gdim_x))
        if(dis_x>1.414*smooth_x) then 
             weight(j)=0.0
        else
             dis_z=abs(mkernel(i,gdim_z)-mkernel(j,gdim_z))
             if(dis_z>1.414*smooth_z) then
                 weight(j)=0.0
             else    
                 weight(j)=exp(-((dis_x/smooth_x)**2+(dis_z/smooth_z)**2))
             endif
       endif 
     end do
     ! smoothing
     srho(i)=sum(mkernel(:,gdim_rho)*weight(:))/sum(weight(:))
     svp(i)=sum(mkernel(:,gdim_vp)*weight(:))/sum(weight(:))
     svs(i)=sum(mkernel(:,gdim_vs)*weight(:))/sum(weight(:))
     sp(i)=sum(P(:)*weight(:))/sum(weight(:))
   end do
       mkernel(:,gdim_rho)=srho(:)
       mkernel(:,gdim_vp)=svp(:)
       mkernel(:,gdim_vs)=svs(:) 
       P = sp

   if(DISPLAY_DETAILS) then
   !! save misfit_kernel
     filename=''//trim(directory)//'/misfit_kernel_smoothed.dat'
     OPEN (UNIT=1,FILE= filename)
     do itime=1,NX
         write(1,'(5e15.5)') mkernel(itime,gdim_x),mkernel(itime,gdim_z),&
           mkernel(itime,gdim_rho),mkernel(itime,gdim_vp),mkernel(itime,gdim_vs)
     end do
     close(1)
   endif
endif  ! smooth

! preconditioning
if(precond) then 
print*
print*,'preconditioning -- type ',precond_type
print*
mkernel(:,gdim_rho) = mkernel(:,gdim_rho) * P(:)
mkernel(:,gdim_vp) = mkernel(:,gdim_vp) * P(:)
mkernel(:,gdim_vs) = mkernel(:,gdim_vs) * P(:)

   if(DISPLAY_DETAILS) then
   !! save misfit_kernel
     filename=''//trim(directory)//'/misfit_kernel_precond.dat'
     OPEN (UNIT=1,FILE= filename)
     do itime=1,NX
         write(1,'(5e15.5)') mkernel(itime,gdim_x),mkernel(itime,gdim_z),&
           mkernel(itime,gdim_rho),mkernel(itime,gdim_vp),mkernel(itime,gdim_vs)
     end do
     close(1)
    endif
endif ! precond

!if mask
inquire(file=mask_file,exist=ex)
if(ex) then
print*
print*,'appying mask to gradient ... '
print*
     OPEN (UNIT=1,FILE=mask_file,STATUS='OLD',action='read',iostat=st)
     if(st>0) then
        print*,'Error opening file: ',mask_file
        stop
     else
     do itime=1,NX
         read(1,*) mm
         mkernel(itime,gdim_rho)=mkernel(itime,gdim_rho)*mm
         mkernel(itime,gdim_vp)=mkernel(itime,gdim_vp)*mm
         mkernel(itime,gdim_vs)=mkernel(itime,gdim_vs)*mm
         P(itime)=P(itime)*mm
     enddo
     endif
endif


!!! save files .....

   !! save misfit_kernel
     filename=''//trim(directory)//'/misfit_kernel.dat'
     OPEN (UNIT=1,FILE= filename)
     do itime=1,NX
         write(1,'(5e15.5)') mkernel(itime,gdim_x),mkernel(itime,gdim_z),&
           mkernel(itime,gdim_rho),mkernel(itime,gdim_vp),mkernel(itime,gdim_vs)
     end do
     close(1)

   if(DISPLAY_DETAILS) then
   !! save preconditioner
     filename=''//trim(directory)//'/precond.dat'
     OPEN (UNIT=1,FILE= filename)
     do itime=1,NX
         write(1,'(3e15.5)') mkernel(itime,gdim_x),mkernel(itime,gdim_z),P(itime)
     end do
     close(1)
    endif


    !! SAVE gradient vector
       call matrix2vector(mkernel,NX,gndim,g_new)

         filename = ''//trim(directory)//'/g_new.dat'
         OPEN(UNIT=3,FILE=filename)
       do itime=1,3*NX 
          write(3,'(e15.5)') g_new(itime)
       enddo
         close(3)
      print*, '(new) gradient is ready for optimization:', filename

  !! convert current model to vector for optimization 
               ! read current model
               filename = ''//trim(directory)//'/model_current.dat'
                 OPEN(UNIT=1,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,NX
              read(1,*) model(i,mdim_index),model(i,mdim_x),model(i,mdim_z),&
                        model(i,mdim_rho),model(i,mdim_vp),model(i,mdim_vs)
               end do
               end if
               close(1)

       call matrix2vector(model,NX,mndim,m_new)

         filename = ''//trim(directory)//'/m_new.dat'
         OPEN(UNIT=3,FILE=filename)
       do itime=1,3*NX
          write(3,'(e15.5)') m_new(itime)
       enddo
         close(3)
      print*, '(new) model is ready for optimization:', filename

end program gradient

