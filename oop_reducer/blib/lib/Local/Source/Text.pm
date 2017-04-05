package Local::Source::Text;
use parent Local::Source::Parent;
use strict;
use warnings;
use utf8;



sub  new {
	my ($class, %param) = @_;
	my $self = bless {}, $class;
	
	$param{'delemiter'} = $param{'delemiter'} // '\n';
	my @arr = split( $param{'delemiter'}, $param{'text'} );
	delete $param{'text'};
	
	$self->{'array'} = \@arr;
	$self->{'num_str'} = 0;
	return $self;
}



1;
