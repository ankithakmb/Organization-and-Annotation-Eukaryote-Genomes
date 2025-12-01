#!/bin/bash
#SBATCH --job-name=BUSCO_stats
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=50G
#SBATCH --time=1-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/06.1_BUSCO_stats%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/06.1_BUSCO_stats%J.err

# General paths
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/06_BUSCO"

# Create the directory for the error and output file if not present
mkdir -p "$LOGDIR"

# Create the directory output if not present
mkdir -p "$OUTDIR"

# Change to output directory
cd "$OUTDIR"

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

generate_plot.py -wd "$OUTDIR/proteins_busco"
generate_plot.py -wd "$OUTDIR/transcriptome_busco"

#combined plot
mkdir -p "$OUTDIR/combined_summaries"
cp "$OUTDIR/proteins_busco"/short_summary*.txt "$OUTDIR/combined_summaries/"
cp "$OUTDIR/transcriptome_busco"/short_summary*.txt "$OUTDIR/combined_summaries/"
generate_plot.py -wd "$OUTDIR/combined_summaries"

# Path to the directory for AGAT stats
INPUTDIR="$WORKDIR/Annotation_results/05_MAKER/final/filtered.genes.renamed.gff3"
OUTDIR_AGAT="$WORKDIR/Annotation_results/06_BUSCO/agat_stats"

# Create the directory output if not present
mkdir -p "$OUTDIR_AGAT"

# Change to new output directory
cd "$OUTDIR_AGAT"

#Get AGAT stats
APPTAINERPATH="/data/courses/assembly-annotation-course/CDS_annotation/containers/agat_1.5.1--pl5321hdfd78af_0.sif"

# Run AGAT statistics using apptainer
apptainer exec --bind /data "$APPTAINERPATH" agat_sp_statistics.pl \
  -i "$INPUTDIR" \
  -o "$OUTDIR/annotation_statistics.txt"

