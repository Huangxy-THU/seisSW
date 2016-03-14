program model_update
                ! this routine is used to update model from current model in the search direction defined in p_new.dat
                ! How to run:
                ! gfortran model_update.f90 -o model_update
                ! ./model_update
                ! yanhuay@princeton.edu 08-16-2012
!! line-search with constant step length 
!! other approaches, e.g. bracketing etc.

use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
! index used
INTEGER :: i,j
! status of file
INTEGER :: st
integer :: step_back
double precision :: step_length
! initial model    
double precision :: model(NX,mndim)
! update model
double precision :: model_new(NX,mndim)
! search direction
double precision :: eta(NX)
double precision :: p_new(3*NX)
double precision :: p(NX,gndim)=0.0
double precision :: Dm(3*NX)
! normalized factor
double precision :: nf
character(len=200) :: filename
CHARACTER(len=10) :: arg
character(len=200) :: directory


              ! input
               j=1; call getarg(j,arg); read(arg,*) step_length
               j=2; call getarg(j,directory)
               
               !print*,'input step length = ',step_length
               write(*,'(a,f15.2,a)') 'try step length -- ',step_length*100,'%'             

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
                  print*,'Successfully read current model from:',filename

              ! read update search_direction
                filename =''//trim(directory)//'/p_new.dat'
                 OPEN(UNIT=3,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                  do i=1,3*NX
                   read(3,*) p_new(i)
                  enddo
               end if
               close(3)
                  print*,'Successfully load search direction from  ',filename

              !! convert 1D vector to 2D matrix 
              call vector2matrix(p_new,NX,gndim,p)
                      
              ! update direction for model parameters 
              if (use_rhop_phip_betap_kernel) then
                  !! convert from rhop-phip-betap to rhop-alpha-beta
                  eta(:)=(model(:,mdim_vs)/model(:,mdim_vp))**2*(4.0/3.0)
                  p(:,gdim_vp)=p(:,gdim_vp)*(1-eta(:))+p(:,gdim_vs)*eta(:)
                  p(:,gdim_vs)=p(:,gdim_vs)
              endif

              ! normalized direction
               nf=maxval(abs(p))
               if(nf>threshold) p=p/nf
               
              ! update Vp and Vs in direction of (have been normalized direction)
               model_new=model
               if(model_Vp) then
                  model_new(:,mdim_vp)=model(:,mdim_vp)*(1+step_length*p(:,gdim_vp))
               endif
             ! update Vs
              if(model_Vs) then
                  model_new(:,mdim_vs)=model(:,mdim_vs)*(1+step_length*p(:,gdim_vs))
              endif
              ! update \rho
               if(model_Rho) then
                 model_new(:,mdim_rho)=model(:,mdim_rho)*(1+step_length*p(:,gdim_rho))
               elseif (scale_Rho_Vp) then  !! scaling relation
                  model_new(:,mdim_rho)= 33*(model_new(:,mdim_vp))**0.54
              endif
                        
               ! write new models
               filename = ''//trim(directory)//'/model_update.dat'
              ! print*,filename
                OPEN(UNIT=3,FILE=filename)
               do i=1,NX
                write(3,'(6e15.5)') model(i,mdim_index),model(i,mdim_x),model(i,mdim_z),&
                        model_new(i,mdim_rho),model_new(i,mdim_vp),model_new(i,mdim_vs)
               end do
               close(3)
              !    print*,'Successfully write update model into:',filename
  
               if(backtracking) then                  
                 call matrix2vector(model_new-model,NX,mndim,Dm)
                 filename = ''//trim(directory)//'/Dm.dat'
                 OPEN(UNIT=3,FILE=filename)
                 do i=1,3*NX
                    write(3,'(e15.5)') Dm(i)
                enddo
                close(3)
               print*, 'Delta model is ready for backtracking line search:', filename
               endif

end program model_update


