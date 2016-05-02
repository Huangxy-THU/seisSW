        !COMPILER-GENERATED INTERFACE MODULE: Sun May  1 23:04:27 2016
        MODULE SYST_LU__genmod
          INTERFACE 
            SUBROUTINE SYST_LU(A,I_MIN,N,B,M)
              INTEGER(KIND=4), INTENT(IN) :: M
              INTEGER(KIND=4), INTENT(IN) :: N
              INTEGER(KIND=4), INTENT(IN) :: I_MIN
              REAL(KIND=8), INTENT(IN) :: A(I_MIN:N,I_MIN:N)
              REAL(KIND=8), INTENT(INOUT) :: B(I_MIN:N,I_MIN:M)
            END SUBROUTINE SYST_LU
          END INTERFACE 
        END MODULE SYST_LU__genmod
