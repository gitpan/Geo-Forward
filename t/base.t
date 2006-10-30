#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: base.t,v 0.1 2006/02/21 eserte Exp $
# Author: Michael R. Davis
#

=head1 Test Examples

base.t has good examples concerning how to use this module

=cut

use strict;
use lib q{lib};
use lib q{../lib};
use constant NEAR_DEFAULT => 7;

sub near {
  my $x=shift();
  my $y=shift();
  my $p=shift()||NEAR_DEFAULT;
  if (($x-$y)/$y < 10**-$p) {
    return 1;
  } else {
    return 0;
  }
}

sub dms2dd {
  my $d=shift();
  my $m=shift();
  my $s=shift();
  my $dir=shift()||'N';
  my $val=$d+($m+$s/60)/60;
  if ($dir eq 'W' or $dir eq 'S') {
    return -$val;
  } else {
    return $val;
  }
}

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "1..0 # tests only works with installed Test module\n";
	exit;
    }
}

BEGIN { plan tests => 17 }

# just check that all modules can be compiled
ok(eval {require Geo::Forward; 1}, 1, $@);

my $o = Geo::Forward->new();
ok(ref $o, "Geo::Forward");

my @data=$o->forward(34,-77,45,100);
ok(near $data[0], 34.000637478);
ok(near $data[1], -76.999234611);
ok(near $data[2], 225.000428);

#Examples from the Fortran Version
my @test=(
[qw{38 52 15.68000 N 77  3 21.15000 W 38 53 23.12000 N 77  0 32.52000 W 62 53 18.6255 242 55  4.4740 4565.6854}],
[qw{ 34 34 34.34000 N 0  1  1.01000 W 34 35 35.35000 N 0  1  1.01000 E 58 50  5.7824 238 51 15.0439 3633.8334 }],
[qw{  12 34 54.45450 N 179 45 56.34342 E  12 33 34.21323 N 179 50 34.34000 W  93 16 28.8588  273 21 35.5882   42612.4852 }],
[qw{ 1  1  1.01111 N 56 56 56.56000 W 1  1  1.01010 S 57 57 57.57000 W 206 43 15.8917 26 43 15.8916 251779.2461 }],
#[qw{}],
#[qw{}],
#[qw{}],
#[qw{}],
#[qw{}],
);

foreach (@test) {
  my $lat1=dms2dd(@$_[0..3]);
  my $lon1=dms2dd(@$_[4..7]);
  my $lat2=dms2dd(@$_[8..11]);
  my $lon2=dms2dd(@$_[12..15]);
  my $faz=dms2dd(@$_[16..18]);
  my $baz=dms2dd(@$_[19..21]);
  my $dist=$_->[22];
  my @data=$o->forward($lat1,$lon1,$faz,$dist);
  ok(near $data[0], $lat2);
  ok(near $data[1], $lon2);
  ok(near $data[2], $baz);
}
