package Local::Reducer;

use strict;
use warnings;
use utf8;


my $str;
sub  new {
	my ($class, %param) = @_;
	return bless \%param, $class;
}

sub reduced {
	return $_[0]->{'initial_value'};
}

1;
