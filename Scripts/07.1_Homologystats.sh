#!/bin/bash
#SBATCH --job-name=homologystats
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/07_homologystats_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/07_homologystats_%J.err

# General path
WORKDIR="/data/users/${USER}/annotation_course"
LOGDIR="$WORKDIR/log_annot"

# Path to the directory of the input files
TOTALPROTEINS="$WORKDIR/Annotation_results/05_MAKER/final/HiFiasm_Ice1_primary.all.maker.proteins.fasta.renamed.filtered.fasta"


OUTDIR="$WORKDIR/Annotation_results/07_Functional_annotation"
mkdir -p $OUTDIR
cd $OUTDIR

BLASTHITS="$OUTDIR/blastp_tair10.out.besthits"

# 1. Count TOTAL proteins in your annotation
grep -c "^>" $TOTALPROTEINS

# 2. Count proteins WITH TAIR10 hits (homologs in Arabidopsis)
cut -f1 $BLASTHITS | sort -u | wc -l

# 3. Calculate the proportion
echo "scale=2; $(cut -f1 $BLASTHITS | sort -u | wc -l) * 100 / $(grep -c "^>" $TOTALPROTEINS)" | bc

# 4. More detailed breakdown - save to a file
TOTAL=$(grep -c "^>" $TOTALPROTEINS)
WITH_HIT=$(cut -f1 $BLASTHITS | sort -u | wc -l)
WITHOUT_HIT=$((TOTAL - WITH_HIT))
PERCENT=$(echo "scale=2; $WITH_HIT * 100 / $TOTAL" | bc)

cat > tair10_homology.txt << EOF
Homology to Arabidopsis thaliana (TAIR10)
==========================================
Total proteins: $TOTAL
Proteins WITH TAIR10 hits: $WITH_HIT ($PERCENT%)
Proteins WITHOUT TAIR10 hits: $WITHOUT_HIT ($(echo "100 - $PERCENT" | bc)%)

Interpretation:
- ${PERCENT}% of your proteins have detectable homologs in Arabidopsis
- This suggests the level of sequence conservation between your species and A. thaliana
EOF

cat tair10_homology.txt