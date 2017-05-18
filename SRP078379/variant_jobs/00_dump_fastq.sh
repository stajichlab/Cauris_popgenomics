#!/usr/bin/bash
#SBATCH --time 12:00:00 -p batch --ntasks 2 --mem 1G

module load sratoolkit
ODIR=fastq
LINE=${SLURM_ARRAY_TASK_ID}
if [ ! $LINE ]; then
 LINE=$1
 if [ ! $LINE ]; then
  echo "need an ID"
  exit
 fi
fi

ACCFILE=accessions.txt
acc=$(sed -n ${LINE}p $ACCFILE)
if [ ! -f $ODIR/${acc}_1.fastq.gz ]; then
 fastq-dump -W --origfmt --split-files --gzip -O $ODIR --skip-technical  --readids --read-filter pass --dumpbase $acc 
fi
