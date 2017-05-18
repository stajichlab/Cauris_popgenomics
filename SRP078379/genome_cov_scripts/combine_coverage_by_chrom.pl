#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $bedfile = "Candida_auris.genes.bed";
my $covdir = "coverage";
my $strain_depth = 'depth/strain.depths.tab';
my $odir = 'plot';
my $ext = ".bamcoverage.tsv";
my $skip_strains = 'skip.tab'; # not used now
my $min_depth = 2;
GetOptions('b|bed:s' => \$bedfile,
	   'c|cov|dir:s' => \$covdir,
	   'o|odir:s'    => \$odir,
	   'd|depth:s'   => \$strain_depth,
	   'min|mindepth:s' => \$min_depth,
	   's|skip:s'    => \$skip_strains,
    );
mkdir($odir) unless -d $odir;
mkdir("$odir/tables") unless -d "$odir/tables";
my %depths;
open(my $fh => $strain_depth) || die "$strain_depth: $!";

while(<$fh>) {
    next if /^\#/;
    my ($strain,$asm_len,$total_reads, $avg_coverage) = split;
    #warn("strain=$strain\n");
    if ( $avg_coverage < $min_depth ) {
	warn("skipping $strain, coverage $avg_coverage is too low\n");
        next;
    }
    $depths{$strain} = $avg_coverage;

}

open($fh => $bedfile) || die "cannot open $bedfile: $!";

my %chroms;
while(<$fh>) {
    my ($chrom,$start,$end,$gene) = split;
    push @{$chroms{$chrom}}, [$start,$end, $gene];
}


my %genecov;
my %strains_list;
opendir(DIR, $covdir) || die "cannot open $covdir dir: $!";
for my $file ( readdir(DIR) ) {
    next unless $file =~ /\Q$ext\E$/;
    open(my $fh => "$covdir/$file") || die $!;
    my @strains;
    while(<$fh>) {
	if( /^\#/ ) {
	    (undef,undef,@strains) = split;
	    if( ! @strains ) { 
		last;
	    }
	    for my $m ( @strains ) { 
		$strains_list{$m}++;
	    }
	} else {
	    my ($gene,$len,@covinfo) = split;
	    $genecov{$gene} = { map { $_ => shift @covinfo } @strains };
	}
    }
}

my @strains_final = sort keys %depths;
for my $chrom (sort keys %chroms ) {
    next if( ! @{$chroms{$chrom}} || @{$chroms{$chrom}} < 50 ); 
    my @geneorder = sort { $a->[0] <=> $b->[0] } @{$chroms{$chrom}};
    my (undef,undef,$firstgene) = @{$geneorder[0]};
    next if ! keys %{$genecov{$firstgene}}; # genes with no coverage
    
    open(my $ofh => ">$odir/tables/$chrom.gene_cov.tab") || die $!;
    open(my $normofh => ">$odir/tables/$chrom.gene_cov_norm.tab") || die $!;
    print $ofh join("\t", qw(GENE), @strains_final), "\n";
    print $normofh join("\t", qw(GENE), @strains_final), "\n";
    for my $genear ( @geneorder ) {
	my ($gstart,$gend, $gene) = @$genear;
	for my $str ( @strains_final ) {
	  if( ! exists $genecov{$gene}->{$str} ) {
	    warn("cannot find coverage for $gene in $str (chrom: $chrom)\n");
	  }
        }
	print $ofh join("\t", $gene, map { $genecov{$gene}->{$_} } @strains_final), "\n";
	print $normofh join("\t", $gene, 
			    map { sprintf("%.4f", $genecov{$gene}->{$_}  /
					  $depths{$_}) } @strains_final), "\n";
    }
}
