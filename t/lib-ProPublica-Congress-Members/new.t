use strict;
use warnings;

use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../../lib";

my $class = 'ProPublica::Congress::Members';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'apikeyGOEShere' );

    isa_ok( $members_obj, $class );

    ok( exists $members_obj->{key}, 'object contains key' );

    # we're also testing here the access to the parent methods.
    my @methods = qw(
        request
        get_members
        get_member_by_id
        get_new_members
        get_current_members_by_state_and_district
        get_members_leaving_office
        get_member_votes
        compare_member_vote_positions 
        compare_member_bill_sponsorships
        get_member_quarterly_office_expenses
        get_member_office_expenses_by_category
        get_quarterly_office_expenses_by_category
        get_privately_funded_trips
        get_member_privately_funded_trips
    );

    can_ok( $class, $_ ) foreach @methods;
}

EXCEPTIONS: {
    note( 'exceptions' );

    dies_ok { ProPublica::Congress::Members->new() }
              'dies if key undefined';
    like $@, qr/The key argument is required/,
         'exception indicates key is required';

    dies_ok { ProPublica::Congress::Members->new( key => '' ) }
              'dies if key is empty string';
}

done_testing();
