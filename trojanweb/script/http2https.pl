#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;

# Define the HTTP and HTTPS ports
my $http_port = 80;
my $https_port = 443;

# Create an HTTP server that listens on the HTTP port
my $http_server = HTTP::Daemon->new(
    LocalPort => $http_port,
    ReuseAddr => 1,
) || die "Can't create HTTP server: $!";

print "HTTP server started on port $http_port\n";

# Infinite loop to handle incoming HTTP requests
while (my $client = $http_server->accept) {
    my $request = $client->get_request;

    if ($request) {
        # Redirect to HTTPS
        my $redirect_url = "https://" . $request->header('Host') . $request->uri;
        my $response = HTTP::Response->new(RC_MOVED_PERMANENTLY);
        $response->header('Location' => $redirect_url);
        $client->send_response($response);
    }

    $client->close;
    undef $client;
}


