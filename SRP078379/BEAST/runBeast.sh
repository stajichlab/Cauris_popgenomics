#!/bin/sh
#SBATCH -J ClusBEAST.trim
#SBATCH --time=5-00:00:00       # The walltime
#SBATCH --mem=100gb            # Total Memory
#SBATCH --qos=gpu
#SBATCH --gres=gpu:2
#SBATCH -o beast_trim_gpu.log # The output file
#SBATCH -e gpu.err # The error file
#SBATCH -p gpu

module load beagle-lib/2.1.2_gpu
module load beast/2.4.5
module load java/8u45

#beast -threads 64 -beagle_instances 16 -verbose -seed 1486682045044 4beast184.xml
beast -threads 2 -beagle_GPU -beagle_order 1,2 -seed 1486682045044 -prefix  Cauris.simple C_auris.simple.xml 
