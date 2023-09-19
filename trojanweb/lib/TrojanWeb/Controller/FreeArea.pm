package TrojanWeb::Controller::Freearea;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use TrojanWeb::Helper::DbStatements qw(select_config_by_password);
use TrojanWeb::Helper::AdminTools   qw(cipher_passowrd decipher_password);

use Data::Dumper;

sub index ($self) {
    return $self->render( text => 'Free area' );
}

# UserController.pm
sub switch_language ($self) {
    my $lang = $self->param('lang');

    # Set a cookie to remember the user's language preference
    # $self->cookie('user_lang' => $lang, { expires => time + 365 * 86400 });
    # $self->htmx->res->trigger( newLang => $lang );
    # Redirect the user to a page or route of your choice

    $self->redirect_to( '/', lang => $lang );

    # $self->render(template => 'layouts/_language_dropdown', lang => $lang)
}

sub retrieve_config ($self) {
    my $cpw = $self->param('pw');
    # my $secret = $self->app->secrets->[0];

    my $config = select_config_by_password( $self->dbh, $cpw );
    if ($config) {
        $self->render( text => $config->{config} );
    }
    else {
        $self->render( text => 'No config found' );
    }
}

1;
