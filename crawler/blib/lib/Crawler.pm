package Crawler;

use 5.010;
use strict;
use warnings;

use URI::URL;
use LWP::Simple;
use HTML::LinkExtor;
use URI::URL;
use AnyEvent::HTTP;
use Data::Dumper;
use DDP;

#my $start_url = 'https://github.com/Nikolo/Technosfera-perl/tree/anosov-crawler/';
my %data;
my $counter = 999;
my $count_links = 0; #глубина рекурсии
my @all_links;
my $cv = AnyEvent->condvar;

$|=1;

sub run {
	my $start_url = shift;
	#выкачиваем
	http_get 
		$start_url,
		sub {geter($_[0], $_[1], $start_url)};
	$cv->recv;
	
	#обрабатываем
	my @keys = sort{$data{$b} <=> $data{$a} }keys %data;
	my $sum = 0;
	my $count = 0;
	for(values %data) {
		$sum += $_;
		$count++;
	}
	
	
	
	warn Dumper(($sum, @keys[0..9]));
	return ($sum, @keys[0..9]);
}




sub geter{	
		my ($body, $hr, $url) = @_;
		goto FUNCTION_EXIT if( $hr->{'Status'} > 299 || $hr->{'Status'} < 200);

		$data{$url} = $hr->{'content-length'};
				
		
		my $p = HTML::LinkExtor->new(\&callback);
		$p->parse($body);
		
		links_handler($url);		

		FUNCTION_EXIT:
		#print $count_links.'->';
		unless($count_links) {
			$count_links = 1;
			$cv->send;
		}
}

sub links_handler {
	my $url = shift;
	my @links = ();
	for(@all_links) {
		my $link  = URI->new($_)->abs($url)->as_string;
		if( $link =~ m{^$url}) {
		
			$link = [split('#', $link)]->[0]; #отрезаем теги приивязки
			unless( exists $data{$link} ) {
				$count_links++;
				$data{$link} = 0;
				original_link_handler($link);
			}
		}
		
	}
	@all_links = ();
}

sub original_link_handler {
	my $link = shift;
	--$counter;
	$cv->send if( $counter <= 0 );
	http_head
			$link,
			sub {
				if($_[1]->{'content-type'} =~ m{text/html}  &&
					$_[1]->{'Status'} / 100 == 2 ) {					
					http_get 
						$link, 
						sub { --$count_links; geter(@_, $link)};
				}else{
					$data{$link} = 0; #неподходящая ссылка
				}
			};
}

sub callback {
	my($tag, %attr) = @_;
	return if $tag ne 'a';
	push(@all_links, values %attr);
}

1;
