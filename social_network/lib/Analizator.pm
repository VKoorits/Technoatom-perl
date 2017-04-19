package Analizator;
use strict;
use warnings;
use DBI;
use DBD::SQLite;
use Config::YAML;
use JSON::XS;
use 5.010;

sub new {
	my ($class, %param)  = @_;
	
	
	my $self = bless {}, $class;
	$self->{'config'} =  Config::YAML->new(config => $param{'config file'});
	
		# define database name and driver
	my $driver = $self->{'config'}{'db_param'}{'driver'};
	my $db_name = $self->{'config'}{'db_param'}{'db_name'};
	my $username = $self->{'config'}{'db_param'}{'username'};
	my $password = $self->{'config'}{'db_param'}{'password'};

	my $dbd = "DBI:$driver:dbname=$db_name";
	# sqlite does not have a notion of username/password

	# create and connect to a database
	$self->{'dbh'} = DBI->connect($dbd, $username, $password, { RaiseError => 1 })
		                  or die "can not connect: ".$DBI::errstr;
	return $self;
}

sub nofriends {
	my ($self) = @_;
	my $users  = $self->{'dbh'}->selectall_arrayref('SELECT ID, name FROM user WHERE count_friends == 0', {'Slice' =>{} } );
	return JSON::XS::encode_json($users);
}



sub friends{
	my ($self, @users) = @_;
	_check(@users);
	
	my (%hash_user_friends, @users_friends);
	$users_friends[$_] = _get_all_friends_id($self, $users[$_]) for(0..1);
	
	%hash_user_friends = map{$_ => 1} @{ $users_friends[0] };
	my ( $counter, @common_friends_id) = 0;
	my @answer;
	for(@{ $users_friends[1]} ) {
		if(exists $hash_user_friends{$_} ) {
			++$counter;
			my $name = $self->{'dbh'}->selectall_arrayref("SELECT name FROM user WHERE ID == ".$_);
			push @answer,  {'name' => $name->[0]->[0], 'id' => $_};
		}
	}
	return JSON::XS::encode_json( { list=>\@answer, count=>$counter} );
}



sub num_handshakes {
	my ($self, @users) = @_;	
	_check(@users);
	if( _count_friends($self, int($users[1])) > 0 ) {
		
		my ($num_handshakes, @suspects) = (0, $users[0]);
		my %checked_people = ($users[0] => 1);

		$| = 1;
		while (scalar @suspects) {
			if( $users[1] ~~ @suspects){
				return "[".$num_handshakes."]";
			}
		
			my @new_suspects = _get_all_friends_id($self, @suspects);
			@suspects = ();
			for(@new_suspects) {
				unless(exists $checked_people{$_}) {
					$checked_people{$_} = 1;
					push @suspects, @$_;
				}
			}		
			++$num_handshakes;
			say "count numshackes checked: $num_handshakes";
		}
	}
	return "[-1]";
}


sub _check{
	my @users = @_;
	unless(defined $users[0] && defined $users[1]) {
		die "Expected 2 iser_id\n";
	}
}

sub _count_friends {
	my ($self, $id) = @_;
	my $count = $self->{'dbh'}->selectall_arrayref('SELECT count_friends FROM user WHERE ID == '.$id);
	return $count->[0]->[0]//0;
}

sub _get_all_friends_id {
	my ($self, @id) = @_;
	my @friends;
	for my $i (0..1) {
		my $stmt = 	'SELECT friend'.(int(1 + $i)).'_id FROM user_relation WHERE friend'.(int(2 - $i)).'_id IN ( ';
		for(@id){
			$stmt .= int($_).', ';
		}
		chop($stmt);chop($stmt); $stmt .= ')';
		my $arr = $self->{'dbh'}->selectall_arrayref($stmt);
		for(@$arr) { push @friends, $_->[0]; }
	}
	return \@friends;
}

sub _get_name_array_by_id {
	my ($self, $id) = @_;
}

sub DESTROY {
	$_[0]->{'dbh'}->disconnect();
}














1;


