#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=500M

# Script to parametrise and submit snakemake HapScafFlow
# from https://github.com/adlnosk/HapScafFlow


# !!! FOR DRY-RUN, ADD `-n` FLAG IN THE LAST LINE !!!

##### Input files #####

# mandatory INPUTS: hap_{n}.fasta, hap_{n}.fasta.length, aligned HiC reads with Juicer
export ALIGNED_MERGED_NODUPS="/work/project/briefwp3/Adela/Medicago_sativa/scaffolding/hifiasm_0.24.0/Juicer/all.corrected_renamed_hifiv24/aligned/merged_nodups.txt" # Set correct merged_nodups.txt input path.
export PATH_TO_FASTA="$PWD/.." # Change if input files are stored else than in above directory.

###### Species-specific parameters ######

export NUM_CHRS=8 # Define number of chromosomes
export NUM_HAP=$(ls $PATH_TO_FASTA/hap_*.fasta 2>/dev/null | grep -oP '(?<=/hap_)\d+' | sort -nr | head -n1) # Automatise number of haplotypes
export LINEAGE="fabales" # Set BUSCO lineage
export MOTIF="AAACCCTAAACCCT" # Set telomeric repeats motif

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
