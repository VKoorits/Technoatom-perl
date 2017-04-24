use strict;
use warnings;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AnyEvent::HTTP;
use 5.010;
use Data::Dumper;

sub worker{
	my ($handler, $request, $url) = @_;
	say $request;
	
	if($request =~ m/^URL\s(?<url>[\w\/\.\:]+)/){
		$url = $1;
	$handler->push_write ("OK\n");
	say 'OK';
	}elsif($request eq 'HEAD') {
		http_head($url, sub{ $handler->push_write( Dumper $_[1]); say 'OK';} );
	}elsif($request eq 'GET') {
		http_get($url, sub{ $handler->push_write( $_[0]."\n"); say 'OK'; } );
	}elsif($request eq 'FIN') {
		close $handler->fh;		
		say 'OK closed';
		return;
	}else{
		$handler->push_write("Wrong request\n");
		say 'Wrong request';
	}
	
	$handler->push_read (line => sub{ worker($_[0], $_[1], $url) } );
}

tcp_server '127.0.0.1', 8081, sub {
	my ($fh, $host, $port) = @_;
	$fh->autoflush(1);
	my $handler;
	$handler = new AnyEvent::Handle
		fh     	=> $fh,
		on_error=> sub {
			AE::log error => $_[2];
			$_[0]->destroy;
		},
		on_eof => sub {
			$handler->destroy; # destroy handle
			AE::log info => "Done.";
		};
	$handler->push_read (line => \&worker);	
};

AE::cv->recv();
