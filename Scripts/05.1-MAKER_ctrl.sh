#!/bin/bash
#SBATCH --job-name=MAKER_ctrl
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=2-00:00
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/MAKER_ctrl%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/MAKER_ctrl%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/05_MAKER"
LOGDIR="$WORKDIR/log_annot"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

apptainer exec --bind $WORKDIR $CONTAINER maker -CTL