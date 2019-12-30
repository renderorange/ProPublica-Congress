use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::Bin/../../lib";

my $class = 'ProPublica::Congress';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $congress_obj = ProPublica::Congress->new( key => 'apikeyGOEShere' );

    isa_ok( $congress_obj, $class );

    ok( exists $congress_obj->{key}, 'object contains key' );

    my @methods = qw(
        request
    );

    can_ok( $class, $_ ) foreach @methods;
}

done_testing();
