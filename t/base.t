#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: base.t,v 0.1 2006/02/21 eserte Exp $
# Author: Michael R. Davis
#

use strict;
use lib q{lib};
use lib q{../lib};

sub near {
  my $x=shift();
  my $y=shift();
  my $p=shift()||5;
  if ($x-$y < 10**-$p) {
    return 1;
  } else {
    return 0;
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

BEGIN { plan tests => 45 }

# just check that all modules can be compiled
ok(eval {require Geo::Forward; 1}, 1, $@);

my $o = Geo::Forward->new();
ok(ref $o, "Geo::Forward");

ok(near [$o->forward(34,-77,45,100)]->[0], [34.000637478,-76.999234611,225.000428]->[0]);
ok(near [$o->forward(34,-77,45,100)]->[1], [34.000637478,-76.999234611,225.000428]->[1]);
ok(near [$o->forward(34,-77,45,100)]->[2], [34.000637478,-76.999234611,225.000428]->[2]);
#ok(near $o->forward($p1,$p2), 1);
