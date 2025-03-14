import os

PATH = os.getenv("PATH_TO_FASTA")
nchr = int(os.getenv("NUM_CHRS", 0))
CHROMOSOMES = list(range(1, nchr+1))
nhap = int(os.getenv("NUM_HAP", 0))
HAPS = list(range(1, nhap+1))

MERGEDNODUPS = os.getenv("ALIGNED_MERGED_NODUPS")


print(f"Path = {PATH} | Chromosomes = {CHROMOSOMES} | Haps = {HAPS}")


rule all:
    input:
        expand(PATH + "/q1_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.hic", n=HAPS),
        expand(PATH + "/q1_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.assembly", n=HAPS),
        expand(PATH + "/q0_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.hic", n=HAPS),
        expand(PATH + "/q0_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.assembly", n=HAPS),
        PATH + "/BUSCO/busco_summaries/busco_figure.png",
        PATH + "/FINALS/whole_genome.fasta.gz",
        PATH + "/FINALS/chrs/only_chrall_allhap.fasta.gz"

rule links:
    input:
        merged_nodups=MERGEDNODUPS,
        contigs=PATH + "/hap_{n}.fasta.length"
    output:
        PATH + "/links/merged_nodups_hap_{n}.txt"
    shell:
        """
        awk 'NR==FNR {{ids[$1]; next}} ($2 in ids) && ($6 in ids)' {input.contigs} {input.merged_nodups}  > {output}
        """

rule fold:
    input:
        genome=PATH + "/hap_{n}.fasta"
    output:
        PATH + "/hap_{n}.fasta.fold"
    shell:
        "fold -w 80 {input.genome} > {output}"

rule q1:
    input:
        genome=rules.fold.output,
        links=rules.links.output
    output:
        PATH + "/q1_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.hic",
        PATH + "/q1_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.assembly"
    params:
        mapq=1
    resources: 
        mem_mb=50000
    shell:
        "scripts/run_3d_dna_haps.sh {wildcards.n} {params.mapq} {input.genome} {input.links} {PATH}/q{params.mapq}_3D_DNA_HAP{wildcards.n}"

rule q0:
    input:
        genome=rules.fold.output,
        links=rules.links.output
    output:
        PATH + "/q0_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.hic",
        PATH + "/q0_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.assembly"
    params:
        mapq=0
    resources: 
        mem_mb=50000
    shell:
        "scripts/run_3d_dna_haps.sh {wildcards.n} {params.mapq} {input.genome} {input.links} {PATH}/q{params.mapq}_3D_DNA_HAP{wildcards.n}"

rule busco:
    input:
        genome=PATH + "/hap_{n}.fasta"
    output:
        PATH + "/BUSCO/hap{n}/short_summary.specific.fabales_odb10.hap{n}.txt"
    threads: 10
    resources: 
        mem_mb=20000
    shell:
        "scripts/BUSCO.sh {wildcards.n} {input.genome} {PATH}/BUSCO/hap{wildcards.n}"

rule copy:
    input:
        rules.busco.output
    output:
        PATH + "/BUSCO/busco_summaries/short_summary.specific.fabales_odb10.hap{n}.txt"
    shell:
        "cp {input} {PATH}/BUSCO/busco_summaries/"

rule plot_busco:
    input:
        expand(rules.copy.output, n=HAPS)
    output:
        PATH + "/BUSCO/busco_summaries/busco_figure.png"
    shell:
        "scripts/plot_busco.sh {PATH}/BUSCO/busco_summaries/ {PATH}/snake/scripts/generate_plot.py"

rule final_review:
    input:
        genome=rules.fold.output,
        links=rules.links.output,
        review=PATH + "/q0_3D_DNA_HAP{n}/hap_{n}.fasta.fold.0.review.assembly"
    output:
        PATH + "/q0_3D_DNA_HAP{n}/FINAL/hap_{n}.fasta.fold.FINAL.fasta"
    params:
        mapq=0
    resources:
        mem_mb=50000
    shell:
        "scripts/final.sh {wildcards.n} {params.mapq} {input.genome} {input.links} {input.review} {PATH}/q{params.mapq}_3D_DNA_HAP{wildcards.n}/FINAL"

rule copy_finals:
    input:
        rules.final_review.output
    output:
        PATH + "/FINALS/hap_{n}.fasta.fold.FINAL.fasta"
    shell:
        "cp {input} {PATH}/FINALS/"

rule whole_genome:
    input:
        expand(rules.copy_finals.output, n=HAPS)
    output:
        PATH + "/FINALS/whole_genome.fasta.gz"
    resources:
        mem_mb=20000
    threads: 10
    shell:
        "scripts/make_whole.sh {PATH}/FINALS"

rule get_chrs:
    input:
        rules.whole_genome.output
    output:
        expand(PATH + "/FINALS/chrs/only_chr{chrs}_allhap.fasta.gz", chrs=CHROMOSOMES)
    resources:
        mem_mb=20000
    threads: 10
    shell:
        "scripts/get_chrs.sh {input} {PATH}/FINALS/chrs {CHROMOSOMES}"

rule cat_chrs:
    input:
        expand(rules.get_chrs.output, chrs=CHROMOSOMES)
    output:
        PATH + "/FINALS/chrs/only_chrall_allhap.fasta.gz"
    shell:
        "cat {input} >> {output}"
