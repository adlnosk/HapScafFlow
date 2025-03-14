#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=500M


# workflow to produce BUSCO scores and scaffold genomes with -q0 and -q1 for 4 haplotypes
# after manual curation and producing review files, Snakemake can be resumed to create a whole_genome.fasta file (incl. assemblathon and bgzipping)

# mandatory INPUTS: hap_{n}.fasta, hap_{n}.fasta.length, aligned HiC reads with Juicer

export ALIGNED_MERGED_NODUPS="/work/project/briefwp3/Adela/Medicago_sativa/scaffolding/hifiasm_0.24.0/Juicer/all.corrected_renamed_hifiv24/aligned/merged_nodups.txt"

# By default the input files should be stored above the /snake directory ($PWD/..). 
# If not, change next line. The output is stored next to the input files.
export PATH_TO_FASTA="$PWD/.."

# Define number of chromosomes
export NUM_CHRS=8

# Automatise number of haplotypes
export NUM_HAP=$(ls $PATH_TO_FASTA/hap_*.fasta 2>/dev/null | grep -oP '(?<=/hap_)\d+' | sort -nr | head -n1)

# Set BUSCO lineage
export LINEAGE="fabales"

module purge
module load bioinfo/Snakemake/7.20.0


if ls $PATH_TO_FASTA/q*_3D_DNA_HAP*/hap_*.fasta.fold.0.review.assembly &> /dev/null; then
	echo 'Review file found, re-running all rules.'
	export REVIEW="YES"
else
	echo 'Review file not found, running until scaffolding.'
	export REVIEW="NO"
fi


snakemake -s Snakefile --profile . --rerun-incomplete --keep-going
