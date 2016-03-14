
subroutine finalize_simulation()

#ifdef USE_MPI
  use mpi
#endif

  use specfem_par

  implicit none

integer i,ispec,j,iglob


#ifdef USE_MPI
  include "precision.h"
#endif


if (GPU_MODE) call prepare_cleanup_device(Mesh_pointer, &
                              any_acoustic,any_elastic, &
                              STACEY_BOUNDARY_CONDITIONS, &
                              ANISOTROPY, &
                              APPROXIMATE_HESS_KL)


  if(output_wavefield_dumps) deallocate(mask_ibool)


!!!! Deplacement Etienne GPU

! stores absorbing boundary contributions into files
      if(anyabs .and. SAVE_FORWARD .and. SIMULATION_TYPE == 1 .and. (.not. PML_BOUNDARY_CONDITIONS)) then

      if (any_acoustic) then

        !--- left absorbing boundary
        if(nspec_left >0) then
              write(65) b_absorb_acoustic_left(:,:,:)
        endif
        !--- right absorbing boundary
        if(nspec_right >0) then
              write(66) b_absorb_acoustic_right(:,:,:)
        endif
        !--- bottom absorbing boundary
        if(nspec_bottom >0) then
              write(67) b_absorb_acoustic_bottom(:,:,:)
        endif
        !--- top absorbing boundary
        if(nspec_top >0) then
              write(68) b_absorb_acoustic_top(:,:,:)
        endif

    endif !any acoustic

      close(65)
      close(66)
      close(67)
      close(68)
      close(72)

 if(any_elastic) then

        !--- left absorbing boundary
        if(nspec_left >0) then
            if(p_sv)then!P-SV waves
                write(35) b_absorb_elastic_left(1,:,:,:)
                write(35) b_absorb_elastic_left(3,:,:,:)
            else!SH (membrane) waves
                write(35) b_absorb_elastic_left(2,:,:,:)
            endif
        endif
        !--- right absorbing boundary
        if(nspec_right >0) then
            if(p_sv)then!P-SV waves
                write(36) b_absorb_elastic_right(1,:,:,:)
                write(36) b_absorb_elastic_right(3,:,:,:)
            else!SH (membrane) waves
                write(36) b_absorb_elastic_right(2,:,:,:)
            endif
        endif
        !--- bottom absorbing boundary
        if(nspec_bottom >0) then
            if(p_sv)then!P-SV waves
                write(37) b_absorb_elastic_bottom(1,:,:,:)
                write(37) b_absorb_elastic_bottom(3,:,:,:)
            else!SH (membrane) waves
                write(37) b_absorb_elastic_bottom(2,:,:,:)
            endif
        endif
        !--- top absorbing boundary
        if(nspec_top >0) then
            if(p_sv)then!P-SV waves
                write(38) b_absorb_elastic_top(1,:,:,:)
                write(38) b_absorb_elastic_top(3,:,:,:)
            else!SH (membrane) waves
                write(38) b_absorb_elastic_top(2,:,:,:)
            endif
        endif

   endif !any elastic

      close(35)
      close(36)
      close(37)
      close(38)
      close(71)


    if(any_poroelastic) then
      close(25)
      close(45)
      close(26)
      close(46)
      close(29)
      close(47)
      close(28)
      close(48)
    endif

  endif

!
!--- save last frame
!
  if(SAVE_FORWARD .and. SIMULATION_TYPE ==1 .and. any_elastic) then
    if ( myrank == 0 ) then
      write(IOUT,*)
      write(IOUT,*) 'Saving elastic last frame...'
      write(IOUT,*)
    endif
    write(outputname,'(a,i6.6,a)') 'lastframe_elastic',myrank,'.bin'
    open(unit=55,file='OUTPUT_FILES/'//outputname,status='unknown',form='unformatted')
    if(p_sv)then !P-SV waves
      !do j=1,nglob
        write(55) displ_elastic(1,:), displ_elastic(3,:), &
                  veloc_elastic(1,:), veloc_elastic(3,:), &
                  accel_elastic(1,:), accel_elastic(3,:)
      !enddo
    else !SH (membrane) waves
      !do j=1,nglob
        write(55) displ_elastic(2,:), &
                  veloc_elastic(2,:), &
                  accel_elastic(2,:)
     ! enddo
    endif
    close(55)
  endif

  if(SAVE_FORWARD .and. SIMULATION_TYPE ==1 .and. any_poroelastic) then
    if ( myrank == 0 ) then
      write(IOUT,*)
      write(IOUT,*) 'Saving poroelastic last frame...'
      write(IOUT,*)
    endif
    write(outputname,'(a,i6.6,a)') 'lastframe_poroelastic_s',myrank,'.bin'
    open(unit=55,file='OUTPUT_FILES/'//outputname,status='unknown',form='unformatted')
    write(outputname,'(a,i6.6,a)') 'lastframe_poroelastic_w',myrank,'.bin'
    open(unit=56,file='OUTPUT_FILES/'//outputname,status='unknown',form='unformatted')
     !  do j=1,nglob
      write(55) (displs_poroelastic(i,:), i=1,NDIM), &
                  (velocs_poroelastic(i,:), i=1,NDIM), &
                  (accels_poroelastic(i,:), i=1,NDIM)
      write(56) (displw_poroelastic(i,:), i=1,NDIM), &
                  (velocw_poroelastic(i,:), i=1,NDIM), &
                  (accelw_poroelastic(i,:), i=1,NDIM)
     !  enddo
    close(55)
    close(56)
  endif

  if(SAVE_FORWARD .and. SIMULATION_TYPE ==1 .and. any_acoustic) then
    if ( myrank == 0 ) then
      write(IOUT,*)
      write(IOUT,*) 'Saving acoustic last frame...'
      write(IOUT,*)
    endif
    write(outputname,'(a,i6.6,a)') 'lastframe_acoustic',myrank,'.bin'
    open(unit=55,file='OUTPUT_FILES/'//outputname,status='unknown',form='unformatted')
    !   do j=1,nglob
      write(55) potential_acoustic(:),&
               potential_dot_acoustic(:),&
               potential_dot_dot_acoustic(:)
   !    enddo
    close(55)
  endif


  deallocate(v0x_left)
  deallocate(v0z_left)
  deallocate(t0x_left)
  deallocate(t0z_left)

  deallocate(v0x_right)
  deallocate(v0z_right)
  deallocate(t0x_right)
  deallocate(t0z_right)

  deallocate(v0x_bot)
  deallocate(v0z_bot)
  deallocate(t0x_bot)
  deallocate(t0z_bot)

!----  close energy file
  if(output_energy .and. myrank == 0) close(IOUT_ENERGY)

  if (OUTPUT_MODEL_VELOCITY_FILE .and. .not. any_poroelastic) then
    write(outputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_rho_vp_vs.dat_output'
    open(unit=1001,file=outputname,status='unknown')
  !  write(outputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_anisotropy.dat_output'
    open(unit=1002,file=outputname,status='unknown')

    if ( .NOT. assign_external_model) then
      allocate(rho_local(ngllx,ngllz,nspec)); rho_local=0.
      allocate(vp_local(ngllx,ngllz,nspec)); vp_local=0.
      allocate(vs_local(ngllx,ngllz,nspec)); vs_local=0.
      do ispec = 1,nspec
        do j = 1,NGLLZ
          do i = 1,NGLLX
            iglob = ibool(i,j,ispec)
            rho_local(i,j,ispec) = density(1,kmato(ispec))
            vp_local(i,j,ispec) = sqrt(poroelastcoef(3,1,kmato(ispec))/density(1,kmato(ispec)))
            vs_local(i,j,ispec) = sqrt(poroelastcoef(2,1,kmato(ispec))/density(1,kmato(ispec)))
            write(1001,'(I10, 5F13.4)') iglob, coord(1,iglob),coord(2,iglob),&
                                      rho_local(i,j,ispec),vp_local(i,j,ispec),vs_local(i,j,ispec)
           ! write(1001,'(10e16.6)') rho_local(i,j,ispec), &

          enddo
        enddo
      enddo
    else
      do ispec = 1,nspec
        do j = 1,NGLLZ
          do i = 1,NGLLX
            iglob = ibool(i,j,ispec)
            write(1001,'(I10,5F13.4)') iglob, coord(1,iglob),coord(2,iglob),&
                                       rhoext(i,j,ispec),vpext(i,j,ispec),vsext(i,j,ispec)
          enddo
        enddo
      enddo
    endif
    close(1001)
  endif

! print exit banner
  if (myrank == 0) call datim(simulation_title)

!
!----  close output file
!
  if(IOUT /= ISTANDARD_OUTPUT) close(IOUT)

!
!----  end MPI
!
#ifdef USE_MPI
  call MPI_FINALIZE(ier)
#endif


end subroutine finalize_simulation
