#!/bin/bash
#SBATCH --job-name=genespace
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/08.3_genespace_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/08.3_genespace_%J.err

# ============================================
# Paths Configuration
# ============================================
WORKDIR="/data/users/${USER}/annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
GENESPACEDIR="${WORKDIR}/Annotation_results/08_GENESPACE"

# Container and script PATHS
CONTAINER="${COURSEDIR}/containers/genespace_latest.sif"
RSCRIPT="${WORKDIR}/Annotation_scripts/08.2-genespace.R"

# Run GENESPACE in container
apptainer exec \
    --bind /data \
    --bind ${SCRATCH}:/temp \
    ${CONTAINER} Rscript ${RSCRIPT} ${GENESPACEDIR}

echo "Job completed successfully!"