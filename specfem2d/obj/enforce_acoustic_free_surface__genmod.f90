        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:15:11 2016
        MODULE ENFORCE_ACOUSTIC_FREE_SURFACE__genmod
          INTERFACE 
            SUBROUTINE ENFORCE_ACOUSTIC_FREE_SURFACE(                   &
     &POTENTIAL_DOT_DOT_ACOUSTIC,POTENTIAL_DOT_ACOUSTIC,                &
     &POTENTIAL_ACOUSTIC)
              USE SPECFEM_PAR, ONLY :                                   &
     &          ACOUSTIC_SURFACE,                                       &
     &          IBOOL,                                                  &
     &          NELEM_ACOUSTIC_SURFACE,                                 &
     &          NGLOB,                                                  &
     &          THIS_IBOOL_IS_A_PERIODIC_EDGE
              REAL(KIND=4) :: POTENTIAL_DOT_DOT_ACOUSTIC(NGLOB)
              REAL(KIND=4) :: POTENTIAL_DOT_ACOUSTIC(NGLOB)
              REAL(KIND=4) :: POTENTIAL_ACOUSTIC(NGLOB)
            END SUBROUTINE ENFORCE_ACOUSTIC_FREE_SURFACE
          END INTERFACE 
        END MODULE ENFORCE_ACOUSTIC_FREE_SURFACE__genmod
