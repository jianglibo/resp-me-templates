#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

get '/' => sub ($c) {
  $c->render(template => 'index');
};

# Access request information
get '/agent' => sub ($c) {
  my $host = $c->req->url->to_abs->host;
  my $ua   = $c->req->headers->user_agent;
  $c->render(text => "Request by $ua reached $host.");
};

# Echo the request body and send custom header with response
post '/echo' => sub ($c) {
  $c->res->headers->header('X-Bender' => 'Bite my shiny metal ass!');
  $c->render(data => $c->req->body);
};

# Modify the received JSON document and return it
put '/reverse' => sub ($c) {
  my $hash = $c->req->json;
  $hash->{message} = reverse $hash->{message};
  $c->render(json => $hash);
};


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
