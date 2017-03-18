use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Test::Deep;


sub clone{
	my $orig = shift;
	my $refs = shift;
	my $cloned;
	
	unless(defined $refs){
		$refs = { "undef" => 0};		
	}

	if(ref $orig eq "ARRAY"){
		unless(exists $refs->{$orig}){
			if( ref $orig eq "ARRAY" || ref $orig eq "HASH"){
				$refs->{$orig} = \$cloned; #запоминаем, чтобы использовать ссылку, а не создавать новую копию
			}
			for my $i(0..((scalar @$orig)-1)){
				if( (ref $orig->[$i] eq "ARRAY" || ref $orig->[$i] eq "HASH") && exists $refs->{ $orig->[$i] } ){
					$cloned->[$i] = ${$refs->{ $orig->[$i] }};
				}else{
					$cloned->[$i] = clone($orig->[$i],  $refs);
				}
			}
		}else{
			$cloned = ${ $refs->{$orig}};
		}
		
	}elsif(ref $orig eq "HASH"){ #аналогично массивам
		unless(exists $refs->{$orig}){
			if( ref $orig eq "ARRAY" || ref $orig eq "HASH"){
				$refs->{$orig} = \$cloned; #ccылка на ссылку, т.к. на в первый раз undef
			}
			while( my ($k, $v) = each %$orig){
				if( ( ref $v eq "HASH" || ref $v eq "HASH" ) && exists $refs->{ $v } ){
					$cloned->{$k} = ${$refs->{ $v }};
				}else{
					$cloned->{$k} = clone($orig->{$k}, $refs);			
				}
			}
		}else{
			$cloned = ${ $refs->{$orig}};
		}
		
	}elsif(ref $orig eq ""){
		$cloned = $orig;
	}else{
		$cloned = undef;
		$refs->{"undef"} = 1;
	}
	return undef if($refs->{"undef"} == 1);
	return $cloned;
}

my $CYCLE_HASH = { a => 1, b => 2 };
$CYCLE_HASH->{c} = $CYCLE_HASH;
$CYCLE_HASH->{d} = $CYCLE_HASH;
$CYCLE_HASH->{e} = { a => 1, b => 2, c => [ { 1 => $CYCLE_HASH } ] };
$CYCLE_HASH->{f} = $CYCLE_HASH->{e}{c};

my $CYCLE_ARRAY = [ 1, 2, 3 ];
$CYCLE_ARRAY->[4] = $CYCLE_ARRAY;
$CYCLE_ARRAY->[5] = $CYCLE_ARRAY;
$CYCLE_ARRAY->[6] = [ 1, 2, 3, [  {1 => $CYCLE_ARRAY } ] ];
$CYCLE_ARRAY->[7] = $CYCLE_ARRAY->[6][3];

my $copy = clone($CYCLE_HASH);
my $copy2 = clone($CYCLE_ARRAY);
my $ok = eq_deeply($copy2, $CYCLE_ARRAY);
my $ok2 = eq_deeply($copy, $CYCLE_HASH);
if($ok){print "ARRAY_GOOD!!! :=)";}else{print "ARRAY_BAD!!! :=(";}
if($ok2){print "HASH_GOOD!!! :=)";}else{print "HASH_BAD!!! :=(";}

my $var = 1;
if($var == 1){
print "===--===\n   ||\n===--===\n";
print Dumper($copy)."\n";
print Dumper($CYCLE_HASH);
}else{
print "===--===\n   ||\n===--===\n";
print Dumper($copy2)."\n";
print Dumper($CYCLE_ARRAY);
}













