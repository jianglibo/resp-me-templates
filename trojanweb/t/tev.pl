#!/usr/bin/perl -w

use EV;

# Display the contents of @INC 
warn "\@INC is: ", join(' ', @INC), "\n";

my $w = EV::timer 2, 0, sub {
   warn "is called after 2s";
};

my $w = EV::periodic 0, 60, 0, sub {
   warn "is called every minute, on the minute, exactly";
};

EV::run;