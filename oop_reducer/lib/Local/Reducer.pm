package Local::Reducer;

use strict;
use warnings;
use utf8;


my $str;
sub  new {
	my ($class, %param) = @_;
	my $self = bless {}, $class;
	$self->{$_} = $param{$_} for( qw/field row_class initial_value top bottom source/ );
	$self->{'reduced'} = $self->{'initial_value'};
	return $self;
}	

sub reduced {
	return $_[0]->{'reduced'};
}

1;
