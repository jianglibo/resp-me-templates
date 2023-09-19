#!/usr/bin/perl

use 5.30.0;
use warnings;
use DBI;

my @drvs = DBI->available_drivers;
say join "\n", @drvs;