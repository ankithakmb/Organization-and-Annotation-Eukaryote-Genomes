#!/bin/bash
#SBATCH --job-name=LTR-RTS
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/02_LTR_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/02_LTR_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/02_intact_LTR_RTs"
FASTAFILE="$WORKDIR/Annotation_results/01_EDTA_annotation/HiFiasm_Ice1_primary.fa.mod.EDTA.raw/HiFiasm_Ice1_primary.fa.mod.LTR.raw.fa"
LOGDIR="$WORKDIR/log_annot"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"

#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

# Refine TE classification for full length LTR-RTs and split them into Clades. 
# TE sorter generates the clade classification 
apptainer exec --bind $WORKDIR $CONTAINER TEsorter \
    $FASTAFILE -db rexdb-plant

