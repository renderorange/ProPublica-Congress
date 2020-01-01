package ProPublica::Congress::Members;

use strict;
use warnings;

use parent 'ProPublica::Congress';

our $VERSION = '0.01';

use constant {
    HOUSE_MINIMUM  => 102,
    SENATE_MINIMUM => 80,
};

sub get_members {
    my $self = shift;
    my $args = {
        congress => undef,
        chamber  => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    $args->{chamber} = lc $args->{chamber};

    unless ( $args->{chamber} eq 'house' || $args->{chamber} eq 'senate' ) {
        die 'The chamber argument must be either house or senate';
    }

    if ( $args->{congress} !~ m/^\d+$/ || $args->{congress} < 1 ) {
        die 'The congress argument must be a positive integer';
    }

    if ( $args->{chamber} eq 'house' ) {
        if ( $args->{congress} < HOUSE_MINIMUM ) {
            die 'The congress argument must be >= ' . HOUSE_MINIMUM . ' for the house';
        }
    }
    else {
        if ( $args->{congress} < SENATE_MINIMUM ) {
            die 'The congress argument must be >= ' . SENATE_MINIMUM . ' for the senate';
        }
    }

    my $uri = 'https://api.propublica.org/congress/v1/' . $args->{congress} . q{/} . $args->{chamber} . '/members.json';

    return $self->request( uri => $uri );
}

sub get_member_by_id {
    my $self = shift;
    my $args = {
        member_id => undef,
        @_,
    };

    if ( !defined $args->{member_id} || $args->{member_id} eq q{} ) {
        die 'The member_id argument is required';
    }

    if ( $args->{member_id} !~ m/^[A-Z0-9]+$/ ) {
        die 'The member_id argument must be a string of alpha numberic characters';
    }

    my $uri = 'https://api.propublica.org/congress/v1/members/' . $args->{member_id} . '.json';

    return $self->request( uri => $uri );
}

sub get_new_members {
    my $self = shift;

    my $uri = 'https://api.propublica.org/congress/v1/members/new.json';

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

=head1 DESCRIPTION

This module is used to request congress member information from ProPublica's Congress API.  It inherits the C<new> and C<request> methods from L<ProPublica::Congress>.

=head1 SUBROUTINES/METHODS

=head2 get_members

Retrieve objects for all members of congress the specified congress and chamber.

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

=head2 get_member_by_id

Retrieve specific member information.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

=head3 ARGUMENTS

=over

=item member_id

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_new_members

Retrieve information about new members.

Creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head1 DEPENDENCIES

=over

=item constant

=back

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut
