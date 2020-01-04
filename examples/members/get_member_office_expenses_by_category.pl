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
    'category=s',
    'help',
);

if ( $opts{help} || !$opts{member_id} || !$opts{category} ) {
    print "Usage: get_member_office_expenses_by_category.pl --member_id K000388 --category total\n";
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
my $expenses = $members_obj->get_member_office_expenses_by_category( member_id => $opts{member_id}, category => $opts{category} );

print Data::Dumper::Dumper( $expenses );
