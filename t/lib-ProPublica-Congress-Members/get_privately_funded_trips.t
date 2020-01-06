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
    my $trips = $members_obj->get_privately_funded_trips( congress => 110 );

    is_deeply( $trips, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'congress values' );
    dies_ok { $members_obj->get_privately_funded_trips() }
              "dies if congress argument is missing";
    like $@, qr/The congress argument is required/,
         'exception indicates congress argument is required';
    dies_ok { $members_obj->get_privately_funded_trips( congress => '' ) }
              "dies if congress argument is empty string";
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_privately_funded_trips( congress => $value ) }
                  "dies if congress argument is $value";
        like $@, qr/The congress argument must be a positive integer/,
             'exception indicates congress argument must be positive int';
    }
    dies_ok { $members_obj->get_privately_funded_trips( congress => 109 ) }
              "dies if congress argument is < 110";
    like $@, qr/The congress argument must be >= 110/,
         'exception indicates congress argument must be >= 110';
}

done_testing();
