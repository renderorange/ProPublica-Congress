package ProPublica::Congress;

use strict;
use warnings;

use HTTP::Tiny;
use JSON::MaybeXS;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $args  = {
        key => undef,
        @_,
    };

    unless ( defined $args->{key} ) {
        die 'The key argument is required';
    }

    return bless $args, $class;
}

sub request {
    my $self = shift;
    my $args = {
        uri => undef,
        @_,
    };

    my $http     = HTTP::Tiny->new();
    my $response = $http->request( 'GET', $args->{uri}, { headers => { 'X-API-Key' => $self->{key} } }, );

    unless ( $response->{success} ) {
        die 'Request was not successful: ' . $response->{reason};
    }

    return JSON::MaybeXS::decode_json( $response->{content} );
}

1;

__END__

=pod

=head1 NAME

ProPublica::Congress - base class for the ProPublica::Congress API SDK

=head1 SYNOPSIS

 use ProPublica::Congress;

 my $congress = ProPublica::Congress->new( key => 'apikeyGOEShere' );

=head1 DESCRIPTION

This module is the base class for the L<ProPublica::Congress> namespace providing a constructor and utility methods for the child modules.

=head1 SUBROUTINES/METHODS

=head2 new

Constructor for the L<ProPublica::Congress> object.

=head3 ARGUMENTS

=over

=item key

The key for the ProPublica Congress API.

Keys can be requested from L<https://www.propublica.org/datastore/api/propublica-congress-api>.

=back

=head3 RETURNS

A L<ProPublica::Congress> object.

=head2 request

Method to make an http request to the ProPublica Congress API.

=head3 ARGUMENTS

=over

=item uri

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head1 DEPENDENCIES

=over

=item HTTP::Tiny

=item JSON::MaybeXS

=back

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut
