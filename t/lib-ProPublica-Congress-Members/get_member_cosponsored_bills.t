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
    my $cosponsored_bills = $members_obj->get_member_cosponsored_bills(
        member_id => 'ABC123', type => 'cosponsored'
    );

    is_deeply( $cosponsored_bills, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'member values' );
    dies_ok { $members_obj->get_member_cosponsored_bills( type => 'cosponsored' ) }
              'dies if member_id argument is missing';
    like $@, qr/The member_id argument is required/,
         'exception indicates member_id argument is required';
    dies_ok { $members_obj->get_member_cosponsored_bills( member_id => '', type => 'cosponsored' ) }
              'dies if member_id argument is empty string';
    dies_ok { $members_obj->get_member_cosponsored_bills( member_id => '_ABC123', type => 'cosponsored' ) }
              'dies if member_id argument contains non alpha numeric chars';
    like $@, qr/The member_id argument must be a string of alpha numeric characters/,
         'exception indicates member_id must be a string of alpha numeric characters';

    note( 'type values' );
    dies_ok { $members_obj->get_member_cosponsored_bills( member_id => 'ABC123' ) }
              'dies if type argument is missing';
    like $@, qr/The type argument is required/,
         'exception indicates type argument is required';
    dies_ok { $members_obj->get_member_cosponsored_bills( member_id => 'ABC123', type => '' ) } 
              'dies if type argument is empty string';
    dies_ok { $members_obj->get_member_cosponsored_bills( member_id => 'ABC123', type => 'a' ) } 
              'dies if type argument is a';
    like $@, qr/The type argument must be either cosponsored or withdrawn/,
         'exception indicates type argument must be either cosponsored or withdrawn';
}

done_testing();
