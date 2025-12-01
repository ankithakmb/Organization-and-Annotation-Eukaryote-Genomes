#!/bin/bash
#SBATCH --job-name=MAKER
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=120G
#SBATCH --time=7-0
#SBATCH --mail-user=ramakanth.kumble@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/rkumble/annotation_course/log_annot/MAKER_%J.out
#SBATCH --error=/data/users/rkumble/annotation_course/log_annot/MAKER_%J.err

# variables
WORKDIR="/data/users/${USER}/annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUTDIR="$WORKDIR/Annotation_results/05_MAKER"
LOGDIR="$WORKDIR/log_annot"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

REPEATMASKER_DIR="$COURSEDIR/softwares/RepeatMasker"
export PATH=$PATH:$REPEATMASKER_DIR

#Make dir if it does not exist already
mkdir -p $OUTDIR
cd $OUTDIR

module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $SCRATCH:/TMP --bind $WORKDIR --bind $COURSEDIR --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR \
    $CONTAINER \
    maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl
