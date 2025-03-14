#!/bin/bash

motif=$1
input=$2
nhaps=$3
wd=$4


cd $wd

head -n 1 $input > search_telomeric_repeat_windows_haps.tsv

for n in $nhaps
do 
	cat $input | grep \_h${n} >> search_telomeric_repeat_windows_haps.tsv
done

module load devel/Miniconda/Miniconda3 bioinfo/tidk/0.2.63
tidk plot -o "plot_haps" --height 70 --width 500 --strokewidth 3 --tsv search_telomeric_repeat_windows_haps.tsv

