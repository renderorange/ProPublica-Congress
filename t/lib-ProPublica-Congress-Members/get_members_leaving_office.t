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
    my $members = $members_obj->get_members_leaving_office( chamber => 'house', congress => 1 );

    is_deeply( $members, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'chamber values' );
    dies_ok { $members_obj->get_members_leaving_office( chamber => 'a', congress => 1 ) }
              "dies if chamber argument is a";
    like $@, qr/The chamber argument must be either house or senate/,
         'exception indicates chamber argument must be house or senate';
    dies_ok { $members_obj->get_members_leaving_office( congress => 1 ) }
              'dies if chamber argument is missing';
    like $@, qr/The chamber argument is required/,
         'exception indicates chamber argument is required';
    dies_ok { $members_obj->get_members_leaving_office( chamber => '', congress => 1 ) }
              'dies if chamber argument is empty string';

    note( 'congress values' );
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->get_members_leaving_office( chamber => 'house', congress => $value ) }
                  "dies if congress argument is $value";
        like $@, qr/The congress argument must be a positive integer/,
             'exception indicates congress argument must be positive int';
    }
}

done_testing();
