package TrojanWeb::Controller::Playground;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use YAML::XS;

use Data::Dumper;
use TrojanWeb::Helper::AdminTools qw(check_admin);

sub index ($self) {
    return $self->render();
}

sub get_github_resource ($url) {
    my $ua = Mojo::UserAgent->new;
    $ua->get(
        $url => {
            'Accept'               => 'application/vnd.github+json',
            'X-GitHub-Api-Version' => '2022-11-28'
        }
    )->result;
}

sub github_repo ($self) {
    my $repo = $self->param('repo');

    # check the cache first.
    my $cache_key = "github_repo_$repo";
    my $cache     = $self->cache;
    if ( $cache->{$cache_key} ) {
        return $self->render(
            template => 'playground/github_assets',
            repo     => $repo,
            assets   => $cache->{$cache_key}
        );
    }
    else {
        my $ua     = Mojo::UserAgent->new;
        my $url    = "https://api.github.com/repos/$repo/releases?per_page=1";
        my $result = get_github_resource $url;
        my $asset_url = $result->json->[0]{assets_url};
        my $assets    = ( get_github_resource $asset_url)->json;

        # put to cache
        $cache->{$cache_key} = $assets;

        # $self->htmx->res->reswap('none');
        return $self->render(
            template => 'playground/github_assets',
            repo     => $repo,
            assets   => $assets
        );
    }

}

sub fetch_rule_providers {
    my $self = shift;
    return if check_admin($self);
    my $fothers  = $self->app->home->child( 'templates', 'others' );
    my $f        = $fothers->child('rule-providers.yaml');
    my $rule_dir = $fothers->child('rules');

    if ( !-d $rule_dir ) {
        mkdir $rule_dir;
    }
    my $rule_providers = YAML::XS::LoadFile($f)->{'rule-providers'};
    for my $rule_name ( keys %$rule_providers ) {
        my $rule_provider = $rule_providers->{$rule_name};
        my $url        = $rule_provider->{url};
        my $local_file = $rule_dir->child( $rule_name . '.yaml' );
        my $ua         = Mojo::UserAgent->new;
        my $tx         = $ua->get($url);
        if ( $tx->result->is_success ) {
            my $content = $tx->result->body;
            $local_file->spurt($content);
        }
        else {
            $self->app->log->error("Download $url failed.");
        }
    }
    my $swal = {
        title => 'Success!',
        text  => qq(rules updated!),
        icon  => 'success',
    };
    $self->htmx->res->reswap('none');
    return $self->render( text => '' );
}

1;
