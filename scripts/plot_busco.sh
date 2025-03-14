#!/bin/sh
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=50M

module load devel/Miniconda/Miniconda3
module load bioinfo/BUSCO/5.4.7

outdir=$1
gp_script=$2

cd $outdir

python3 $gp_script -wd .

sbatch --wrap="R --save < busco_figure.R"


