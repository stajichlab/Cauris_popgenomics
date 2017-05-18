#!/usr/bin/bash
#SBATCH --mem 8G --ntasks 1 --time 2:00:00 -p short
module load vcftools
module load trimal
if [ ! -f vcf/C_auris.genotypes.selected.SNPONLY.tab ]; then
 vcf-to-tab < vcf/C_auris.genotypes.selected.SNPONLY.vcf > vcf/C_auris.genotypes.selected.SNPONLY.tab
fi
perl ~/src/genome-scripts/popgen/vcftab_to_fasta.pl --refstrain C_auris_6684 -o vcf/C_auris.genotypes.selected.SNPONLY.fas vcf/C_auris.genotypes.selected.SNPONLY.tab
trimal -in vcf/C_auris.genotypes.selected.SNPONLY.fas -out vcf/C_auris.genotypes.selected.SNPONLY.nex -nexus
