use strict;
use warnings;

use Test::More;
use Test::Exception;

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

EXCEPTIONS: {
    note( 'exceptions' );

    dies_ok { ProPublica::Congress->new() }
              'dies if key undefined';
    like $@, qr/The key argument is required/,
         'exception indicates key is required';

    dies_ok { ProPublica::Congress->new( key => '' ) }
              'dies if key is empty string';
}

done_testing();
