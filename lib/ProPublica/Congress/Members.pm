package ProPublica::Congress::Members;

use strict;
use warnings;

use parent 'ProPublica::Congress';

our $VERSION = '0.01';

use constant {
    HOUSE_MINIMUM  => 102,
    SENATE_MINIMUM => 80,
};

sub members {
    my $self = shift;
    my $args = {
        congress => undef,
        chamber  => undef,
        @_,
    };

    foreach my $key ( keys %$args ) {
        unless ( defined $args->{$key} ) {
            die "The $key argument is required";
        }
    }

    unless ( $args->{chamber} eq 'house' || $args->{chamber} eq 'senate' ) {
        die 'The chamber argument must be either house or senate';
    }

    unless ( $args->{congress} =~ m/\d+/ ) {
        die 'The congress argument must be a positive integer';
    }

    if ( $args->{chamber} eq 'house' ) {
        unless ( $args->{congress} >= 102 ) {
            die 'The congress argument must be >= 102 for the house';
        }
    }
    else {
        unless ( $args->{congress} >= 80 ) {
            die 'The congress argument must be >= 80 for the senate';
        }
    }

    my $uri = 'https://api.propublica.org/congress/v1/' . $args->{congress} . '/' . $args->{chamber} . '/members.json';

    return $self->request( uri => $uri );
}

1;

__END__

=pod

=head1 NAME

ProPublica::Congress::Members - request congress member information from ProPublica

=head1 SYNOPSIS

 use ProPublica::Congress::Members;

 my $members_obj = ProPublica::Congress::Members->new( key => 'apikeyGOEShere' );
 my $members = $members_obj->members( congress => '116', chamber => 'house' );

=head1 DESCRIPTION

This module is used to request congress member information from ProPublica's Congress API.  It inherits the C<new> and C<request> methods from L<ProPublica::Congress>.

=head1 SUBROUTINES/METHODS

=head2 members

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

=head3 ARGUMENTS

=over

=item congress

If chamber is house, congress must be >= 102.

If chamber is senate, chamber must be >= 80.

=item chamber

Must be either house or senate.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head1 DEPENDENCIES

=over

=item constant

=back

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut
