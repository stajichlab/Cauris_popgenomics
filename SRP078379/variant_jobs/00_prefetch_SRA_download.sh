#!/usr/bin/bash
#SBATCH --time 12:00:00 -p batch --ntasks 2 --mem 1G

module load sratoolkit
module load aspera

ASCP=$(which ascp)
for acc in $(cat accessions.txt)
do
prefetch -a "$ASCP|$ASPERAKEY"  --ascp-options "-Q -l 200000 -m 100 -k 2" $acc 
done
