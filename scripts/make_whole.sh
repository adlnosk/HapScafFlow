#!/bin/bash
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G


wd=$1

cd $wd


module load bioinfo/bgzip/1.18
module load bioinfo/samtools/1.19


for f in `ls hap*FINAL.fasta`
do
	n=`echo $f | awk -F '[_.]' '{print $2}'`
	samtools faidx $f
	awk -v n="$n" 'NR <= 8 {print $1, "chr" NR "_h" n} NR > 8 {print $1, $1 "_hap" n}' $f.fai > list_$f.txt
	awk 'FNR==NR { a[">"$1] = $2 ; next} $1 in a { sub($1,">" a[$1]) }1' list_$f.txt $f > renamed_$f 
	bgzip -@ 8 -f -l 9 -k renamed_$f
	
	cat renamed_$f >> whole_genome.fasta

done

bgzip -@ 10 whole_genome.fasta

module load bioinfo/assemblathon2/d1f044b; assemblathon_stats.pl whole_genome.fasta.gz > whole_genome.fasta.gz.assemblathon_stats


