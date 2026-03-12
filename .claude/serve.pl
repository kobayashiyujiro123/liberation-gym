#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

my $port = $ENV{PORT} || 6543;
my $root = 'C:/Users/kobay/Downloads/AI-Engineer-claude-plan-solution-architecture-aHZVv 4';

my %mime = (
  html => 'text/html; charset=utf-8',
  js   => 'application/javascript',
  css  => 'text/css',
  png  => 'image/png',
  jpg  => 'image/jpeg',
  svg  => 'image/svg+xml',
  ico  => 'image/x-icon',
);

my $server = IO::Socket::INET->new(
  LocalAddr => '127.0.0.1',
  LocalPort => $port,
  Proto     => 'tcp',
  Listen    => 20,
  ReuseAddr => 1,
) or die "Cannot bind port $port: $!\n";

$SIG{PIPE} = 'IGNORE';  # SIGPIPEで落ちないようにする

print "Server started on http://localhost:$port\n";
STDOUT->flush();

while (1) {
  my $client = $server->accept() or next;
  eval {
    my $req = '';
    while (my $line = <$client>) {
      $req .= $line;
      last if $line =~ /^\r?\n$/;
    }
    my ($path) = $req =~ m{^\w+\s+(\S+)};
    $path //= '/';
    $path =~ s/\?.*//;
    $path =~ s{^/+}{};
    $path = 'gym-member.html' if $path eq '';

    my $file = $root . '/' . $path;
    $file =~ s{/}{\\}g;

    if (-f $file) {
      my ($ext) = $file =~ /\.(\w+)$/;
      my $ct = $mime{lc($ext // '')} // 'application/octet-stream';
      open(my $fh, '<:raw', $file) or die;
      my $body = do { local $/; <$fh> };
      close $fh;
      print $client "HTTP/1.1 200 OK\r\nContent-Type: $ct\r\nContent-Length: " . length($body) . "\r\nConnection: close\r\n\r\n$body";
    } else {
      print $client "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\nConnection: close\r\n\r\nNot Found";
    }
  };
  eval { close $client };
}
