use 5.010;
use strict;
use warnings;
use Data::Dumper;
my $arr = 52;#[2,3,["popa1", "popa2", "popa3"],5,7,11,13,17, {"Victor"=>9, "Dima"=>8}];
#my $arr= {"popa" => 8, "nose"=>7}; 

sub clone{
	my $orig = shift;
	my $cloned;
	if(ref $orig eq "ARRAY"){
		for my $i(0..((scalar @$orig)-1) ){
			@{$cloned}[$i] = clone(@{$orig}[$i]);
		}
	}elsif(ref $orig eq "HASH"){
		while( my ($k, $v) = each %$orig){
			$cloned->{$k} = clone($orig->{$k});			
		}
	}elsif(ref $orig eq ""){
		$cloned = $orig;
	}else{
		$cloned = undef;
	}
	return $cloned;
}


my $copy = clone($arr);

print Dumper($copy)."\n";
print Dumper($arr)."\n";


