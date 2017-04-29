package Stickers;
use Dancer;
use DBI;
use DBD::SQLite;
use 5.010;
use YAML::Tiny;

sub connect_db {
	state $dbh;
	return $dbh if(defined $dbh);
	my $config = YAML::Tiny->read('etc/config_file.yaml');
	$config = $config->[0];
	
		# define database name and driver
	my $driver = $config->{'db_param'}->{'driver'};
	my $db_name = $config->{'db_param'}->{'db_name'};
	my $username = $config->{'db_param'}->{'username'};
	my $password = $config->{'db_param'}->{'password'};
	

	my $dbd = "DBI:$driver:dbname=$db_name";
	$dbh = DBI->connect($dbd, $username, $password, { RaiseError => 1 })
		                  or die "can not connect: ".$DBI::errstr;
	
#$dbh = DBI->connect("DBI:SQLite:dbname=user.db", "", "", { RaiseError => 1 }) or die "can not connect: ".$DBI::errstr;
	return $dbh;
}	

hook 'before' => sub {
		set session => 'simple';
		if (request->path_info !~ m{^/login} && !session('user_id')) {
		    redirect '/login';
		}
    };
any '/index' => sub {
	my $title = params->{title};
	my $text = params->{text};
	if(defined $title && defined $text ) {
		my $dbh = connect_db();

		my $sth = $dbh->prepare("INSERT INTO notes (user_id, title, text) VALUES (?,?,?)");
		$sth->execute(session('user_id'), $title, $text);
		my $note_id = $dbh->selectall_arrayref("SELECT max(ID) FROM notes")->[0]->[0];
		
		my %nicknames = map{ $dbh->quote($_) => 1}  split ' ', params->{users}//'';
		my %for_who_id = map{$_->[0] => 1 } @{ $dbh->selectall_arrayref(
				"SELECT ID FROM user WHERE name IN(".(join',', keys %nicknames).")"
		 ) };	
		delete $for_who_id{session('user_id')};
		
		my $stmt = "INSERT INTO relation (note_id, reader_id) VALUES (".$note_id.",".session('user_id');
		if(scalar keys %for_who_id){  $stmt .= "), ($note_id, ".(join "), ($note_id, ", keys %for_who_id); };
		$stmt .= ")";
		
		$dbh->do($stmt);
		redirect '/list'; 
	} else {
		template 'index';
	}
   
};

any '/list' => sub {
	my $dbh = connect_db();
	my @notes_id = map{$_->[0]} @{
					$dbh->selectall_arrayref("SELECT note_id FROM relation WHERE reader_id = ".(session('user_id'))) };
	my @notes = @{
			$dbh->selectall_arrayref(
			"SELECT u.name, n.title, n.text 
				FROM notes n INNER JOIN user u ON n.user_id = u.ID
				WHERE n.ID IN ("
				.(join ', ', @notes_id)
				.")"
			, {Slice => {}}) };
	template 'list', {notes => \@notes};
};

any '/login' => sub {
   my $user = params->{username};
   my $password = params->{password};
   if(defined $user && defined $password) {
        
		my $dbh = connect_db();

		my $sth = $dbh->prepare("SELECT ID FROM user WHERE name = ? AND password = ?");
		$sth->execute($user, crypt($password, $user));
		my $answer = $sth->fetchrow_arrayref();
		
		if( not defined $answer) {  #registration
			my $sth = $dbh->prepare("INSERT INTO user (name, password) VALUES(?, ?)");
			$sth->execute($user, crypt($password, $user));
			$answer = $dbh->selectall_arrayref("SELECT max(ID) FROM user")->[0];	
		}		
		session user_id => $answer->[0];
		redirect '/index';
	}else{
		template '/login';
	}
}; 

1;
