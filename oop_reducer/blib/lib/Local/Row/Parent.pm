package Local::Source::Parent;

use strict;
use warnings;
use utf8;

sub next {
	my $self = shift;
	if(@{ $self->{'array'} } - $self->{'num_str'} > 0 ) {
		return $self->{'array'}[ $self->{'num_str'}++ ];
	}
	return undef;
}
