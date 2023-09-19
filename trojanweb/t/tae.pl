#!/bin/perl

use AnyEvent;

my $timer_fired = AnyEvent->condvar;

my $seconds = 3;

my $w = AnyEvent->timer (after => $seconds, interval => $seconds, cb => sub {
	print AnyEvent->time;
	# $timer_fired->send
});

$w->recv;
$timer_fired->send;
$timer_fired->recv;

# $w->send; # wake up current and all future recv's
# $w->recv; # enters "main loop" till $condvar gets ->send