#!/bin/bash
#SBATCH --job-name=BUSCO_analysis
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=50G
#SBATCH --time=1-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/BUSCO_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/BUSCO_%J.err

# General paths
WORKDIR="/data/users/${USER}/annotation_course"
OUTDIR="$WORKDIR/Annotation_results/05_MAKER/final"
BUSCO_OUTDIR="$WORKDIR/Annotation_results/06_BUSCO"

# prefix 
prefix="HiFiasm_Ice1"

# Input files (filtered from previous step)
PROTEIN_FASTA="$OUTDIR/${prefix}_primary.all.maker.proteins.fasta.renamed.filtered.fasta"
TRANSCRIPT_FASTA="$OUTDIR/${prefix}_primary.all.maker.transcripts.fasta.renamed.filtered.fasta"

# Lineage dataset
LINEAGE="brassicales_odb10"

# Create BUSCO output directory
mkdir -p "$BUSCO_OUTDIR"
cd "$BUSCO_OUTDIR"

# Output files
LONGEST_PROTEIN="$BUSCO_OUTDIR/${prefix}.proteins.longest.fasta"
LONGEST_TRANSCRIPT="$BUSCO_OUTDIR/${prefix}.transcripts.longest.fasta"

echo "=== Starting BUSCO analysis pipeline ==="
echo "Working directory: $BUSCO_OUTDIR"
echo "Input protein file: $PROTEIN_FASTA"
echo "Input transcript file: $TRANSCRIPT_FASTA"

echo "=== Extracting longest protein sequence per gene ==="

# Load required modules
module load SAMtools/1.13-GCC-10.3.0

# Step 1: Index the protein fasta file
echo "Indexing protein fasta file..."
samtools faidx "$PROTEIN_FASTA"

# Step 2: Get sequence lengths and extract gene names
echo "Identifying longest protein isoforms..."
cut -f1,2 ${PROTEIN_FASTA}.fai | \
awk '{
    # Extract gene name (everything before -R)
    gene = $1
    sub(/-R.*/, "", gene)
    # Keep only longest isoform per gene
    if ($2 > maxlen[gene]) {
        maxlen[gene] = $2
        longest[gene] = $1
    }
}
END {
    for (gene in longest) {
        print longest[gene]
    }
}' > protein_longest_ids.txt

# Step 3: Extract sequences using samtools
echo "Extracting longest protein sequences..."
samtools faidx "$PROTEIN_FASTA" $(cat protein_longest_ids.txt | tr '\n' ' ') > "$LONGEST_PROTEIN"

echo "Created: $LONGEST_PROTEIN"
echo "Number of proteins: $(grep -c "^>" "$LONGEST_PROTEIN")"

echo "=== Extracting longest transcript sequence per gene ==="

# Step 1: Index the transcript fasta file
echo "Indexing transcript fasta file..."
samtools faidx "$TRANSCRIPT_FASTA"

# Step 2: Get sequence lengths and extract gene names
echo "Identifying longest transcript isoforms..."
cut -f1,2 ${TRANSCRIPT_FASTA}.fai | \
awk '{
    # Extract gene name (everything before -R)
    gene = $1
    sub(/-R.*/, "", gene)
    # Keep only longest isoform per gene
    if ($2 > maxlen[gene]) {
        maxlen[gene] = $2
        longest[gene] = $1
    }
}
END {
    for (gene in longest) {
        print longest[gene]
    }
}' > transcript_longest_ids.txt

# Step 3: Extract sequences using samtools
echo "Extracting longest transcript sequences..."
samtools faidx "$TRANSCRIPT_FASTA" $(cat transcript_longest_ids.txt | tr '\n' ' ') > "$LONGEST_TRANSCRIPT"

echo "Created: $LONGEST_TRANSCRIPT"
echo "Number of transcripts: $(grep -c "^>" "$LONGEST_TRANSCRIPT")"

echo "=== Running BUSCO on proteins ==="

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

# Run BUSCO on proteins
busco -i "$LONGEST_PROTEIN" \
      -l "$LINEAGE" \
      -o "proteins_busco" \
      -m proteins \
      -c 20

echo "=== Running BUSCO on transcripts ==="

# Run BUSCO on transcripts
busco -i "$LONGEST_TRANSCRIPT" \
      -l "$LINEAGE" \
      -o "transcriptome_busco" \
      -m transcriptome \
      -c 20