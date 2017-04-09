package Local::MatrixMultiplier;
use Data::Dumper;
use strict;
use warnings;
use POSIX ':sys_wait_h';
use Test::Deep;

sub mult {
	$SIG{CHLD} = sub {
		while( my $pid = waitpid(-1, WNOHANG)){
			last if $pid == -1;
			if( WIFEXITED($?) ){
				my $status = $? >> 8;
				die"$pid returned status $status" if($status);
			}
		}
	};	
	
	my ($mat_a, $mat_b, $max_child) = @_;
    check_size($mat_a, $mat_b);
    $max_child = scalar @$mat_a if(@{ $mat_a->[0]} - 1 < $max_child);#каждый child вычисляет целоу число строк
    my $res = [];
    
    my ($r, $w);
    pipe($r, $w);
	for my $num_child(0..$max_child - 1) {
		if(my $child = fork() ) {
		
			if($num_child = $max_child - 2){
				close($w);
		  		for(1..@{$mat_b->[0]} * @$mat_a) {#родительский процесс считывает
		   			my ($block, $index, $data);
					read($r, $block, 8);
					($index, $data) = unpack('L2',$block);#возможно, стоило сделать pipe для каждого процесса и не использовать index
					my ($i, $j) = ($index / @{$mat_b->[0]}, $index % @{$mat_b->[0]});
					$res->[$i]->[$j] = $data;		
		
		   		}
		   		close($r);
			} else {  next;  }
				
		} else { #каждый дочерний процесс считает несколько строк матрицы
		
			close($r);
			die "Cannot fork $!" unless(defined $child);
			my $i = $num_child * @{ $mat_a->[0] } / $max_child;
			my $max = (1+$num_child) * @{ $mat_a->[0] } / $max_child;
			for ($i; $i < $max; $i++) {
				for (my $j = 0; $j < @$mat_b; $j++) {
					my $num = 0;
					for (my $k = 0; $k < @$mat_a; $k++) { 
						$num += $mat_a->[$i][$k] * $mat_b->[$k][$j];
					}
					print $w (pack 'L2', $i * @{$mat_b->[0]} +$j, $num);# записать индекс и значение					
				}
			}	
			exit 0;
		} 	
	}
   	return $res;
}


sub check_size { #проверка размерностей матрицы
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
