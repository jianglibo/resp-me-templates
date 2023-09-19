package TrojanWeb::Controller::Login;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Crypt::Digest::SHA224 qw( sha224_hex);
use TrojanWeb::Helper::AdminTools qw(cipher_passowrd);

use Data::Dumper;

sub index ($self) {
    my $user = $self->param('user') || '';
    my $pass = $self->param('pass') || '';

    if ( $self->session('user') ) {
        if ( $self->is_admin ) {
            $self->redirect_to('admin');
            return;
        }
        else {
            $self->redirect_to('customers');
            return;
        }
    }

    my $check_result = $self->users->check( $self->dbh, $user, $pass );

    if ($check_result) {
        $check_result->{ppw} = cipher_passowrd $self->app->secrets->[0], $pass;
        $self->session( user => $check_result );
        $self->flash( message => 'Thanks for logging in.' );
        print Dumper($check_result);
        print Dumper($pass);
        # if ( $self->is_admin ) {
        # $self->redirect_to('admin');
        # } else {
        $self->redirect_to('customers');

        # }
    }
    else {
        return $self->render();
    }

    #   unless $self->users->check( $self->dbh, $user, $pass );

}

our @predefined_paths = ( '/path1', '/path2', '/path3' );
our $alloed_prefix    = '/free/';

sub allowed ( $self, $path ) {
    my $allowed = 0;
    foreach my $p (@predefined_paths) {
        if ( $p eq $path ) {
            $allowed = 1;
            last;
        }
    }
    return $allowed;
}

sub logged_in ($self) {
    my $path = $self->req->url->path;
    return 1
      if substr( $path, 0, length($alloed_prefix) ) eq $alloed_prefix
      || $self->allowed($path);
    return 1 if $self->session('user');
    $self->redirect_to('index');
    return undef;
}

sub logout ($self) {
    $self->session( expires => 1 );
    $self->redirect_to('index');
}

1;
