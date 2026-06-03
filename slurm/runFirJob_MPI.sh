#!/bin/bash
#SBATCH --account=def-kevbot                            # account name
#SBATCH --nodes=1                                       # X server node
#SBATCH --ntasks-per-node=192                           # MPI ranks per node; one rank per 8-core CCD on Fir
#SBATCH --cpus-per-task=1                               # MPI ranks are single-threaded; no OpenMP threads
#SBATCH --mem=0                                         # memory per node
#SBATCH --time=00-00:05:00                              # days-hh:mm:ss
#SBATCH --job-name=Au22KCK16                            # Name of the job
#SBATCH --output=slurm_%j_tddft_Au22KCK16.out           # output file
#SBATCH --error=slurm_%j_tddft_Au22KCK16.err            # error file

set -euo pipefail

# helper function to print variables
print_var() {
    local name="$1"
    echo ">>> $name: ${!name:-not_set}"
}

echo --------------------------------------------------
echo ">>>> Started job $SLURM_JOB_ID at: $(date) <<<<"
if [ -n "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo ">>>> Started task $SLURM_ARRAY_TASK_ID at: $(date) <<<<"
fi

# Usage:
# submit through Slurm
#   >> sbatch runFirJob.sh

echo ">>> Job environment variables:"
print_var SLURM_CLUSTER_NAME
print_var SLURM_JOB_ACCOUNT
print_var SLURM_JOB_NAME
print_var SLURM_SUBMIT_DIR
print_var SLURM_JOB_ID
print_var SLURM_JOB_NODELIST
print_var SLURMD_NODENAME
print_var SLURM_MEM_PER_NODE
print_var SLURM_MEM_PER_CPU
print_var SLURM_JOB_NUM_NODES
print_var SLURM_TASKS_PER_NODE
print_var SLURM_JOB_CPUS_PER_NODE
print_var SLURM_NTASKS_PER_NODE
print_var SLURM_NTASKS
print_var SLURM_CPUS_PER_TASK
print_var SLURM_THREADS_PER_CORE
print_var SLURM_SUBMIT_HOST
print_var SLURM_CPUS_ON_NODE
print_var SLURM_ARRAY_JOB_ID
print_var SLURM_ARRAY_TASK_COUNT
print_var SLURM_ARRAY_TASK_ID

echo ">>>"
echo ">>> basedir: ${PWD##*/}"
echo ">>>"
echo ">>> Modules loaded:"
echo ">>>"
module list
echo ">>>"

# set OpenMP env variable for number of threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
# Keeps threads near each other, helps preserve cache and NUMA locality
export OMP_PROC_BIND=close
# Binds threads to CPU cores
export OMP_PLACES=cores
# Controls math-library threading, Prevents hidden over-threading in Python/R/NumPy/BLAS workloads
export MKL_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OPENBLAS_NUM_THREADS=$SLURM_CPUS_PER_TASK
export NUMEXPR_NUM_THREADS=$SLURM_CPUS_PER_TASK

# cd into job directory
# (insert job directory here)

echo ">>> Syncing files to $SLURM_TMPDIR <<<"
# rsync to SLURM_TMPDIR
rsync -av --exclude='*.out' --exclude='*.err' ./ "$SLURM_TMPDIR"/
# cd into SLURM_TMPDIR
cd "$SLURM_TMPDIR"

# (insert job commands here)
srun --cpu-bind=cores ./my_mpi_program # MPI program

echo ">>> Syncing results back to $SLURM_SUBMIT_DIR <<<"
# make sure results directory exists
mkdir -p "$SLURM_SUBMIT_DIR"/results_${SLURM_JOB_ID}/
# rsync results back to submit directory
rsync -av --exclude='*.tmp' "$SLURM_TMPDIR"/ "$SLURM_SUBMIT_DIR"/results_${SLURM_JOB_ID}/

echo ""
if [ -n "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo ">>> Ended task $SLURM_ARRAY_TASK_ID at: $(date) <<<"
else
    echo ">>> Ended job $SLURM_JOB_ID at: $(date) <<<"
fi

echo "---------------------------------------------------"

# Summary of the job
echo ">>> Job summary:"
seff "$SLURM_JOB_ID" || true
echo ">>>"
echo ">>> Job resource usage details:"
sacct -j "$SLURM_JOB_ID" --format=JobID,JobName,State,ExitCode,Elapsed,Timelimit,AllocNodes,AllocCPUS,ReqMem,MaxRSS,AveCPU


echo "---------------------------------------------------"

exit 0
