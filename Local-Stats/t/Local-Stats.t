use strict;
use warnings;

use Test::More tests => 7;
my $returned;
my $expected;
my $function;


use_ok('Local::Stats'); #TEST 1

$function = sub { return qw(min max cnt) };
Local::Stats::new($function);
Local::Stats::add('m1', 7);
Local::Stats::add('m1', 3);
Local::Stats::add('m1',11);
$returned = Local::Stats::stat();
$expected = { m1 =>{ cnt => 3, min =>3, max => 11 } };
is_deeply($returned, $expected, "TEST 2");

$function = sub { return qw(cnt avg) };
Local::Stats::new($function);
Local::Stats::add('m1', 42) for(1..100);
$returned = Local::Stats::stat();
$expected = { m1 => { cnt => 100, avg => 42 } };
is_deeply($returned, $expected, "TEST 3");

$function = sub { return qw() };
Local::Stats::new($function);
Local::Stats::add("m$_", 42) for(1..100);
$returned = Local::Stats::stat();
$expected = {};
is_deeply($returned, $expected, "TEST 4");

Local::Stats::new($function);
$returned = Local::Stats::stat();
$expected = {};
is_deeply($returned, $expected, "TEST 5");

$function = sub { return qw(sum min max avg cnt) };
Local::Stats::new($function);
for my $i(1..6) { Local::Stats::add("m$i", $_*10) for(1..6); }
$returned = Local::Stats::stat();
$expected = {
	m1 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
	m2 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
	m3 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
	m4 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
	m5 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
	m6 => {sum => 210, min => 10, max => 60, avg => 35, cnt => 6},
};
is_deeply($returned, $expected, "TEST 6");

$returned = Local::Stats::stat();
$expected = {};
is_deeply($returned, $expected, "TEST 7");

