package TrojanWeb::Model::Users;

use strict;
use warnings;
use experimental qw(signatures);
use Data::Dumper;
# use Mojo::Base 'MojoX::Model';
use Crypt::Digest::SHA224 qw( sha224_hex);
use TrojanWeb::Helper::DbStatements qw($insert_user $select_user update_one_field select_users select_user_by_name select_role);

use Mojo::Util qw(secure_compare);

# my $USERS = {joe => '123', marcus => 'lulz', sebastian => 'secr3t'};

sub new ($class) { bless {}, $class }

sub check ($self,$dbh, $user, $pass) {
  print Dumper($self);
  my $client = select_user_by_name $dbh, $user;

  return undef unless $client;

  if (secure_compare $client->{password}, sha224_hex($pass)) {
    print Dumper($client);
    my $role = select_role $dbh, $client->{role_id};
    print Dumper("Role: $role");
    my $role_name = defined($role) ? $role->{name} : 'guest';
    return { user => $user, role => $role_name, user_id => $client->{id}};
  }

  # Fail
  return undef;
}

1;
