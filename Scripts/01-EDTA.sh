#!/bin/bash
#SBATCH --job-name=EDTA_annotation
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/01_EDTA_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/01_EDTA_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/01_EDTA_annotation"
LOGDIR="$WORKDIR/log_annot"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif"
INPUT_FASTA="$WORKDIR/Assemblies/Hifi/HiFiasm_Ice1_primary.fa"

#CDS is the coding sequences of the organism, with no introns, UTRs, or TEs
CDS="$WORKDIR/coding_gene/TAIR10_cds_20110103_representative_gene_model_updated"


#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

# Full run: runs TOOL_CMD inside the container using allocated CPUS
apptainer exec --bind $WORKDIR $CONTAINER EDTA.pl\
    --genome $INPUT_FASTA \
    --species others \
    --step all \
    --sensitive 1 \
    --cds $CDS \
    --anno 1 \
    --threads 20

