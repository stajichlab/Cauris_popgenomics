GENOMEGFF=../genome/GCF_001189475.1_ASM118947v1_genomic.gff
grep -P "\tgene\t" $GENOMEGFF | awk -F"\t" 'BEGIN{OFS="\t"}{print $1,$4,$5,$9}' | perl -p -e 's/ID=\S+;.+locus_tag=([^;]+);?.*/$1/' > Candida_auris.genes.bed
