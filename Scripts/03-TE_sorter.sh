#!/bin/bash
#SBATCH --job-name=TE_sorter
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/03_TE_sorter_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/03_TE_sorter_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/03_Refining_TE"
FASTAFILE="$WORKDIR/Annotation_results/01_EDTA_annotation/HiFiasm_Ice1_primary.fa.mod.EDTA.TElib.fa"
LOGDIR="$WORKDIR/log_annot"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"

#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

# module load SeqKit/2.6.1
# # Extract Copia sequences
# seqkit grep -r -p "Copia" $FASTAFILE > Copia_sequences.fa
# # Extract Gypsy sequences
# seqkit grep -r -p "Gypsy" $FASTAFILE > Gypsy_sequences.fa
# Extract MITE sequences
seqkit grep -r -p "MITE" $FASTAFILE > MITE_sequences.fa

# Refine TE classification for clade-level classification of LTR retrotransposons
# on the Copia and Gypsy superfamilies
# apptainer exec --bind $WORKDIR $CONTAINER TEsorter \
#     Copia_sequences.fa -db rexdb-plant

# apptainer exec --bind $WORKDIR $CONTAINER TEsorter \
#     Gypsy_sequences.fa -db rexdb-plant

apptainer exec --bind $WORKDIR $CONTAINER TEsorter \
    MITE_sequences.fa -db rexdb-plant
