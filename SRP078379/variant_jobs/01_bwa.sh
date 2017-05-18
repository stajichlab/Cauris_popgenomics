#!/usr/bin/bash
#SBATCH --nodes 1 --ntasks 4 --mem 32G --time 2:00:00 -p short -J bwa.Caur --output bwa_aln.Cauris.%A_%a.log

module load bwa
module load samtools
module load picard
module load gatk
MEM=32G
CPU=$SLURM_CPUS_ON_NODE
if [ ! $CPU ]; then
 CPU=2
fi

STRAINS=strains.csv
IN=fastq
OUT=aln
mkdir -p $OUT
LINE=${SLURM_ARRAY_TASK_ID}
GENOME=/bigdata/stajichlab/shared/projects/Candida/C_auris/genome/C_auris_6684.fasta
b=`basename $GENOME .fasta`
dir=`dirname $GENOME`
if [ ! -f $dir/$b.dict ]; then
 java -jar $PICARD CreateSequenceDictionary R=$GENOME O=$dir/$b.dict SPECIES="Candida aurius" TRUNCATE_NAMES_AT_WHITESPACE=true
fi

if [ ! $LINE ]; then
 LINE=$1
 if [ ! $LINE ]; then
  echo "Need an ID on cmdline or --array"
  exit
 fi
fi

IFS=,
sed -n ${LINE}p $STRAINS | while read STRAIN FWD REV
do
  BASE=$(basename $FWD _1.fastq.gz | perl -p -e 's/_pass//')
  echo "$STRAIN $FWD $REV  --> $BASE"
  if [ ! -f $OUT/$BASE.realign.bam ]; then
    if [ ! -f $OUT/$BASE.sam ]; then
     bwa mem -t $CPU $GENOME $IN/$FWD $IN/$REV > $OUT/$BASE.sam
    fi
 # after this fix read groups and sort 
   if [ ! -f $OUT/$BASE.RG.bam ]; then
    java -jar $PICARD AddOrReplaceReadGroups I=$OUT/$BASE.sam O=$OUT/$BASE.RG.bam RGLB=$BASE RGID=$STRAIN RGSM=$STRAIN RGPL=Illumina RGPU=$BASE RGCN=Broad SO=coordinate TMP_DIR=/scratch
    if [ ! -z $OUT/$BASE.RG.bam ]; then
      rm $OUT/$BASE.sam
      touch $OUT/$BASE.sam
    else 
      echo "Error running AddReplaceGroups"
      exit
    fi
   fi

   if  [ ! -f $OUT/$BASE.DD.bam ]; then
    java -Xmx$MEM -jar $PICARD MarkDuplicates I=$OUT/$BASE.RG.bam O=$OUT/$BASE.DD.bam METRICS_FILE=$OUT/$BASE.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT
    if [ ! -z $OUT/$BASE.DD.bam ]; then
     rm $OUT/$BASE.RG.bam
     touch $OUT/$BASE.RG.bam
    else 
     echo "Error running MarkDuplicates"
     exit
    fi
   fi

   if [ ! -f $OUT/$BASE.intervals ]; then
    java -Xmx$MEM -jar $GATK \
      -T RealignerTargetCreator \
      -R $GENOME \
      -I $OUT/$BASE.DD.bam \
      -o $OUT/$BASE.intervals
   fi

    java -Xmx$MEM -jar $GATK \
      -T IndelRealigner \
      -R $GENOME \
      -I $OUT/$BASE.DD.bam \
      -targetIntervals $OUT/$BASE.intervals \
      -o $OUT/$BASE.realign.bam

    if [ ! -z $OUT/$BASE.realign.bam ]; then
     rm $OUT/$BASE.DD.bam
     touch $OUT/$BASE.DD.bam
    else 
     echo "Did not see successful $OUT/$BASE.realign.bam"
     exit
    fi

  fi # test for $BASE.realign.bam
done
