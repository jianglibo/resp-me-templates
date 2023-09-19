package TrojanWeb::Helper::TableRow;

use Mojo::Base -strict;

# https://docs.mojolicious.org/Mojolicious/Plugin/TagHelpers

sub table_row {
    my ( $c, $data ) = @_;
    my $deli = <<string_ending_delimiter;
	on click
		if .editing is not empty
		Swal.fire({title: 'Already Editing',
					showCancelButton: true,
					confirmButtonText: 'Yep, Edit This Row!',
					text:'Hey!  You are already editing a row!  Do you want to cancel that edit and continue?'})
		if the result's isConfirmed is false
			halt
		end
		send cancel to .editing
		end
		trigger edit
string_ending_delimiter

    return $c->tag(
        'tr',
        sub {
            $c->tag( 'td', $data->{field1} );
            $c->tag( 'td', $data->{field2} );
            $c->tag( 'td', $data->{field2} );
            $c->tag( 'td', $data->{field2} );
            $c->tag( 'td', $data->{field1} );
            # $c->tag(
            #     'td',
            #     sub {
            #         $c->tag(
            #             'button',
            #             'class'    => 'btn btn-primary',
            #             'hx-get' => '/contact/1',
            #             'Delete'
            #         );
            #         $c->tag(
            #             'button',
            #             'class'      => "btn btn-danger",
            #             'hx-get'     => "/clients/5/edit",
            #             'hx-trigger' => "edit",
            #             '_'          => "$deli",
            #             'Edit'
            #         );
            #     }
            # );
        }
    );
}

1;
