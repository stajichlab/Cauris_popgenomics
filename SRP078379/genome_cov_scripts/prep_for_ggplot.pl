#!/usr/bin/perl
use strict;
use warnings;
my $runinfo = "run_info.txt";
open(my $fh => $runinfo) || die $!;
my $hdr = <$fh>;
chomp($hdr);
my @cols = split(/\t/,$hdr);
my $i = 0;
my %col2n = map { $_ => $i++ } @cols;
if ( ! $col2n{Sample_Name_s} || ! $col2n{geo_loc_name_s} ) {
	die("expect at least cols to be Sample_Name_s and geo_loc_name_s\n");
}
my %strain2group;
while(<$fh>) {
	chomp;
	my @row = split(/\t/,$_);
	my $strain = $row[$col2n{Sample_Name_s}];
	my $loc    = $row[$col2n{geo_loc_name_s}];
	$strain2group{$strain} = $loc;
}
my $header = <>;
my ($gn,@header) = split(/\s+/,$header);

print join("\t",qw(GENE COVERAGE STRAIN GROUP)), "\n";

while(<>) {
    my ($gene,@row) = split;
    my $i = 0;
    for my $c ( @row ) {
	my $strain = $header[$i++];
	my $group = $strain2group{$strain};
	print join("\t", $gene, $c, $strain, $group),"\n";
    }
}
