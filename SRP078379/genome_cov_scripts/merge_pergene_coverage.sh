cat coverage/* | sort | uniq > C_auris.bamcoverage.tsv
rm -f coverage/*
mv C_auris.bamcoverage.tsv coverage
