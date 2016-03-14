program prepare_model

use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
! index used
INTEGER :: i
! status of file
logical :: st
! initial model    
double precision :: vel_model(NX,mndim)
double precision :: att_model(NX,2)
double precision :: ani_model(NX,2)
double precision :: C11,C13,C15,C33,C35,C55,C12,C23,C25 
character(len=200) :: filename

  !! velocity file
  filename='DATA/model_velocity.dat'          
  inquire(file=filename,exist=st)
  ! if file exist
  if(st) then
         OPEN(UNIT=1,FILE=filename,STATUS='old',action='read')
         do i=1,NX
              read(1,*) vel_model(i,mdim_index),vel_model(i,mdim_x),vel_model(i,mdim_z),&
                        vel_model(i,mdim_rho),vel_model(i,mdim_vp),vel_model(i,mdim_vs)
         end do
         close(1)
   else
         print*,'Error opening file --- ',filename
         stop
   end if
   
  !! attenuation file
  filename='DATA/model_attenuation.dat'
  inquire(file=filename,exist=st)
  ! if file exist
  if(st) then
         OPEN(UNIT=1,FILE=filename,STATUS='old',action='read')
         do i=1,NX
              read(1,*) att_model(i,mdim_QKappa),att_model(i,mdim_Qmu)
         end do
         close(1)
   elseif(attenuation) then
         print*,'Error opening file --- ',filename
         stop
   end if

  !! anisotropy file
  filename='DATA/model_anisotropy.dat'
  inquire(file=filename,exist=st)
  ! if file exist
  if(st) then
         OPEN(UNIT=1,FILE=filename,STATUS='old',action='read')
         do i=1,NX
              read(1,*) ani_model(i,mdim_epsilon),ani_model(i,mdim_delta)
         end do
         close(1)
   elseif(anisotropy) then
         print*,'Error opening file --- ',filename
         stop
   end if


  !! outputs:
  if(isotropy) then
  filename='DATA/model_velocity.dat_input'
  OPEN(UNIT=1,FILE=filename)
  do i=1,NX
      write(1,'(6e15.5)') vel_model(i,mdim_index),vel_model(i,mdim_x),vel_model(i,mdim_z),&
                        vel_model(i,mdim_rho),vel_model(i,mdim_vp),vel_model(i,mdim_vs)

  end do
  close(1)
  endif

  if(attenuation) then
  filename='DATA/model_attenuation.dat_input'
  OPEN(UNIT=1,FILE=filename)
  do i=1,NX
      write(1,'(2e15.5)') att_model(i,mdim_QKappa),att_model(i,mdim_Qmu)

  end do
  close(1)
  endif
   
  if(anisotropy) then
      filename='DATA/model_anisotropy.dat_input'
      OPEN(UNIT=1,FILE=filename)
      do i=1,NX
         if(ani_model(i,mdim_epsilon)>threshold .or. &
                ani_model(i,mdim_delta)>threshold ) then

         C33 = vel_model(i,mdim_vp)**2*vel_model(i,mdim_rho)
         C55 = vel_model(i,mdim_vs)**2*vel_model(i,mdim_rho)  
         C11 = (2.0*ani_model(i,mdim_epsilon)+1)*C33
         C13 = sqrt(2.0*C33*ani_model(i,mdim_delta)*(C33-C55) + (C33-C55)**2)-C55
         
         C15 = 0.0
         C35 = 0.0 
         
         C12 = 1.0d-6 
         C23 = 1.0d-6
         C25 = 1.0d-6
         else
         C11=0.0
         C13=0.0
         C15=0.0
         C33=0.0
         C35=0.0
         C55=0.0
         C12=0.0
         C23=0.0
         C25=0.0 
         endif 
         write(1,'(12e15.5)') vel_model(i,mdim_rho),vel_model(i,mdim_vp),vel_model(i,mdim_vs), &
                               C11,C13,C15,C33,C35,C55,C12,C23,C25 
      end do
      close(1)
  endif
   

end program prepare_model


