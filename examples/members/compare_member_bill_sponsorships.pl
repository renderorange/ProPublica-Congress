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
    'member_id_1=s',
    'member_id_2=s',
    'congress=i',
    'chamber=s',
    'help',
);

if ( $opts{help} || !$opts{member_id_1} || !$opts{member_id_2} || !$opts{congress} || !$opts{chamber} ) {
    print "Usage: compare_member_bill_sponsorships.pl --member_id_1 Y000031 --member_id_2 Z000004 --congress 102 --chamber house\n" . 
          "                                           --member_id_1 W000581 --member_id_2 Y000047 --congress 80 --chamber senate\n";
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
my $comparison = $members_obj->compare_member_bill_sponsorships( member_id_1 => $opts{member_id_1}, member_id_2 => $opts{member_id_2}, congress => $opts{congress}, chamber => $opts{chamber} );

print Data::Dumper::Dumper( $comparison );
