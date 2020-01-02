package ProPublica::Congress::Members;

use strict;
use warnings;

use parent 'ProPublica::Congress';

use List::MoreUtils ();

our $VERSION = '0.01';

use constant {
    HOUSE_MINIMUM  => 102,
    SENATE_MINIMUM => 80,
};

use constant STATES => qw{
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE
    NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
};

use constant AT_LARGE_DISTRICTS => qw{
    AK DE MT ND SD VT WY
};

use constant FEDERAL_DISTRICTS => qw{
    DC
};

use constant TERRITORIES_AND_COMMONWEALTHS => qw{
    AS GU MP VI PR
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

sub get_current_members_by_state_and_district {
    my $self = shift;
    my $args = {
        chamber  => undef,
        state    => undef,
        district => undef,
        @_,
    };

    foreach my $key (qw{ chamber state }) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    $args->{chamber} = lc $args->{chamber};
    $args->{state}   = uc $args->{state};

    unless ( $args->{chamber} eq 'house' || $args->{chamber} eq 'senate' ) {
        die 'The chamber argument must be either house or senate';
    }

    my @valid_states = ( STATES, AT_LARGE_DISTRICTS, FEDERAL_DISTRICTS, TERRITORIES_AND_COMMONWEALTHS );

    unless ( List::MoreUtils::any { $args->{state} eq $_ } @valid_states ) {
        die 'The ' . $args->{state} . ' state argument is an unknown state abbreviation';
    }

    if ( $args->{chamber} eq 'house' ) {
        if ( !defined $args->{district} || $args->{district} eq q{} ) {
            die 'The district argument is required for the house';
        }

        if ( $args->{district} !~ m/^\d+$/ || $args->{district} < 1 ) {
            die 'The district argument must be a positive integer';
        }

        # for states without districts, the ProPublica API takes a value of 1.
        my @no_district_states = ( AT_LARGE_DISTRICTS, FEDERAL_DISTRICTS, TERRITORIES_AND_COMMONWEALTHS );

        if ( List::MoreUtils::any { $args->{state} eq $_ } @no_district_states ) {
            if ( $args->{district} != 1 ) {
                die 'The district argument must be 1 for ' . $args->{state};
            }
        }
    }

    my $uri =
          'https://api.propublica.org/congress/v1/members/'
        . $args->{chamber} . q{/}
        . $args->{state} . q{/}
        . ( $args->{chamber} eq 'house' ? $args->{district} . q{/} : q{} )
        . 'current.json';

    return $self->request( uri => $uri );
}

sub get_members_leaving_office {
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

    my $uri =
          'https://api.propublica.org/congress/v1/'
        . $args->{congress} . q{/}
        . $args->{chamber}
        . '/members/leaving.json';

    return $self->request( uri => $uri );
}

sub get_member_votes {
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

    my $uri = 'https://api.propublica.org/congress/v1/members/' . $args->{member_id} . '/votes.json';

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

=head2 get_current_members_by_state_and_district

Retrieve objects for members by state and district.  Accepted state and district abbreviation is defined in this module as constants at the top.

Creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

=head3 ARGUMENTS

=over

=item chamber

Must be either house or senate.

=item state

Accepted state argument can be any defined within the STATES, AT_LARGE_DISTRICTS, FEDERAL_DISTRICTS, and TERRITORIES_AND_COMMONWEALTHS constants within this module.

Federal districts, territories, and commonwealths do not have senate members, but do have house members.  This module does not restrict querying the ProPublica API for senate members in places that do not have senate members.

=item district

States with at-large districts (AK, DE, MT, ND, SD, VT, WY), territories (GU, AS, VI, MP), commonwealths (PR), and the District of Columbia don't have district numbers for the house.  For those cases, district must be set to 1.

If chamber is senate, the district argument will be ignored.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_members_leaving_office

Retrieve information for members leaving congress.

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

=head2 get_member_votes

Retrieve specific member votes information.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

=head3 ARGUMENTS

=over

=item member_id

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head1 DEPENDENCIES

=over

=item constant

=item List::MoreUtils

=back

=head1 AUTHOR

Blaine Motsinger <blaine@renderorange.com>

=cut
