#!/bin/bash


wd=$2
chrs=$3


cd $wd


module load bioinfo/Seqtk/1.3
module load bioinfo/bgzip/1.18
module load bioinfo/samtools/1.19


# Input file
input_file=$1

samtools faidx $input_file


output_dir=$PWD

# Process the file
while IFS= read -r line; do
    # Extract chromosome prefix (e.g., chr1 from chr1_h1)
    chromosome=$(echo "$line" | cut -d'_' -f1)
    
    # Append the line to a temporary file for that chromosome
    echo "$line" >> "$output_dir/tmp_${chromosome}.txt"
done < "$input_file.fai"

# Create the final lists with the first 4 lines
for tmp_file in "$output_dir"/tmp_chr*; do
    # Extract chromosome name (e.g., chr1)
    chromosome=$(basename "$tmp_file" | sed 's/tmp_//; s/.txt//')
    
    # Create the output file with the first 4 lines
    head -n 4 "$tmp_file" | cut -f1 > "$output_dir/list_${chromosome}.txt"
    
    # Remove the temporary file
    rm "$tmp_file"
done

echo `ls list*`


for chr in 1 $chrs
do

seqtk subseq $input_file list_chr${chr}.txt | bgzip > only_chr${chr}_allhap.fasta.gz
rm list_chr${chr}.txt

done
