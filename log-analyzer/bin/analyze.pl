#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = 1.0;


my $filepath = $ARGV[0];
#die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";

	my $result;
	my %data;
	my %status;
	my %minutes_counter; 
#--------------------------------------------------------------обработка лога построчно
    while (my $log_line = <$fd>) {
		
		my $copy = $log_line;
		$copy =~ m{
				^(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
				\s\[\d{2}/\w{3}/\d{4}:(?<minute>\d{2}:\d{2}):\d{2}\s\+\d{4}\]\s
				".+?"\s
				(?<status>\d+)\s
				(?<size>\d+)\s
				".+"\s
				"(?<compress>.+)"$
		}x;
		
		
		$data{$1}{count} //= 0;
		$data{$1}{data} //= 0;
		$data{$1}{statuses}{$+{status}} //= 0;
		

		$data{$1}{count}+=1;
		$data{$1}{statuses}{$+{status}} += $+{size};
		$status{$+{status}}=1;

		if($+{status} eq "200"){
			if($+{compress} eq "-"){
				$data{$1}{data} += $+{size};
			}else{
				$data{$1}{data} += int($+{size}*$+{compress});
			}
		}
		$data{$1}{all_minutes}{$+{minute}} = 1;#отмечаем все минуты, в которые были запросы
		$minutes_counter{$+{minute}} = 1;
    }
    close $fd;
#-----------------------------------------------------------------подсчет total
	my @index = sort{$a cmp $b}keys %status;

	$data{total}{count} = 0;
	$data{total}{data} = 0;
	$data{total}{count_minuts} = scalar keys %minutes_counter;

	while( my ($k, $v) = each %data){
		if($k ne "total") {
			
			$data{total}{count} += $v->{count};
			$data{total}{data} += $v->{data};
			for my $status(@index){
				if(exists $v->{statuses}{$status}){
					$data{total}{statuses}{$status} += $v->{statuses}{$status};
				}
			}
		} 
	}
#-------------------------------------------------------------копирование необходимых данных в возвращаемую переменную
	

	my @arr_data = (sort{ $data{$b}{count} <=> $data{$a}{count} }keys %data)[0..10];#total + 10 ip с максимальной активностью
	$result->{status} = \@index;
	$result->{sorted_ip} = \@arr_data;
	for my $ip(@arr_data){
		$data{$ip}{count_minuts} = scalar keys %{ $data{$ip}{all_minutes} } if($ip ne "total");
		delete $data{$ip}{all_minutes};
		$data{$ip}{avg} = 
		$result->{$ip} = $data{$ip};
	}

    return $result;
}

sub report {
    my $result = shift;


    print "IP	count	avg	data";
	for my $status(@{$result->{status}}){
		print "\t".$status;
	}
	print "\n";
#////////////////////////
	for my $ip(@{ $result->{sorted_ip} }){
		print $ip."\t".$result->{$ip}{count}."\t".sprintf("%.2f", $result->{$ip}{count}/$result->{$ip}{count_minuts})."\t".int($result->{$ip}{data} / 1024);
		for my $status(@{$result->{status}}){
			if(exists $result->{$ip}{statuses}{$status}){
				print "\t".int($result->{$ip}{statuses}{$status} / 1024);
			 }else{ print "\t0"; }
		}	


		print "\n";
	}
}
