use strict;
use warnings;

use Test::More;
use English qw( -no_match_vars );
use File::Spec;
use FindBin;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}
 
eval { require Test::Perl::Critic; };
 
if ( $EVAL_ERROR ) {
   my $msg = 'Test::Perl::Critic required for test';
   plan( skip_all => $msg );
}
 
my $rcfile = File::Spec->catfile( 't', 'config/perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile );

all_critic_ok( "$FindBin::Bin/../lib" );
