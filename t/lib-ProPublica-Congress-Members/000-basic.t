use strict;
use warnings;

use Test::More;

use FindBin ();
use lib "$FindBin::Bin/../../lib";

my $class = 'ProPublica::Congress::Members';
use_ok( $class );

my @required_modules = qw{
    ProPublica::Congress
    constant
};

foreach ( @required_modules ) {
    use_ok($_);
};

done_testing();
