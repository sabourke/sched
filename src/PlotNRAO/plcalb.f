      SUBROUTINE PLCALB( SCREEN, COLOR, RXMIN, RXMAX, RYMIN, RYMAX )
C
C     Routine for SCHED that plots source positions in RA - Dec.
C     and calibrators
C
      INCLUDE 'sched.inc'
      INCLUDE 'plot.inc'
C
      INTEGER           I, IER, ITICKS, ISRC, SL, LEN1, KSRC
      INTEGER           LABSIZ, LINSIZ, NP, SP, CIND
      LOGICAL           SCREEN, COLOR, VALID
      REAL              XPT, YPT, XSHADE(4), YSHADE(4)
      REAL              XMIN, XMAX, YMIN, YMAX
      REAL              XB(4), YB(4), R, RDI, DECM, RAM
      REAL              X1, X2, Y1, Y2, XW2, YW2, RXX
      REAL              XSTEP, YSTEP, XMED, YMED, DMED
      CHARACTER         TITLE*80, LABELX*60, LABELY*60, TYPE*8
      CHARACTER         SCOOR*12, COTIT*60, RADSTR*80
      DOUBLE PRECISION  DAY0, RXMIN, RXMAX, RYMIN, RYMAX
      DOUBLE PRECISION  TMID, RAS, DECS, RXOFFS, RYOFFS
C -------------------------------------------------------------------
C
      IF( PCALCK .EQ. 0 ) THEN
C
         PCALCK = 1
C
C        Rescale the center of the calibrators window
C
         XSTEP = ( RXMAX - RXMIN ) / ( PZMWIN(2) - PZMWIN(1) )
         YSTEP = ( RYMAX - RYMIN ) / ( PZMWIN(4) - PZMWIN(3) )
         RXX = ( PZMWIN(1) + PZMWIN(2) ) - PCALXY(1)
         XMED = RXMIN + ( XSTEP * ( RXX - PZMWIN(1) ) )
         YMED = RYMIN + ( YSTEP * ( PCALXY(2) - PZMWIN(3) ) )
         DMED = ( YMED / 3600.0 ) * RADDEG
C
C        Rescale the limits of the calibrators window
C
         RYOFFS = 5.D0 * 3600.D0
         RXOFFS = ( ( 5.D0 / 15.D0 ) / COS( DMED ) ) * 3600.D0
         RXMAX = XMED + RXOFFS
         RXMIN = XMED - RXOFFS
         RYMAX = YMED + RYOFFS
         RYMIN = YMED - RYOFFS
C
      END IF
C
C     Set plot scale and axis labels depending on request.  Check the
C     request.
C
      DAY0 = DINT( TFIRST )
      TYPE = 'RA'
      CALL PLOTDEF( IER, 'X', TYPE, RXMIN, RXMAX, DAY0, LABELX, 
     1              XMIN, XMAX )
      IF( IER .NE. 0 ) GO TO 990
      TYPE = 'DEC'
      CALL PLOTDEF( IER, 'Y', TYPE, RYMIN, RYMAX, DAY0, LABELY, 
     1              YMIN, YMAX )
      IF( IER .NE. 0 ) GO TO 990
C
C     Set the world coordinates and plot area.
C
      CALL PGQVSZ( 1, X1, XW2, Y1, YW2 )
      Y2 = 0.70
      X2 = Y2 / ( XW2 / YW2 )
      Y1 = ( ( 1.0 - Y2 ) / 2.0 ) + 0.05
      X1 = ( 1.0 - X2 ) / 2.0
      Y2 = Y2 + Y1 
      X2 = X2 + X1
C
      CALL PGSVP( X1, X2, Y1, Y2 )
      IF( XMIN .EQ. XMAX) XMAX = XMIN + 0.1
      IF( YMIN .EQ. YMAX) YMAX = YMIN + 0.1
      CALL PGSWIN( XMAX, XMIN, YMIN, YMAX )
C
C     Set Calib window for coordinate conversions
C
      PZMWIN(1) = X1
      PZMWIN(2) = X2
      PZMWIN(3) = Y1
      PZMWIN(4) = Y2
C
C     Color the background.
C
      IF( COLOR ) THEN
         IF( SCREEN ) THEN
            ITICKS = 9
            LINSIZ = PLYLW(1)
            LABSIZ = PLYAW(1)
            CIND    = 16
         ELSE
            ITICKS = 1
            LINSIZ = PLYLW(2)
            LABSIZ = PLYAW(2)
            IF( PFLBCK .LE. 2 ) THEN
               CIND    = 17
            ELSE
               CIND    = 18
            END IF
         END IF
         XSHADE(1) = XMIN !  + ( XMAX - XMIN ) * 0.002
         XSHADE(2) = XSHADE(1)
         XSHADE(3) = XMAX ! - ( XMAX - XMIN ) * 0.002
         XSHADE(4) = XSHADE(3)
         YSHADE(1) = YMIN ! + ( YMAX - YMIN ) * 0.004
         YSHADE(2) = YMAX ! - ( YMAX - YMIN ) * 0.004
         YSHADE(3) = YSHADE(2)
         YSHADE(4) = YSHADE(1)
         CALL PGSCI( CIND )
         CALL PGPOLY( 4, XSHADE, YSHADE )
      END IF
C
C     Select normal or time axes.
C
      CALL PGSCH( 0.85 )
      IF( SCREEN ) THEN
         CALL PGSCI( 0 )
      ELSE
         CALL PGSCI( 1 )
      END IF
      CALL PGSLW( 1 )
C
C     Radius for Calibrators check
C
      R = ( YMAX - YMIN ) / 2.0
      DECM = ( ( ( YMIN + YMAX ) / 3600.0 ) / 2.0 ) * RADDEG
      RAM  = ( ( XMIN + XMAX ) / 2.0 ) * 15.0 * COS( DECM )
C
C     Reset Window coordinate to plot central axis, if requested,
C     and circolar ticks, fixed or scaled.
C
      CALL PGSFS( 2 )
C
      IF( PRDAXI .OR. .NOT. PRZOFX ) THEN
         CALL PGSWIN( -0.5, 0.5, -0.5, 0.5 )
         IF( PRDAXI ) THEN
            CALL PGBOX( 'ATS', 0.25, 2, 'ATS', 0.25, 2 )
         END IF
         IF( .NOT. PRZOFX ) THEN
            CALL PGSFS( 2 )
            CALL PGCIRC( 0.0, 0.0, 0.05 )
            DO 100 I = 1, 2
               RDI = 0.25 * I
               CALL PGCIRC( 0.0, 0.0, RDI )
 100        CONTINUE 
         END IF
      END IF
C
      IF( PRZOFX ) THEN     
         CALL PGSWIN( YMIN, YMAX, YMIN, YMAX )
         YMED = YMIN + R
         RADSTR = 'Circle radii: 0.5 deg, 2.5 deg, 5 deg'
         YSTEP = 3600.0 * 5.0
         IF( R .LT. YSTEP ) RADSTR = RADSTR(1:30)
         CALL PGCIRC( YMED, YMED, YSTEP)
         YSTEP = 3600.0 * 2.5
         IF( R .LT. YSTEP ) RADSTR = 'Circle radius: 0.5 deg'
         CALL PGCIRC( YMED, YMED, YSTEP)
         YSTEP = 3600.0 * 0.5
         IF( R .LT. YSTEP ) RADSTR = ' '
         CALL PGCIRC( YMED, YMED, YSTEP)
      END IF
C
C     Plot Frames and Labels
C
      CALL PGSFS( 1 )
      CALL PGSWIN( XMAX, XMIN, YMIN, YMAX )
C
      CALL PGSLW( LABSIZ )
      CALL PGSCI( ITICKS )
      CALL PGTBOX( 'BCNTSZYXHO', 0.0, 0, 'BCNTSZYDO', 0.0, 0 )
C
C     Plot Labels describing the circle radii 
C
      IF( .NOT. PRZOFX ) CALL PLMKRD( R, RADSTR )
      CALL PGSCH( 1.0 )
      CALL PGMTXT( 'L', 9.0, 0.5, 0.5, RADSTR )
C
C     Plot Central Coordinate label
C
      XMED = XMIN + ( ( XMAX - XMIN ) / 2.0 )
      COTIT = 'Center coordinate: RA '
      CALL PLMKCO( XMED, SCOOR, 0, SP )      
      COTIT(23:) = SCOOR(1:SP)
      NP = SP + 23
      COTIT(NP:) = '   DEC '
      NP = NP + 7
      YMED = YMIN + R
      CALL PLMKCO( YMED, SCOOR, 1, SP )      
      COTIT(NP:) = SCOOR(1:SP)
      NP = NP + SP
      CALL PGMTXT( 'R', 9.0, 0.5, 0.5, COTIT(1:NP) )
C
C     If the sun is plotted add the start date to the title
C
      TITLE = 'Experiment code: '//EXPCODE
      IF( PXYSUN ) CALL PLTLAB( 'RADEC', DAY0, 0, TITLE )
C
C     Label axes
C
      CALL PGSCH( 1.3 )
      CALL PGSCI( 2 )
      CALL PGLAB( LABELX, LABELY, TITLE )
C
C     Draw Calibrators
C
      CALL PLCATA( SCREEN, COLOR, XMIN, XMAX, YMIN, YMAX, 1 )
C
C     Loop over sources.
C
      CALL PGBBUF
      CALL PGSCI( PLYCT(2,1) )
      DO 200 ISRC = 1, NSRC
C
C        Draw data.
C
         KSRC = SRCATN(ISRC)
         XPT = RA2000(KSRC) * 3600.D0 / RADHR
         YPT = D2000(KSRC) * 3600.D0 / RADDEG
         CALL PLCKRD( XPT, YPT, R, DECM, RAM, VALID )
         IF( VALID ) THEN
C
            CALL PGSCH( 1.0 )
            CALL PGSLW( LINSIZ )
            CALL PGPT( 1, XPT, YPT, PLYCT(2,2) )
            CALL PGSCH( 0.6 )
C
C           Check if the bounding box string is less than max
C           X axis. If not plot the source name before the
C           source mark.
C
            CALL PGSLW( LABSIZ )
            SL = LEN1( SRCNAME(ISRC) )
            CALL PGQTXT( XPT, YPT, 0.0, 0.0, 
     1                   'X'//SRCNAME(ISRC)(1:SL), XB, YB )
            IF( XB(4) .GE. XMAX ) THEN
               XPT = XPT - ( XB(4) - XB(1) )
               CALL PGTEXT( XPT, YPT, SRCNAME(ISRC)(1:SL) )
            ELSE
               CALL PGTEXT( XPT, YPT, '  '//SRCNAME(ISRC) )
            END IF
C
C           Plot a line for each scan for moving sources.
C           Do for planets, satellites, and sources with
C           non-zero planetary motion.  Ignore stationary
C           or slowly moving sources.
C	 	 
             IF( SATEL(KSRC) .OR. PLANET(KSRC) .OR.
     1          DRA(KSRC) * 15.0 * (STARTJ(SCAN1)-STOPJ(SCANL)) .GT. 
     2          ( XMAX - XMIN ) / 2000.0 .OR. 
     3          DDEC(KSRC) * (STARTJ(SCAN1)-STOPJ(SCANL)) .GT. 
     4          ( YMAX - YMIN ) / 2000.0 ) THEN 
               CALL PLSAT( ISRC )
            END IF
C
         END IF
C
 200  CONTINUE
C
      CALL PGEBUF
C
C     Draw Sun
C
      IF( PXYSUN ) THEN
         TMID = TFIRST + ( TEND - TFIRST ) / 2.D0
         CALL SUNPOS( TMID, RAS, DECS )
         IF( RAS .LT. 0.D0 ) RAS = TWOPI + RAS
         XPT = RAS * 3600.D0 / RADHR
         YPT = DECS * 3600.D0 / RADDEG
         CALL PLCKRD( XPT, YPT, R, DECM, RAM, VALID )
         IF( VALID ) THEN
C
            CALL PGSCI( PLYCT(1,1) )
            CALL PGSCH( 1.0 )
            CALL PGSLW( LINSIZ )
            CALL PGPT( 1, XPT, YPT, PLYCT(1,2) )
            CALL PGSCH( 0.6 )
            CALL PGSLW( LABSIZ )
            CALL PGQTXT( XPT, YPT, 0.0, 0.0,'XSUN', XB, YB )
            IF( XB(4) .GE. XMAX ) THEN
               XPT = XPT - ( XB(4) - XB(1) )
               CALL PGTEXT( XPT, YPT, 'SUN' )
            ELSE
               CALL PGTEXT( XPT, YPT, '  SUN' )
            END IF
         END IF
      END IF
C
C     Draw Key Table
C
      CALL PLCKEY( SCREEN )
C
  990 CONTINUE
      RETURN
      END
