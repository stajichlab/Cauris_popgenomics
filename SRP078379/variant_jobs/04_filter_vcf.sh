#!/usr/bin/bash
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --mem-per-cpu 16G
#SBATCH --job-name=GATK.select_filter
#SBATCH --output=GATK.select_filter.%a.log


module load gatk/3.7
OUTDIR=vcf
INFILE=vcf/C_auris.genotypes.vcf.gz
INSNP=$OUTDIR/C_auris.genotypes.SNPS.vcf
ININDEL=$OUTDIR/C_auris.genotypes.INDEL.vcf
FILTEREDSNP=$OUTDIR/C_auris.genotypes.filtered.SNPONLY.vcf
FILTEREDINDEL=$OUTDIR/C_auris.genotypes.filtered.INDELONLY.vcf
GENOME=/bigdata/stajichlab/shared/projects/Candida/C_auris/genome/C_auris_6684.fasta
SNPONLY=$OUTDIR/C_auris.genotypes.selected.SNPONLY.vcf
INDELONLY=$OUTDIR/C_auris.genotypes.selected.INDELONLY.vcf

if [ ! -f $INSNP ]; then
java -Xmx3g -jar $GATK \
-T SelectVariants \
-R $GENOME \
--variant $INFILE \
-o $INSNP \
-env \
-ef \
-restrictAllelesTo BIALLELIC \
-selectType SNP
fi

if [ ! -f $ININDEL ]; then
java -Xmx3g -jar $GATK \
-T SelectVariants \
-R $GENOME \
--variant $INFILE \
-o $ININDEL \
-env \
-ef \
-selectType INDEL -selectType MIXED -selectType MNP
fi

if [ ! -f $FILTEREDSNP ]; then
java -Xmx3g -jar $GATK \
-T VariantFiltration -o $FILTEREDSNP \
--variant $INSNP -R $GENOME \
--clusterWindowSize 10  -filter "QD<2.0" -filterName QualByDepth \
-filter "MQ<40.0" -filterName MapQual \
-filter "QUAL<100" -filterName QScore \
 -filter "MQRankSum < -12.5" -filterName MapQualityRankSum \
-filter "SOR > 4.0" -filterName StrandOddsRatio \
-filter "FS>60.0" -filterName FisherStrandBias \
-filter "ReadPosRankSum<-8.0" -filterName ReadPosRank \
--missingValuesInExpressionsShouldEvaluateAsFailing 

#-filter "HaplotypeScore > 13.0" -filterName HaplotypeScore
#-filter "MQ0>=10 && ((MQ0 / (1.0 * DP)) > 0.1)" -filterName MapQualRatio \
fi

if [ ! -f $FILTEREDINDEL ]; then
java -Xmx3g -jar $GATK \
-T VariantFiltration -o $FILTEREDINDEL \
--variant $ININDEL -R $GENOME \
--clusterWindowSize 10  -filter "QD<2.0" -filterName QualByDepth \
 -filter "MQRankSum < -12.5" -filterName MapQualityRankSum \
-filter "SOR > 4.0" -filterName StrandOddsRatio \
-filter "FS>200.0" -filterName FisherStrandBias \
-file "InbreedingCoeff<-0.8" -filterName InbreedCoef \
-filter "ReadPosRankSum<-20.0" -filterName ReadPosRank 
fi

if [ ! -f $SNPONLY ]; then
java -Xmx16g -jar $GATK \
   -R $GENOME \
   -T SelectVariants \
   --variant $FILTEREDSNP \
   -o $SNPONLY \
   -env \
   -ef \
   --excludeFiltered
fi

if [ ! -f $INDELONLY ]; then
java -Xmx16g -jar $GATK \
   -R $GENOME \
   -T SelectVariants \
   --variant $FILTEREDINDEL \
   -o $INDELONLY \
   --excludeFiltered 
fi

