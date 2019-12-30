use strict;
use warnings;

use Test::More;

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
        members
    );

    can_ok( $class, $_ ) foreach @methods;
}

done_testing();
