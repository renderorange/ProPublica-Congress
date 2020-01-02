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

my @no_district_states = (
    ProPublica::Congress::Members::AT_LARGE_DISTRICTS(),
    ProPublica::Congress::Members::FEDERAL_DISTRICTS(),
    ProPublica::Congress::Members::TERRITORIES_AND_COMMONWEALTHS(),
);

HAPPY_PATH: {
    note( 'happy path' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );
    my $members = $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        state    => 'TX',
        district => 7,
    );

    is_deeply( $members, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'chamber values' );
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_current_members_by_state_and_district(
            chamber  => $value,
            state    => 'TX',
            district => 7,
        ) } "dies if chamber argument is $value";
        like $@, qr/The chamber argument must be either house or senate/,
             'exception indicates chamber argument must be house or senate';
    }
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        state    => 'TX',
        district => 7,
    ) } 'dies if chamber argument is missing';
    like $@, qr/The chamber argument is required/,
         'exception indicates chamber argument is required';
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => '',
        state    => 'TX',
        district => 7,
    ) } 'dies if chamber argument is empty string';

    note( 'state values' );
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        district => 7,
    ) } 'dies if state argument is missing';
    like $@, qr/The state argument is required/,
         'exception indicates state argument is required';
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        state    => '',
        district => 7,
    ) } 'dies if state argument is empty string';
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        state    => 'ZZ',
        district => 7,
    ) } 'dies if state argument is unknown';
    like $@, qr/The ZZ state argument is an unknown state abbreviation/,
         'exception indicates state argument is an unknown state abbreviation';

    note( 'district values' );
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        state    => 'TX',
    ) } 'dies if district argument is missing';
    like $@, qr/The district argument is required for the house/,
         'exception indicates district argument is required for the house';
    dies_ok { $members_obj->get_current_members_by_state_and_district(
        chamber  => 'house',
        state    => 'TX',
        district => '',
    ) } 'dies if district argument is empty string';
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_current_members_by_state_and_district(
            chamber  => 'house',
            state    => 'TX',
            district => $value,
        ) } "dies if district argument is $value";
        like $@, qr/The district argument must be a positive integer/,
             'exception indicates district argument must be a positive integer';
    }
    foreach my $state ( @no_district_states ) {
        dies_ok { $members_obj->get_current_members_by_state_and_district(
            chamber  => 'house',
            state    => $state,
            district => 2,
        ) } "dies if district argument != 1 if state is $state";
        like $@, qr/The district argument must be 1 for $state/,
             "exception indicates district argument must be 1 for $state";
    }
}

done_testing();
