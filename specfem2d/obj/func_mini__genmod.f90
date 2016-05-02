        !COMPILER-GENERATED INTERFACE MODULE: Sun May  1 23:04:27 2016
        MODULE FUNC_MINI__genmod
          INTERFACE 
            SUBROUTINE FUNC_MINI(X,RES,QREF,N,NOPT,K,F_MIN,F_MAX)
              INTEGER(KIND=4), INTENT(IN) :: NOPT
              REAL(KIND=8), INTENT(IN) :: X(1:NOPT)
              REAL(KIND=8), INTENT(OUT) :: RES
              REAL(KIND=8), INTENT(IN) :: QREF
              INTEGER(KIND=4), INTENT(IN) :: N
              INTEGER(KIND=4), INTENT(IN) :: K
              REAL(KIND=8), INTENT(IN) :: F_MIN
              REAL(KIND=8), INTENT(IN) :: F_MAX
            END SUBROUTINE FUNC_MINI
          END INTERFACE 
        END MODULE FUNC_MINI__genmod
