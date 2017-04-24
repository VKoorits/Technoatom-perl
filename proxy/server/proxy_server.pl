use strict;
use warnings;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AE;
use DDP;
$| = 1;

tcp_server '127.0.0.1', 8081, sub {
	my ($fh, $host, $port) = @_;
	$fh->autoflush(1);
	my $handle;
	$handle = new AnyEvent::Handle
		fh     	=> $fh,
		on_error=> sub {
			AE::log error => $_[2];
			print "ON_ERROR\n";
			$_[0]->destroy;
		},
		on_eof => sub {
			print "ON_EOF\n";
			$handle->destroy; # destroy handle
			AE::log info => "Done.";
		};
	
	
	my $request = "";
	my $url = "";

	for(1..3) {
		$handle->push_read (line => sub {
			$request = $_[1];
			print "$request\n";
		});
		$handle->push_write( "OK".(time())."\n" );		
	}
};

AE::cv->recv();

