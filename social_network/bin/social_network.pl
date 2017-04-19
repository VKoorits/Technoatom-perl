use strict;
use warnings;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use Analizator;
use 5.010;
use Data::Dumper;
use JSON::XS;

my (%param ,@param_users);
GetOptions(\%param, 'nofriends', 'friends', 'num_handshakes', 'user=i'=>\@param_users);
my $obj = Analizator->new('config file'=> 'config_file.yaml');

my $answer;

if(exists $param{'nofriends'}) {
	$answer = $obj->nofriends();
} elsif(exists $param{'friends'} ) {		
	$answer = $obj->friends(@param_users);
} elsif (exists $param{'num_handshakes'} ) {
	$answer = $obj->num_handshakes(@param_users);
} else { 
	die "programm want to get flag 'nofriends', 'friends' or 'num_handshakes'";
}

#любые действия с полученным JSON;
print Dumper(JSON::XS::decode_json($answer));

