#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры: 

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut

sub run {
    my ($x, $y) = @_;
	if($x < 2){ $x = 2;} # нет простых чисел меньше чем 2
	if($y >= 2 || $y < $x) {
		my $i;
		my @arr; # решето Эратосфена
		for ($i = 0; $i <= $y; $i++) { push @arr, 1; } # возможно можно создать массив из единиц более оптимально
	
		my $j;
		for($i=2; $i < $y/2; $i++) {
			if ($arr[$i] == 1) {
				for($j = $i*2; $j<=$y; $j += $i){ $arr[$j] = 0; }
			}
		}
		
	
		for ($i = $x; $i <= $y; $i++) {
			if( $arr[$i] ==1 ) { print "$i\n"; }
		}
    }
}

1;
