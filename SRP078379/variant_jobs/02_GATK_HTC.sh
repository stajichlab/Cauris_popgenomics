#!/usr/bin/bash
#SBATCH --mem 32G --ntasks 16 --nodes 1 --time 18:00:00 -J C_aur.HTC.GATK --output HTC.GATK.Caur.%A_%a.log
module load gatk
module load picard

MEM=32g
GENOMEIDX=/bigdata/stajichlab/shared/projects/Candida/C_auris/genome/C_auris_6684.fasta
BAMDIR=aln
OUTDIR=Variants
mkdir -p $OUTDIR
SAMPLEFILE=strains.csv
b=`basename $GENOMEIDX .fasta`
dir=`dirname $GENOMEIDX`
if [ ! -f $dir/$b.dict ]; then
 java -jar $PICARD CreateSequenceDictionary R=$GENOMEIDX O=$dir/$b.dict SPECIES="Candida auris" TRUNCATE_NAMES_AT_WHITESPACE=true
fi

CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then 
 CPU=1
fi

LINE=${SLURM_ARRAY_TASK_ID}

if [ ! $LINE ]; then
 LINE=$1
 if [ ! $LINE ]; then
  echo "Need a number via slurm --array or cmdline"
  exit
 fi
fi

IFS=,
sed -n ${LINE}p $SAMPLEFILE | while read STRAIN FWD REV
do
 SAMPLE=$(basename $FWD _1.fastq.gz | perl -p -e 's/_pass//')
echo "$SAMPLE"

N=$BAMDIR/$SAMPLE.realign.bam

if [ ! -f $OUTDIR/$SAMPLE.g.vcf ]; then
 java -Xmx${MEM} -jar $GATK \
  -T HaplotypeCaller \
  -ERC GVCF \
  -ploidy 1 \
  -I $N -R $GENOMEIDX \
  -o $OUTDIR/$SAMPLE.g.vcf -nct $CPU
fi

done
