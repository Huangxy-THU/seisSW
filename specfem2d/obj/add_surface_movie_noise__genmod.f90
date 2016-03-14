        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:15:34 2016
        MODULE ADD_SURFACE_MOVIE_NOISE__genmod
          INTERFACE 
            SUBROUTINE ADD_SURFACE_MOVIE_NOISE(ACCEL_ELASTIC)
              USE SPECFEM_PAR, ONLY :                                   &
     &          P_SV,                                                   &
     &          NOISE_TOMOGRAPHY,                                       &
     &          IT,                                                     &
     &          NSTEP,                                                  &
     &          NSPEC,                                                  &
     &          NGLOB,                                                  &
     &          IBOOL,                                                  &
     &          SURFACE_MOVIE_X_NOISE,                                  &
     &          SURFACE_MOVIE_Y_NOISE,                                  &
     &          SURFACE_MOVIE_Z_NOISE,                                  &
     &          MASK_NOISE,                                             &
     &          JACOBIAN,                                               &
     &          WXGLL,                                                  &
     &          WZGLL
              REAL(KIND=4) :: ACCEL_ELASTIC(3,NGLOB)
            END SUBROUTINE ADD_SURFACE_MOVIE_NOISE
          END INTERFACE 
        END MODULE ADD_SURFACE_MOVIE_NOISE__genmod
