package TrojanWeb::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use TrojanWeb::Helper::DbStatements qw($insert_user $select_user update_one_field select_users);

use Data::Dumper;



sub index ($self) {
    my $rows = select_users $self->dbh, 0;
    $self->render( error => undef, rows => $rows );
}

1;
