package ProPublica::Congress::Members;

use strict;
use warnings;

use parent 'ProPublica::Congress';

use List::MoreUtils ();

our $VERSION = '0.01';

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
        if ( $args->{congress} < 102 ) {
            die 'The congress argument must be >= 102 for the house';
        }
    }
    else {
        if ( $args->{congress} < 80 ) {
            die 'The congress argument must be >= 80 for the senate';
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
        die 'The member_id argument must be a string of alpha numeric characters';
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

    if ( $args->{congress} < 111 ) {
        die 'The congress argument must be >= 111';
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
        die 'The member_id argument must be a string of alpha numeric characters';
    }

    my $uri = 'https://api.propublica.org/congress/v1/members/' . $args->{member_id} . '/votes.json';

    return $self->request( uri => $uri );
}

sub compare_member_vote_positions {
    my $self = shift;
    my $args = {
        member_id_1 => undef,
        member_id_2 => undef,
        congress    => undef,
        chamber     => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    foreach my $key (qw{ member_id_1 member_id_2 }) {
        if ( $args->{$key} !~ m/^[A-Z0-9]+$/ ) {
            die "The $key argument must be a string of alpha numeric characters";
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
        if ( $args->{congress} < 102 ) {
            die 'The congress argument must be >= 102 for the house';
        }
    }
    else {
        if ( $args->{congress} < 101 ) {
            die 'The congress argument must be >= 101 for the senate';
        }
    }

    my $uri =
          'https://api.propublica.org/congress/v1/members/'
        . $args->{member_id_1}
        . '/votes/'
        . $args->{member_id_2} . q{/}
        . $args->{congress} . q{/}
        . $args->{chamber} . '.json';

    return $self->request( uri => $uri );
}

sub compare_member_bill_sponsorships {
    my $self = shift;
    my $args = {
        member_id_1 => undef,
        member_id_2 => undef,
        congress    => undef,
        chamber     => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    foreach my $key (qw{ member_id_1 member_id_2 }) {
        if ( $args->{$key} !~ m/^[A-Z0-9]+$/ ) {
            die "The $key argument must be a string of alpha numeric characters";
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
        if ( $args->{congress} < 102 ) {
            die 'The congress argument must be >= 102 for the house';
        }
    }
    else {
        if ( $args->{congress} < 101 ) {
            die 'The congress argument must be >= 101 for the senate';
        }
    }

    my $uri =
          'https://api.propublica.org/congress/v1/members/'
        . $args->{member_id_1}
        . '/bills/'
        . $args->{member_id_2} . q{/}
        . $args->{congress} . q{/}
        . $args->{chamber} . '.json';

    return $self->request( uri => $uri );
}

sub get_member_cosponsored_bills {
    my $self = shift;
    my $args = {
        member_id => undef,
        type      => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    if ( $args->{member_id} !~ m/^[A-Z0-9]+$/ ) {
        die "The member_id argument must be a string of alpha numeric characters";
    }

    $args->{type} = lc $args->{type};

    unless ( $args->{type} eq 'cosponsored' || $args->{type} eq 'withdrawn' ) {
        die 'The type argument must be either cosponsored or withdrawn';
    }

    my $uri =
        'https://api.propublica.org/congress/v1/members/' . $args->{member_id} . '/bills/' . $args->{type} . '.json';

    return $self->request( uri => $uri );
}

sub get_member_quarterly_office_expenses {
    my $self = shift;
    my $args = {
        member_id => undef,
        year      => undef,
        quarter   => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    if ( $args->{member_id} !~ m/^[A-Z0-9]+$/ ) {
        die "The member_id argument must be a string of alpha numeric characters";
    }

    if ( $args->{year} !~ m/^\d+$/ || $args->{year} < 2009 ) {
        die 'The year argument must be a >= 2009';
    }

    if ( $args->{quarter} !~ m/^[1-4]$/ ) {
        die 'The quarter argument must be 1-4';
    }

    my $uri =
          'https://api.propublica.org/congress/v1/members/'
        . $args->{member_id}
        . '/office_expenses/'
        . $args->{year} . q{/}
        . $args->{quarter} . '.json';

    return $self->request( uri => $uri );
}

sub get_member_office_expenses_by_category {
    my $self = shift;
    my $args = {
        member_id => undef,
        category  => undef,
        @_,
    };

    foreach my $key ( keys %{$args} ) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    if ( $args->{member_id} !~ m/^[A-Z0-9]+$/ ) {
        die "The member_id argument must be a string of alpha numeric characters";
    }

    my @valid_categories = (
        qw{
            travel personnel rent-utilities other-services supplies
            franked-mail printing equipment total
            }
    );

    unless ( List::MoreUtils::any { $args->{category} eq $_ } @valid_categories ) {
        die 'The ' . $args->{category} . ' category argument is unknown';
    }

    my $uri =
          'https://api.propublica.org/congress/v1/members/'
        . $args->{member_id}
        . '/office_expenses/category/'
        . $args->{category} . '.json';

    return $self->request( uri => $uri );
}

sub get_quarterly_office_expenses_by_category {
    my $self = shift;
    my $args = {
        category => undef,
        year     => undef,
        quarter  => undef,
        offset   => undef,
        @_,
    };

    foreach my $key (qw{ category year quarter }) {
        if ( !defined $args->{$key} || $args->{$key} eq q{} ) {
            die "The $key argument is required";
        }
    }

    my @valid_categories = (
        qw{
            travel personnel rent-utilities other-services supplies
            franked-mail printing equipment total
            }
    );

    unless ( List::MoreUtils::any { $args->{category} eq $_ } @valid_categories ) {
        die 'The ' . $args->{category} . ' category argument is unknown';
    }

    if ( $args->{year} !~ m/^\d+$/ || $args->{year} < 2009 ) {
        die 'The year argument must be a >= 2009';
    }

    if ( $args->{quarter} !~ m/^[1-4]$/ ) {
        die 'The quarter argument must be 1-4';
    }

    if ( defined $args->{offset} && ( $args->{offset} eq q{} || $args->{offset} % 20 ) ) {
        die 'The offset argument must be a multiple of 20';
    }

    my $uri =
          'https://api.propublica.org/congress/v1/office_expenses/category/'
        . $args->{category} . q{/}
        . $args->{year} . q{/}
        . $args->{quarter} . '.json';

    if ( defined $args->{offset} ) {
        $uri .= '?offset=' . $args->{offset};
    }

    return $self->request( uri => $uri );
}

sub get_privately_funded_trips {
    my $self = shift;
    my $args = {
        congress => undef,
        @_,
    };

    if ( !defined $args->{congress} || $args->{congress} eq q{} ) {
        die 'The congress argument is required';
    }

    if ( $args->{congress} !~ m/^\d+$/ || $args->{congress} < 1 ) {
        die 'The congress argument must be a positive integer';
    }

    if ( $args->{congress} < 110 ) {
        die 'The congress argument must be >= 110';
    }

    my $uri = 'https://api.propublica.org/congress/v1/' . $args->{congress} . '/private-trips.json';

    return $self->request( uri => $uri );
}

sub get_member_privately_funded_trips {
    my $self = shift;
    my $args = {
        member_id => undef,
        @_,
    };

    if ( !defined $args->{member_id} || $args->{member_id} eq q{} ) {
        die 'The member_id argument is required';
    }

    if ( $args->{member_id} !~ m/^[A-Z0-9]+$/ ) {
        die "The member_id argument must be a string of alpha numeric characters";
    }

    my $uri = 'https://api.propublica.org/congress/v1/members/' . $args->{member_id} . '/private-trips.json';

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

L<https://projects.propublica.org/api-docs/congress-api/members/#lists-of-members>

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

L<https://projects.propublica.org/api-docs/congress-api/members/#get-a-specific-member>

=head3 ARGUMENTS

=over

=item member_id

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_new_members

Retrieve information about new members.

Creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-new-members>

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_current_members_by_state_and_district

Retrieve objects for members by state and district.  Accepted state and district abbreviation is defined in this module as constants at the top.

Creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-current-members-by-statedistrict>

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

L<https://projects.propublica.org/api-docs/congress-api/members/#get-members-leaving-office>

=head3 ARGUMENTS

=over

=item congress

Must be >= 111;

=item chamber

Must be either house or senate.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_member_votes

Retrieve specific member votes information.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-a-specific-members-vote-positions>

=head3 ARGUMENTS

=over

=item member_id

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 compare_member_vote_positions

Retrieve member vote comparison information between 2 members.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#compare-two-members-vote-positions>

=head3 ARGUMENTS

=over

=item member_id_1

=item member_id_2

=item congress

If chamber is house, congress must be >= 102.

If chamber is senate, chamber must be >= 101.

=item chamber

Must be either house or senate.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 compare_member_bill_sponsorships

Retrieve member bill sponsorship comparison information between 2 members.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#compare-two-members-bill-sponsorships>

=head3 ARGUMENTS

=over

=item member_id_1

=item member_id_2

=item congress

If chamber is house, congress must be >= 102.

If chamber is senate, chamber must be >= 101.

=item chamber

Must be either house or senate.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_member_cosponsored_bills

Retrieve the 20 most recent bill cosponsorships for a particular member, either bills cosponsored or bills where cosponsorship was withdrawn.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-bills-cosponsored-by-a-specific-member>

=head3 ARGUMENTS

=over

=item member_id

=item type

Must be either cosponsored or withdrawn.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_member_quarterly_office_expenses

Retrieve the amount a given lawmaker spent during a specified year and quarter.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-quarterly-office-expenses-by-a-specific-house-member>

=head3 ARGUMENTS

=over

=item member_id

=item year

Must be >= 2009.

=item quarter

Must be 1-4.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_member_office_expenses_by_category

Retrieve the amount a given lawmaker spent in a specified category.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-quarterly-office-expenses-by-category-for-a-specific-house-member>

=head3 ARGUMENTS

=over

=item member_id

=item category

Must be one of the following:

=over

=item travel

=item personnel

=item rent-utilities

=item other-services

=item supplies

=item franked-mail

=item printing

=item equipment

=item total

=back

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_quarterly_office_expenses_by_category

Retrieve the amounts lawmakers spent in a specified category by quarter.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-quarterly-office-expenses-for-a-specified-category>

=head3 ARGUMENTS

=over

=item category

Must be one of the following:

=over

=item travel

=item personnel

=item rent-utilities

=item other-services

=item supplies

=item franked-mail

=item printing

=item equipment

=item total

=back

=item year

Must be >= 2009.

=item quarter

Must be 1-4.

=item offset

Must be a multiple of 20.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_privately_funded_trips

Retrieve list of privately funded trips reported by all House members and staff in a particular Congress.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-recent-privately-funded-trips>

=head3 ARGUMENTS

=over

=item congress

Must be >= 110.

=back

=head3 RETURNS

Hashref of decoded JSON from the request to the ProPublica API.

=head2 get_member_privately_funded_trips

Retrieve list of privately funded trips for a given lawmaker.  Member ids can be retrieved from C<get_members> or from L<http://bioguide.congress.gov/biosearch/biosearch.asp>.

Verifies arguments and creates the uri to pass to L<ProPublica::Congress>'s C<request> method.

L<https://projects.propublica.org/api-docs/congress-api/members/#get-recent-privately-funded-trips-by-a-specific-house-member>

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
