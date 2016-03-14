program model_misfit
! model misfit
use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! index used
INTEGER :: i,j,iter
! status of file
INTEGER :: st
! models   
double precision :: m_estimate(NX,mndim),m_target(NX,mndim)
double precision :: misfit(mndim)=0.0
! files
character(len=200) :: filename
character(len=200) :: directory
character(len=10)  :: arg

              ! input
               j=1; call getarg(j,directory)
               j=2; call getarg(j,arg); read(arg,*) iter 
               ! read target model
               filename = ''//trim(directory)//'/model_target.dat'
                 OPEN(UNIT=1,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,NX
              read(1,*) m_target(i,mdim_index), &
                        m_target(i,mdim_x),m_target(i,mdim_z),&
                        m_target(i,mdim_rho),m_target(i,mdim_vp),&
                        m_target(i,mdim_vs)
               end do
               end if
               close(1)

               ! read estimate model
               filename = ''//trim(directory)//'/model_current.dat'
                 OPEN(UNIT=1,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,NX
              read(1,*) m_estimate(i,mdim_index), &
                        m_estimate(i,mdim_x),m_estimate(i,mdim_z),&
                        m_estimate(i,mdim_rho),m_estimate(i,mdim_vp),&
                        m_estimate(i,mdim_vs)
 
               end do
               end if
               close(1)
               !   print*,'Successfully read estimate model from:',filename

              misfit(mdim_rho)= &
                    sum((m_estimate(:,mdim_rho)-m_target(:,mdim_rho))**2)
              misfit(mdim_vp)= &
                    sum((m_estimate(:,mdim_vp)-m_target(:,mdim_vp))**2)
              misfit(mdim_vs)= &
                    sum((m_estimate(:,mdim_vs)-m_target(:,mdim_vs))**2)

              write(*,100),sqrt(misfit(mdim_rho)),sqrt(misfit(mdim_vp)),sqrt(misfit(mdim_vs))
         100 format(1x,'model rmse for Rho, Vp, Vs are:',1x,F15.5,1x,F15.5,1x,F15.5)
                    
               ! write into model misfit file
               filename = ''//trim(directory)//'/model_misfit_hist.dat'
              ! print*,filename
               OPEN(UNIT=3,FILE=filename,status='unknown',POSITION='APPEND')
               write(3,'(I5,3e15.5)') iter, sqrt(misfit(mdim_rho)), &
                          sqrt(misfit(mdim_vp)),sqrt(misfit(mdim_vs))
               close(3)

 end program model_misfit


