#!/bin/bash/perl -l

use strict;

sub hello {
	my $name = shift;
	print @_ + 0;
	print ref($name);
	print "type eq: " . (ref($name) eq "HASH");
	print "number eq: " . (1 == 2);
	print "number eq: " . (1 == 1);
	print "number eq: " . (1 == 1.0);
	print "Hello, $name!";
}

hello("World");

hello "World";

hello greeting => "World";
hello {greeting => "World"};
