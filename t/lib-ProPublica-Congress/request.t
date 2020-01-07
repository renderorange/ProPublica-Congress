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
my $fail_propublica_nest_error = 0;

*HTTP::Tiny::request = sub {
    my $self = shift;
    my ( $method, $uri, $headers ) = @_;

    my $response;

    if ( $fail_http ) {
        if ( $fail_propublica ) {
            # status OK from propublica, but status ERROR in the content.
            # this is a really strange pattern for errors, but we have to work with it.
            $response = {
                status  => 'OK',
                success => 1,
                content => {
                    status => 'ERROR',
                }
            };

            if ( $fail_propublica_nest_error ) {
                $response->{content}->{errors} = [
                    { error => "not enough nested olives on ProPublica's pizza." },
                ];
            }
            else {
                $response->{content}->{error} = "not enough olives on ProPublica's pizza.";
            }
        }
        else {
            # the first error code check in request sub
            $response = {
                status  => 500,
                success => '',
                reason  => "not enough olives on the pizza.",
            };
        }
    }
    else {
        $response = {
            success => 1,
            content => {
                status  => 'OK',
                results => [
                    { json => 'data' },
                ],
            }
        };
    }

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

    is_deeply( $data,
               { status  => 'OK',
                 results => [
                     { json => 'data' },
                 ],
               }, 'returned contains expected data' );
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

    $fail_propublica = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if return from ProPublica indicates ERROR";
    like $@, qr/Request was not successful: not enough olives on ProPublica's pizza/,
         'exception includes the reason from the http request';

    $fail_propublica_nest_error = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if return from ProPublica indicates ERROR";
    like $@, qr/Request was not successful: not enough nested olives on ProPublica's pizza/,
         'exception includes the reason from the http request, with nested error';

    $fail_http = 0;
    $fail_propublica = 0;
    $fail_propublica_nest_error = 0;
    $fail_json = 1;

    dies_ok { $congress_obj->request( uri => 'https://fake.url.tld' ) }
              "dies if json decode wasn't successful";
    like $@, qr/Decode JSON from request was not successful: not enough olives on the pizza/,
         'exception includes the reason from the JSON decode';
}

done_testing();
