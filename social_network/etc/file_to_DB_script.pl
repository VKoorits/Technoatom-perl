#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use DBD::SQLite;
use Archive::Zip;


# define database name and driver
my $driver   = "SQLite";
my $db_name = "user.db";
my $dbd = "DBI:$driver:dbname=$db_name";
# sqlite does not have a notion of username/password
my $username = "";
my $password = "";

# create and connect to a database
my $dbh = DBI->connect($dbd, $username, $password, { RaiseError => 1 })
                      or die "can not connect: ".$DBI::errstr;

my %count_friends;                     
##############################################################################        USER_RELATION
my $stmt = qq(CREATE TABLE IF NOT EXISTS user_relation
             (friend1_id INTEGER,
              friend2_id INTEGER));
my $ret = $dbh->do($stmt);
if($ret < 0) {
   die "can not create DB: ".$DBI::errstr;
}           


print "count user relation requests (x100000):\n";
my $zip = Archive::Zip->new("user_relation.zip");
$zip->extractMember('user_relation');
open(my $users_fh, '<', 'user_relation') or die 'no file "user_relation"';
	my $i = 0; #ограничние на время рзработки
	my $z = 0;
	$stmt = "INSERT INTO user_relation (friend1_id, friend2_id) VALUES ";
	while(<$users_fh>) {
		my @data = split(' ', $_);	
		$stmt .= '(' . (int($data[0])) . ', '. (int($data[1])) . '), ';
		if ( exists $count_friends{ $data[0] } ) {
			$count_friends{ $data[0] }++;
		}else{ $count_friends{ $data[0] } = 1; }
		
		if ( exists $count_friends{ $data[1] } ) {
			$count_friends{ $data[1] }++;
		}else{ $count_friends{ $data[1] } = 1; }

		if(++$i % 100000 == 0) {
			chop ($stmt);
			chop ($stmt);
			$stmt .=';';
			$dbh->do($stmt);
$| = 1; print (++$z); print " ";
			$stmt = 'INSERT INTO user_relation (friend1_id, friend2_id) VALUES ';
		}
	}
	if($i % 100000 != 0) {
			chop ($stmt);
			chop ($stmt);
			$dbh->do($stmt);
	}

close($users_fh);
unlink("user_relation");

##################################################################### USERS
$stmt = qq(CREATE TABLE IF NOT EXISTS user
             (ID INTEGER PRIMARY KEY     AUTOINCREMENT,
              name      VARCHAR    NOT NULL,
              count_friends INTEGER ));

$ret = $dbh->do($stmt);
if($ret < 0) {
   die "can not create DB: ".$DBI::errstr;
}
print "\ncount user requests (x1000):\n";
$zip = Archive::Zip->new("user.zip");
$zip->extractMember('user');
open($users_fh, '<', "user") or die "no file 'user'";
	$i = $z = 0;
	$stmt = 'INSERT INTO user (name, count_friends) VALUES ';
	while(<$users_fh>) {
		++$i;		
		my @data = split(" ", $_);
		my $count_friends = $count_friends{$i} // 0;
		$stmt .= "('".$data[1]." ".$data[2]."', ".$count_friends."), ";

		if($i % 1000 == 0) {
			chop ($stmt);
			chop ($stmt);
			$stmt .=';';
			$dbh->do($stmt);
				$| = 1; print ++$z." ";
			$stmt = 'INSERT INTO user (name, count_friends) VALUES ';

		}
	}
	if($i % 1000 != 0) {
			chop ($stmt);
			chop ($stmt);
			$dbh->do($stmt);
	}
	

close($users_fh);
unlink("user");



# quit the database
$dbh->disconnect();
