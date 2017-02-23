#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление корней квадратного уравнения a*x**2+b*x+c=0.

=head1 run ($A, $B, $C)

Функция вычисления корней квадратного уравнения.
Принимает на вход  коэфиценты квадратного уравнения $A, $B, $C.
Вычисляет корни в переменные $x1 и $x2.
Печатает результат вычисления в виде строки "$x1, $x2\n".
Если уравнение не имеет решания должно быть напечатано "No solution!\n"

Примеры: 

run(1, 0, 0) - печатает "0, 0\n"

run(1, 1, 0) - печатает "0, -1\n"

run(1, 1, 1) - печатает "No solution!\n"

=cut

sub run {
    my ($A, $B, $C) = @_;

    my $x1 = undef;
    my $x2 = undef;

    my $D = $B*$B - 4*$A*$C; #дискриминант

	if($D < 0  ||  $A == 0) {
		print "No solution!\n";
	}
	else {
		$x1 = (-$B + sqrt($D) ) / (2*$A);
		$x2 = (-$B - sqrt($D) ) / (2*$A);
	
		print "$x1, $x2\n";
	}
}

1;