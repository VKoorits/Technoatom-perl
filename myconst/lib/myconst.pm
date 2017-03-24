package myconst;


use strict;
no warnings;

sub import() {
	shift;
	my $tags = _parse_arr(\@_);
	_add_constant($tags);	
	_create_export($tags);
	_use_export_in_caller();
}



	
sub _parse_arr {
	my $orig = shift;
	if(ref $orig eq "ARRAY") {
		
		(@$orig - 1) or die "invalid args checked"; #если передается только один параметр
		my %hash = @$orig;
		$orig = \%hash;		
	}
	my $where = shift // ['all'];
	my $tags = shift // {};
	while( my($k, $v) = each %$orig) {
		die "invalid args checked" unless($k =~ m/^[a-zA-Z_]+[0-9a-zA-Z_]*$/);#неподходящее название
		if(ref $v eq '') {
			for my $tag(@$where) {
				$tags->{$tag}{$k} = $v;
			}
		}elsif(ref $v eq 'HASH') {
			die "invalid args checked" if(scalar keys %$v == 1); #пустой хеш
			my @copy_where = (@$where, $k);
			_parse_arr($v, \@copy_where, $tags);
		}else{
			die "invalid args checked"; #неподходящий параметр
		}
	}
	return $tags;
}

sub _add_constant{
	my $tags = shift;
	my $pack = caller(1);
	no strict;
	while( my($k, $v) = each %{ $tags->{all} }) {	
		*{$pack."::".$k} =  sub(){return $v;};
	}
	use strict;
}

sub _create_export{
	my $tags = shift;
	my @export_ok = keys %{$tags->{all}};
	my %export_tags;
	for my $group_name(keys %$tags) {
		for my $constant_name(keys %{$tags->{$group_name}}) {
			push @{ $export_tags{$group_name} }, $constant_name;
		}
	}

	my $pack = caller(1);
	no strict;
	*{$pack."::EXPORT_OK"} = \@export_ok;
	*{$pack."::EXPORT_TAGS"} = \%export_tags;	
	use strict;
}
sub _use_export_in_caller {
	my $pack = caller(1);
	my $this_pack = __PACKAGE__;	
	eval "package $pack; use Exporter 'import'; package $this_pack;";
}






1;
