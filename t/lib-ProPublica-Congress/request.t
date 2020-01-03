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

my $fail_propublica = 0;
my $fail_propublica_content = {
    status => 'ERROR',
    errors => [
        { error => "not enough olives on ProPublica's pizza." },
    ],
};
my $success_propublica_content = {
    status  => 'OK',
    results => [
        { json => 'data' },
    ],
};

*HTTP::Tiny::request = sub {
    my $self = shift;
    my ( $method, $uri, $headers ) = @_;

    my $content;

    my $response = {
        success => ( $fail_http ? 0 : 1 ),
        reason  => 'not enough olives on the pizza.',
        content => ( $fail_propublica ? $fail_propublica_content : $success_propublica_content ),
    };

    return $response;
};

my $fail_json = 0;

*JSON::Tiny::decode_json = sub {
    my $data = shift;

    if ( $fail_json ) {
        die 'not enough olives on the pizza.';
    }

    return $data;
};

HAPPY_PATH: {
    note( 'happy path' );

    my $congress_obj = ProPublica::Congress->new( key => 'unitTESTkey' );
    my $data = $congress_obj->request( uri => 'https://fake.url.tld' );

    is_deeply( $data, $success_propublica_content, 'returned contains expected data' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $congress_obj = ProPublica::Congress->new( key => 'unitTESTkey' );

    dies_ok { $congress_obj->request() }
              "dies if uri is missing";
    like $@, qr/The uri argument is required/,
         'exception includes the uri urgument is required';

    dies_ok { $congress_obj->request( uri => '' ) }
              "dies if uri is empty string";
    like $@, qr/The uri argument is required/,
         'exception includes the uri urgument is required';

    $fail_http = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if http request wasn't successful";
    like $@, qr/Request was not successful: not enough olives on the pizza/,
         'exception includes the reason from the http request';

    $fail_http = 0;
    $fail_json = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if json decode wasn't successful";
    like $@, qr/Decode JSON from request was not successful: not enough olives on the pizza/,
         'exception includes the reason from the JSON decode';

    $fail_json = 0;
    $fail_propublica = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if return from ProPublica indicates ERROR";
    like $@, qr/Request was not successful: not enough olives on ProPublica's pizza\./,
         'exception includes the reason from the http request';
}

done_testing();
