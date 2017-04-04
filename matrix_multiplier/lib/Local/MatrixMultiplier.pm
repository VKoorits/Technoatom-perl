package Local::MatrixMultiplier;
use Data::Dumper;
use strict;
use warnings;
use POSIX ':sys_wait_h';
use Test::Deep;


sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    check_size($mat_a, $mat_b);
    $max_child = scalar @$mat_a if(@{ $mat_a->[0]} - 1 < $max_child);#каждый child вычисляет целоу число строк
    my $res = [];
    
    my ($r, $w);
    pipe($r, $w);

    defined(my $child_pid = fork()) or die "can not fork";
   	if($child_pid) {
   		close($w);
   		for(1..@{$mat_b->[0]} * @$mat_a) {#родительский процесс считывает
   			my ($block, $index, $data);
			read($r, $block, 8);
			($index, $data) = unpack('L2',$block);#возможно, стоило сделать pipe для каждого процесса и не использовать index
			my ($i, $j) = ($index / @{$mat_b->[0]}, $index % @{$mat_b->[0]});
			$res->[$i]->[$j] = $data;		
			
   		}
   		close($r);
   	} else { #дочерний доводит кол-во процессов до максимального
   		close($r);
   		for my $num_child(0..$max_child - 1) {
   			if($num_child < $max_child - 1 and my $child = fork() ) { #в последний раз не делать fork, а заняться подсчётом
   				next;	
   			}else{ #каждый дочерний процесс считает несколько строк матрицы
   				die "Cannot fork $!" if( $num_child < $max_child - 1 && !defined $child);
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
   		close($w);
   		exit;
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
