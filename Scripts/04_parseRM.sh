#!/bin/bash
#SBATCH --job-name=parse_RM
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=2-00:00
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/04_parse_RM_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/04_parse_RM_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
INPUTDIR="$WORKDIR/Annotation_results/01_EDTA_annotation"
GENOME="HiFiasm_Ice1_primary.fa"
RMOUT="${INPUTDIR}/${GENOME}.mod.EDTA.anno/${GENOME}.mod.out"
PARSER="$WORKDIR/CDS_annotation/scripts/05-parseRM.pl"
OUTDIR="$WORKDIR/Annotation_results/04_parsePM"
LOGDIR="$WORKDIR/log_annot"

# Create directories
mkdir -p "$LOGDIR" "$OUTDIR"

# Load the modules
module load BioPerl/1.7.8-GCCcore-10.3.0

# Run the parser (from the input directory where the .mod.out file is)
cd "$INPUTDIR" || exit 1
perl "$PARSER" -i "$RMOUT" -l 50,1 -v

# Move the result files to output directory
mv ${GENOME}.mod.EDTA.anno/${GENOME}.mod.out.landscape.*.tab "$OUTDIR/" 2>/dev/null