package TrojanWeb;
use Mojo::Base 'Mojolicious', -signatures;

use Data::Dumper;
use Session::Token;
use TrojanWeb::Model::Users;
use TrojanWeb::Helper::TableRow;
use File::Path            qw(make_path);
use Mojo::JSON            qw(decode_json encode_json);
use Crypt::Digest::SHA224 qw( sha224 sha224_hex sha224_b64 sha224_b64u
  sha224_file sha224_file_hex sha224_file_b64 sha224_file_b64u );
use Number::Bytes::Human qw(format_bytes parse_bytes);
use DBI;

# BEGIN { $ENV{MOJO_I18N_DEBUG} = 1 }

sub startup ($self) {

# my $cfg = $self->config;
# my $cfg = $self->plugin( 'Config' => { file => 'trojanweb.conf.pl', hypnotoad => {proxy => 1} } );
    my $cfg = $self->plugin( 'Config' => { file => 'trojanweb.conf.pl' } );

    # https://metacpan.org/dist/Mojolicious-Plugin-I18N/view/README.pod
    # $self->plugin( 'I18N' => { default => 'en', lexicon => 'gettext' } );
    $self->plugin(
        I18N => {
            default           => 'en',
            namespace         => 'TrojanWeb::I18N',
            support_url_langs => [qw(en zh ja ko fa)]
        }
    );

    # $self->config( reverse_proxy => 1, hypnotoad => {proxy => 1} );
    $self->config(
        hypnotoad => {
            proxy  => 1,
            log => 'hypnotoad.log',
            listen => ['http://localhost:8080']
        }
    );
    $self->plugin('Mojolicious::Plugin::HTMX');
    my $dsn = "DBI:mysql:database=$cfg->{database};host=$cfg->{host}";

    my $download_path = $self->home->child('downloads');

    # Create the directory and its parents if they don't exist
    if ( !-d $download_path ) {
        make_path($download_path);
    }
    # my $dbh = DBI->connect( $dsn, $cfg->{username}, $cfg->{password},
    #     { RaiseError => 1, AutoCommit => 1 } );

    $self->helper( users => sub { state $users = TrojanWeb::Model::Users->new }
    );
    
    $self->helper( dbh => sub { 
        DBI->connect_cached( $dsn, $cfg->{username}, $cfg->{password},
        { RaiseError => 1, AutoCommit => 1 } );
     } );

    my $tpl = $self->app->home->child( 'templates', 'others', 'profiles',
        'basic.yaml' );

    $self->helper(
        cache => sub {
            state $cache = {
                basic_yaml => $tpl->slurp,
                cfg        => $cfg,
            };
        }
    );

    $self->secrets( [ $cfg->{secret} ] );

    $self->hook(
        before_routes => sub ($c) {
            $c->stash->{lang} = 'en' unless $c->stash->{lang};
        }
    );

    $self->helper(
        encode_json => sub {
            my $c = shift;
            return encode_json(@_);
        }
    );

    $self->helper(
        decode_json => sub {
            my $c = shift;
            return decode_json(@_);
        }
    );

    $self->helper( s_generator =>
          sub { state $s_generator = Session::Token->new( entropy => 256 ) } );

    $self->helper(
        is_admin => sub {
            my $c  = shift;
            my $ur = $c->session('user');
            return defined($ur) && $ur->{role} eq 'admin';
        }
    );

    $self->helper(
        user_lang => sub ($c) {
            my $crc = $c->req->cookie('user_lang');
            $crc && $crc->{value} || 'en';
        }
    );

    $self->helper(
        table_row => sub { TrojanWeb::Helper::TableRow::table_row(@_) } );

    $self->helper(
        format_bytes => sub ( $c, $bytes ) {
            return format_bytes($bytes);
        }
    );

    my $r = $self->routes;
    $r->any('/')->to('login#index')->name('index');

    my $logged_in = $r->under('/')->to('login#logged_in');

    $logged_in->get('/customers')->to('customers#index')->name('customers');
    $logged_in->get('/customers/configs')->to('customers#list_configs');
    $logged_in->post('/customers/configs')->to('customers#new_config');
    $logged_in->get('/customers/downloads')->to('customers#downloads')
      ->name('downloads');
    $logged_in->get('/customers/downloads/:id')->to('customers#download_get')
      ->name('download_get');
    $logged_in->post('/customers/downloads')->to('customers#new_download');
    $logged_in->delete('/customers/configs/:config_id')
      ->to('customers#delete_config');
    $logged_in->delete('/customers/downloads/:download_id')
      ->to('customers#delete_download');

    $r->get('/logout')->to('login#logout');

    # https://docs.mojolicious.org/Mojolicious/Routes
    # https://docs.mojolicious.org/Mojolicious/Routes/Route
    $logged_in->under('/trigger')->post(
        sub ($c) {
            state $count = 0;
            $count++;
            $c->htmx->res->trigger( showMessage => 'Here Is A Message' );
            $c->render( text => "Triggered $count times" );
        }
    );

    # my $size = format_bytes(0);

    $r->under('/misc/sha224')->post(
        sub ($c) {
            my $phrase = $c->param('phrase');
            $c->render( text => sha224_hex($phrase) );
        }
    );

    my $freearea = $r->any('/free')->to( controller => 'freearea' );
    $freearea->get('/')->to( action => 'index' );
    $freearea->get('/switch-lang/:lang')->to( action => 'switch_language' );
    $freearea->get('/config')->to( action => 'retrieve_config' )
      ->name('retrieve_config');

    my $is_admin = $r->under(
        '/admin',
        sub ($c) {
            return 1 if $c->is_admin;
            $c->render( text => 'Not Authorized', status => 401 );
            return undef;
        }
    );

    $is_admin->get("/")->to('admin#index')->name('admin');
    $is_admin->get("/clients")->to('client#index');
    $is_admin->post("/clients")->to('client#create');
    $is_admin->get("/clients/:client_id/edit")->to('client#edit_get');
    $is_admin->put("/clients/:client_id")->to('client#edit_put');
    $is_admin->get("/clients/:client_id")->to('client#show');
    $is_admin->post("/clients/search")->to('client#search');
    $is_admin->delete("/clients/:client_id")->to('client#delete');

    $logged_in->get("/help")->to('help#index')->name('help');

    $logged_in->get("/playground")->to('playground#index');
    $logged_in->get("/playground/github-repo")->to('playground#github_repo');
    $logged_in->get("/customers")->to('customers#index');
    $logged_in->get('/tools/fetch-rule-providers')
      ->to('playground#fetch_rule_providers')->name('fetch_rule_providers');

}

1;
