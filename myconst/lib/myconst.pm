package myconst;


use strict;
use warnings;
use Scalar::Util 'looks_like_number';

sub import() {
	shift;
	my $tags = _parse_arr(\@_);
	_add_constant($tags);
	
}



	
sub _parse_arr{
	my $orig = shift;
	if(ref $orig eq "ARRAY") {
		my %hash = @$orig;
		$orig = \%hash;		
	}
	my $where = shift // [];
	my $tags = shift // {};
	while( my($k, $v) = each %$orig) {
		if(ref $v eq ''){
			for my $tag(@$where) {
				push @{ $tags->{$tag} }, $k;
			}
			$tags->{'all'}{$k} = $v;
		}elsif(ref $v eq 'HASH') {
			my @copy_where = (@$where, $k);
			_parse_arr($v, \@copy_where, $tags);
		}else{
			die "invalid args checked"
		}
	}
	return $tags;
}

sub _add_constant{
	my $tags = shift;
	my $pack = caller(1);
	no strict;
	while( my($k, $v) = each %{ $tags->{all} }) {	
		*{$pack."::".$k} =  sub {return $v;};
	}
	use strict;
}






1;
