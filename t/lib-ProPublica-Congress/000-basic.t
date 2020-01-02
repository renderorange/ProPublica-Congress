use strict;
use warnings;

use Test::More;

use FindBin ();
use lib "$FindBin::Bin/../../lib";

my $class = 'ProPublica::Congress';
use_ok( $class );

my @required_modules = qw{
    Try::Tiny
    HTTP::Tiny
    JSON::Tiny
};

foreach ( @required_modules ) {
    use_ok($_);
};

done_testing();
