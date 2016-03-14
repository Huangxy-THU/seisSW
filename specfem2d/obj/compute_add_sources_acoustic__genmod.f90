        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:14:13 2016
        MODULE COMPUTE_ADD_SOURCES_ACOUSTIC__genmod
          INTERFACE 
            SUBROUTINE COMPUTE_ADD_SOURCES_ACOUSTIC(                    &
     &POTENTIAL_DOT_DOT_ACOUSTIC,IT,I_STAGE)
              USE SPECFEM_PAR, ONLY :                                   &
     &          ACOUSTIC,                                               &
     &          NGLOB_ACOUSTIC,                                         &
     &          NSOURCES,                                               &
     &          SOURCE_TYPE,                                            &
     &          SOURCE_TIME_FUNCTION,                                   &
     &          IS_PROC_SOURCE,                                         &
     &          ISPEC_SELECTED_SOURCE,                                  &
     &          HXIS_STORE,                                             &
     &          HGAMMAS_STORE,                                          &
     &          IBOOL,                                                  &
     &          KAPPASTORE
              REAL(KIND=4) :: POTENTIAL_DOT_DOT_ACOUSTIC(NGLOB_ACOUSTIC)
              INTEGER(KIND=4) :: IT
              INTEGER(KIND=4) :: I_STAGE
            END SUBROUTINE COMPUTE_ADD_SOURCES_ACOUSTIC
          END INTERFACE 
        END MODULE COMPUTE_ADD_SOURCES_ACOUSTIC__genmod
