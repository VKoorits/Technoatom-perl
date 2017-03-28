package Local::Source::Text;

use strict;
use warnings;
use utf8;



sub  new {
	my ($class, %param) = @_;
	$param{'delemiter'} = $param{'delemiter'} // '\n';
	my @arr = split( $param{'delemiter'}, $param{'text'} );
	$param{'array'} = \@arr;
	return bless \%param, $class;
}

my $num_str = 0;
sub next {
	my $self = shift;
	if(@{ $self->{'array'} } - $num_str > 0 ) {
		return $self->{'array'}[$num_str++];
	}
	return undef;
}





1;
