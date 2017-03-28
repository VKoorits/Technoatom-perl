package Local::Reducer::MaxDiff;
use parent Local::Reducer;
use strict;
use warnings;
use Local::Row::JSON;
use Local::Row::Simple;

sub reduce_n {
	my ($self, $n) = @_;
	for(1..$n) {
		my $str = $self->{source}->next();
		last unless(defined $str);

		my $obj = $self->{'row_class'}->new(text => $str);

		my $top = $obj->get( $self->{'top'}, 0 );
		my $bottom = $obj->get( $self->{'bottom'}, 0 );
		$self->{'initial_value'} = $top - $bottom if( $top - $bottom > $self->{'initial_value'} );

	}
	return $self->reduced();
}

sub reduce_all {
	my ($self) = @_;
	while(defined (my $str = $self->{source}->next())  ) {
		my $obj = $self->{'row_class'}->new(text => $str);
		
		my $top = $obj->get( $self->{'top'}, 0 );
		my $bottom = $obj->get( $self->{'bottom'}, 0 );
		$self->{'initial_value'} = $top - $bottom if( $top - $bottom > $self->{'initial_value'} );
	}
	return $self->reduced();
}




1;
