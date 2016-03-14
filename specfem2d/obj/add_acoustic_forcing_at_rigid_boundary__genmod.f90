        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:14:13 2016
        MODULE ADD_ACOUSTIC_FORCING_AT_RIGID_BOUNDARY__genmod
          INTERFACE 
            SUBROUTINE ADD_ACOUSTIC_FORCING_AT_RIGID_BOUNDARY(          &
     &POTENTIAL_DOT_DOT_ACOUSTIC)
              USE SPECFEM_PAR, ONLY :                                   &
     &          NGLOB_ACOUSTIC,                                         &
     &          NELEM_ACFORCING,                                        &
     &          CODEACFORCING,                                          &
     &          NUMACFORCING,                                           &
     &          ACOUSTIC,                                               &
     &          IBOOL,                                                  &
     &          XIX,                                                    &
     &          XIZ,                                                    &
     &          JACOBIAN,                                               &
     &          GAMMAX,                                                 &
     &          GAMMAZ,                                                 &
     &          WXGLL,                                                  &
     &          WZGLL,                                                  &
     &          PML_BOUNDARY_CONDITIONS,                                &
     &          IS_PML
              REAL(KIND=4) :: POTENTIAL_DOT_DOT_ACOUSTIC(NGLOB_ACOUSTIC)
            END SUBROUTINE ADD_ACOUSTIC_FORCING_AT_RIGID_BOUNDARY
          END INTERFACE 
        END MODULE ADD_ACOUSTIC_FORCING_AT_RIGID_BOUNDARY__genmod
