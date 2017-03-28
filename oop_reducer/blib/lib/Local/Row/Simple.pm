package Local::Row::Simple;

use strict;
use warnings;
use utf8;


sub  new {
	my ($class, %param) = @_;
	#TODO поверка на  допустимость строки
	return bless \%param, $class;
}

sub get {
	my ($self, $name, $default) = @_;

	$self->{text} =~ m/$name\s?:\s?(\d+)/;
	return $1 // $default;	
}





1;
