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

my $house_min  = ProPublica::Congress::Members::HOUSE_MINIMUM();
my $senate_min = ProPublica::Congress::Members::SENATE_MINIMUM();

HAPPY_PATH: {
    note( 'happy path' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );
    my $members = $members_obj->get_members_leaving_office( chamber => 'house', congress => $house_min );

    is_deeply( $members, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'chamber values' );
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_members_leaving_office( chamber => $value, congress => 1 ) }
                  "dies if chamber argument is $value";
        like $@, qr/The chamber argument must be either house or senate/,
             'exception indicates chamber argument must be house or senate';
    }
    dies_ok { $members_obj->get_members_leaving_office( congress => $house_min ) }
              'dies if chamber argument is missing';
    like $@, qr/The chamber argument is required/,
         'exception indicates chamber argument is required';
    dies_ok { $members_obj->get_members_leaving_office( chamber => '', congress => $house_min ) }
              'dies if chamber argument is empty string';

    note( 'house chamber and corresponding congress values' );
    dies_ok { $members_obj->get_members_leaving_office( chamber => 'house', congress => $house_min - 1 ) }
              "dies if chamber is house and congress is < $house_min";

    note( 'senate chamber and corresponding congress values' );
    dies_ok { $members_obj->get_members_leaving_office( chamber => 'senate', congress => $senate_min - 1 ) }
              "dies if chamber is senate and congress is < $senate_min";

    note( 'congress values' );
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_members_leaving_office( chamber => 'house', congress => $value ) }
                  "dies if congress argument is $value";
        like $@, qr/The congress argument must be a positive integer/,
             'exception indicates congress argument must be positive int';
    }
}

done_testing();
