package Local::MatrixMultiplier;
use strict;
use warnings;
use POSIX ':sys_wait_h';


sub mult {
	local $| = 1;
	local $SIG{CHLD} = sub {
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
    my $res;
    
    my $count_cell_res = @$mat_a * @{$mat_b->[0]};
   	$max_child = $count_cell_res if($count_cell_res < $max_child);


   	my(@r, @w);
   	for(0..$max_child-1){ pipe($r[$_], $w[$_]); }
   	
    my $count_cell_for_pid = $count_cell_res / $max_child;
   		
	for my $num_child (0..$max_child-1) {
	   	if(my $pid = fork()) {
			if($num_child != $max_child-1){ next; }
			
			for(0..$max_child-1){ close $w[$_]; }
	   		for my $index (0..$count_cell_res-1){
				read $r[int($index/$count_cell_for_pid)], my $data, 4 ;
				$data = unpack 'L', $data;
				my ($i, $j) = ($index / @{$mat_b->[0]}, $index % @{$mat_b->[0]});
				$res->[$i]->[$j] = $data;
			
			}
			
				for(0..$max_child-1){ close $w[$_]; }
				
		}else{
			
			close $r[$num_child];
			for my $index ($num_child * $count_cell_for_pid
							..	($num_child + 1) * $count_cell_for_pid  - 1){
					my ($i, $j) = ($index / @{$mat_b->[0]}, $index % @{$mat_b->[0]});
		   			my $num = 0;
					for my $k (0..@{ $mat_a->[0] }-1){
						$num += $mat_a->[$i]->[$k]*$mat_b->[$k]->[$j];
					}
					syswrite $w[$num_child], (pack 'L',$num);
			}
			close $w[$num_child];
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
