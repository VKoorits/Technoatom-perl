use DBI;
use DBD::SQLite;

my $dbh = DBI->connect("DBI:SQLite:dbname=user.db", "", "", { RaiseError => 1 }) or die "can not connect: ".$DBI::errstr;

my $stmt = <<END;
CREATE TABLE notes
             (ID INTEGER PRIMARY KEY     AUTOINCREMENT,
			 user_id INTEGER  NOT NULL,
			 title VARCHAR NOT NULL,
			 text TEXT)
END
$dbh->do($stmt);

$stmt = <<END;
CREATE TABLE relation
             (note_id INTEGER NOT NULL,
			 reader_id INTEGER NOT NULL)
END
$dbh->do($stmt);

$stmt = <<END;
CREATE TABLE user
             (ID INTEGER PRIMARY KEY     AUTOINCREMENT,
              name      VARCHAR    NOT NULL,
              password VARCHAR NOT NULL)
END
$dbh->do($stmt);

$dbh->disconnect();
