        !COMPILER-GENERATED INTERFACE MODULE: Sun May  1 23:06:31 2016
        MODULE WRITE_OUTPUT_SU__genmod
          INTERFACE 
            SUBROUTINE WRITE_OUTPUT_SU(X_SOURCE,Z_SOURCE,IREC,          &
     &BUFFER_BINARY,NUMBER_OF_COMPONENTS)
              USE SPECFEM_PAR, ONLY :                                   &
     &          NSTEP,                                                  &
     &          NREC,                                                   &
     &          DELTAT,                                                 &
     &          SEISMOTYPE,                                             &
     &          ST_XVAL,                                                &
     &          NSTEP_BETWEEN_OUTPUT_SEISMOS,                           &
     &          SEISMO_OFFSET,                                          &
     &          SEISMO_CURRENT,                                         &
     &          P_SV,                                                   &
     &          ST_ZVAL,                                                &
     &          SUBSAMP_SEISMOS
              INTEGER(KIND=4) :: NUMBER_OF_COMPONENTS
              REAL(KIND=8) :: X_SOURCE
              REAL(KIND=8) :: Z_SOURCE
              INTEGER(KIND=4) :: IREC
              REAL(KIND=8) :: BUFFER_BINARY(NSTEP_BETWEEN_OUTPUT_SEISMOS&
     &/SUBSAMP_SEISMOS,NREC,NUMBER_OF_COMPONENTS)
            END SUBROUTINE WRITE_OUTPUT_SU
          END INTERFACE 
        END MODULE WRITE_OUTPUT_SU__genmod
