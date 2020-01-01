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
    my $member = $members_obj->get_member_by_id( member_id => 'ABC123' );

    is_deeply( $member, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    dies_ok { $members_obj->get_member_by_id() }
              'dies if member_id argument is missing';
    like $@, qr/The member_id argument is required/,
         'exception indicates member_id argument is required';
    dies_ok { $members_obj->get_member_by_id( member_id => '' ) }
              'dies if member_id argument is empty string';
    dies_ok { $members_obj->get_member_by_id( member_id => '_ABC123' ) }
              'dies if member_id argument contains non alpha numeric chars';
    like $@, qr/The member_id argument must be a string of alpha numberic characters/,
         'exception indicates member_id must be a string of alpha numberic characters';
}

done_testing();
