use strict;
use warnings;

use Test::More;
use English qw( -no_match_vars );
use FindBin;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval { require Test::PerlTidy; };

if ( $EVAL_ERROR ) {
   my $msg = 'Test::PerlTidy required for test';
   plan( skip_all => $msg );
}

Test::PerlTidy::run_tests(
    path       => "$FindBin::Bin/../lib",
    perltidyrc => "$FindBin::Bin/perltidyrc",
);
