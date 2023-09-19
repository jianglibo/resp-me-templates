package TrojanWeb::Controller::Customers;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::Util qw(b64_encode );
use HTML::Entities;
use YAML::XS;

use TrojanWeb::Helper::AdminTools qw(check_admin substitute_domain_password);

# use File::Path qw(basename);
use File::Basename;
use Encode;
use TrojanWeb::Helper::DbStatements
  qw($insert_user $select_user update_one_field
  select_configs create_config select_config select_downloads select_download create_download
  );

use Data::Dumper;

sub index ($self) {
    print Dumper("-----------------------------------");

    # print Dumper($self->user_lang);
    print Dumper("-----------------------------------");
    my $user_id = $self->session('user')->{user_id};
    my $rows    = select_configs $self->dbh, $user_id, 0;
    my $ppw     = $self->session('user')->{ppw};
    $self->render(
        error       => undef,
        rows        => $rows,
        ppw         => $self->session('user')->{ppw},
        model_value => {
            config => ( substitute_domain_password $self, $ppw ),
            name   => '',
        },
    );
}

sub list_configs ($self) {
    my $page = $self->param('page') || 1;

    # my $search = $self->param('search');
    my $user_id = $self->session('user')->{user_id};
    my $rows    = select_configs $self->dbh, $user_id, $page - 1;
    return $self->render(
        error => undef,
        rows  => $rows,
        ppw   => $self->session('user')->{ppw},
    );
}

sub downloads ($self) {
    my $page = $self->param('page') || 1;
    my $rows = select_downloads $self->dbh, $page - 1;
    return $self->render(
        error => undef,
        rows  => $rows
    );
}

sub delete_config ($self) {
    my $config_id     = $self->param('config_id');
    my $login_user_id = $self->session('user')->{user_id};
    my $row_to_delete = select_config $self->dbh, $login_user_id, $config_id;
    if ( !$row_to_delete || $row_to_delete->{owner_id} != $login_user_id ) {
        my $swal = {
            title => 'Error!',
            text  => $self->l(q(It's not your config!)),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
    # my $rows_affected = 
    #   $self->dbh->do( "DELETE FROM configs WHERE id = ?", undef, $config_id );
    TrojanWeb::Helper::DbStatements::delete_config $self->dbh, $config_id;
    # print "Rows Affected: $rows_affected\n";
    return $self->render( text => '' );
}

sub new_config ($self) {
    my $user_id        = $self->session('user')->{user_id};
    my $config_name    = $self->param('config_name');
    my $config_content = $self->param('config_content');
    my $password       = $self->s_generator->get;

    eval { Load($config_content); } or do {
        my $error = $@;
        my $swal  = {
            title => 'Malformed YAML!',
            text  => $error,
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    };

    my $ppw = $self->session('user')->{ppw};

    my $config = create_config $self->dbh, $user_id, $config_name,
      $password, $config_content;

    my $tr = $self->render_to_string(
        template    => 'customers/_config_row',
        model_value => $config,
        ppw         => $ppw,
        fix_lang    => 1,
        h           => {}
    );

    $self->htmx->res->trigger( newConfig => $tr );

    $self->render(
        template    => 'customers/_edit_config',
        error       => undef,
        model_value => {
            name   => '',
            config => ( substitute_domain_password $self, $ppw ),
        },
        h => { display => 1 }
    );
}

# Function to extract filename from URL
sub extract_filename {
    my ($url) = @_;

    # Use a regular expression to match the filename
    if ( $url =~ m/\/([^\/?#]+)(?:\?|\#|$)/ ) {
        return $1;    # Return the matched filename
    }
    else {
        return undef;    # Return "null" if no filename can be guessed
    }
}

# don't save the download but instead return the download object.
sub _download_remote_asset {
    my ( $self, $name, $url ) = @_;
    my $filename_url = basename($url);
    $filename_url =~ s/#.*$//;
    my $downloads_dir = $self->app->home()->child('downloads');
    my $ua            = Mojo::UserAgent->new;
    my $res;
    eval {
        $res = $ua->max_redirects(5)->get($url)->result;
        if ( $res->is_success ) {
            my $content_disposition =
              $res->headers->header('Content-Disposition');
            my $filename;
            if ($content_disposition) {
                $filename = $content_disposition =~ /filename="([^"]+)"/;
            }

            $filename //= $filename_url;
            $filename ||= $name;

            my $file_dst = $downloads_dir->child($filename);

            # if $file_dst exists, delete it.
            if ( -e $file_dst ) {
                unlink $file_dst;
            }
            $res->save_to($file_dst);

            # my $download = create_download $self->dbh, $name, $url, $filename;
            return { name => $name, url => $url, pathname => $filename };
        }
    } or do {
        my $error = $@;
        warn "Error: $error";
        return undef;
    };
}

sub new_download ($self) {
    return if check_admin($self);
    my $name            = $self->param('name');
    my $url             = $self->param('url');
    my $download_result = _download_remote_asset $self, $name, $url;
    if ($download_result) {
        my $download = create_download $self->dbh, $download_result->{name},
          $download_result->{url}, $download_result->{pathname};
        my $tr = $self->render_to_string(
            template    => 'customers/_download_row',
            model_value => $download,
            h           => {}
        );
        $self->htmx->res->trigger( newDownload => $tr );
        $self->render(
            template    => 'customers/_edit_download',
            error       => undef,
            model_value => {
                name => '',
                url  => '',
            },
            h => { display => 1 }
        );

    }
    else {
        my $swal = {
            title => 'Error!',
            text  => $self->l(q(Cannot download file)),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
}

sub delete_download ($self) {
    return if check_admin($self);
    my $download_id = $self->param('download_id');
    eval {
        # Code that might throw an exception
        my $download = select_download $self->dbh, $download_id;
        print Dumper($download);
        my $file_dst =
          $self->app->home->child('downloads')
          ->child( $download->{'pathname'} );
        unlink $file_dst;
        1;    # Return a true value to indicate success
    } or do {
        my $error = $@;
        warn "Error: $error";
    };

    my $rows_affected = $self->dbh->do( "DELETE FROM downloads WHERE id = ?",
        undef, $download_id );
    print "Rows Affected: $rows_affected\n";
    return $self->render( text => '' );
}

sub download_get ($self) {
    print Dumper( $self->is_htmx_request );
    my $is_hx = $self->is_htmx_request;
    print Dumper($is_hx);
    my $download = select_download $self->dbh, $self->param('id');
    if ( !$download ) {
        if ($is_hx) {
            my $swal = {
                title => 'Error!',
                text  => $self->l(q(Not Found)),
                icon  => 'error',
            };
            $self->htmx->res->reswap('none');
            $self->htmx->res->trigger(
                newError => $self->l( $self->encode_json($swal) ) );
            return $self->render( text => '' );
        }
        else {
            return $self->render( text => 'Not Found', status => 404 );
        }
    }
    my $pathname   = $download->{'pathname'};
    my $file_local = undef;
    if ($pathname) {
        my $_file_local =
          $self->app->home->child('downloads')->child($pathname);
        if ( -e $_file_local ) {
            $file_local = $_file_local;
        }
    }
    if ( !$file_local ) {
        my $download = _download_remote_asset $self, $download->{name},
          $download->{'url'};
        if ($download) {
            $pathname = $download->{pathname};
            $file_local =
              $self->app->home->child('downloads')->child($pathname);
        }
        else {
            if ($is_hx) {
                my $swal = {
                    title => 'Error!',
                    text  => $self->l(q(Cannot download file)),
                    icon  => 'error',
                };
                $self->htmx->res->reswap('none');
                $self->htmx->res->trigger(
                    newError => $self->l( $self->encode_json($swal) ) );
                return $self->render( text => '' );
            }
            else {
                return $self->render( text => 'Not Found', status => 404 );
            }
        }
    }

    if ($is_hx) {
        $self->htmx->res->reswap('none');
        print Dumper( $self->req->url->path );
        $self->htmx->res->redirect( $self->req->url->path );
        return $self->render( text => '' );
    }
    else {
        $self->res->headers->content_disposition(
            "attachment; filename=${pathname};");
        return $self->reply->file($file_local);
    }

}

1;
