#!/usr/bin/bash
#SBATCH --time 1:00:00

module load bedtools
mkdir -p gene_variant_analysis
bedtools intersect -a Candida_auris.genes.bed -b vcf/C_auris.genotypes.selected.SNPONLY.vcf.gz -wo | gzip -c > gene_variant_analysis/gene_overlap_SNPs.tab.gz
zcat  gene_variant_analysis/gene_overlap_SNPs.tab.gz | awk '{print $4}' | uniq -c | sort -nr > gene_variant_analysis/gene_count_SNPs.txt
