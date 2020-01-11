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
    'congress=i',
    'offset=i',
    'help',
);

if ( $opts{help} || !$opts{congress} ) {
    print "Usage: get_privately_funded_trips.pl --congress 110 --offset 20\n";
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
    congress => $opts{congress},
);

if ( defined $opts{offset} ) {
    $options{offset} = $opts{offset};
}

my $trips = $members_obj->get_privately_funded_trips( %options );

print Data::Dumper::Dumper( $trips );
