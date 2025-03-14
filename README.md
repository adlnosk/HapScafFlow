# HapScafFlow

**Haplotype-resolved scaffolding with 3D-DNA, producing whole-genome or chromosome-level assemblies.**  

## Overview  

HapScafFlow is a Snakemake workflow designed to scaffold individual haplotypes using [3D-DNA](https://github.com/aidenlab/3d-dna), assess genome completeness with [BUSCO](https://busco.ezlab.org/), and generate final **whole-genome** or **chromosome-level assemblies**. The pipeline was designed to scaffold the output from [Toulbar2](https://github.com/toulbar2/toulbar2), which assigns contigs to new haplotype numbers based on protein alignment. The original assembly comes from [Hifiasm](https://hifiasm.readthedocs.io/en/latest/).  

### Workflow Execution and Manual Curation  

1. **First Submission**: If submitted once, the pipeline will **crash after 3D-DNA scaffolding**.  
2. **Manual Curation**: The user must **open [Juicebox](https://github.com/aidenlab/Juicebox)** and export the genome to create `.review` files.  
3. **Resubmission**: After review file generation, **re-run the pipeline without changes**. It will continue until completion.  
4. **Iterative Manual Curation**: After **each review file update**, the pipeline can be resubmitted.  

**Warning**: The pipeline **does not** back up `.review` files or track curation rounds. Users should **manually save** previous versions if needed.  

## Input Requirements  

The following input files are required:  
- `hap_{n}.fasta` – Haplotype-specific assembly files  
- `hap_{n}.fasta.length` – Corresponding length files  
- `merged_nodups.txt` - **Aligned Hi-C reads** to the whole-genome assembly with [Juicer](https://github.com/aidenlab/juicer)  


## Configuration  

Pipeline configuration variables are set in `run_snake.sh`.  

### Defining Genome Structure  

Set the number of expected chromosomes:  

```bash
export NUM_CHRS=8
```

The number of haplotypes is determined automatically from the number in input fasta files:  

```bash
export NUM_HAP=$(ls $PATH_TO_FASTA/hap_*.fasta 2>/dev/null | grep -oP '(?<=/hap_)\d+' | sort -nr | head -n1)
```

### BUSCO Lineage  

Set lineage of your organism:

```bash
export LINEAGE="fabales"
```

By default, the pipeline uses the .odb10 version of the BUSCO dataset.  

## Snakemake and Dependencies  

This pipeline is designed for **Snakemake 7.20.0** and runs using a **Slurm cluster** (preconfigured in `config.yaml`).  

### Required Modules  

The pipeline requires the following software modules, which are loaded within individual scripts using `module load`:  

```bash
module load devel/Miniconda/Miniconda3
module load bioinfo/BUSCO/5.4.7
module load bioinfo/LASTZ/1.04.22 devel/python/Python-3.6.3
module load bioinfo/3D-DNA/529ccf4
module load bioinfo/Seqtk/1.3
module load bioinfo/bgzip/1.18
module load bioinfo/samtools/1.19
module load bioinfo/assemblathon2/d1f044b
```

## Installing the Pipeline  

To install and configure the pipeline:  

1. **Navigate to the directory** containing the FASTA files:  

```bash
cd /path/to/fasta/files
```

2. **Clone the repository**:  

```bash
git clone https://github.com/adlnosk/HapScafFlow.git
```

3. **Modify `run_snake.sh`** according to your dataset.  

## Running the Workflow  

To launch the Snakemake pipeline, ensure all required files are in place and execute:  

```bash
sbatch run_snake.sh
```

## Output  

- output files are stored next to the input FASTA files

The pipeline generates:  
- Scaffolds for **each haplotype** (in `q0` or `q1_3D_DNA_HAP$n`)
- **BUSCO scores** to assess completeness  (in `BUSCO/busco_summaries`)
- **Final whole-genome and chromosome-level assemblies** (in `FINALS/` and `FINALS/chrs/`)  
- **Assemblathon statistics**  (`/FINALS/whole_genome.fasta.gz.assemblahon_stats`)

