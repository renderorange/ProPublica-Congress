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
    my $comparison = $members_obj->compare_member_vote_positions( member_id_1 => 'ABC123', member_id_2 => 'ABC124', congress => 102, chamber => 'house' );

    is_deeply( $comparison, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'member values' );
    foreach my $arg ( qw{ member_id_1 member_id_2 } ) {
        my %args = (
            member_id_1 => 'ABC123',
            member_id_2 => 'ABC124',
            congress => 102,
            chamber  => 'house',
        );

        my $stored = delete $args{$arg};
    
        dies_ok { $members_obj->compare_member_vote_positions(
            %args 
        ) } "dies if $arg argument is missing";
        like $@, qr/The $arg argument is required/,
             "exception indicates the $arg argument is required";
        
        $args{$arg} = '';
             
        dies_ok { $members_obj->compare_member_vote_positions(
            %args
        ) } "dies if $arg argument is empty string";
        
        $args{$arg} = '_' . $stored;
    
        dies_ok { $members_obj->compare_member_vote_positions(
            %args
        ) } "dies if $arg argument contains non alpha numeric chars";
        like $@, qr/The $arg argument must be a string of alpha numeric characters/,
             "exception indicates $arg must be a string of alpha numeric characters";
    }

    note( 'congress values' );
    foreach my $value ( qw{ a 0 -1 } ) {
        dies_ok { $members_obj->compare_member_vote_positions(
            member_id_1 => 'ABC123',
            member_id_2 => 'ABC124',
            congress => $value,
            chamber  => 'house',
        ) } "dies if congress argument is $value";
        like $@, qr/The congress argument must be a positive integer/,
             'exception indicates congress argument must be positive int';
    }
    dies_ok { $members_obj->compare_member_vote_positions(
        member_id_1 => 'ABC123',
        member_id_2 => 'ABC124',
        congress => 101,
        chamber  => 'house',
    ) } "dies if congress argument is < 102 for the house";
    like $@, qr/The congress argument must be >= 102 for the house/,
         'exception indicates congress argument must be >= 102 for the house';
    dies_ok { $members_obj->compare_member_vote_positions(
        member_id_1 => 'ABC123',
        member_id_2 => 'ABC124',
        congress => 100,
        chamber  => 'senate',
    ) } "dies if congress argument is < 101 for the senate";
    like $@, qr/The congress argument must be >= 101 for the senate/,
         'exception indicates congress argument must be >= 101 for the senate';

    note( 'chamber values' );
    dies_ok { $members_obj->compare_member_vote_positions(
        member_id_1 => 'ABC123',
        member_id_2 => 'ABC124',
        congress => 102,
        chamber  => 'a',
    ) } "dies if chamber argument is a";
    like $@, qr/The chamber argument must be either house or senate/,
        'exception indicates chamber argument must be house or senate';
    dies_ok { $members_obj->compare_member_vote_positions(
        member_id_1 => 'ABC123',
        member_id_2 => 'ABC124',
        congress => 102,
    ) } 'dies if chamber argument is missing';
    like $@, qr/The chamber argument is required/,
         'exception indicates chamber argument is required';
    dies_ok { $members_obj->compare_member_vote_positions(
        member_id_1 => 'ABC123',
        member_id_2 => 'ABC124',
        congress => 102,
        chamber  => '',
    ) } 'dies if chamber argument is empty string';
}

done_testing();
