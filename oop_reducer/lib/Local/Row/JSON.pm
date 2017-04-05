package Local::Row::JSON;

use strict;
use warnings;
use utf8;
use Data::Dumper;
use JSON::XS;


sub  new {
	my ($class, %param) = @_;
	my $self = bless {}, $class;
	eval { $self->{json} = JSON::XS::decode_json( $param{text} ) };
	return $self;
}

sub get {
	my ($self, $name, $default) = @_;
	if(ref $self->{json} eq "HASH" ) {
		return $self->{json}{$name} // $default;
	}
	return $default;
}





1;
