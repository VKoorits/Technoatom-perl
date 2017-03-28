package Local::Row::JSON;

use strict;
use warnings;
use utf8;
use Data::Dumper;
use JSON::XS;


sub  new {
	my ($class, %param) = @_;

	eval { $param{json} = JSON::XS::decode_json( $param{text} ) };
	
	delete $param{text};
	return bless \%param, $class;
}

sub get {
	my ($self, $name, $default) = @_;
	if(ref $self->{json} eq "HASH" ) {
		return $self->{json}{$name} // $default;
	}
	return 0;
}





1;
