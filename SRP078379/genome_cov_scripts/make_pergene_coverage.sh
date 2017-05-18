#!/usr/bin/bash

#SBATCH --nodes 1 --ntasks 1 --time 2:00:00 -p short

module load samtools
BEDFILE=Candida_auris.genes.bed
BAMLIST=all.bams.list
SRA=strains.tab
mkdir -p coverage
RANGE=1000
N=${SLURM_ARRAY_TASK_ID}
if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then
   echo "need an N to start, will use 1"
   N=1
 fi
fi

MAX=$(wc -l $BEDFILE | awk '{print $1}')
START=$(python -c "print $N*$RANGE")
if [ $START -eq 0 ]; then
 START=1
fi
END=$(python -c "print ($N*$RANGE) + $RANGE - 1")
echo "START=$START END=$END"
for n in $(seq $START 1 $END);
do
 if [ $n -gt $MAX ]; then
   echo "reached end $MAX lines"
   exit
 fi
 sed -n ${n}p $BEDFILE | while read CHR START END NAME;
 do
    echo "$CHR $START $END name=$NAME"
    # one coverage file per gene, each file has N 
    if [ ! -f coverage/$NAME.bamcoverage.tsv ]; then
   #   echo "will run on $NAME.bamcoverage.tsv"
     samtools depth -r $CHR:$START-$END -f $BAMLIST | perl genome_cov_scripts/depth2perlib_sum.pl -g $NAME -b $BAMLIST -s $SRA > coverage/$NAME.bamcoverage.tsv
    fi
 done
done
