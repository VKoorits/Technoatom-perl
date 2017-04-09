#!/usr/bin/perl

use Getopt::Long;
use Data::Dumper;
use DDP;

my $param = {};
GetOptions($param, 'file=s');
open( my $fh, '>', $param->{file} ) or die 'no this file';


print "Get ready\n";
my $count_str = 0;
my $data_size = 0;

sub printer {
	print $data_size." ".$count_str." ".int($data_size / $count_str);
}

sub signal1 {
	print STDERR 'Double Ctrl+C for exit';
	$SIG{INT} = sub{
		printer();
		close($fh);
		exit;
	};
};

$SIG{INT} = \&signal1;


while(<>){ print $fh $_ ; $data_size += length($_)-1; $count_str++; }
printer();

