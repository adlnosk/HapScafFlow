#!/bin/bash
#SBATCH --mem=20G


motif=$1
fa=$2
wd=$3


module load devel/Miniconda/Miniconda3 bioinfo/tidk/0.2.63

cd $wd

tidk build
tidk search --string $motif --output search --dir . $fa

~
