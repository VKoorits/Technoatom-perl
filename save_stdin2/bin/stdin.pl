#!/usr/bin/perl

use Getopt::Long;
use Data::Dumper;
use DDP;

my $param = {};
GetOptions($param, 'file=s');
open( my $fh, '>', $param->{file} ) or die 'no this file';


sub signal1 {
	print STDERR 'Double Ctrl+C for exit';
	$SIG{INT} = sub{
		close($fh);
		exit;
	};
};

$SIG{INT} = \&signal1;

print "Get ready\n";
my $count_str = 0;
my $data_size = 0;

while(<>){ print $fh $_ ; $data_size += length($_)-1; $count_str++; }
print $data_size." ".$count_str." ".int($data_size / $count_str);

