#!/bin/bash
#SBATCH --job-name=genespace_setup
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/08.1_genespace_setup_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/08.1_genespace_setup%J.err

# ============================================
# Paths Configuration
# ============================================
WORKDIR="/data/users/${USER}/annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# Input files from MAKER
ANNODIR="$WORKDIR/Annotation_results/05_MAKER/final"
GFFFILE="filtered.genes.renamed.gff3"
FASTAPROTEINFILE="HiFiasm_Ice1_primary.all.maker.proteins.fasta.renamed.filtered.fasta"

# Output directory for GENESPACE
GENESPACE_DIR="$WORKDIR/Annotation_results/08_GENESPACE"
PEPTIDE_DIR="$GENESPACE_DIR/peptide"
BED_DIR="$GENESPACE_DIR/bed"

# Reference data paths
LIAN_GFF="$COURSEDIR/data/Lian_et_al/gene_gff/selected"
LIAN_PROTEIN="$COURSEDIR/data/Lian_et_al/protein/selected"

# Accession names
MY_ACCESSION="Ice_1"
OTHER_ACCESSIONS=("Kar_1" "Are_6" "Taz_0" "Est_0")

# ============================================
# Create directory structure
# ============================================
mkdir -p "$PEPTIDE_DIR"
mkdir -p "$BED_DIR"

echo "=========================================="
echo "GENESPACE Input Preparation"
echo "=========================================="
echo "My accession: $MY_ACCESSION"
echo "Additional accessions: ${OTHER_ACCESSIONS[@]}"
echo "Working directory: $GENESPACE_DIR"
echo ""

# ============================================
# Process MY ACCESSION (Ice1)
# ============================================
echo "Step 1: Processing $MY_ACCESSION..."

cd "$ANNODIR"

# Create BED file from GFF3
# Extract gene features, convert to 0-based BED format, clean gene IDs
grep -P "\tgene\t" "$GFFFILE" | \
awk 'BEGIN{OFS="\t"} {
    # Extract gene ID from attributes (column 9)
    split($9, a, ";");
    split(a[1], b, "=");
    gene_id = b[2];
    # Replace problematic characters with underscores
    gsub(/[:.-]/, "_", gene_id);
    # Print: chr, start-1 (0-based), end, gene_id
    print $1, $4-1, $5, gene_id
}' | sort -k1,1 -k2,2n > "$BED_DIR/${MY_ACCESSION}.bed"

echo "  BED file created: $BED_DIR/${MY_ACCESSION}.bed"
echo "  Number of genes: $(wc -l < "$BED_DIR/${MY_ACCESSION}.bed")"

# Process protein FASTA file
# Clean headers and ensure proper formatting
awk '
/^>/ {
    # Print previous sequence if exists
    if(seq != "") {
        print seq;
    }
    # Extract and clean gene ID from header
    id = substr($1, 2);
    # Remove transcript variants (e.g., -RA, -RB)
    sub(/-R.*/, "", id);
    # Remove version numbers
    sub(/\.[0-9]+$/, "", id);
    # Replace problematic characters
    gsub(/[:.-]/, "_", id);
    print ">" id;
    seq = "";
    next;
}
{
    # Remove any non-amino acid characters except *
    gsub(/[^A-Za-z*]/, "", $0);
    seq = seq $0;
}
END {
    # Print last sequence
    if(seq != "") {
        print seq;
    }
}
' "$FASTAPROTEINFILE" > "$PEPTIDE_DIR/${MY_ACCESSION}.fa"

echo "  FASTA file created: $PEPTIDE_DIR/${MY_ACCESSION}.fa"
echo "  Number of proteins: $(grep -c "^>" "$PEPTIDE_DIR/${MY_ACCESSION}.fa")"
echo ""

# ============================================
# Process TAIR10 Reference
# ============================================
echo "Step 2: Processing TAIR10 reference..."

# Process TAIR10 BED file
if [ -f "$COURSEDIR/data/TAIR10.bed" ]; then
    awk 'BEGIN{OFS="\t"} {
        gene_id = $4;
        # Remove version numbers
        sub(/\.[0-9]+$/, "", gene_id);
        # Replace problematic characters
        gsub(/[:.-]/, "_", gene_id);
        print $1, $2, $3, gene_id;
    }' "$COURSEDIR/data/TAIR10.bed" | \
    sort -k1,1 -k2,2n > "$BED_DIR/TAIR10.bed"
    
    echo "  TAIR10 BED processed: $BED_DIR/TAIR10.bed"
    echo "  Number of genes: $(wc -l < "$BED_DIR/TAIR10.bed")"
else
    echo "  Warning: TAIR10.bed not found"
fi

# Process TAIR10 FASTA file
if [ -f "$COURSEDIR/data/TAIR10.fa" ]; then
    awk '
    /^>/ {
        if(seq != "") {
            print seq;
        }
        id = substr($1, 2);
        sub(/\.[0-9]+$/, "", id);
        gsub(/[:.-]/, "_", id);
        print ">" id;
        seq = "";
        next;
    }
    {
        gsub(/[^A-Za-z*]/, "", $0);
        seq = seq $0;
    }
    END {
        if(seq != "") {
            print seq;
        }
    }
    ' "$COURSEDIR/data/TAIR10.fa" > "$PEPTIDE_DIR/TAIR10.fa"
    
    echo "  TAIR10 FASTA processed: $PEPTIDE_DIR/TAIR10.fa"
    echo "  Number of proteins: $(grep -c "^>" "$PEPTIDE_DIR/TAIR10.fa")"
else
    echo "  Warning: TAIR10.fa not found"
fi
echo ""

# ============================================
# Process Additional Accessions (Lian et al)
# ============================================
echo "Step 3: Processing additional accessions from Lian et al..."

for ACC in "${OTHER_ACCESSIONS[@]}"; do
    echo "  Processing $ACC..."
    
    # Convert underscore to dash for file matching (e.g., Altai_5 -> Altai-5)
    ACC_DASH="${ACC//_/-}"
    
    # Find GFF file (handle wildcards)
    GFF_PATTERN="${LIAN_GFF}/${ACC_DASH}.*.gff"
    GFF_FILE=$(ls $GFF_PATTERN 2>/dev/null | head -n 1)
    
    # Find protein file
    PROT_PATTERN="${LIAN_PROTEIN}/${ACC_DASH}.protein.faa"
    PROT_FILE=$(ls $PROT_PATTERN 2>/dev/null | head -n 1)
    
    # Check if files exist
    if [[ -z "$GFF_FILE" ]] || [[ -z "$PROT_FILE" ]]; then
        echo "    Warning: Files not found for $ACC, skipping..."
        continue
    fi
    
    # Process GFF to BED
    grep -P "\tgene\t" "$GFF_FILE" | \
    awk 'BEGIN{OFS="\t"} {
        split($9, a, ";");
        split(a[1], b, "=");
        gene_id = b[2];
        gsub(/[:.-]/, "_", gene_id);
        print $1, $4-1, $5, gene_id
    }' | sort -k1,1 -k2,2n > "$BED_DIR/${ACC}.bed"
    
    echo "    BED created: ${ACC}.bed ($(wc -l < "$BED_DIR/${ACC}.bed") genes)"
    
    # Process protein FASTA
    awk '
    /^>/ {
        if(seq != "") {
            print seq;
        }
        id = substr($1, 2);
        sub(/-R.*/, "", id);
        sub(/\.[0-9]+$/, "", id);
        gsub(/[:.-]/, "_", id);
        print ">" id;
        seq = "";
        next;
    }
    {
        gsub(/[^A-Za-z*]/, "", $0);
        seq = seq $0;
    }
    END {
        if(seq != "") {
            print seq;
        }
    }
    ' "$PROT_FILE" > "$PEPTIDE_DIR/${ACC}.fa"
    
    echo "    FASTA created: ${ACC}.fa ($(grep -c "^>" "$PEPTIDE_DIR/${ACC}.fa") proteins)"
done

echo ""

# ============================================
# Final Summary
# ============================================
echo "=========================================="
echo "GENESPACE Preparation Complete!"
echo "=========================================="
echo ""
echo "Directory structure:"
echo "$GENESPACE_DIR/"
echo "├── peptide/"
for file in "$PEPTIDE_DIR"/*.fa; do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        count=$(grep -c "^>" "$file" || echo "0")
        echo "│   ├── $basename_file ($count proteins)"
    fi
done
echo "└── bed/"
for file in "$BED_DIR"/*.bed; do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        count=$(wc -l < "$file" || echo "0")
        echo "    ├── $basename_file ($count genes)"
    fi
done
echo ""
echo "Summary:"
echo "  Total BED files: $(ls -1 "$BED_DIR"/*.bed 2>/dev/null | wc -l)"
echo "  Total FASTA files: $(ls -1 "$PEPTIDE_DIR"/*.fa 2>/dev/null | wc -l)"
echo ""
echo "Next step: Run GENESPACE R script"
echo "Working directory: $GENESPACE_DIR"