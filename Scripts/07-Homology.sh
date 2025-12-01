#!/bin/bash
#SBATCH --job-name=homology
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/07_homology_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/07_homology_%J.err

# General path
WORKDIR="/data/users/${USER}/annotation_course"
LOGDIR="$WORKDIR/log_annot"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# Path to the directory of the input files
ANNODIR="$WORKDIR/Annotation_results/05_MAKER/final"
FASTAPROTEINFILE="HiFiasm_Ice1_primary.all.maker.proteins.fasta.renamed.filtered.fasta"
GFFFILE="filtered.genes.renamed.gff3"

OUTDIR="$WORKDIR/Annotation_results/07_Functional_annotation"
mkdir -p $OUTDIR
cd $OUTDIR

# Path to the program used to merge
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Define databases
UNIPROTDB="$COURSEDIR/data/uniprot/uniprot_viridiplantae_reviewed.fa"
TAIR10DB="$COURSEDIR/data/TAIR10_pep_20110103_representative_gene_model"

# Load module
module load BLAST+/2.15.0-gompi-2021a

################################################################################
# BLAST against UniProt Viridiplantae
################################################################################
echo "Running BLAST against UniProt..."
BLASTP_UNIPROT="blastp_uniprot.out"

blastp -query $ANNODIR/$FASTAPROTEINFILE \
    -db $UNIPROTDB \
    -num_threads 12 \
    -outfmt 6 \
    -evalue 1e-5 \
    -max_target_seqs 10 \
    -out $BLASTP_UNIPROT

# Sort to keep only the best hit per query sequence
sort -k1,1 -k12,12gr $BLASTP_UNIPROT | sort -u -k1,1 --merge > ${BLASTP_UNIPROT}.besthits

# Copy original files before adding functional annotations
cp $ANNODIR/$FASTAPROTEINFILE ${FASTAPROTEINFILE}.Uniprot
cp $ANNODIR/$GFFFILE ${GFFFILE}.Uniprot

# Map the protein putative functions to the MAKER produced GFF3 and FASTA files
$MAKERBIN/maker_functional_fasta $UNIPROTDB ${BLASTP_UNIPROT}.besthits \
    ${FASTAPROTEINFILE}.Uniprot > ${FASTAPROTEINFILE}.Uniprot.annotated

$MAKERBIN/maker_functional_gff $UNIPROTDB ${BLASTP_UNIPROT}.besthits \
    ${GFFFILE}.Uniprot > ${GFFFILE}.Uniprot.annotated

################################################################################
# BLAST against Arabidopsis thaliana TAIR10
################################################################################
echo "Running BLAST against TAIR10..."
BLASTP_TAIR10="blastp_tair10.out"

blastp -query $ANNODIR/$FASTAPROTEINFILE \
    -db $TAIR10DB \
    -num_threads 12 \
    -outfmt 6 \
    -evalue 1e-5 \
    -max_target_seqs 10 \
    -out $BLASTP_TAIR10

# Sort to keep only the best hit per query sequence
sort -k1,1 -k12,12gr $BLASTP_TAIR10 | sort -u -k1,1 --merge > ${BLASTP_TAIR10}.besthits

################################################################################
# Summary statistics
################################################################################
echo "=== Summary Statistics ==="
echo "Total proteins annotated: $(grep -c '^>' $ANNODIR/$FASTAPROTEINFILE)"
echo "UniProt hits: $(wc -l < ${BLASTP_UNIPROT}.besthits)"
echo "TAIR10 hits: $(wc -l < ${BLASTP_TAIR10}.besthits)"
