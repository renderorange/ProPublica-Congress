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
    'chamber=s',
    'help',
);

if ( $opts{help} || !$opts{congress} || !$opts{chamber} ) {
    print "Usage: get_members.pl --congress 102 --chamber house\n";
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
my $members = $members_obj->get_members( congress => $opts{congress}, chamber => $opts{chamber} );

print Data::Dumper::Dumper( $members );
