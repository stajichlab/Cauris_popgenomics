#!/usr/bin/bash

#SBATCH --nodes 1 --ntasks 1 --time 24:00:00 --mem 8G 

module load samtools
BAMLIST=all.bams.list
SRA=strains.tab

mkdir -p depth

samtools depth -f $BAMLIST | perl genome_cov_scripts/depth_alllib_sum.pl -b $BAMLIST -s $SRA > depth/strain.depths.tab
