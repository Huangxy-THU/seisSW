
!========================================================================
!
!                   S P E C F E M 2 D  Version 7 . 0
!                   --------------------------------
!
!     Main historical authors: Dimitri Komatitsch and Jeroen Tromp
!                        Princeton University, USA
!                and CNRS / University of Marseille, France
!                 (there are currently many more authors!)
! (c) Princeton University and CNRS / University of Marseille, April 2014
!               Pieyre Le Loher, pieyre DOT le-loher aT inria.fr
!
! This software is a computer program whose purpose is to solve
! the two-dimensional viscoelastic anisotropic or poroelastic wave equation
! using a spectral-element method (SEM).
!
! This software is governed by the CeCILL license under French law and
! abiding by the rules of distribution of free software. You can use,
! modify and/or redistribute the software under the terms of the CeCILL
! license as circulated by CEA, CNRS and Inria at the following URL
! "http://www.cecill.info".
!
! As a counterpart to the access to the source code and rights to copy,
! modify and redistribute granted by the license, users are provided only
! with a limited warranty and the software's author, the holder of the
! economic rights, and the successive licensors have only limited
! liability.
!
! In this respect, the user's attention is drawn to the risks associated
! with loading, using, modifying and/or developing or reproducing the
! software by the user in light of its specific status of free software,
! that may mean that it is complicated to manipulate, and that also
! therefore means that it is reserved for developers and experienced
! professionals having in-depth computer knowledge. Users are therefore
! encouraged to load and test the software's suitability as regards their
! requirements in conditions enabling the security of their systems and/or
! data to be ensured and, more generally, to use and operate it in the
! same conditions as regards security.
!
! The full text of the license is available in file "LICENSE".
!
!========================================================================


  subroutine prepare_absorb_files()

  use specfem_par, only: myrank,any_elastic,any_poroelastic,any_acoustic, &
                         nspec_left,nspec_right,nspec_bottom,nspec_top,SIMULATION_TYPE


  implicit none
  include "constants.h"

  ! local parameters
  character(len=150) :: outputname,outputname2


  if(any_elastic) then

    !--- left absorbing boundary
    if( nspec_left >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_elastic_left',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=35,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=35,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of left absorbing boundary

    !--- right absorbing boundary
    if( nspec_right >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_elastic_right',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=36,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=36,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of right absorbing boundary

    !--- bottom absorbing boundary
    if( nspec_bottom >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_elastic_bottom',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=37,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=37,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of bottom absorbing boundary

    !--- top absorbing boundary
    if( nspec_top >0 ) then
        write(outputname,'(a,i6.6,a)') 'absorb_elastic_top',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=38,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=38,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif ! end of top absorbing boundary

  endif ! any_elastic

  if(any_poroelastic) then

    !--- left absorbing boundary
    if( nspec_left >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_poro_s_left',myrank,'.bin'
      write(outputname2,'(a,i6.6,a)') 'absorb_poro_w_left',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=45,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
        open(unit=25,file='OUTPUT_FILES/'//outputname2,status='old',&
              form='unformatted')
      else
        open(unit=45,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
        open(unit=25,file='OUTPUT_FILES/'//outputname2,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of left absorbing boundary

    !--- right absorbing boundary
    if( nspec_right >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_poro_s_right',myrank,'.bin'
      write(outputname2,'(a,i6.6,a)') 'absorb_poro_w_right',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=46,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
        open(unit=26,file='OUTPUT_FILES/'//outputname2,status='old',&
              form='unformatted')
      else
        open(unit=46,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
        open(unit=26,file='OUTPUT_FILES/'//outputname2,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of right absorbing boundary

    !--- bottom absorbing boundary
    if( nspec_bottom >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_poro_s_bottom',myrank,'.bin'
      write(outputname2,'(a,i6.6,a)') 'absorb_poro_w_bottom',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=47,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
        open(unit=29,file='OUTPUT_FILES/'//outputname2,status='old',&
              form='unformatted')
      else
        open(unit=47,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
        open(unit=29,file='OUTPUT_FILES/'//outputname2,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of bottom absorbing boundary

    !--- top absorbing boundary
    if( nspec_top >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_poro_s_top',myrank,'.bin'
      write(outputname2,'(a,i6.6,a)') 'absorb_poro_w_top',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=48,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
        open(unit=28,file='OUTPUT_FILES/'//outputname2,status='old',&
              form='unformatted')
      else
        open(unit=48,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
        open(unit=28,file='OUTPUT_FILES/'//outputname2,status='unknown',&
              form='unformatted')
      endif

    endif ! end of top absorbing boundary

  endif !any_poroelastic

  if(any_acoustic) then

    !--- left absorbing boundary
    if( nspec_left >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_acoustic_left',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=65,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=65,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of left absorbing boundary

    !--- right absorbing boundary
    if( nspec_right >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_acoustic_right',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=66,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=66,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of right absorbing boundary

    !--- bottom absorbing boundary
    if( nspec_bottom >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_acoustic_bottom',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=67,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=67,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif  !  end of bottom absorbing boundary

    !--- top absorbing boundary
    if( nspec_top >0 ) then
      write(outputname,'(a,i6.6,a)') 'absorb_acoustic_top',myrank,'.bin'
      if(SIMULATION_TYPE == 3) then
        open(unit=68,file='OUTPUT_FILES/'//outputname,status='old',&
              form='unformatted')
      else
        open(unit=68,file='OUTPUT_FILES/'//outputname,status='unknown',&
              form='unformatted')
      endif

    endif ! end of top absorbing boundary

  endif !any_acoustic


  end subroutine prepare_absorb_files


!
!-------------------------------------------------------------------------------------------------
!

  subroutine prepare_absorb_elastic()

  use specfem_par, only: NSTEP,p_sv, &
                         nspec_left,nspec_right,nspec_bottom,nspec_top, &
                         b_absorb_elastic_left,b_absorb_elastic_right, &
                         b_absorb_elastic_bottom,b_absorb_elastic_top

  implicit none
  include "constants.h"

  ! local parameters
  integer :: it

 !! YY -- write absorbing boundary out of loop

 do it=1,NSTEP
 
    !--- left absorbing boundary
    if(nspec_left >0) then
        if(p_sv)then!P-SV waves
            read(35) b_absorb_elastic_left(1,1:NGLLZ,1:nspec_left,it)
            read(35) b_absorb_elastic_left(3,1:NGLLZ,1:nspec_left,it)
            b_absorb_elastic_left(2,1:NGLLZ,1:nspec_left,it) = ZERO
        else!SH (membrane) waves
            read(35) b_absorb_elastic_left(2,1:NGLLZ,1:nspec_left,it)
            b_absorb_elastic_left(1,1:NGLLZ,1:nspec_left,it) = ZERO
            b_absorb_elastic_left(3,1:NGLLZ,1:nspec_left,it) = ZERO
        endif
    endif

    !--- right absorbing boundary
    if(nspec_right >0) then
        if(p_sv)then!P-SV waves
            read(36) b_absorb_elastic_right(1,1:NGLLZ,1:nspec_right,it)
            read(36) b_absorb_elastic_right(3,1:NGLLZ,1:nspec_right,it)
            b_absorb_elastic_right(2,1:NGLLZ,1:nspec_right,it) = ZERO
        else!SH (membrane) waves
            read(36) b_absorb_elastic_right(2,1:NGLLZ,1:nspec_right,it)
            b_absorb_elastic_right(1,1:NGLLZ,1:nspec_right,it) = ZERO
            b_absorb_elastic_right(3,1:NGLLZ,1:nspec_right,it) = ZERO
        endif
    endif

    !--- bottom absorbing boundary
    if(nspec_bottom >0) then
        if(p_sv)then!P-SV waves
            read(37) b_absorb_elastic_bottom(1,1:NGLLX,1:nspec_bottom,it)
            read(37) b_absorb_elastic_bottom(3,1:NGLLX,1:nspec_bottom,it)
            b_absorb_elastic_bottom(2,1:NGLLX,1:nspec_bottom,it) = ZERO
        else!SH (membrane) waves
            read(37) b_absorb_elastic_bottom(2,1:NGLLX,1:nspec_bottom,it)
            b_absorb_elastic_bottom(1,1:NGLLX,1:nspec_bottom,it) = ZERO
            b_absorb_elastic_bottom(3,1:NGLLX,1:nspec_bottom,it) = ZERO
        endif
    endif

    !--- top absorbing boundary
    if(nspec_top >0) then
        if(p_sv)then!P-SV waves
            read(38) b_absorb_elastic_top(1,1:NGLLX,1:nspec_top,it)
            read(38) b_absorb_elastic_top(3,1:NGLLX,1:nspec_top,it)
            b_absorb_elastic_top(2,1:NGLLX,1:nspec_top,it) = ZERO
        else!SH (membrane) waves
            read(38) b_absorb_elastic_top(2,1:NGLLX,1:nspec_top,it)
            b_absorb_elastic_top(1,1:NGLLX,1:nspec_top,it) = ZERO
            b_absorb_elastic_top(3,1:NGLLX,1:nspec_top,it) = ZERO
        endif
    endif

 enddo

  end subroutine prepare_absorb_elastic

!
!-------------------------------------------------------------------------------------------------
!

  subroutine prepare_absorb_poroelastic()

  use specfem_par, only:NSTEP, &
                        nspec_left,nspec_right,nspec_bottom,nspec_top, &
                        b_absorb_poro_s_left,b_absorb_poro_w_left, &
                        b_absorb_poro_s_right,b_absorb_poro_w_right, &
                        b_absorb_poro_s_bottom,b_absorb_poro_w_bottom, &
                        b_absorb_poro_s_top,b_absorb_poro_w_top

  implicit none
  include "constants.h"

  ! local parameters
  integer :: it

  do it =1, NSTEP

    !--- left absorbing boundary
    if(nspec_left >0) then
          read(45) b_absorb_poro_s_left(:,:,:,it)
          read(25) b_absorb_poro_w_left(:,:,:,it)
    endif

    !--- right absorbing boundary
    if(nspec_right >0) then
          read(46) b_absorb_poro_s_right(:,:,:,it)
          read(26) b_absorb_poro_w_right(:,:,:,it)
    endif

    !--- bottom absorbing boundary
    if(nspec_bottom >0) then
          read(47) b_absorb_poro_s_bottom(:,:,:,it)
    endif

    !--- top absorbing boundary
    if(nspec_top >0) then
          read(48) b_absorb_poro_s_top(:,:,:,it)
          read(28) b_absorb_poro_w_top(:,:,:,it)
    endif

  enddo

  end subroutine prepare_absorb_poroelastic

!
!-------------------------------------------------------------------------------------------------
!

  subroutine prepare_absorb_acoustic()

  use specfem_par, only: NSTEP, &
                         nspec_left,nspec_right,nspec_bottom,nspec_top, &
                         b_absorb_acoustic_left,b_absorb_acoustic_right, &
                         b_absorb_acoustic_bottom,b_absorb_acoustic_top

  implicit none
  include "constants.h"

  ! local parameters
  integer :: it

  do it =1, NSTEP

    !--- left absorbing boundary
    if(nspec_left >0) then
          read(65) b_absorb_acoustic_left(:,:,it)
    endif

    !--- right absorbing boundary
    if(nspec_right >0) then
          read(66) b_absorb_acoustic_right(:,:,it)
    endif

    !--- bottom absorbing boundary
    if(nspec_bottom >0) then
          read(67) b_absorb_acoustic_bottom(:,:,it)
    endif

    !--- top absorbing boundary
    if(nspec_top >0) then
          read(68) b_absorb_acoustic_top(:,:,it)
    endif

  enddo

  end subroutine prepare_absorb_acoustic

