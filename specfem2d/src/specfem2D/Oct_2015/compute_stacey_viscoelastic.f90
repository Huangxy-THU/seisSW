
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
 subroutine store_stacey_BC_effect_term_viscoelastic()

  use specfem_par, only: p_sv,nspec_left,nspec_right,nspec_bottom,nspec_top, &
                         b_absorb_elastic_left,b_absorb_elastic_right, &
                         b_absorb_elastic_bottom,b_absorb_elastic_top,it
  implicit none
  include "constants.h"


!! YY - save absorbing boundary out of loop

  !--- left absorbing boundary
  if( nspec_left >0 ) then
      if( p_sv ) then!P-SV waves
          write(35) b_absorb_elastic_left(1,1:NGLLZ,1:nspec_left,it)
          write(35) b_absorb_elastic_left(3,1:NGLLZ,1:nspec_left,it)
      else!SH (membrane) waves
          write(35) b_absorb_elastic_left(2,1:NGLLZ,1:nspec_left,it)
      endif
  endif

  !--- right absorbing boundary
  if( nspec_right >0 ) then
      if( p_sv ) then!P-SV waves
          write(36) b_absorb_elastic_right(1,1:NGLLZ,1:nspec_right,it)
          write(36) b_absorb_elastic_right(3,1:NGLLZ,1:nspec_right,it)
      else!SH (membrane) waves
          write(36) b_absorb_elastic_right(2,1:NGLLZ,1:nspec_right,it)
      endif
  endif

  !--- bottom absorbing boundary
  if(nspec_bottom >0) then
      if(p_sv) then!P-SV waves
          write(37) b_absorb_elastic_bottom(1,1:NGLLX,1:nspec_bottom,it)
          write(37) b_absorb_elastic_bottom(3,1:NGLLX,1:nspec_bottom,it)
      else!SH (membrane) waves
          write(37) b_absorb_elastic_bottom(2,1:NGLLX,1:nspec_bottom,it)
      endif
  endif

  !--- top absorbing boundary
  if(nspec_top >0) then
      if(p_sv) then!P-SV waves
          write(38) b_absorb_elastic_top(1,1:NGLLX,1:nspec_top,it)
          write(38) b_absorb_elastic_top(3,1:NGLLX,1:nspec_top,it)
      else!SH (membrane) waves
          write(38) b_absorb_elastic_top(2,1:NGLLX,1:nspec_top,it)
      endif
  endif

 end subroutine store_stacey_BC_effect_term_viscoelastic

