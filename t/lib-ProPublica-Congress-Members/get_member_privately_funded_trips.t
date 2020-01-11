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
    my $trips = $members_obj->get_member_privately_funded_trips( member_id => 'ABC123', offset => 20 );

    is_deeply( $trips, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'member values' );
    dies_ok { $members_obj->get_member_privately_funded_trips() }
              'dies if member_id argument is missing';
    like $@, qr/The member_id argument is required/,
         'exception indicates member_id argument is required';
    dies_ok { $members_obj->get_member_privately_funded_trips( member_id => '' ) }
              'dies if member_id argument is empty string';
    dies_ok { $members_obj->get_member_privately_funded_trips( member_id => '_ABC123' ) }
              'dies if member_id argument contains non alpha numeric chars';
    like $@, qr/The member_id argument must be a string of alpha numeric characters/,
         'exception indicates member_id must be a string of alpha numeric characters';

    note( 'offset values' );
    lives_ok { $members_obj->get_member_privately_funded_trips( member_id => 'ABC123' ) }
              'lives if offset argument is missing';
    dies_ok { $members_obj->get_member_privately_funded_trips( member_id => 'ABC123', offset => '' ) }
              'dies if offset argument is empty string';
    dies_ok { $members_obj->get_member_privately_funded_trips( member_id => 'ABC123', offset => '21' ) }
              'dies if offset argument is not multiple of 20';
    like $@, qr/The offset argument must be a multiple of 20/,
         'exception indicates offset must be a multiple of 20';
}

done_testing();
