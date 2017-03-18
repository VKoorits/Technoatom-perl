package Anagram;

<<<<<<< HEAD
use 5.010;
use strict;
use warnings;
use locale;
use Encode;
=======

use strict;
use warnings;
use utf8;
use locale;
use Encode;
use Data::Dumper;


>>>>>>> e6514de44445e7b207b336c9b7b590024b631c21

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

<<<<<<< HEAD
=======

>>>>>>> e6514de44445e7b207b336c9b7b590024b631c21
sub anagram {
    my $words_list = shift;
    my %result;

	
	my @words =  map{encode("utf8", lc( decode("utf8",$_) ) )}@$words_list;
	my %original;

	for my $i(0..scalar(@words)-1) {	
		my $a = join("", ( sort{$a cmp $b}split(//, $words[$i]) ) );#получение отсортированной строки

		unless(exists $original{$words[$i]}){#если такого слова ещё не было
			$original{$words[$i]} = 1;
			unless(exists $result{$a}){ $result{$a} = []; }
			push @{$result{$a}}, $words[$i];
		}	
	}

	my @keys = keys %result;

	for my $k(@keys){#удаляем группы с одним словом и меняем ключи на первые слова множества
		if(scalar @{$result{$k}} >= 2) {
			$result{  @{$result{$k}}[0] } = [sort{$a cmp $b } @{$result{$k}} ];
		}
		delete $result{$k};
	
	}

    return \%result;
}

1;
