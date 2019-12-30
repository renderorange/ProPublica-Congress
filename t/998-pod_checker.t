use strict;
use warnings;

use Test::More;
use English qw( -no_match_vars );
use FindBin;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval { require Test::Pod; };

if ( $EVAL_ERROR ) {
   my $msg = 'Test::Pod required for test';
   plan( skip_all => $msg );
}

Test::Pod::all_pod_files_ok(
    Test::Pod::all_pod_files( "$FindBin::Bin/../lib" )
);
