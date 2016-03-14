program data_misfit
! sum of misfits

use seismo_parameters
implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! indexes used:
INTEGER :: isrc,iter
INTEGER :: i,j
INTEGER :: st
LOGICAL :: compute_adjoint

! misfit
double precision ::   misfit_value(Nmisfit)=0.d0
double precision ::   event_misfit(Nmisfit)=0.d0
double precision ::   sum_misfit(Nmisfit)=0.d0
double precision ::   target_misfit=0.d0, optimal_misfit=0.0
double precision ::   alpha(max_step)=0.d0,misfit(max_step)=0.0
INTEGER :: is_done=0, is_cont=0, is_brak=0
double precision ::   step_length, next_step_length,optimal_step_length
double precision :: temp(2)=0.0

!!
double precision ::  Dm(3*NX)
double precision ::  g_new(3*NX)
double precision ::  slope
double precision ::  slope_const=0.5
double precision ::  shrink_const=0.5

! files
character(len=200) :: filename
character(len=6)   :: source
character(len=10)   ::fname
character(len=200) :: directory
character(len=10)  :: arg

!! get parameters
j=1; call getarg(j,arg); read(arg,*) iter
j=2; call getarg(j,arg); read(arg,*) step_length
j=3; call getarg(j,directory)
j=4; call getarg(j,arg); read(arg,*) compute_adjoint
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!! source loop
    do isrc=1, nsrc
       write(source, "(i6.6)") isrc-1
    misfit_value=0.d0
    event_misfit=0.d0
! open file 
filename &
=''//trim(directory)//'/'//trim(source)//'/misfit.dat' 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    OPEN (UNIT=1,FILE= filename,STATUS='OLD',action='read',iostat=st)
     if(st>0) then
        print*,'Error opening file. File load status:', st
        stop
     else
         read(1,*) misfit_value
     end if
      close(1)
!   event_misfit=dot_product(misfit_value,misfit_value)
   event_misfit=misfit_value
!! sum over source (chi-squared)
   sum_misfit=sum_misfit+event_misfit
  !! sum_misfit = sum_misfit/2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
enddo !! source loop

! target misfit 
target_misfit = sum_misfit(1)/2

print*, 'Data misfit = : ', target_misfit

!!! misfit hist for line search
     write(fname, "(i6)") iter 
     filename = ''//trim(directory)//'/data_misfit_hist_iter'//trim(adjustl(fname))
     OPEN (UNIT=5, FILE=filename,status='unknown',POSITION='APPEND')
     write(5,*) step_length,target_misfit
     close(5)

if (.not. compute_adjoint) then
!!! check current search status
    ! load search history
     OPEN (UNIT=5, FILE=filename,status='old')
       j=0
       do i=1,max_step+1 
        read(5,*,iostat=st) temp
        if (st/=0) exit
        alpha(i)=temp(1)
        misfit(i)=temp(2)
        j=j+1
       enddo
     close(5)
   
    ! determine next step search status
  if(.not. backtracking) then
    print*,'line search method -- constant step size'

     if(step_length>=0.9*initial_step_length ) then
           print*,' current status -- forward search'     
        if(misfit(j)<misfit(j-1))  then    ! decrease misfit      
           if(j<max_step+1 .and. &
              (misfit(j-1) - misfit(j))/misfit(j-1) >= 0.01) then  
              ! not exceed max step, next status -- forward continue
              is_cont=1
              is_done=0
              is_brak=0
              next_step_length=alpha(j)+initial_step_length
              optimal_step_length=alpha(j)
              write(*,'(a,f15.5)') 'next step : forward continue -- next step_length=',next_step_length
           else
              is_cont=0
              is_done=1
              is_brak=0
              next_step_length=0.0
              optimal_step_length=alpha(j)
              optimal_misfit=misfit(j)  
             write(*,'(a,f15.5)') 'next step : forward stop -- exceed max step, optimal step_length=',optimal_step_length             
           endif
        else   ! not decrease misfit
           if(step_length>=1.5*initial_step_length) then
              !! more than one step forwad,  next status -- forward stop
              is_cont=0
              is_done=1
              is_brak=0
              next_step_length=0.0
              optimal_step_length=alpha(j-1)
              optimal_misfit=misfit(j-1)
               write(*,'(a,f15.5)') 'next step : forward done -- optimal step_length=',optimal_step_length
           else    !! next status -- backward start
              is_cont=1
              is_done=0
              is_brak=0
              next_step_length=alpha(j)/2
              optimal_step_length=0.0
               write(*,'(a,f15.5)') 'next step : backward start -- next step_length=',next_step_length
           endif
         endif
    else   
         print*,' current status -- backward search'
         print*,'step_length =',step_length
         print*,'initial_step_length=',initial_step_length  
        if(misfit(j)<misfit(1)) then  ! next status -- backward stop
              is_cont=0
              is_done=1
              is_brak=0
              next_step_length=0.0
              optimal_step_length=alpha(j)
              optimal_misfit=misfit(j)
               write(*,'(a,f15.5)') 'next step : backward done -- optimal step_length=',optimal_step_length
         else  
            if(step_length>=min_step_length) then !!  next status -- backward continue               
              is_cont=1
              is_done=0
              is_brak=0
              next_step_length=alpha(j)/2
              optimal_step_length=0.0
               write(*,'(a,f15.5)') 'next step : backward continue -- next step_length=',next_step_length
            else    !!  next status -- break 
              is_cont=0
              is_done=0
              is_brak=1
              next_step_length=0.0
              optimal_step_length=0.0
               write(*,'(a)') 'next step : backward exit'
            endif
         endif
     endif

   else 
    print*,'line search method -- backtracking'
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
               print*,'Successfully read gradient from:',filename

               filename =''//trim(directory)//'/Dm.dat'
               OPEN(UNIT=2,FILE=filename,STATUS='old',action='read',iostat=st)
               if(st>0) then
                    print*,'Error opening file. File load status',st
                    stop
               else
                 do i=1,3*NX
                   read(2,*) Dm(i)
                enddo
               end if
               close(2)
               print*,'Successfully read model change from:',filename
               slope=alpha(j)*slope_const*dot_product(Dm,g_new)

          print*,'misfit change -- ', misfit(j)-misfit(1)
          print*, 'slope -- ',slope, dot_product(Dm,g_new) 
          if((misfit(j)-misfit(1))<=slope) then 
              is_cont=0
              is_done=1
              is_brak=0
              next_step_length=0.0
              optimal_step_length=alpha(j)  
              optimal_misfit=misfit(j) 
               write(*,'(a,f15.5)') 'next step : backtracking done -- optimal step length=',optimal_step_length
          else
              if(step_length>=min_step_length) then              
                 is_cont=1
                 is_done=0
                 is_brak=0
                 next_step_length=alpha(j)*shrink_const
                 optimal_step_length=0.0
                 write(*,'(a,f15.5)') 'next step : backtracking continue -- next step_length=',next_step_length             
             else
                 is_cont=0
                 is_done=0
                 is_brak=1
                 next_step_length=0.0
                 optimal_step_length=0.0
                 print*,'next step : backtracking exit'
             endif
          endif

    endif ! line search method


     filename = ''//trim(directory)//'/search_status.dat'
     OPEN (UNIT=5, FILE=filename)
        write(5,'(I5)') is_cont
        write(5,'(I5)') is_done
        write(5,'(I5)') is_brak
        write(5,'(f15.5)') next_step_length
        write(5,'(f15.5)') optimal_step_length
     close(5)

    if(is_done==1) then 
       !!! misfit hist for iteration 
     filename = ''//trim(directory)//'/data_misfit_hist.dat'
     OPEN (UNIT=5, FILE=filename,status='unknown',POSITION='APPEND')
        write(5,'(I5,e15.5)') iter,optimal_misfit
     close(5)
    endif

else
   if(iter==1)  then 
    !!! misfit hist for iteration 
     filename = ''//trim(directory)//'/data_misfit_hist.dat'
     OPEN (UNIT=5, FILE=filename,status='unknown',POSITION='APPEND')      
        write(5,'(I5,e15.5)') iter-1,target_misfit
     close(5)
   endif
endif


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

end program data_misfit



