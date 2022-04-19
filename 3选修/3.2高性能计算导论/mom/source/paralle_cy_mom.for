C *-----------------------------------------------------------------------
C *  PARALLEL_MOM 
C *
C *  MoM Analysis of PEC Cylinders for TM-POL 
C *  Plane-wave Excitation -- Program Finds the Current 
C *  Density and RCS 
C *  The E-field Integral Equation is Discretized with Pulse Basis 
C *  Functions and Tested with Point-Matching 
C *         
C * + Description 
C *    A Frame Code for Parallelizing MoM Using ScaLAPACK and MPICH2 
C * + Note: Demonstration Purpose Only, Not Optimized for Performance!!! 
C *---------------------------------------------------------------------- 
C *  MOM VARIABLES 
C *---------------------------------------------------------------------- 
 
      MODULE MOM_VARIABLES 
      IMPLICIT NONE 
      DOUBLE PRECISION ,PARAMETER:: E=2.7182818284590451,GAMA=1.78107 
      COMPLEX*16 ,PARAMETER :: CJ=CMPLX(0,1) 
      DOUBLE PRECISION ,PARAMETER :: PI=3.14159265 
      DOUBLE PRECISION WAVElength, A,B, WAVEK,DPHI,CN,DIST, DOAINC 
      INTEGER NUN 
      COMPLEX*16, ALLOCATABLE :: Z_MN(:,:) , V_M(:) 
      COMPLEX*16, ALLOCATABLE :: CWW(:) , CCWW(:) 
      COMPLEX*16, ALLOCATABLE :: NEARF(:,:),SUM_NEARF(:,:) 
      DOUBLE PRECISION ,ALLOCATABLE :: RCS(:),SUM_RCS(:) 
      INTEGER   NPHI, NX, NY 
      DOUBLE PRECISION  W 
      INTEGER :: M,N, LCOLNUM,LROWNUM
      DOUBLE PRECISION starttime1,endtime1,starttime2,endtime2,
     +                   FILLT,SOLVET
      
C *---------------------------------------------------------------------- 
C *             GEOMITRICAL VARIABLES 
C *---------------------------------------------------------------------- 
      DOUBLE PRECISION,ALLOCATABLE ::XN(:),YN(:),ARCLENGTH(:) 
     +   ,XCN(:),YCN(:)       
      END MODULE MOM_VARIABLES   
 
C *---------------------------------------------------------------------- 
C *                     MPI  VARIABLES 
C *---------------------------------------------------------------------- 
 
      MODULE MPI_VARIABLES 
      INTEGER :: MY_MPI_FLOAT, MY_ID, NPROCESS 
      INTEGER, PARAMETER :: SFP = SELECTED_REAL_KIND(6,37)    
      INTEGER, PARAMETER  :: DFP = SELECTED_REAL_KIND(13,99) 
      INTEGER, PARAMETER :: RFP=DFP    ! 32 BIT PRECISION 
      INTEGER :: ISTAT, ERROR,IERR 
      END MODULE MPI_VARIABLES 
       
C *---------------------------------------------------------------------- 
C *                     ScaLAPACK VARIABLES 
C *---------------------------------------------------------------------- 
 
      MODULE SCALAPACK_VARIABLES        
      INTEGER   DLEN_,IA,JA,IB,JB,MB,NB,RSRC,CSRC, MXLLDA, MXLLDB, NRHS,
     +           NBRHS, NOUT,MXLOCR, MXLOCC, MXRHSC 
      PARAMETER  ( DLEN_ = 9,  NOUT = 6 ) 
      DOUBLE PRECISION   ONE 
      PARAMETER  ( ONE = 1.0D+0 )      
C *    .. LOCAL SCALARS .. 
      INTEGER    ICTXT, INFO, MYCOL, MYROW, NPCOL, NPROW        
      INTEGER    NPROC_ROWS 
      INTEGER    NPROC_COLS 
      INTEGER    NROW_BLOCK   !MB 
      INTEGER    NCOL_BLOCK    !NB 
      INTEGER    ICROW 
      INTEGER    ICCOL 
      INTEGER    LOCAL_MAT_ROWS,LOCAL_MAT_COLS,B_LOCAL_SIZE  
      INTEGER, ALLOCATABLE:: IPIV(:), DESCA(:), DESCB(:)     
      CHARACTER,PARAMETER ::TRANS='N'    
C****************************************************       
C* EXTERNAL FUNCTIONS
C***************************************************
      INTEGER,EXTERNAL ::   INDXG2P,INDXG2L,INDXL2G,NUMROC 
      END MODULE SCALAPACK_VARIABLES        
C *---------------------------------------------------------------------- 
C *                  PARALLEL CODE STARTS HERE 
C *----------------------------------------------------------------------  
 
      PROGRAM PARALLEL_MOM 
 
C *---------------------------------------------------------------------- 
C *                     GLOBAL VARIABLES 
C *----------------------------------------------------------------------  
      USE MPI_VARIABLES 
      USE MOM_VARIABLES 
      USE SCALAPACK_VARIABLES 
C      USE DFPORT 
      IMPLICIT NONE 
      INCLUDE 'mpif.h' 
      COMPLEX*16,EXTERNAL :: H02 
  
C *---------------------------------------------------------------------- 
C *                     LOCAL VARIABLES 
C *----------------------------------------------------------------------  
      INTEGER::I,J 
      INTEGER ITEMP,JTEMP 
      INTEGER STATUS(MPI_STATUS_SIZE) 
      INTEGER :: III,JJJ 
      INTEGER :: NO_USE_1
      REAL    :: NO_USE_2,PER
      character :: nameindex
 
C *---------------------------------------------------------------------- 
C *                   MAIN PROGRAM STARTS HERE 
C *----------------------------------------------------------------------  
 
C *---------------------------------------------------------------------- 
C *                   MPI INITIALIZING  
C *---------------------------------------------------------------------- 
      CALL MPI_INIT(IERR) 
      CALL MPI_COMM_SIZE(MPI_COMM_WORLD, NPROCESS, IERR) 
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, MY_ID, IERR) 
 
      IF (RFP==SFP) THEN 
        MY_MPI_FLOAT = MPI_REAL 
      ELSE IF (RFP==DFP) THEN 
        MY_MPI_FLOAT = MPI_DOUBLE_PRECISION 
      ELSE 
        WRITE(*,*) 'FATAL ERROR! , MY_ID = ', MY_ID 
        STOP 
      END IF 
C *---------------------------------------------------------------------- 
C                 INPUT PROCESS GRID AND BLOCK SIZE 
C *----------------------------------------------------------------------  
      IF (MY_ID.EQ.0) THEN 
C        WRITE(*,*)'Input Number of Rows in the process grid,' 
C        WRITE(*,*)' Number of Columns in the process grid, ' 
C        WRITE(*,*)' and Row and Column Block  size ' 
 
C        READ(5,*) NPROC_ROWS, NPROC_COLS, NROW_BLOCK, NCOL_BLOCK 


C**************************************************************
C    SET THE PROCESS GRID AND BLOCK SIZE
C**************************************************************
      OPEN(18,file="input.txt")
	      READ(18,*)
	      READ(18,*) NPROC_ROWS
	      READ(18,*)
	      READ(18,*) NPROC_COLS
	      READ(18,*)
	      READ(18,*) NROW_BLOCK
	      READ(18,*)
	      READ(18,*) NCOL_BLOCK
	      READ(18,*)
	      READ(18,*) NUN
C***************************************************************
      IF (NPROCESS.LT.(NPROC_ROWS*NPROC_COLS)) THEN 
        WRITE(6,250)  NPRO CESS, NPROC_ROWS, NPROC_COLS 
  250      FORMAT(' ','PROC ','  > NP = ',I2,', NPROC_ROWS = ',I2,',
     +             NPROC_COLS = ',I2) 
        WRITE(6,260) 
  260      FORMAT(' ','NEED MORE PROCESSES!  QUITTING.') 
               WRITE(*,*) 'ABNORMALLY QUIT!' 
      CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERR) 
          END IF 
      IF (NPROCESS.GT.(NPROC_ROWS*NPROC_COLS)) THEN 
        WRITE(6,270)  NPRO CESS, NPROC_ROWS, NPROC_COLS 
  270      FORMAT(' ','PROC ','  < NP = ',I2,', NPROC_ROWS = ',I2,', 
     +             NPROC_COLS = ',I2) 
      WRITE(6,280) 
  280       FORMAT(' ','CHECK PROCESS GRID!  QUITTING.') 
               WRITE(*,*) 'ABNORMALLY QUIT!' 
      CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERR) 
          ENDIF 
      IF (NROW_BLOCK .NE. NCOL_BLOCK) THEN 
        WRITE(6,290)  NROW_BLOCK, NCOL_BLOCK 
 290        FORMAT(' ', 'NROW_BLOCK = ',I2,',','NCOL_BLOCK= ',I2) 
        WRITE(6,291) 
 291        FORMAT(' ','NROW_BLOCK!= NPROC_COLS,  QUITTING.')  
              WRITE(*,*) 'ABNORMALLY QUIT!' 
      CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERR)              
          END IF
         END IF 
		     CLOSE(18)
  
       CALL MPI_BCAST(NPROC_ROWS,1,MPI_INTEGER,0,MPI_COMM_WORLD,IERR) 
       CALL MPI_BCAST(NPROC_COLS,1,MPI_INTEGER,0,MPI_COMM_WORLD,IERR) 
       CALL MPI_BCAST(NROW_BLOCK,1,MPI_INTEGER,0,MPI_COMM_WORLD, IERR) 
       CALL MPI_BCAST(NCOL_BLOCK,1,MPI_INTEGER,0,MPI_COMM_WORLD, IERR) 
	   CALL MPI_BCAST(NUN,1,MPI_INTEGER,0,MPI_COMM_WORLD, IERR)
       CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)
C *---------------------------------------------------------------------- 
C *                   MOM INITIALIZING  
C *----------------------------------------------------------------------  
c      NUN=1000; 
      ALLOCATE (XN(1:NUN+1),YN(1:NUN+1),ARCLENGTH(1:NUN+1), STAT=ISTAT)  
      ALLOCATE (XCN(1:NUN),YCN(1:NUN), STAT=ISTAT)       
      ALLOCATE (IPIV(1:NUN), STAT=ISTAT)        
      ALLOCATE( CWW(1:NUN),CCWW(1:NUN), STAT=ISTAT ) 




      IF (MY_ID ==0) THEN 
      CALL GEONWAVE_INITIALIZE 
      ENDIF 
      CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)  
      CALL GEONWAVE_PARA_INITIALIZE 
      CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)   
C *---------------------------------------------------------------------- 
C *                   BLACS  INITIALIZING  
C *----------------------------------------------------------------------  
      CALL BLACS_PINFO(MY_ID,NPROCESS) 
      CALL BLACS_GET(-1, 0,ICTXT)            
      CALL BLACS_GRIDINIT(ICTXT,'R',NPROC_ROWS,NPROC_COLS)    
      CALL BLACS_GRIDINFO(ICTXT , NPROC_ROWS,NPROC_COLS, MYROW, MYCOL ) 
      CALL BLACS_PCOORD(ICTXT, MY_ID, MYROW,MYCOL) 
C *---------------------------------------------------------------------- 
C *  GET LOCAL MATRIX DIMENSION INFORMATION 
C *----------------------------------------------------------------------  
      LOCAL_MAT_ROWS = NUMROC(NUN, NROW_BLOCK, MYROW, 0, NPROC_ROWS) 
      LOCAL_MAT_COLS = NUMROC(NUN, NCOL_BLOCK, MYCOL, 0, NPROC_COLS) 
      B_LOCAL_SIZE = NUMROC(NUN, NROW_BLOCK, MYROW,0, NPROC_ROWS) 
C *---------------------------------------------------------------------- 
C *   ALLOCATE  RAM FOR IMPE DANCE MATRIX AND VOLTAGE  
C *   VECTOR ON EACH PROCESS, THEN INITIALIZING THE ARRAY 
C *---------------------------------------------------------------------- 
      ALLOCATE( V_M(1:B_LOCAL_SIZE),  STAT=ISTAT )  
      ALLOCATE( Z_MN(1:LOCAL_MAT_ROWS ,1:LOCAL_MAT_COLS ),STAT=ISTAT) 
          Z_MN(:,:)=0.0D0 
          V_M(:)=0 
C *---------------------------------------------------------------------- 
C *     INITIALIZE THE ARRAY DESCRIPTORS  
C *----------------------------------------------------------------------  
      ALLOCATE( DESCA( DLEN_ ), DESCB(  DLEN_  )) 
      IA = 1 
      JA = 1 
      IB = 1 
      JB = 1 
      RSRC=0 
      CSRC=0 
      NRHS=1 
      NBRHS=1  
C * ---------------------------------------------------------------------- 
C *  DESCINIT INITIALIZES THE DESCRIPTOR VECTOR. 
C *  EACH GLOBAL DATA OBJECT IS DESCRIBED BY AN ASSOCIATED 
C *  DESCRIPTION VECTOR DESCA .  THIS VECTOR STORES THE 
C *  INFORMATION REQUIRED TO  ESTABLISH  THE MAPPING   
C *  BETWEEN AN OBJECT ELEMENT AND ITS CORRESPONDING 
C *  PROCESS AND MEMORY LOCATION. 
C * ---------------------------------------------------------------------- 
      CALL DESCINIT( DESCA, NUN, NUN, NROW_BLOCK,NCOL_BLOCK,RSRC,
     +               CSRC, ICTXT, LOCAL_MAT_ROWS,INFO ) 
      CALL DESCINIT( DESCB, NUN, NRHS, NROW_BLOCK, NBRHS,RSRC,  
     +                CSRC, ICTXT,B_LOCAL_SIZE, INFO )   
       IF (MY_ID ==0) OPEN(147,file='pmom.log')
       IF (MY_ID ==0) WRITE(147,*) 'THIS PROGRAM SOLVE MATRIX WITH'
     +              ,NUN, '    UNKNOWN'
       IF (MY_ID ==0)   starttime1=MPI_WTIME()  
       IF (MY_ID ==0)  WRITE(147,*) 'START TO FILL THE  MATRIX' 
      CALL MATRIX_FILLING   
       IF (MY_ID ==0) WRITE(147,*) 'FINISH MATRIX FILLING' 
       IF (MY_ID ==0)   endtime1=MPI_WTIME()
         FILLT=endtime1-starttime1
       IF (MY_ID ==0)  WRITE(147,*) "MATRIX FILL TIME ",FILLT,"SECONDS"
C *---------------------------------------------------------------------- 
C *       CALL  SCALAPACK ROUTINES TO 
C *       SOLVE THE LINEAR SYSTEM [Z]*[I] = [V] 
C *       USING LU DECOMPOSITION METHOD 
C *---------------------------------------------------------------------- 
clv       IF (MY_ID ==0)   starttime2=MPI_WTIME()
       IF (MY_ID ==0) WRITE(147,*) 'START TO SOLVE THE MATRIX EQUATION'  
      IF (MY_ID ==0) print*,LOCAL_MAT_ROWS,LOCAL_MAT_COLS
c mic
c      call mic_work_init( LOCAL_MAT_ROWS, LOCAL_MAT_COLS, NCOL_BLOCK, 
c     +             Z_MN, Z_MN, Z_MN)

      CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)
       IF (MY_ID ==0)     starttime2=MPI_WTIME()
      IF (MY_ID ==0) WRITE(*,*) 'START PZGETRF'
      CALL PZGETRF(NUN,NUN ,Z_MN,IA,JA, DESCA,IPIV,INFO)
c mic
c      CALL pzcatilelu(NUN,NUN ,Z_MN,IA,JA, DESCA,IPIV,INFO)
      CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)
      IF (MY_ID ==0) WRITE(*,*) 'FINISH PZGETRF'
       IF (MY_ID ==0) endtime2=MPI_WTIME()  
c mic
c      call mic_work_final(LOCAL_MAT_COLS)
      CALL PZGETRS(TRANS,NUN,NRHS,Z_MN,IA,JA,DESCA,IPIV,V_M,IB,JB,DESCB,
     +             INFO ) 
 
       IF (MY_ID ==0) WRITE(147,*) 'FINISH SOLVING THE MATRIX EQUATION'
       SOLVET=endtime2-starttime2
       IF (MY_ID ==0) WRITE(147,*) "MATRIX SPLVE TIME ",SOLVET,"SECONDS"
C *---------------------------------------------------------------------- 
C *         COLLECT CURRENT COEFFICIENT FROM DIFFERENT  
C *         PROCESS USING MPI_REDUCE   
C *----------------------------------------------------------------------  
         CWW(1:NUN)=0 
        IF(MYCOL==0)  THEN 
          DO III=1,B_LOCAL_SIZE 
            JJJ=INDXL2G(III,NROW_BLOCK,MYROW,RSRC,NPROC_ROWS) 
            CWW(JJJ)=V_M(III) 
          ENDDO     
        ENDIF 
       
        CCWW(1:NUN)=0        
      CALL MPI_REDUCE(CWW,CCWW,NUN,MPI_DOUBLE_COMPLEX,MPI_SUM,0,
     +                 MPI_COMM_WORLD,IERR) 
 
      CALL MPI_BCAST(CCWW,NUN,MPI_DOUBLE_COMPLEX,0,MPI_COMM_WORLD,IERR) 
C *---------------------------------------------------------------------- 
C *         OUTPUT THE CURRENT COEFFICIENT 
C *----------------------------------------------------------------------  
      IF (MY_ID ==0) THEN 
      OPEN ( UNIT=2,  FILE='CURRENT_PARALLEL.DAT' )  
      DO III=1,NUN 
      WRITE(2,*) ABS(CCWW(III))  
C *   *120*PI  ! IF NORMALIZE TO |HINC| 
C *    REAL(CCWW(III)), CIMAG(CCWW(III)) 
      ENDDO 
      CLOSE(2) 
      ENDIF 
C *---------------------------------------------------------------------- 
C *        POST PROCES SING TO CALCULATE THE RCS 
C *----------------------------------------------------------------------  
      IF (MY_ID ==0) WRITE(147,*) 'START POST PROCESSING'  
      CALL POST_PROCESSING 
      IF (MY_ID ==0) WRITE(147,*) 'FINISH POST PROCESSING'  
C *---------------------------------------------------------------------- 
C *        EXIT THE CODE 
C *---------------------------------------------------------------------- 
      IF ( MY_ID .EQ. 0) WRITE(147,*) 'PROGRAM FINISHED PROPERLY' 
      CALL MPI_FINALIZE(IERR) 
       
      END PROGRAM PARALLEL_MOM 
C**************************************************************************
      SUBROUTINE POST_PROCESSING 
C *---------------------------------------------------------------------- 
C *         THE CODE HERE IS NOT OPTIMIZED FOR A MINIMUM  
C *         REQUIREMENT OF RAM FOR PARALLEL POST PROCESSING  
C **---------------------------------------------------------------------- 
      USE MOM_VARIABLES 
      USE MPI_VARIABLES, ONLY: MY_ID, ISTAT, NPROCESS 
      IMPLICIT NONE  
  
      INCLUDE 'mpif.h'  
      INTEGER IX, IY,I,IPHI,IERR 
      DOUBLE PRECISION XO,YO 
      DOUBLE PRECISION PHI 
      COMPLEX*16,EXTERNAL :: H02,EINC 
      COMPLEX*16 SIG 
      W=4*WAVElength 
      NX=100 
      NY=100 
      NPHI=360 
  
      ALLOCATE( NEARF(1:NX,1:NY),SUM_NEARF(1:NX,1:NY), STAT=ISTAT)   
      ALLOCATE( RCS(1:NPHI),SUM_RCS(1:NPHI), STAT=ISTAT) 
  
      NEARF(1:NX ,1:NY)=0 
      SUM_NEARF(1:NX,1:NY)=0 
      RCS(1:NPHI)=0 
      SUM_RCS(1:NPHI)=0 
C *---------------------------------------------------------------------- 
C *     COMPUTE THE BISTATIC RCS 
C * ---------------------------------------------------------------------- 
      DO IPHI=1,NPHI 
      IF ( MOD((IPHI-1),NPROCESS) == MY_ID) THEN 
      PHI=IPHI*PI/180.0 
      SIG = (0.,0.) 
      DO  I=1,NUN 
       SIG = SIG + CCWW(I)*cdEXP(1.0*CJ*WAVEK*( XCN(I)*COS(PHI)+ 
     +                 YCN(I)*SIN(PHI) ) )*ARCLENGTH(I) 
      ENDDO 
      RCS(IPHI) = 10.*LOG10(CDABS(SIG)**2 * WAVEK*(120*PI)**2/4.0) 
           
      ENDIF 
      ENDDO 
      CALL  MPI_REDUCE(RCS,SUM_RCS,NPHI,MPI_DOUBLE_PRECISION,MPI_SUM,0,
     +                  MPI_COMM_WORLD,IERR) 
      IF (MY_ID==0)    THEN 
 
      OPEN(4,FILE='RCS_PARALLEL.DAT') 
      WRITE(4,*) 'RCS IN DB-WAVELENGTH' 
      WRITE(4,*) ' ANGLE  RCS' 
      WRITE(4,*) 
      DO IPHI=1,NPHI 
      WRITE(4,*) IPHI,SUM_RCS(IPHI)   
      ENDDO 
      ENDIF          
      
      DO  IX=1,NX 
         XO = (2*((IX-1.0)/(NX-1))-1)*W; 
      DO IY=1,NY 
         YO = (2*((IY-1.0)/(NY-1))-1)*W;         
      IF (  MOD((IX-1)*NX+IY-1,NPROCESS)==MY_ID) THEN       
      DO N=1,NUN 
      DIST = SQRT((XO-XCN(N))**2+(YO-YCN(N))**2);           
      NEARF(IX,IY) =  NEARF(IX,IY)-120*PI/4.*CN*WAVEK *CCWW(N)
     +                 *H02(WAVEK*DIST) 
      ENDDO
      NEARF(IX,IY) =  NEARF(IX,IY)+EINC(XO,YO,DOAINC)       
      ENDIF 
       
      ENDDO 
      ENDDO   
       
      SUM_NEARF(1:NX,1:NY)=0 
       
      CALL MPI_REDUCE (NEARF,SUM_NEARF,NX*NY,MPI_DOUBLE_COMPLEX, 
     +     MPI_SUM,0,MPI_COMM_WORLD,IERR) 
 
      IF (MY_ID==0) THEN 
      OPEN (3, FILE = "NEARF_PARALLEL.DAT") 
      DO  IX=1,NX 
      DO IY=1,NY 
      WRITE(3,*)ABS(SUM_NEARF(IX,IY))       
 
      ENDDO
      ENDDO 
      CLOSE(3) 
      ENDIF 
         
      END SUBROUTINE POST_PROCESSING 
C *----------------------------------------------------------------------  
      SUBROUTINE GEONWAVE_INITIALIZE 
C *---------------------------------------------------------------------- 
C *      THIS SUBROUTINE WILL RETURN HOW MANY UNKNOWNS 
C *      AND GEOMETIRC INFO  FOR IMPEDANCE MATRIX AND  
C *      VOLTAGE MATRIX OF MOM.  
C *      THE FOLLOWING ARE THE GEOMETRIC COORDINATES (X,Y) 
C *      OF EACH  SUBDIVISION ALONG THE BOUNDARY OF 
C *      THE PEC CYLINDER   
C *---------------------------------------------------------------------- 
      USE MOM_VARIABLES 
      USE MPI_VARIABLES,ONLY:MY_ID,ISTAT,IERR,MY_MPI_FLOAT  
      USE SCALAPACK_VARIABLES,ONLY: IPIV 
      IMPLICIT NONE 
      INCLUDE 'mpif.h'      
      INTEGER I 
 
      WAVElength=1.0;         
      WAVEK=2*PI/WAVElength   
      A=100.0/WAVEK; 
      B=100.0/WAVEK;       
      DPHI=2.0*PI/NUN             !ANGLE OF EACH SEGMENT 
      DOAINC=180.0                ! DIRECTION OF INCIDENT WAVE  
     
      IF(MY_ID==0) THEN   
      DO I=1,NUN+1 
      XN(I)=A*DCOS((I-1)*DPHI) 
      YN(I)=B*DSIN((I-1)*DPHI) 
      ENDDO 
      DO I=1,NUN 
C *---------------------------------------------------------------------- 
C *  X AND Y COORDINATES AT THE CENTER OF EACH SEGMENT  
        XCN(I)=(XN(I)+XN(I+1)) /2 
        YCN(I)=(YN(I)+YN(I+1)) /2 
        ARCLENGTH(I)  =DSQRT((XN(I+1)-XN(I))**2+(YN(I+1)-YN(I))**2);
C *----------------------------------------------------------------------  
C*   FOR A CIRCULAR CYLINDER, USING THE FOLLOWING 
C*   ARCLENGTH(I)= A*DPHI 
      ENDDO 
      ENDIF 
      END SUBROUTINE GEONWAVE_INITIALIZE 
C *----------------------------------------------------------------------  
      SUBROUTINE GEONWAVE_PARA_INITIALIZE 
C *---------------------------------------------------------------------- 
C *     THIS SUBROUTINE WILL BROADCAST THE GEOMETRIC  
C *     COORDINATES TO EVERY PROCESS 
C *---------------------------------------------------------------------- 
 
      USE MOM_VARIABLES 
      USE MPI_VARIABLES,ONLY:MY_ID, ISTAT,IERR,MY_MPI_FLOAT 
      USE SCALAPACK_VARIABLES,ONLY: IPIV 
      IMPLICIT NONE 
      INCLUDE 'mpif.h'      
      CALL MPI_BCAST(a ,1, MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      CALL MPI_BCAST(b ,1, MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR)  
      CALL MPI_BCAST(NUN,1,MPI_INTEGER, 0,MPI_COMM_WORLD,IERR)      
      CALL MPI_BCAST(XN  ,NUN,  MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      CALL MPI_BCAST(YN  ,NUN,  MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      CALL MPI_BCAST(XCN  ,NUN,  MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      CALL MPI_BCAST(YCN  ,NUN,  MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR)   
      CALL MPI_BCAST(ARCLENGTH ,NUN, MY_MPI_FLOAT,0,MPI_COMM_WORLD,IERR)
      CALL MPI_BCAST(DOAINC ,1, MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      CALL MPI_BCAST(WAVElength ,1, MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR)
      CALL MPI_BCAST(WAVEK ,1, MY_MPI_FLOAT, 0,MPI_COMM_WORLD,IERR) 
      END SUBROUTINE GEONWAVE_PARA_INITIALIZE 
C *----------------------------------------------------------------------  
      SUBROUTINE MATRIX_FILLING   
C *---------------------------------------------------------------------- 
C *     THIS SUBROUTINE FILLS THE MATRIX OF MOM IN PARALLEL 
C *---------------------------------------------------------------------- 
      USE MPI_VARIABLES 
      USE MOM_VARIABLES 
      USE SCALAPACK_VARIABLES 
C      USE DFPORT 
      IMPLICIT NONE 
      INCLUDE 'mpif.h' 
            INTEGER::I,J 
      INTEGER ITEMP,JTEMP 
      INTEGER STATUS(MPI_STATUS_SIZE) 
      INTEGER :: III,JJJ 
      COMPLEX*16,EXTERNAL :: EINC 
      COMPLEX*16,EXTERNAL :: H02 
C *---------------------------------------------------------------------- 
C *  FILLING IMPEDANCE MA TRIX ON EACH PROCESS 
C *----------------------------------------------------------------------               
       DO M=1,NUN 
       ICROW = INDXG2P(M,NROW_BLOCK,0,0,NPROC_ROWS)  
       IF(ICROW==MYROW) THEN 
       LROWNUM=INDXG2L(M,NROW_BLOCK,0,0,NPROC_ROWS) 
       DO N=1,NUN      
       ICCOL = INDXG2P(N,NCOL_BLOCK,0,0,NPROC_COLS) 
       IF (ICCOL==MYCOL) THEN   
       LCOLNUM=INDXG2L(N,NCOL_BLOCK,0,0,NPROC_COLS) 
       IF(M==N)THEN 
      CN=ARCLENGTH(N)     
      Z_MN(LROWNUM,LCOLNUM)=120*PI/4.*CN*WAVEK 
     +                 *(1-CJ*2.0/PI*LOG(GAMA*WAVEK*CN/(4.0*E) )  )
       ELSE  
      CN=ARCLENGTH(N) 
      DIST=DSQRT((XCN(M)-XCN(N))**2+(YCN(M)-YCN(N))**2) 
      Z_MN(LROWNUM,LCOLNUM)=120*PI/4.*CN*WAVEK *H02(WAVEK*DIST) 
       ENDIF
       ENDIF 
       ENDDO 
       ENDIF 
       ENDDO  
C *---------------------------------------------------------------------- 
C *  OUTPUT THE IMPEDANCE MATRIX THAT WAS DISTRIBUTED TO 
C *  THE FIRST PROCESS 
C * FOR VALIDATION PURPOSE ONLY 
C *---------------------------------------------------------------------- 
        IF (MY_ID==0)  THEN            
c        OPEN ( UNIT=1,  FILE='Z_MN.DAT' )  
c            DO III=1,LOCAL_MAT_ROWS      
c            DO JJJ=1, LOCAL_MAT_COLS 
c                WRITE(1,*)DREAL(Z_MN(III,JJJ)),DIMAG(Z_MN(III,JJJ)) 
c            ENDDO
c            ENDDO 
        CLOSE(1) 
        ENDIF  
C *---------------------------------------------------------------------- 
C *  FILLING EXCITATION VECTOR ON EACH PROCESS 
C *----------------------------------------------------------------------   
         DO M=1,NUN 
         ICROW = INDXG2P(M,NROW_BLOCK,0,0,NPROC_ROWS)  
         IF(ICROW==MYROW .AND. MYCOL==0) THEN 
         LROWNUM=INDXG2L(M,NROW_BLOCK,0,0,NPROC_ROWS) 
         V_M(LROWNUM)=EINC(XCN(M),YCN(M),DOAINC)    
         ENDIF 
         ENDDO 
C *---------------------------------------------------------------------- 
C *  OUTPUT THE VOLTAGE MATRIX THAT WAS DISTRIBUTED TO 
C *  THE FIRST PROCESS 
C *---------------------------------------------------------------------- 
        IF (MY_ID==0)  THEN            
        OPEN ( UNIT=13,  FILE='V_M.DAT' )  
            DO III=1,B_LOCAL_SIZE      
            WRITE(13,*)DREAL(V_M(III)),DIMAG(V_M(III)) 
            ENDDO
        CLOSE(13) 
        ENDIF  
 
        END SUBROUTINE MATRIX_FILLING 
C *----------------------------------------------------------------------  
       COMPLEX*16 FUNCTION EINC(X,Y,INCPHI) 
C *---------------------------------------------------------------------- 
C *     THIS FUNCTION RETURNS THE INCIDENT WAVE   
C *---------------------------------------------------------------------- 
       USE MOM_VARIABLES,ONLY: WAVEK,CJ ,PI  
        IMPLICIT NONE 
       DOUBLE PRECISION X,Y,INCPHI,INCPHI1
        INCPHI1=INCPHI*PI/180.0
        EINC=cdEXP(1.0*CJ*WAVEK*( X*COS(INCPHI1)+Y*SIN(INCPHI1) ))    
  
       RETURN 
       END
C *----------------------------------------------------------------------
       COMPLEX*16 FUNCTION H02(A) 
C *---------------------------------------------------------------------- 
C * ZERO-ORDER HANKEL FUNCTION (2ND KIND) FROM [5]  
C *---------------------------------------------------------------------- 
      DOUBLE PRECISION A 
      DOUBLE PRECISION T0,F0,BY,BJ 
 
      IF(A.GT.3.000) GOTO 5 
      BJ=(A/3.00)**2 
      BJ=1.0+BJ*(-2.2499997+BJ*(1.2656208+BJ*(-.3163866+BJ* 
     +   (.0444479+BJ*(-.0039444+BJ*.00021))))) 
      BY=(A/3.00)**2 
      BY=2.0/3.1415926*DLOG(A/2.)*BJ+.36746691+BY*(.60559366+BY 
     +   *(-.74350384+BY*(.25300117+BY*(-.04261214+BY*(.00427916- 
     +   BY*.00024846))))) 
      GOTO 10 
 5    BJ=3.00/A 
      F0=.79788456+BJ*(-.00000077+BJ*(-.00552740+BJ*(-.00009512 
     +   +BJ*(.00137237+BJ*(-.00072805+BJ*.00014476))))) 
      T0=A-.78539816+BJ*(-.04166397+BJ*(-.00003954+BJ*(.00262573 
     +   +BJ*(-.00054125+BJ*(-.00029333+BJ*.00013558))))) 
      BY=DSQRT(A) 
      BJ=F0*DCOS(T0)/BY 
      BY=F0*DSIN(T0)/BY 
10    H02=DCMPLX(BJ,-BY) 
      RETURN 
 
      END   
