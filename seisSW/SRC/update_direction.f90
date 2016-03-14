program update_direction

                ! this routine is used to calculate update direction
                ! yanhuay@princeton.edu 03-14-2013

!! add Newton, Pseudo-Newton (L-BFGS), Gausson-Newton etc. 
!! preconditioned conjugate gradient  

use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! read parameters
INTEGER :: iter

! index
INTEGER :: j
! status of file
INTEGER :: st
! gradients            
double precision :: g_new(3*NX),g_old(3*NX)
! search direction
double precision :: p_new(3*NX),p_old(3*NX)
! search direction
double precision :: m_new(3*NX),m_old(3*NX)
!!accumulative steps from starting/restarting CG
INTEGER :: cgstep = 0 
!! accmulative steps from starting/restarting LBFGS 
INTEGER :: BFGS_step = 0
!! m steps L-BFGS (use previous m terms) 
INTEGER :: m = 0  
! change of gradients delta_g            
double precision :: Deltag(3*NX,BFGS_stepmax)
! change of gradients delta_g 
double precision :: Dm(3*NX)           
double precision :: Deltam(3*NX,BFGS_stepmax)
double precision :: trunk

integer :: i
character(len=100) :: filename
CHARACTER(len=10) :: arg
character(len=200) :: directory


    ! inputs
     j=1; call getarg(j,arg); read(arg,*) iter
     j=2; call getarg(j,directory)
             
   !! initialization
   g_new(:) = 0.0 
   g_old(:) = 0.0
   p_new(:) = 0.0
   p_old(:) = 0.0 
   Deltag(:,:)=0.0
   Deltam(:,:)=0.0

    print*
    print*, 'optimization scheme is ', opt_scheme
    select case(opt_scheme)
           case("SD") !! steepest descent method   
             ! input file needed: g_new  
             filename =''//trim(directory)//'/g_new.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) g_new(i)
                enddo
               end if
               close(2)
               print*,'Successfully read new gradient from:',filename

              !! search direction
              call SD(g_new, 3*NX, p_new)

           case("CG") !! conjugate gradient method   
             ! input file needed: g_new  
             filename =''//trim(directory)//'/g_new.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) g_new(i)
                 enddo
               end if
               close(2)
               print*,'Successfully read new gradient from:',filename
             
             !! first if 
             if(iter==1) then   !! first iter step, do SD
              !! search direction 
              print*, 'steepest descent for iter 1 ' 
              call SD(g_new, 3*NX, p_new)
              cgstep = 1

             else !! not the first iter step, try CG
              ! additional file needed: cgstep
                filename =''//trim(directory)//'/cgstep.dat'
                OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                   read(2,*) cgstep
               end if
               close(2)
               print*,'Successfully read cgstep from:',filename
              
               !! second if   
               if( cgstep > cgstepmax ) then ! exceed max cg steps, do SD
                   print*, 'restarting NLCG ... [periodic restart]'
                   cgstep = 1 
                   !! search direction 
                   print*, 'steepest descent for restarting iter=',&
                            iter, ' cgstep=', cgstep
                   call SD(g_new, 3*NX, p_new)

               elseif(cgstep>=1 .and. cgstep<=cgstepmax) then !! not exceed max cg steps, try CG 
                ! additional file needed: g_old, p_old                                 
                filename =''//trim(directory)//'/g_old.dat'
                OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) g_old(i)
                 enddo
               end if
               close(2)
               print*,'Successfully read old gradient from:',filename

               filename =''//trim(directory)//'/p_old.dat'
                 OPEN(UNIT=3,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,3*NX
                   read(3,*) p_old(i)
               enddo
               end if
               close(3)
              print*,'Successfully previous search direction from  ',filename

             !! search direction 
             print*, 'conjugate gradient direction for iter=',&
                            iter, ' cgstep=', cgstep              
            call NLCG(g_new, g_old, p_old, 3*NX, CG_scheme, cgstep, p_new)

            endif !! cgmax
           endif !! iter==1

            !! file save needed : cgstep 
                filename =''//trim(directory)//'/cgstep.dat'
              ! print*,filename
                OPEN(UNIT=3,FILE=filename)
                write(3,'(I5)') cgstep
               close(3)
               print*,'Successfully save cgstep into:',filename

           case("QN") !! Qausi-Newton (L-BFGS) method   
             ! input file needed: g_new  
             filename =''//trim(directory)//'/g_new.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) g_new(i)
                 enddo
               end if
               close(2)
               print*,'Successfully read new gradient from:',filename

             !! first if 
             if(iter==1) then   !! first iter step, do SD
              !! search direction 
              print*, 'steepest descent for iter 1 '
              call SD(g_new, 3*NX, p_new)
              BFGS_step = 1

             else !! not the first iter step, try L_BFGS
              ! additional file needed: BFGS_step, m_new, m_old, g_old
                filename =''//trim(directory)//'/BFGS_step.dat'
                OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                   read(2,*) BFGS_step
               end if
               close(2)
               print*,'Successfully read old BFGS_step from:',filename

               filename = ''//trim(directory)//'/m_new.dat'
                 OPEN(UNIT=1,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,3*NX
                     read(1,*) m_new(i)
               end do
               end if
               close(1)
               print*,'Successfully read new model from:',filename

               filename = ''//trim(directory)//'/m_old.dat'
                 OPEN(UNIT=1,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
               do i=1,3*NX
                     read(1,*) m_old(i)
               end do 
               end if
               close(1)
               print*,'Successfully read old model from:',filename 
       
               !! Dm
               Dm=m_new-m_old             

             filename =''//trim(directory)//'/g_old.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) g_old(i)
                 enddo
               end if
               close(2)
               print*,'Successfully read old gradient from:',filename

              
               !! m- step L-BFGS (accumulative steps and max steps)
               m = min(BFGS_step,BFGS_stepmax)

               !! second if
               if(m==1) then !! consider one previous step
                  Deltam(:,1) = Dm(:)
                  Deltag(:,1) = g_new(:)-g_old(:)

               !! search direction  
               print*, 'L-BFGS direction for iter=',iter, &
                      ' BFGS_step=', BFGS_step, ' m=',m
                  call LBFGS(Deltam, Deltag, g_new, 3*NX, m, BFGS_step, p_new) 

               else if(m>1 .and. m<=BFGS_stepmax) then !! consider multiple previous steps
                 ! additonal files: old Deltam, Deltag
               filename =''//trim(directory)//'/Deltam.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                        read(2,*) Deltam(i,2:BFGS_stepmax), trunk
                 enddo
               end if
               close(2)
               print*,'Successfully read old Deltam from:',filename

               filename =''//trim(directory)//'/Deltag.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                        read(2,*) Deltag(i,2:BFGS_stepmax),trunk
                 enddo
               end if
               close(2)
               print*,'Successfully read old Deltag from:',filename
             
               !! add in new Deltam Deltag
                  Deltam(:,1) = Dm(:)
                  Deltag(:,1) = g_new(:)-g_old(:)

                  print*, 'L-BFGS direction for iter=',iter, &
                      ' BFGS_step=', BFGS_step, ' m=',m
                  call LBFGS(Deltam, Deltag, g_new, 3*NX, m, BFGS_step, p_new)
               endif !! if(m==1) 

               !! check restarting or not 
                  if(BFGS_step ==1) then 
                    Deltag(:,:)=0.0
                    Deltam(:,:)=0.0
                  endif
               endif !! if (iter ==1)

             
            !! file save needed : BFGS_step, Deltam, Deltag 
                filename =''//trim(directory)//'/BFGS_step.dat'
              ! print*,filename
                OPEN(UNIT=3,FILE=filename)
                write(3,'(I5)') BFGS_step
               close(3)
               print*,'Successfully save new BFGS_step into:',filename

               filename =''//trim(directory)//'/Deltam.dat'
               OPEN(UNIT=2,FILE=filename)
                 do i=1,3*NX
                        write(2,'(<BFGS_stepmax>e15.5)') Deltam(i,1:BFGS_stepmax)
                 enddo
               close(2)
               print*,'Successfully save new Deltam into:',filename

               filename =''//trim(directory)//'/Deltag.dat'
               OPEN(UNIT=2,FILE=filename)
                 do i=1,3*NX
                        write(2,'(<BFGS_stepmax>e15.5)') Deltag(i,1:BFGS_stepmax)
                 enddo
               close(2)
               print*,'Successfully save new Deltag into:',filename

        case default
            print*, 'opt_scheme must be among "SD"/"CG"/"QN" ...';
            stop
     end select
       

           !! SAVE file : p_new 
              filename =''//trim(directory)//'/p_new.dat'
              OPEN(UNIT=3,FILE=filename)
            do i=1,3*NX
              write(3,'(e15.5)') p_new(i)
            enddo
              close(3)
              print*,'Successfully save update search direction into:',filename

end program update_direction


