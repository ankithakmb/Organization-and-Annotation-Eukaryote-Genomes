#!/bin/bash
#SBATCH --job-name=MAKER_filter
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/MAKER_filter_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/MAKER_filter_%J.err

# General paths
WORKDIR="/data/users/${USER}/annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
LOGDIR="$WORKDIR/log_annot"

# Path to the directories of input files
OUTDIR="$WORKDIR/Annotation_results/05_MAKER"
INPUTDIR="$OUTDIR/Merge_result/"

#Program used
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# prefix 
prefix="HiFiasm_Ice1"

# Create final directory
mkdir -p "$OUTDIR/final"

# Define file names
protein="${prefix}_primary.all.maker.proteins.fasta"
transcript="${prefix}_primary.all.maker.transcripts.fasta"
gff="${prefix}_primary.all.maker.noseq.gff"

# Copy files from Merge_result to final directory
cp "$INPUTDIR/$gff" "$OUTDIR/final/${gff}.renamed.gff"
cp "$INPUTDIR/$protein" "$OUTDIR/final/${protein}.renamed.fasta"
cp "$INPUTDIR/$transcript" "$OUTDIR/final/${transcript}.renamed.fasta"

# Change to final directory
cd "$OUTDIR/final" 

#1. Assign clean, consistent IDs to the gene models
$MAKERBIN/maker_map_ids --prefix $prefix --justify 7 ${gff}.renamed.gff > id.map
$MAKERBIN/map_gff_ids id.map ${gff}.renamed.gff
$MAKERBIN/map_fasta_ids id.map ${protein}.renamed.fasta
$MAKERBIN/map_fasta_ids id.map ${transcript}.renamed.fasta

#2. Run InterProScan on the Protein File
apptainer exec \
  --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data \
  --bind $WORKDIR \
  --bind $COURSEDIR \
  --bind $SCRATCH:/temp \
  $COURSEDIR/containers/interproscan_latest.sif \
  /opt/interproscan/interproscan.sh \
  -appl pfam --disable-precalc -f TSV --goterms --iprlookup --seqtype p \
  -i ${protein}.renamed.fasta -o output.iprscan

#3. Update GFF with InterProScan Results
$MAKERBIN/ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff

#4. Calculate AED Values
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 ${gff}.renamed.gff > assembly.all.maker.renamed.gff.AED.txt

#5. Filter the GFF File for Quality
perl $MAKERBIN/quality_filter.pl -s ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff

#6. Filter the GFF File for Gene Features

#Only keep the gene features in the third column of the gff file
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3

# Check
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# 7. Extract mRNA Sequences and Filter FASTA Files
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt
faSomeRecords ${transcript}.renamed.fasta list.txt ${transcript}.renamed.filtered.fasta
faSomeRecords ${protein}.renamed.fasta list.txt ${protein}.renamed.filtered.fasta