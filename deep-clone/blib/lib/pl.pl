use 5.010;
use strict;
use warnings;
use Data::Dumper;
my $CYCLE_HASH = [ 1, 2, 3 ];
$CYCLE_HASH->[4] = $CYCLE_HASH;
$CYCLE_HASH->[5] = $CYCLE_HASH;
$CYCLE_HASH->[6] = [ 1, 2, 3, [ { 1 => $CYCLE_HASH } ] ];
$CYCLE_HASH->[7] = $CYCLE_HASH->[6][3];

sub clone{
	my $orig = shift;
	my $refs = shift;
	my $cloned;
	
	unless(defined $refs){
		$refs = { "undef" => 0};		
	}

	print $refs->{"undef"}."\t".(ref $orig)."\n";
	return undef if($refs->{"undef"} == 1);

	if(ref $orig eq "HASH"){
		unless(exists $refs->{$orig}){

			for my $i(0..((scalar @$orig)-1) ){
				if( (  ref @{$orig}[$i] eq "HASH" || ref @{$orig}[$i] eq "HASH") && exists $refs->{ @{$orig}[$i] } ) { 
				# и такая ссылка уже использовалась
				# если элемент массива - допустимая ссылка,
						@{$cloned}[$i] = $refs->{ @{$orig}[$i] };
				} else {
					@{$cloned}[$i] = clone(@{$orig}[$i], $refs);
				}
				$refs->{$orig} = $cloned; #на случай, если эта ссылка еще будет где-то использовааться	
			}

		}else{
			$cloned = $refs->{$orig};
		}
	}elsif(ref $orig eq "HASH"){ #аналогично
		unless(exists $refs->{$orig}){
	
			while( my ($k, $v) = each %$orig){
				if( ( ref $v eq "HASH" || ref $v eq "HASH" ) && exists $refs->{ $v } ){
					$cloned->{$k} = $refs->{ $v };
				}else{
					$cloned->{$k} = clone($v, $refs);			
				}
				$refs->{$orig} = $cloned; #на случай, если эта ссылка еще будет где-то использовааться
			}
			print Dumper($refs);
			print "============\n";
		}else{
			$cloned = $refs->{$orig};
		}
		
			
	}elsif(ref $orig eq ""){
		$cloned = $orig;
	}else{
		$cloned = 7;
		print "popa".ref $orig;
		$refs->{"undef"} = 1;
	}
	
	return $cloned;
}
my $arr = [ [5, 7, "str"], { "key"=>sub{print"function";}, "key2"=>2} ];

my $copy = clone($CYCLE_HASH);
#$CYCLE_HASH->{c}->{1}->{e};





print Dumper($copy)."\n";
print "original";
print Dumper($CYCLE_HASH)."\n";


