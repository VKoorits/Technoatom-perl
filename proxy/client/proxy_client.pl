use strict;
use warnings;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AE;
use DDP;
$| = 1;
tcp_connect 'localhost', 8081, sub {
	my ($fh) = @_;
	$fh->autoflush(1);
	my $handle;
	$handle = new AnyEvent::Handle(
		fh => $fh,
		on_error => sub {
			AE::log error => $_[2];
			$_[0]->destroy;
		},
		on_eof => sub {
			$handle->destroy;
			AE::log info => "Done.";
		}
	);
	
	my $request = "";
	for(1..3){
		print '> ';          
		my $request = <>;
		$handle->push_write($request);

		$handle->push_read ( line => sub {
			my ($handle, $answer) = @_;
			print $answer."\n";
		} );
	}
};

AE::cv->recv();
