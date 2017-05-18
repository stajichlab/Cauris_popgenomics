#!/usr/bin/bash
#SBATCH --time 2:00:00 --mem 64G -p short
MEM=64G
module load snpEff

zcat vcf/C_auris.genotypes.selected.SNPONLY.vcf.gz | java -Xmx$MEM -jar $SNPEFFJAR ann -c snpEff.config Candida_auris_gca_001189475 > gene_variant_analysis/snpEff_annot.gff3
