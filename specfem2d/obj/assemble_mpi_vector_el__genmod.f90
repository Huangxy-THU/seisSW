        !COMPILER-GENERATED INTERFACE MODULE: Wed Oct 21 17:45:54 2015
        MODULE ASSEMBLE_MPI_VECTOR_EL__genmod
          INTERFACE 
            SUBROUTINE ASSEMBLE_MPI_VECTOR_EL(ARRAY_VAL2)
              USE SPECFEM_PAR, ONLY :                                   &
     &          NGLOB,                                                  &
     &          NINTERFACE_ELASTIC,                                     &
     &          INUM_INTERFACES_ELASTIC,                                &
     &          IBOOL_INTERFACES_ELASTIC,                               &
     &          NIBOOL_INTERFACES_ELASTIC,                              &
     &          TAB_REQUESTS_SEND_RECV_ELASTIC,                         &
     &          BUFFER_SEND_FACES_VECTOR_EL,                            &
     &          BUFFER_RECV_FACES_VECTOR_EL,                            &
     &          MY_NEIGHBOURS
              REAL(KIND=4), INTENT(INOUT) :: ARRAY_VAL2(3,NGLOB)
            END SUBROUTINE ASSEMBLE_MPI_VECTOR_EL
          END INTERFACE 
        END MODULE ASSEMBLE_MPI_VECTOR_EL__genmod
