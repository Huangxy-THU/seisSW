        !COMPILER-GENERATED INTERFACE MODULE: Sat Mar 12 17:14:01 2016
        MODULE LFIT_ZENER__genmod
          INTERFACE 
            SUBROUTINE LFIT_ZENER(X,Y,SIG,NDAT,POIDS,IA,COVAR,CHISQ,MA, &
     &QREF,POINT)
              INTEGER(KIND=4), INTENT(IN) :: MA
              INTEGER(KIND=4), INTENT(IN) :: NDAT
              REAL(KIND=8), INTENT(IN) :: X(1:NDAT)
              REAL(KIND=8), INTENT(IN) :: Y(1:NDAT)
              REAL(KIND=8), INTENT(IN) :: SIG(1:NDAT)
              REAL(KIND=8), INTENT(OUT) :: POIDS(1:MA)
              LOGICAL(KIND=4), INTENT(IN) :: IA(1:MA)
              REAL(KIND=8), INTENT(OUT) :: COVAR(1:MA,1:MA)
              REAL(KIND=8), INTENT(OUT) :: CHISQ
              REAL(KIND=8), INTENT(IN) :: QREF
              REAL(KIND=8), INTENT(IN) :: POINT(1:MA)
            END SUBROUTINE LFIT_ZENER
          END INTERFACE 
        END MODULE LFIT_ZENER__genmod
