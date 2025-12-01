#!/bin/bash
#SBATCH --job-name=MAKER_merge
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/MAKER_merge_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/MAKER_merge_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
LOGDIR="$WORKDIR/log_annot"

OUTDIR="$WORKDIR/Annotation_results/05_MAKER"
DATASTORE="$OUTDIR/HiFiasm_Ice1_primary.maker.output"
MASTERINDEXFILE="HiFiasm_Ice1_primary_master_datastore_index.log"

CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

#Path to the program used to merge
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
# Create output directory if it doesn't exist
mkdir -p "$OUTDIR/Merge_result"


# Merge GFF with sequences
$MAKERBIN/gff3_merge -s -d $DATASTORE/$MASTERINDEXFILE > "$OUTDIR/Merge_result/HiFiasm_Ice1_primary.all.maker.gff"

# Merge GFF without sequences
$MAKERBIN/gff3_merge -n -s -d $DATASTORE/$MASTERINDEXFILE > "$OUTDIR/Merge_result/HiFiasm_Ice1_primary.all.maker.noseq.gff"

# Merge FASTA files
$MAKERBIN/fasta_merge -d $DATASTORE/$MASTERINDEXFILE -o "$OUTDIR/Merge_result/HiFiasm_Ice1_primary"