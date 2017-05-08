package Crawler;

use 5.010;
use strict;
use warnings;

use URI::URL;
use HTML::LinkExtor;
use URI::URL;
use AnyEvent::HTTP;
use DDP;

my($size, @links) = run('https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler/', 100);
print "\nsummary size: $size\n";
print"\n============================================\n";
p @links;

sub run{
	my @queue = (shift);
	my $max_parallel = shift;
	my %seen;
	
	
	my $cv = AE::cv;
	my $work;
	
	$work = sub{
		$cv->begin();
		my $url = shift @queue;
		return unless(defined $url);
		http_head
			$url,
			sub{
				if($_[1]->{'content-type'} =~ m{^text/html}){
					http_get
						$url,
						sub{
							
							my ($body, $head) = @_;
							if( $head->{'Status'} < 300 && $head->{'Status'} > 199) { 
								$seen{$url} = $head->{'content-length'};
								my $p = HTML::LinkExtor->new(
									sub{
										my($tag, %attr) = @_;
										if($tag eq 'a') {
											my $link  = URI->new($attr{'href'})->abs($url)->as_string;
											$link = [split('#', $link)]->[0]; #отрезаем теги приивязки
										
											unless(defined $seen{$link} || $link !~ m/^$url/) {			
												push(@queue, $link);
											}
										}
									});
								$p->parse($body);
							}
							
							$work->() while @queue && $cv->{_ae_counter} < $max_parallel;

							$cv->end();
						}
						
				}else{
					$cv->end();
				}
				
			}
	};
	$work->();
	$cv->recv; 
	
	my @keys = sort{$seen{$b} <=> $seen{$a} }keys %seen;
	my $sum = 0;
	for(values %seen) {
		$sum += $_;
	}	
	return ($sum, @keys[0..9]);
}
1;
