#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long  ();
use File::HomeDir ();
use Config::Tiny  ();
use Data::Dumper  ();
use FindBin       ();
use lib "$FindBin::Bin/../../lib";
use ProPublica::Congress::Members;

Getopt::Long::GetOptions(
    \my %opts,
    'member_id=s',
    'offset=i',
    'help',
);

if ( $opts{help} || !$opts{member_id} ) {
    print "Usage: get_member_privately_funded_trips.pl --member_id K000388 --offset 20\n";
    exit;
}

my $home = File::HomeDir->my_home;
my $rc   = "$home/.propublicarc";

unless ( -f $rc ) {
    die "$rc is not present";
}

my $config = Config::Tiny->read($rc);

unless ( exists $config->{congress}->{key} && defined $config->{congress}->{key} ) {
    die "key is missing from $rc";
}

my $members_obj = ProPublica::Congress::Members->new( key => $config->{congress}->{key} );

my %options = (
    member_id => $opts{member_id},
);

if ( defined $opts{offset} ) {
    $options{offset} = $opts{offset};
}

my $trips = $members_obj->get_member_privately_funded_trips( %options );

print Data::Dumper::Dumper( $trips );
