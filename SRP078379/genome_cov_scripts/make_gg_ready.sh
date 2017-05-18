for file in plot/tables/*.gene_cov_norm.tab
do
	b=$(basename $file .tab)
	perl genome_cov_scripts/prep_for_ggplot.pl $file > plot/tables/$b.gg.csv
done
