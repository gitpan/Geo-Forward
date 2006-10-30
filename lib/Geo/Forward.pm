package Geo::Forward;

=head1 NAME

Geo::Forward - Calculate geographic location form lat, lon, distance, heading.

=head1 SYNOPSIS

  use Geo::Forward;
  my $object = Geo::Forward->new('WGS84');
  my ($lat2,$lon2,$baz) = $object->forward($lon1,$lat1,$faz,$dist);

=head1 DESCRIPTION

This module is a pure perl port of the NGS program in the public domain "forward" by Robert (Sid) Safford and Stephen J. Frakes.  


=cut

use strict;
use vars qw($VERSION);
use constant PI => 2 * atan2(1, 0);
use constant RAD => 180/PI;
use constant DEFAULT_ELIPS => 'WGS84';

$VERSION = sprintf("%d.%02d", q{Revision: 0.02} =~ /(\d+)\.(\d+)/);

=head1 METHODS

=cut

sub new {
  my $this = shift();
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->initialize(@_);
  return $self;
}

sub initialize {
  my $self = shift();
  my $param = shift();
  if (ref($param)) {
    $self->{'elips'}=$param;  #{a=>x,f=>x}
  } else {
    $self->{'elips'}=$self->elipslist($param||DEFAULT_ELIPS);
  }
}

sub forward {
  my $self=shift();
  my $lat=shift();      #degrees
  my $lon=shift();      #degrees
  my $heading=shift();  #degrees
  my $distance=shift(); #meters (or the units of the semi-major axis)
  my ($lat2, $lon2, $baz)= $self->dirct1($lat/RAD,$lon/RAD,$heading/RAD,$distance);
  return($lat2*RAD, $lon2*RAD, $baz*RAD);
}

sub elipslist {
  my $self=shift();
  my $param=shift();
  my $elipslist = {
    GRS80=>{a=>6378137,f=>1/298.25722210088},
    WGS84=>{a=>6378137,f=>1/298.25722210088},
    NAD83=>{a=>6378137,f=>1/298.25722210088},
    'Clarke 1866'=>{a=>6378206.4,f=>1/294.9786982138},
    Clarke=>{a=>6378206.4,f=>1/294.9786982138},
    NAD27=>{a=>6378206.4,f=>1/294.9786982138},
  };
  return $elipslist->{$param} || die("$param undefined");
}

sub dirct1 {
  my $self=shift();  #provides A and F
  my $GLAT1=shift(); #radians
  my $GLON1=shift(); #radians
  my $FAZ=shift();   #radians
  my $S=shift();     #units of semi-major axis (default meters)


#      SUBROUTINE DIRCT1(GLAT1,GLON1,GLAT2,GLON2,FAZ,BAZ,S)
#C
#C *** SOLUTION OF THE GEODETIC DIRECT PROBLEM AFTER T.VINCENTY
#C *** MODIFIED RAINSFORD'S METHOD WITH HELMERT'S ELLIPTICAL TERMS
#C *** EFFECTIVE IN ANY AZIMUTH AND AT ANY DISTANCE SHORT OF ANTIPODAL
#C
#C *** A IS THE SEMI-MAJOR AXIS OF THE REFERENCE ELLIPSOID
#C *** F IS THE FLATTENING OF THE REFERENCE ELLIPSOID
#C *** LATITUDES AND LONGITUDES IN RADIANS POSITIVE NORTH AND EAST
#C *** AZIMUTHS IN RADIANS CLOCKWISE FROM NORTH
#C *** GEODESIC DISTANCE S ASSUMED IN UNITS OF SEMI-MAJOR AXIS A
#C
#C *** PROGRAMMED FOR CDC-6600 BY LCDR L.PFEIFER NGS ROCKVILLE MD 20FEB75
#C *** MODIFIED FOR SYSTEM 360 BY JOHN G GERGEN NGS ROCKVILLE MD 750608
#C
#      IMPLICIT REAL*8 (A-H,O-Z)
#      COMMON/CONST/PI,RAD
#      COMMON/ELIPSOID/A,F
       my $A=$self->{'elips'}->{'a'};
       my $F=$self->{'elips'}->{'f'};
#      DATA EPS/0.5D-13/
       my $EPS=0.5E-13;
#      R=1.-F
       my $R=1.-$F;
#      TU=R*DSIN(GLAT1)/DCOS(GLAT1)
       my $TU=$R*sin($GLAT1)/cos($GLAT1);
#      SF=DSIN(FAZ)
       my $SF=sin($FAZ);
#      CF=DCOS(FAZ)
       my $CF=cos($FAZ);
#      BAZ=0.
       my $BAZ=0.;
#      IF(CF.NE.0.) BAZ=DATAN2(TU,CF)*2.
       $BAZ=atan2($TU,$CF)*2. if ($CF != 0);
#      CU=1./DSQRT(TU*TU+1.)
       my $CU=1./sqrt($TU*$TU+1.);
#      SU=TU*CU
       my $SU=$TU*$CU;
#      SA=CU*SF
       my $SA=$CU*$SF;
#      C2A=-SA*SA+1.
       my $C2A=-$SA*$SA+1.;
#      X=DSQRT((1./R/R-1.)*C2A+1.)+1.
       my $X=sqrt((1./$R/$R-1.)*$C2A+1.)+1.;
#      X=(X-2.)/X
       $X=($X-2.)/$X;
#      C=1.-X
       my $C=1.-$X;
#      C=(X*X/4.+1)/C
       $C=($X*$X/4.+1)/$C;
#      D=(0.375D0*X*X-1.)*X
       my $D=(0.375*$X*$X-1.)*$X;
#      TU=S/R/A/C
       $TU=$S/$R/$A/$C;
#      Y=TU
       my $Y=$TU;
#  100 SY=DSIN(Y)
       my ($SY, $CY, $CZ, $E);
   do{ $SY=sin($Y);
#      CY=DCOS(Y)
       $CY=cos($Y);
#      CZ=DCOS(BAZ+Y)
       $CZ=cos($BAZ+$Y);
#      E=CZ*CZ*2.-1.
       $E=$CZ*$CZ*2.-1.;
#      C=Y
       $C=$Y;
#      X=E*CY
       $X=$E*$CY;
#      Y=E+E-1.
       $Y=$E+$E-1.;
#      Y=(((SY*SY*4.-3.)*Y*CZ*D/6.+X)*D/4.-CZ)*SY*D+TU
       $Y=((($SY*$SY*4.-3.)*$Y*$CZ*$D/6.+$X)*$D/4.-$CZ)*$SY*$D+$TU;
#      IF(DABS(Y-C).GT.EPS)GO TO 100
     } while (abs($Y-$C) > $EPS);
#      BAZ=CU*CY*CF-SU*SY
       $BAZ=$CU*$CY*$CF-$SU*$SY;
#      C=R*DSQRT(SA*SA+BAZ*BAZ)
       $C=$R*sqrt($SA*$SA+$BAZ*$BAZ);
#      D=SU*CY+CU*SY*CF
       $D=$SU*$CY+$CU*$SY*$CF;
#      GLAT2=DATAN2(D,C)
       my $GLAT2=atan2($D,$C);
#      C=CU*CY-SU*SY*CF
       $C=$CU*$CY-$SU*$SY*$CF;
#      X=DATAN2(SY*SF,C)
       $X=atan2($SY*$SF,$C);
#      C=((-3.*C2A+4.)*F+4.)*C2A*F/16.
       $C=((-3.*$C2A+4.)*$F+4.)*$C2A*$F/16.;
#      D=((E*CY*C+CZ)*SY*C+Y)*SA
       $D=(($E*$CY*$C+$CZ)*$SY*$C+$Y)*$SA;
#      GLON2=GLON1+X-(1.-C)*D*F
       my $GLON2=$GLON1+$X-(1.-$C)*$D*$F;
#      BAZ=DATAN2(SA,BAZ)+PI
       $BAZ=atan2($SA,$BAZ)+PI;
#      RETURN
       return $GLAT2, $GLON2, $BAZ;
#      END
}

1;

__END__

=head1 TODO

=head1 BUGS

=head1 LIMITS

No garentees that perl handles all of the double percision calculations in the same manner.

=head1 AUTHOR

Michael R. Davis qw/perl michaelrdavis com/

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
