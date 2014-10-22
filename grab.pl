#!/usr/bin/perl
use warnings;
use strict;
use LWP::UserAgent;
use AnyEvent::HTTP;
use Data::Dumper;

my $anonymous_proxy_test_web_page = shift;

$AnyEvent::HTTP::MAX_PER_HOST = 5;

my $ua = LWP::UserAgent->new();
$ua->agent('Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:32.0) Gecko/20100101 Firefox/32.0');

open my $fh, ">", "proxy_list.txt";
select((select($fh), $| = 1)[0]);

my $proxy_url = "http://cn-proxy.com/";
my $resp = $ua->get($proxy_url);
my $content = $resp->decoded_content;

my @proxys;
while ( $content =~ m{<td>(\d+\.\d+\.\d+\.\d+)</td>\s*<td>(\d+)</td>}gis ) {
    push @proxys, {ip => $1, port => $2};
}

print "grab proxy num: ", scalar(@proxys), "\n";
is_anonymous(@proxys);

sub is_anonymous {
    my @proxys = @_;

    foreach ( @proxys ) {
	my $proxy = $_->{ip} . ":" . $_->{port};

	my $cv = AnyEvent->condvar;

	http_get $anonymous_proxy_test_web_page,
	proxy => [$_->{ip}, $_->{port}, "http"],
	sub { my ( $body, $hdr ) = @_;
	      #print $body; 
	      
	      if ( $body =~ /^0$/ ) {
		  print "found transparent proxy: $proxy\n";
	      }

	      if ( $body =~ /^1$/ ) {
		  print "found anonymous proxy: $proxy\n";
		  print $fh $proxy . "\n";
	      }
	      $cv->send; 
	};

	$cv->recv;
    }
}

close $fh;
