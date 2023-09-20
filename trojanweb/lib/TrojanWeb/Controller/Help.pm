package TrojanWeb::Controller::Help;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use YAML::XS;

use Data::Dumper;
use TrojanWeb::Helper::AdminTools qw(check_admin);

sub index ($self) {
    return $self->render();
}

1;
