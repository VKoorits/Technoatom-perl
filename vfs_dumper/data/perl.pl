use warnings; 
use strict;
use JSON::XS;
use Data::Dumper;
use 5.010;

open(my $fh, '<', 'example1.bin') or die "no file";
binmode($fh);

my $comand = '';
my @path;
my %struct;
my $this_place = \%struct;

while(!eof($fh)){
	read($fh, $comand, 1);
	if($comand eq "D") {
		my $size = 0;#длина имени директории
		read($fh, $size, 2);
		$size = unpack('n', $size);

		my $dir_name;
		read($fh, $dir_name, $size);
	
		my $status;
		read($fh, $status, 2);
		$status = unpack('n', $status);
		
#say "Create dir: ".$dir_name." (".$status.")";
		
		$this_place->{$dir_name} = {};
		push @path, $dir_name;
	}elsif($comand eq "I") {
		$this_place = $this_place->{ $path[@path-1] };
	}elsif($comand eq "U") {
		pop @path;
		$this_place = replace(\@path, \%struct);
	}elsif($comand eq "F") {
		my $size_name = 0;#длина имени файла
		read($fh, $size_name, 2);
		$size_name = unpack 'n', $size_name;

		my $file_name;
		read $fh, $file_name, $size_name;
	
		my $status;
		read $fh, $status, 2;
		$status = unpack 'n', $status;
		
		my $size_file;
		read $fh, $size_file, 4;
		$size_file = unpack 'L', $size_file;
		
		my $sha1;
		read $fh, $sha1, 20;
		$sha1 = unpack 'C20', $sha1;
		
		say "Create file: $file_name \tsize: $size_file\tsha1: |$sha1|";
		$this_place->{'mode'} = dostup($status);
		$this_place->{$file_name} = 1;

		
		
	}elsif($comand eq "Z") {
		say "THIS IS END OF TREE";
		last;
	}
}
#print Dumper(\%struct);
#############

sub replace {
	my $path = shift;
	my $result = shift;
	
	for my $dir(@path) {
		$result = $result->{$dir};
	}
	
	return $result;
}


sub dostup {
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
	return 'false' if( $_[0] == 0);
	return 'true';
}


close($fh);
