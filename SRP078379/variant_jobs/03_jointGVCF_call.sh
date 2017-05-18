#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --mem 64G
#SBATCH --job-name=GATK.GVCFGeno
#SBATCH --output=GATK.GVCFGeno.%A.log

#
MEM=96g
module load picard
module unload java
module load gatk/3.7
module load java/8
module load tabix

GENOME=/bigdata/stajichlab/shared/projects/Candida/C_auris/genome/C_auris_6684.fasta

INDIR=Variants
OUT=vcf/C_auris.genotypes.vcf
CPU=1
if [ ${SLURM_CPUS_ON_NODE} ]; then
 CPU=${SLURM_CPUS_ON_NODE}
fi

for file in $INDIR/*.g.vcf
do
 bgzip $file
 tabix -f $file.gz
done

N=`ls $INDIR/*.g.vcf.gz | sort | perl -p -e 's/\n/ /; s/(\S+)/-V $1/'`

 java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOME \
    $N \
    --max_alternate_alleles 3 \
    -o $OUT
