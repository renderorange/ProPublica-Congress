use strict;
use warnings;

use Test::More;
use Test::Exception;
use HTTP::Tiny;
use JSON::Tiny;

use FindBin;
use lib "$FindBin::Bin/../../lib";

my $class = 'ProPublica::Congress';
use_ok( $class );

no warnings 'redefine';

my $fail_http = 0;

*HTTP::Tiny::request = sub {
    my $self = shift;
    my ( $method, $uri, $headers ) = @_;

    my $response = {
        success => ( $fail_http ? 0 : 1 ),
        reason  => 'not enough olives on the pizza.',
        content => { json => 'data' },
    };

    return $response;
};

*JSON::Tiny::decode_json = sub {
    return shift;
};

HAPPY_PATH: {
    note( 'happy path' );

    my $congress_obj = ProPublica::Congress->new( key => 'unitTESTkey' );
    my $data = $congress_obj->request( uri => 'https://fake.url.tld' );

    is_deeply( $data, { json => 'data' }, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    $fail_http = 1;

    my $congress_obj = ProPublica::Congress->new( key => 'unitTESTkey' );

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if http request wasn't successful";
    like $@, qr/not enough olives on the pizza/,
         'exception includes the reason from the http request';
}

done_testing();
