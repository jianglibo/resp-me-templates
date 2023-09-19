package TrojanWeb::Helper::DbStatements;

use strict;
use warnings;
use Exporter qw(import);
use DBI;

our @EXPORT = qw($insert_user $select_user
  update_one_field select_users select_user_by_namepass
  select_user_by_name select_role select_configs
  create_config select_config
  select_downloads select_download create_download
  select_config_by_password
  delete_config);

our $insert_user =
  "INSERT INTO users (username, password, quota) VALUES (?, ?, ?)";
our $select_user = "SELECT * FROM users WHERE id = ?";

sub update_one_field {
    my ( $dbh, $cid, $fname, $fvalue ) = @_;

    # Prepare and execute the update statement
    my $update_sql = "UPDATE users SET $fname = ? WHERE id = ?";
    my $update_sth = $dbh->prepare($update_sql);
    $update_sth->execute( $fvalue, $cid );

    # Check if the update was successful
    if ( $update_sth->rows > 0 ) {
        print "$fname updated successfully.\n";
    }
    else {
        print "User not found or no changes made.\n";
    }
}

sub select_users {
    my ( $dbh, $page, $search ) = @_;
    my $offset = $page * 10;
    $search = "" unless $search;
    $dbh->selectall_arrayref(
"SELECT * FROM users WHERE username LIKE ? ORDER BY id DESC LIMIT 10 OFFSET $offset",
        { Slice => {} },
        "%$search%"
    );
}

sub select_user_by_namepass {
    my ( $dbh, $username, $password ) = @_;
    $dbh->selectrow_hashref(
        "SELECT * FROM users WHERE username = ? AND password = ?",
        undef, ( $username, $password ) );
}

sub select_user_by_name {
    my ( $dbh, $username ) = @_;
    $dbh->selectrow_hashref( "SELECT * FROM users WHERE username = ?",
        undef, $username );
}

sub select_role {
    my ( $dbh, $rid ) = @_;
    $dbh->selectrow_hashref( "SELECT * FROM roles WHERE id = ?", undef, $rid );

}

sub select_configs {
    my ( $dbh, $user_id, $page ) = @_;
    my $offset = $page * 10;
    $dbh->selectall_arrayref(
"SELECT * FROM configs WHERE owner_id = ? ORDER BY id DESC LIMIT 10 OFFSET $offset",
        { Slice => {} },
        $user_id
    );
}

sub select_config {
    my ( $dbh, $user_id, $config_id ) = @_;
    $dbh->selectrow_hashref(
        "SELECT * FROM configs WHERE owner_id = ? AND id = ?",
        undef, ( $user_id, $config_id ) );
}

sub select_config_by_password {
    my ( $dbh, $password ) = @_;
    $dbh->selectrow_hashref( "SELECT * FROM configs WHERE password = ?",
        undef, $password );
}

sub create_config {
    my ( $dbh, $user_id, $name, $password, $config ) = @_;
    my $insert_sql =
"INSERT INTO configs (owner_id, name, password, config) VALUES (?, ?, ?, ?)";
    my $insert_sth = $dbh->prepare($insert_sql);
    $insert_sth->execute( $user_id, $name, $password, $config );

    # return the new created record.
    $dbh->selectrow_hashref(
        "SELECT * FROM configs WHERE owner_id = ? ORDER BY id DESC LIMIT 1",
        undef, $user_id );
}

sub select_downloads {
    my ( $dbh, $page ) = @_;
    my $offset = $page * 10;
    $dbh->selectall_arrayref(
        "SELECT * FROM downloads ORDER BY id DESC LIMIT 10 OFFSET $offset",
        { Slice => {} } );
}

sub select_download {
    my ( $dbh, $download_id ) = @_;
    $dbh->selectrow_hashref( "SELECT * FROM downloads WHERE id = ?",
        undef, ($download_id) );
}

sub create_download {
    my ( $dbh, $name, $url, $pathname ) = @_;
    my $insert_sql =
      "INSERT INTO downloads (name, url, pathname) VALUES (?, ?, ?)";
    my $insert_sth = $dbh->prepare($insert_sql);
    $insert_sth->execute( $name, $url, $pathname );
    my $last_insert_id = $dbh->last_insert_id();

    # return the new created record.
    $dbh->selectrow_hashref( "SELECT * FROM downloads WHERE id = ?",
        undef, $last_insert_id );
}

sub delete_config {
    my ($dbh, $id) = @_;
    my $delete_sql = "DELETE FROM configs WHERE id = ?";
    $dbh->do( "DELETE FROM configs WHERE id = ?", undef, $id );
}

1;
