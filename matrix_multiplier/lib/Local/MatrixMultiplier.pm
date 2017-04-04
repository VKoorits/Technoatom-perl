package Local::MatrixMultiplier;
use Data::Dumper;
use strict;
use warnings;
use POSIX ':sys_wait_h';
use Test::Deep;

sub check {
	my $matrix_a = [
	[ 1, 2, 3, 4, 5, 6],
	[11,12,13,14,15,16],
	[21,22,23,24,25,26],
	[31,32,33,34,35,36],
	[41,42,43,44,45,46],
	[51,52,53,54,55,56],
	];

	my $matrix_b = [
	[ 1, 2, 3, 4, 5, 6],
	[11,12,13,14,15,16],
	[21,22,23,24,25,26],
	[31,32,33,34,35,36],
	[41,42,43,44,45,46],
	[51,52,53,54,55,56],
	];

	my $matrix_c = [
	[ 721,  742,  763,  784,  805,   826],
	[2281, 2362, 2443, 2524, 2605,  2686],
	[3841, 3982, 4123, 4264, 4405,  4546],
	[5401, 5602, 5803, 6004, 6205,  6406],
	[6961, 7222, 7483, 7744, 8005,  8266],
	[8521, 8842, 9163, 9484, 9805, 10126]
	];

	my $MM = mult($matrix_a, $matrix_b, 3);

	my $ok = eq_deeply($MM, $matrix_c);
	print "\n==$ok\n";
}
check();

sub mult {
	my ($mat_a, $mat_b, $max_child) = @_;
	$SIG{CHLD} = sub {
		while( my $pid = waitpid(-1, WNOHANG)){
			last if $pid == -1;
		}
	};
	
	my @r;
	my @w;



	for(0..$max_child+2) {
		pipe($r[$_], $w[$_]);
	}
   	defined(my $child_pid = fork()) or die "can not fork";
    	
    if($child_pid){
    	for(0..$max_child-1) {
			close($w[$_]);
		}
		for(0..$max_child-1) {
			my $inf;
			read $r[$_], $inf, 1;
			#print "from $_ : $inf\n";
		}
		for(0..$max_child-1) {
			close($r[$_]);
		}
    }else{
		#делаем $max_child - 1 fork`ов
		for(1..$max_child-1){

			defined(my $child = fork()) or die "can not fork";
			if($child){
				next;
			}else{
				close($r[$_]);				
				 $w[$_] $_;
				close($w[$_]);
				exit;
			}
    #
    #
    	}
	
	
	}
	 return [];
}
=c
    my ($mat_a, $mat_b, $max_child) = @_;
    check_size($mat_a, $mat_b);
    $max_child = @{ $mat_a->[0] } - 1 if(@{ $mat_a->[0]} - 1 < $max_child);#каждый child вычисляет целоу число строк
    my $res = [];

    for my $num_child(0..$max_child - 1){
    	
    	my ($r, $w);
    	pipe($r, $w);
    	defined(my $child_pid = fork()) or die "can not fork";
    	
    	if($child_pid){
    		close($w);
    		my $i = $num_child * @{ $mat_a->[0] } / $max_child;#child подсчитает с этой строки
    		my $max = (1+$num_child) * @{ $mat_a->[0] } / $max_child;# по эту
			for ($i; $i < $max; $i++) {
				for (my $j = 0; $j < @$mat_b; $j++) {
					my $n;
					read($r, $n, 4);
					$n = unpack 'L', $n;
					#print $n." ";				
					$res->[$i][$j] = $n;
				}
			}
			close($r);
    		waitpid($child_pid, WNOHANG);
    	}else{
    		close($r);
    		my $i = $num_child * @{ $mat_a->[0] } / $max_child;
    		my $max = (1+$num_child) * @{ $mat_a->[0] } / $max_child;
			for ($i; $i < $max; $i++) {
				for (my $j = 0; $j < @$mat_b; $j++) {
					my $num = 0;
					for (my $k = 0; $k < @$mat_a; $k++) { 
						$num += $mat_a->[$i][$k] * $mat_b->[$k][$j];
					}

					print $w (pack 'L', $num);
				}
			}#end
			close($w);
			exit 0;
    	}   
    
    }    
    
    print Dumper($res);
    return $res;
}
=cut


=head
sub mult2 {
	$SIG{CHLD} = sub {
		while( my $pid = waitpid(-1, WNOHANG)){
			last if $pid == -1;
		}
	};
    my ($mat_a, $mat_b, $max_child) = @_;
    check_size($mat_a, $mat_b);
    $max_child = @{ $mat_a->[0] } - 1 if(@{ $mat_a->[0]} - 1 < $max_child);#каждый child вычисляет целоу число строк
    my $res = [];

    for my $num_child(0..$max_child - 1){
    	
    	my ($r, $w);
    	pipe($r, $w);
    	defined(my $child_pid = fork()) or die "can not fork";
    	
    	if($child_pid){
    		close($w);
    		my $i = $num_child * @{ $mat_a->[0] } / $max_child;#child подсчитает с этой строки
    		my $max = (1+$num_child) * @{ $mat_a->[0] } / $max_child;# по эту
			for ($i; $i < $max; $i++) {
				for (my $j = 0; $j < @$mat_b; $j++) {
					my $n;
					read($r, $n, 4);
					$n = unpack 'L', $n;
					#print $n." ";				
					$res->[$i][$j] = $n;
				}
			}
			close($r);
    		waitpid($child_pid, WNOHANG);
    	}else{
    		close($r);
    		my $i = $num_child * @{ $mat_a->[0] } / $max_child;
    		my $max = (1+$num_child) * @{ $mat_a->[0] } / $max_child;
			for ($i; $i < $max; $i++) {
				for (my $j = 0; $j < @$mat_b; $j++) {
					my $num = 0;
					for (my $k = 0; $k < @$mat_a; $k++) { 
						$num += $mat_a->[$i][$k] * $mat_b->[$k][$j];
					}

					print $w (pack 'L', $num);
				}
			}#end
			close($w);
			exit 0;
    	}   
    
    }    
    
    print Dumper($res);
    return $res;
}
=cut

sub check_size {
	my ($M1, $M2) = @_;
	if( @$M1 - @{ $M2->[0] } != 0) { die 'Wromg matrix'; }
	
	my $row1 = @$M1-1;
	my $row2 = @$M2-1;
	for my $row(@$M1){
		if( @$row - 1 != $row1) { die 'Wromg matrix'; }
	}
	for my $row(@$M2){
		if( @$row - 1 != $row2) { die 'Wromg matrix'; }
	} 
}


1;
