package Local::Source::Array;
use parent Local::Source::Parent;
use strict;
use warnings;
use utf8;


sub new {
	my ($class, %param) = @_;
	my $self = bless {}, $class;
	$self->{'array'} = $param{'array'};
	$self->{'num_str'} = 0;
	return $self;
}



1;
