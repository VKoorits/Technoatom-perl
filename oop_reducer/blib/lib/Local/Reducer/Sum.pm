package Local::Reducer::Sum;
use parent Local::Reducer;
use strict;

use Local::Row::JSON;
use Local::Row::Simple;

sub reduce_n {
	my ($self, $n) = @_;
	for(1..$n) {
		my $str = $self->{source}->next();
		last unless(defined $str);

		my $obj = $self->{'row_class'}->new(text => $str);
		$self->{'initial_value'} += int( $obj->get( $self->{'field'}, 0 ) );

	}
	return $self->reduced();
}

sub reduce_all {
	my ($self) = @_;
	while(defined (my $str = $self->{source}->next())  ) {
		my $obj = $self->{'row_class'}->new(text => $str);
		$self->{'initial_value'} += int( $obj->get( $self->{'field'}, 0 ) );
	}
	return $self->reduced();
}




1;
