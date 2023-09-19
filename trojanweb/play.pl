#!/usr/bin/env perl -l

use strict;
use feature 'state';

use Try::Tiny;

my $V = '5';

sub Ss {
    state $V = $V;
    my $x = 6;
}

print Ss();

use DBI;
my $dbh = DBI->connect(
    "DBI:mysql:database=oneapi;host=192.168.3.30",
    "root",
    "my-secret-pw",
    {
        RaiseError      => 1,
        AutoCommit        => 1,
        mysql_enable_utf8 => 1,
        PrintError        => 1
    }
);
my $rows = $dbh->selectall_arrayref( "SELECT * FROM users ORDER BY username",
    { Slice => {} } );

foreach my $emp (@$rows) {
    print "Employee: $emp->{username}\n";
}

# print $rows;

print "llllllllllllllllllllllllllllllllll";

my $sth = $dbh->prepare("SELECT * FROM users");

$sth->execute;

while ( my @row = $sth->fetchrow_array ) {
    print "@row\n";
}

use Data::Page;

my $page = Data::Page->new();
$page->total_entries(95);
$page->entries_per_page(10);
$page->current_page(3);

print "         First page: ", $page->first_page, "\n";
print "          Last page: ", $page->last_page,  "\n";
print "First entry on page: ", $page->first,      "\n";
print " Last entry on page: ", $page->last,       "\n";

try {

    my $rows_affected =
      $dbh->do( "INSERT INTO users (username, password) VALUES (?, ?)",
        undef, "my_username", "my_password" );
    print $rows_affected, " row(s) affected\n";

}
catch {
    warn "caught error: $_";
};

print "afeter try";
my $rows_affected =
  $dbh->do("UPDATE users SET password = 'ccc' WHERE username = 'my_username'");
print $rows_affected, " row(s) affected\n";

print "$rows_affected row(s) affected\n, ${rows_affected}";
print qq($rows_affected row(s) affected\n, ${rows_affected});