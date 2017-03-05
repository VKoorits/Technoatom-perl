package SecretSanta;

use 5.010;
use strict;
use warnings;
#use DDP;

sub calculate {
	my @members = @_;
	my @res;
#==========================================================================begin my code
	if(scalar @members > 2 || ( scalar @members == 2 && (ref $members[0] eq "ARRAY" && ref $members[1] eq "ARRAY") ) ){
		my @from;
		my @to;
		my %taboo;

		PODBOR_BEGIN:
		for(@members){
			 if(ref $_){
				push @from, $_->[0];
				push @from, $_->[1];
	
				$taboo{$_->[0]}{$_->[1]} = 1;
				$taboo{$_->[0]}{$_->[0]} = 1;

				$taboo{$_->[1]}{$_->[0]} = 1;
				$taboo{$_->[1]}{$_->[1]} = 1;	
			}else{
				push @from, $_;
				$taboo{$_}{$_} = 1;
			}
		}

		@to = sort{int( rand(3) ) - 1} @from;

		while(scalar @from){
			my $flag = 0;
			for my $man(@to){
				unless(exists $taboo{$from[0]}{$man}){ #from[0] может дарить man
					my @insert = ($from[0], $man);
					push @res, \@insert;
					$taboo{$man}{$from[0]} = 1;
					shift @from;
					@to = grep{$_ ne $man}@to;
					$flag = 1;
					last;
				}
			}
			if($flag != 1){
				%taboo = ();
				@res = ();
				@from = ();
				@to = ();
				goto PODBOR_BEGIN;
			}
		}
	}
	return @res;
#==========================================================================end my code
}

1;
