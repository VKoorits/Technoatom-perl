package DeepClone;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

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

1;
