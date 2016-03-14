        !COMPILER-GENERATED INTERFACE MODULE: Wed Oct 21 17:45:54 2015
        MODULE ASSEMBLE_MPI_VECTOR_AC__genmod
          INTERFACE 
            SUBROUTINE ASSEMBLE_MPI_VECTOR_AC(ARRAY_VAL1)
              USE SPECFEM_PAR, ONLY :                                   &
     &          NGLOB,                                                  &
     &          NINTERFACE_ACOUSTIC,                                    &
     &          INUM_INTERFACES_ACOUSTIC,                               &
     &          IBOOL_INTERFACES_ACOUSTIC,                              &
     &          NIBOOL_INTERFACES_ACOUSTIC,                             &
     &          TAB_REQUESTS_SEND_RECV_ACOUSTIC,                        &
     &          BUFFER_SEND_FACES_VECTOR_AC,                            &
     &          BUFFER_RECV_FACES_VECTOR_AC,                            &
     &          MY_NEIGHBOURS,                                          &
     &          IER
              REAL(KIND=4), INTENT(INOUT) :: ARRAY_VAL1(NGLOB)
            END SUBROUTINE ASSEMBLE_MPI_VECTOR_AC
          END INTERFACE 
        END MODULE ASSEMBLE_MPI_VECTOR_AC__genmod
