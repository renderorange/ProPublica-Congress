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
    'category=s',
    'year=i',
    'quarter=i',
    'help',
);

if ( $opts{help} || !$opts{category} || !$opts{year} || !$opts{quarter} ) {
    print "Usage: get_quarterly_office_expenses_by_category.pl --category total --year 2019 --quarter 3\n";
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
my $expenses = $members_obj->get_quarterly_office_expenses_by_category( category => $opts{category}, year => $opts{year}, quarter => $opts{quarter} );

print Data::Dumper::Dumper( $expenses );
