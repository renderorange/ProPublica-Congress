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
    my $expenses = $members_obj->get_quarterly_office_expenses_by_category(
        category => 'total', year => 2009, quarter => 4, offset => 20,
    );

    is_deeply( $expenses, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $members_obj = ProPublica::Congress::Members->new( key => 'unitTESTkey' );

    note( 'category values' );
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( year => 2008, quarter => 4 ) }
              'dies if category argument is missing';
    like $@, qr/The category argument is required/,
         'exception indicates category argument is required';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => '', year => 2008, quarter => 4 ) }
              'dies if category argument is empty string';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'a', year => 2008, quarter => 4 ) }
              'dies if category argument is a';
    like $@, qr/The a category argument is unknown/,
         'exception indicates category argument is unknown';

    note( 'year values' );
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', quarter => 4 ) }
              'dies if year argument is missing';
    like $@, qr/The year argument is required/,
         'exception indicates year argument is required';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2008, quarter => 4 ) }
              'dies if year argument is < 2009';
    like $@, qr/The year argument must be a >= 2009/,
         'exception indicates year argument must be >= 2009';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 'a', quarter => 4 ) }
              'dies if year argument is a';

    note( 'quarter values' );
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009 ) }
              'dies if quarter argument is missing';
    like $@, qr/The quarter argument is required/,
         'exception indicates quarter argument is required';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009, quarter => 5 ) }
              'dies if quarter argument is 5';
    like $@, qr/The quarter argument must be 1-4/,
         'exception indicates quarter argument must be 1-4';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009, quarter => 'a' ) }
              'dies if quarter argument is a';

    note( 'offset values' );
    lives_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009, quarter => 4 ) }
              'lives if offset argument is missing';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009, quarter => 4, offset => '' ) }
              'dies if offset argument is empty string';
    dies_ok { $members_obj->get_quarterly_office_expenses_by_category( category => 'total', year => 2009, quarter => 4, offset => '21' ) }
              'dies if offset argument is not multiple of 20';
    like $@, qr/The offset argument must be a multiple of 20/,
         'exception indicates offset must be a multiple of 20';
}

done_testing();
