package VFS;
use utf8;
use Encode;
use warnings; 
use strict;
use feature 'state';
use JSON;
use Data::Dumper;
use 5.010;

my $str;
my $offset;

sub get {
	my ($len, $type) = @_;

	if($len == 0){ #аналог eof
		return $offset < length($str);
	}			

	my $res = substr($str, $offset, $len);
	$offset += $len;
	
	return $res unless(defined $type);
	return unpack $type, $res;
}

sub parse {
	$str = shift;
	$offset = 0;
	
	return {} if( substr($str, 0, 1) eq 'Z');
	die "The blob should start from 'D' or 'Z'" if(substr($str, 0, 1) ne 'D');
	
	my $comand = '';
	my $struct = { list=>[] };
	my $this_place = $struct->{'list'};
	my @path = ( $struct );
	my $last_dir;



	while( get(0) ){
		$comand = get(1);
		if($comand eq "D") {
			my $size = get(2,'n');
			my $dir_name = get($size);	
			my $status = get(2, 'n');
		
		
			my $dir = {};
			$dir->{'type'} = 'directory';
			$dir->{'name'} = decode('utf8', $dir_name);
			$dir->{'mode'} = mode2s($status);
			$dir->{'list'} = [];
			
			push @$this_place, $dir;#создать директорию
			$last_dir = $dir;
		}elsif($comand eq "I") {
			push @path, $last_dir;
			$this_place = $last_dir->{'list'};	
		}elsif($comand eq "U") {
			pop @path;
			$this_place = @path[ @path-1]->{'list'};
		}elsif($comand eq "F") {
			my $size_name = get(2, 'n');
			my $file_name = get($size_name);	
			my $status = get(2, 'n');		
			my $size_file = get(4, 'N');		
			my $hash = get(20, 'H40');
			
			my $file = {};
			$file->{'type'} = 'file';
			$file->{'name'} = decode('utf8', $file_name);
			$file->{'hash'} = $hash;
			$file->{'size'} = $size_file;
			
			
					
			$file->{'mode'} = mode2s($status);
			push @$this_place, $file;
		}elsif($comand eq "Z") {
			die "Garbage ae the end of the buffer" if(get(0));
			last;
		}
	}
	
	
	return $struct->{'list'}[0];
}

sub read_file {
	open my $file, "<", "$_[0]" or die "Can't open file $_[0]";
	local $/ = undef;
	return <$file>;
}



sub mode2s {
	my $status = shift;
	my %h;
	
	$h{'other'}{'execute'} = bool( $status & 1 );
	$h{'other'}{'write'} = bool( $status & 2 );
	$h{'other'}{'read'} = bool( $status & 4 );
	
	$h{'group'}{'execute'} = bool( $status & 8 );
	$h{'group'}{'write'} = bool( $status & 16 );
	$h{'group'}{'read'} = bool( $status & 32 );
	
	$h{'user'}{'execute'} = bool( $status & 64 );
	$h{'user'}{'write'} = bool( $status & 128 );
	$h{'user'}{'read'} = bool( $status & 256 );
	
	return \%h;
	
}

sub bool{
	return JSON::false if( $_[0] == 0);
	return JSON::true;
}

1;
