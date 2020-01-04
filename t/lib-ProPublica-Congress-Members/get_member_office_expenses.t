use strict;
use warnings;

use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use ProPublica::Congress;

my $class = 'ProPublica::Congress::Members';
use_ok( $class );

no warnings 'redefine';

*ProPublica::Congress::request = sub {
    my $self = shift;
    my $args = {
        uri => undef,
        @_,
    };

    my $response = { json => 'data' };

    return $response;
};

HAPPY_PATH: {
    note( 'happy path' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );
    my $expenses = $members_obj->get_member_office_expenses(
        member_id => 'ABC123', year => 2009, quarter => 4,
    );

    is_deeply( $expenses, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'member values' );
    dies_ok { $members_obj->get_member_office_expenses( year => 2009, quarter => 4 ) }
              'dies if member_id argument is missing';
    like $@, qr/The member_id argument is required/,
         'exception indicates member_id argument is required';
    dies_ok { $members_obj->get_member_office_expenses( member_id => '', year => 2009, quarter => 4 ) }
              'dies if member_id argument is empty string';
    dies_ok { $members_obj->get_member_office_expenses( member_id => '_ABC123', year => 2009, quarter => 4 ) }
              'dies if member_id argument contains non alpha numeric chars';
    like $@, qr/The member_id argument must be a string of alpha numeric characters/,
         'exception indicates member_id must be a string of alpha numeric characters';

    note( 'year values' );
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', quarter => 4 ) }
              'dies if year argument is missing';
    like $@, qr/The year argument is required/,
         'exception indicates year argument is required';
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', year => 2008, quarter => 4 ) }
              'dies if year argument is < 2009';
    like $@, qr/The year argument must be a >= 2009/,
         'exception indicates year argument must be >= 2009';
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', year => 'a', quarter => 4 ) }
              'dies if year argument is a';

    note( 'quarter values' );
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', year => 2009 ) }
              'dies if quarter argument is missing';
    like $@, qr/The quarter argument is required/,
         'exception indicates quarter argument is required';
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', year => 2009, quarter => 5 ) }
              'dies if quarter argument is 5';
    like $@, qr/The quarter argument must be 1-4/,
         'exception indicates quarter argument must be 1-4';
    dies_ok { $members_obj->get_member_office_expenses( member_id => 'ABC123', year => 2009, quarter => 'a' ) }
              'dies if quarter argument is a';
}

done_testing();
