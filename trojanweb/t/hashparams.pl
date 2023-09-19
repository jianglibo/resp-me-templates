#!/bin/bash/perl -l

use strict;

sub hello {
	my $h = shift;
	print $h->{greeting};
}

# hello greeting => "World";
hello {greeting => "World"};

my %h = {greeting => "World"};
my $hr = \%h;

print $hr->{greeting};

