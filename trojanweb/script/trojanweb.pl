#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::File qw(curfile);
use lib curfile->dirname->sibling('lib')->to_string;
use Mojolicious::Commands;

# Start command line interface for application
Mojolicious::Commands->start_app('TrojanWeb');