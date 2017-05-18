for file in plot/*.gene_cov_norm.tab
do
	b=$(basename $file .tab)
	perl genome_cov_scripts/prep_for_ggplot.pl $file > plot/$b.gg.csv
done
