#!/bin/sh
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G

module load devel/Miniconda/Miniconda3
module load bioinfo/BUSCO/5.4.7

hap=$1
genome=$2
out_dir=$3
lineage=$4

cd $out_dir
busco -i $genome -m geno -f -l ${lineage}_odb10 -c 10 -o $out_dir


