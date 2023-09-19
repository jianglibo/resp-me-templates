package TrojanWeb::Controller::Client;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Data::Dumper;
use Number::Bytes::Human  qw(format_bytes parse_bytes);
use Crypt::Digest::SHA224 qw( sha224 sha224_hex sha224_b64 sha224_b64u
  sha224_file sha224_file_hex sha224_file_b64 sha224_file_b64u );
use TrojanWeb::Helper::DbStatements
  qw($insert_user $select_user update_one_field select_users select_config);

# https://metacpan.org/pod/DBI

sub index ($self) {
    my $page   = $self->param('page') || 1;
    my $search = $self->param('search');
    my $row    = select_users $self->dbh, $page - 1, $search;
    return $self->render(
        error  => undef,
        rows   => $row,
        search => $search,
        page   => $page
    );
}

sub edit_get ($self) {
    my $client_id = $self->param('client_id');
    my $fname     = $self->param('fname');
    my $fvalue    = $self->param('fvalue');
    return $self->render(
        client_id => $client_id,
        fname     => $fname,
        fvalue    => $fvalue
    );
}

sub edit_put ($self) {
    my $hash_ref = $self->req->params->to_hash;
    my $fname    = ( keys %$hash_ref )[0];
    print Dumper($fname);
    my $client_id         = $self->param('client_id');
    my $fvalue            = $self->param($fname);
    my $value_from_client = $fvalue;
    if ( "password" eq $fname ) {
        $fvalue            = sha224_hex($fvalue);
        $value_from_client = "Change me";
    }
    elsif ( "quota" eq $fname ) {
        $fvalue            = parse_bytes($fvalue);
        $value_from_client = format_bytes($fvalue);
    }
    update_one_field $self->dbh, $client_id, $fname, $fvalue;
    return $self->render(
        cid    => $client_id,
        fname  => $fname,
        fvalue => $value_from_client
    );
}

sub create ($self) {
    my $username = $self->param('username');
    my $password = $self->param('password');
    my $quota    = $self->param('quota');

    my $parsed_quota = parse_bytes($quota);
    my $hashed_pass  = sha224_hex($password);

    # $parsed_quota maybe not initialized

    # sleep(5);    # Sleep for 5 seconds

    if ( !$parsed_quota ) {
        my $swal = {
            title => 'Error!',
            text  => $self->l('Invalid quota.'),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }

    if ( !$username || !$password || !$parsed_quota ) {
        my $swal = {
            title => 'Error!',
            text  => $self->l('All input fields are needed.'),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
    }

    eval {
        my $rows_affected =
          $self->dbh->do(
            "INSERT INTO users (username, password, quota) VALUES (?,?, ?)",
            undef, $username, $hashed_pass, $parsed_quota );
        print "Rows Affected: $rows_affected\n";
        my $last_insert_id = $self->dbh->last_insert_id();
        print "Last Insert ID: $last_insert_id\n";
        print "$select_user";
        print "select_user";
        my $client =
          $self->dbh->selectrow_hashref( "SELECT * FROM users WHERE id = ?",
            undef, ($last_insert_id) );

        my $tr = $self->render_to_string(
            template => 'client/_table_row',
            client   => $client,
            h        => {}
        );
        $self->htmx->res->trigger( newClient => $tr );
        print Dumper(".....................................................");
        return $self->render(
            template => 'client/_add_form',
            error    => undef,
            client   => {
                username => '',
                password => '',
                quota    => ''
            },
            h        => { display => 1 }
        );
    };

    if ($@) {
        my $swal = {
            title => 'Error!',
            text  => $self->l('Duplicated username.'),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
}

sub delete ($self) {
    my $client_id  = $self->param('client_id');
    my $login_user = $self->session('user')->{user_id};
    if ( $login_user == $client_id ) {
        my $swal = {
            title => 'Error!',
            text  => $self->l('You cannot delete yourself.'),
            icon  => 'error',
        };
        $self->htmx->res->reswap('none');
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
    if ( !$self->is_admin ) {
        my $swal = {
            title => 'Error!',
            text  => $self->l('You are not authorized to do it.'),
            icon  => 'error',
        };
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        return $self->render( text => '' );
    }
    eval {
        my $rows_affected =
          $self->dbh->do( "DELETE FROM users WHERE id = ?", undef, $client_id );
        print "Rows Affected: $rows_affected\n";
    };

    # Swal.fire({
    #   title: 'Error!',
    #   text: 'Do you want to continue',
    #   icon: 'error',
    #   confirmButtonText: 'Cool'
    # })

    if ($@) {
        my $swal = {
            title => 'Error!',
            text  => 'Should delete the configurations first.',
            icon  => 'error',
        };
        $self->htmx->res->trigger(
            newError => $self->l( $self->encode_json($swal) ) );
        $self->htmx->res->reswap('none');
        return $self->render( text => '' );
    }

    return $self->render( text => '' );
}

1;
