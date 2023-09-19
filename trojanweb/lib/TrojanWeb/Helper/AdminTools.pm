package TrojanWeb::Helper::AdminTools;
use strict;
use warnings;
use Crypt::CBC;
use Exporter qw(import);
use YAML::XS;

our @EXPORT = qw(check_admin cipher_passowrd decipher_password substitute_domain_password);

sub check_admin {
    my $self = shift;
    if ( !$self->is_admin ) {
        my $swal = {
            title => 'Error!',
            text  => q(You are not admin!),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
    return undef;
}

sub _cipher {
    my $secret = shift;
    Crypt::CBC->new(
        -pass   => $secret,
        -cipher => 'Cipher::AES',
        -pbkdf  => 'pbkdf2',
    );
}

sub cipher_passowrd {
    my ( $secret, $password ) = @_;
    _cipher($secret)->encrypt_hex($password);
}

sub decipher_password {
    my ( $secret, $password ) = @_;
    _cipher($secret)->decrypt_hex($password);
}

sub substitute_domain_password {
    my ($self, $ppw) = @_;
    my $yaml = $self->cache->{basic_yaml};
    my $domain = $self->cache->{cfg}->{domain_name};
    my $password = decipher_password $self->app->secrets->[0], $ppw;
    my $config = Load($yaml);
    $config->{proxies}->[0]->{server} = $domain;
    $config->{proxies}->[0]->{password} = $password;
    return Dump($config);
}