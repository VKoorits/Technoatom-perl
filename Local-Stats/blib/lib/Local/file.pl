use ExtUtils::testlib; 
use Local::Stats;
use Data::Dumper;
use DDP;
use 5.010;

sub printer_perl{print "hello world from perl\n";}
my $var = sub{ return qw(min max sum cnt); };
Local::Stats::new($var);

Local::Stats::add("m1", 7);
Local::Stats::add("m1", 11);
Local::Stats::add("m1", 3);

my $stat = Local::Stats::stat();
p $stat;

$stat = Local::Stats::pr();
p $stat;

