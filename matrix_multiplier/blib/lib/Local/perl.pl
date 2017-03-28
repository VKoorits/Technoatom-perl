use strict;
use warnings;
use Data::Dumper;

@SIG{CHLD} = sub { print Dumper(@_);};
my ($r, $w);
pipe($r, $w);
if( my $pid = fork() ){
	close($r);
	print $w $_ for(1..5);
	close($w);
	waitpid($pid, 0);
} else {
	die "can not fork" unless(defined $pid);
	close($w);
	while(<$r>){ print $_; }
	close($r);
	exit(78);
}
