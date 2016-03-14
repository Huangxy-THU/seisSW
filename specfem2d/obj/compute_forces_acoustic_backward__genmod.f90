        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:14:12 2016
        MODULE COMPUTE_FORCES_ACOUSTIC_BACKWARD__genmod
          INTERFACE 
            SUBROUTINE COMPUTE_FORCES_ACOUSTIC_BACKWARD(                &
     &B_POTENTIAL_DOT_DOT_ACOUSTIC,B_POTENTIAL_ACOUSTIC)
              USE SPECFEM_PAR, ONLY :                                   &
     &          NGLOB,                                                  &
     &          NSPEC,                                                  &
     &          NELEMABS,                                               &
     &          IT,                                                     &
     &          NSTEP,                                                  &
     &          ASSIGN_EXTERNAL_MODEL,                                  &
     &          IBOOL,                                                  &
     &          KMATO,                                                  &
     &          NUMABS,                                                 &
     &          ACOUSTIC,                                               &
     &          CODEABS,                                                &
     &          CODEABS_CORNER,                                         &
     &          DENSITY,                                                &
     &          POROELASTCOEF,                                          &
     &          XIX,                                                    &
     &          XIZ,                                                    &
     &          GAMMAX,                                                 &
     &          GAMMAZ,                                                 &
     &          JACOBIAN,                                               &
     &          VPEXT,                                                  &
     &          RHOEXT,                                                 &
     &          HPRIME_XX,                                              &
     &          HPRIMEWGLL_XX,                                          &
     &          HPRIME_ZZ,                                              &
     &          HPRIMEWGLL_ZZ,                                          &
     &          WXGLL,                                                  &
     &          WZGLL,                                                  &
     &          AXISYM,                                                 &
     &          COORD,                                                  &
     &          IS_ON_THE_AXIS,                                         &
     &          HPRIMEBAR_XX,                                           &
     &          HPRIMEBARWGLJ_XX,                                       &
     &          XIGLJ,                                                  &
     &          WXGLJ,                                                  &
     &          IBEGIN_EDGE1,                                           &
     &          IEND_EDGE1,                                             &
     &          IBEGIN_EDGE3,                                           &
     &          IEND_EDGE3,                                             &
     &          IBEGIN_EDGE4,                                           &
     &          IEND_EDGE4,                                             &
     &          IBEGIN_EDGE2,                                           &
     &          IEND_EDGE2,                                             &
     &          IB_LEFT,                                                &
     &          IB_RIGHT,                                               &
     &          IB_BOTTOM,                                              &
     &          IB_TOP,                                                 &
     &          B_ABSORB_ACOUSTIC_LEFT,                                 &
     &          B_ABSORB_ACOUSTIC_RIGHT,                                &
     &          B_ABSORB_ACOUSTIC_BOTTOM,                               &
     &          B_ABSORB_ACOUSTIC_TOP,                                  &
     &          STACEY_BOUNDARY_CONDITIONS
              REAL(KIND=4) :: B_POTENTIAL_DOT_DOT_ACOUSTIC(NGLOB)
              REAL(KIND=4) :: B_POTENTIAL_ACOUSTIC(NGLOB)
            END SUBROUTINE COMPUTE_FORCES_ACOUSTIC_BACKWARD
          END INTERFACE 
        END MODULE COMPUTE_FORCES_ACOUSTIC_BACKWARD__genmod
