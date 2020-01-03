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
    'chamber=s',
    'state=s',
    'district=i',
    'help',
);

if ( $opts{help} || !$opts{chamber} || !$opts{state} ) {
    print "Usage: \n" .
          "get_current_members_by_state_and_district.pl --chamber house --state TX --district 7\n" .
          "                                             --chamber senate --state TX\n";
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
my $members = $members_obj->get_current_members_by_state_and_district(
    chamber  => $opts{chamber},
    state    => $opts{state},
    district => $opts{district},
);

print Data::Dumper::Dumper( $members );
