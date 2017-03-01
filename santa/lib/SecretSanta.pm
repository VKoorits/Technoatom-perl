package SecretSanta;

use 5.010;
use strict;
use warnings;
#use DDP;

sub calculate {
	my @members = @_;
	my @res;
#=============================================================Begin my code

	my @from;
	my @to;
	my %taboo;

	PODBOR_BEGIN:

	for(@members){
		 if(ref $_){
			push @from, $_->[0];
			push @from, $_->[1];
	
			$taboo{$_->[0]} = $_->[1];
			$taboo{$_->[1]} = $_->[0];	
		}else{
			push @from, $_;
			$taboo{$_} = "";
		}
	}
	@from = sort{int(rand(3) ) - 1} @from;
	@to = sort{int( rand(3) ) - 1} @from;

	while( scalar @from ){											# пока не все дарят кому-нибудь подарок
		if( exists $taboo{$from[0]} ){
			my $flag = 0;
			for my $man (@to){										# поиск того, кому может подарить
			  if($man ne $from[0] && exists $taboo{$man}){
				if(index($taboo{$from[0]}, $man )== -1){			# если нет табу на этого человека
					my @insert = ($from[0], $man);
					push @res, \@insert;
					$taboo{$man} .= $from[0];						# запретить дарить в ответ тому же
					shift @from;
					$man = "#";										# чтобы не месить весь массив присвоем ему то, что точно не является именем

					$flag = 1;
					#print Dumper(@res);
					#print "=================================\n";
					last;
				}
			  }
			}
			if($flag == 0){											# ecли зашли в тупик, то выбираем всё сначала
				@from = ();
				@to = ();
				@res = ();
				%taboo = ();
				goto PODBOR_BEGIN;
			}
		
		}
	
	}
#==========================================================================end my code
	return @res;
}

1;
