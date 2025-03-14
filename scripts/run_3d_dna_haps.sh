#!/bin/bash
#SBATCH -J 3D-DNA
#SBATCH --mem=50G

n=$1
mapq=$2
genome=$3
links=$4
outdir=$5

cd $outdir

module load  bioinfo/LASTZ/1.04.22 devel/python/Python-3.6.3
module load bioinfo/3D-DNA/529ccf4
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
run-asm-pipeline.sh -q ${mapq} -r 0 $genome $links
