#!/bin/bash
#SBATCH --account=def-kevbot                            # account name
#SBATCH --nodes=1                                       # X server node
#SBATCH --ntasks=1                                      # One GPU program is usually one process
#SBATCH --cpus-per-task=12                              # 12 cpus per NUMA node
#SBATCH --mem=64G                                       # memory per node
#SBATCH --gpus=h100:1                                   # request 1 H100 GPU
#SBATCH --time=00-00:05:00                              # days-hh:mm:ss
#SBATCH --job-name=Au22KCK16                            # Name of the job
#SBATCH --output=slurm_%j_tddft_Au22KCK16.out           # output file
#SBATCH --error=slurm_%j_tddft_Au22KCK16.err            # error file

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
echo ""
echo ">>> basedir: ${PWD##*/}"
echo ""
echo ">>> Modules loaded:"
echo ""
module list

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=close
export OMP_PLACES=cores
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

# GPU diagnostics
echo ">>> GPU information:"
nvidia-smi
echo ">>> CUDA_VISIBLE_DEVICES: ${CUDA_VISIBLE_DEVICES:-not_set}"

echo ""
echo ">>> Starting GPU program at: $(date)"
# GPU program
srun --cpu-bind=cores --gpu-bind=closest ./my_gpu_program
# for a python program
srun --cpu-bind=cores --gpu-bind=closest python train.py
# for CUDA executable
srun --cpu-bind=cores --gpu-bind=closest ./my_cuda_program
echo ">>> Finished GPU program at: $(date)"
echo ""

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
echo ""
echo ">>> Job resource usage details:"
sacct -j "$SLURM_JOB_ID" --format=JobID,JobName,State,ExitCode,Elapsed,Timelimit,AllocNodes,AllocCPUS,ReqMem,MaxRSS,AveCPU

echo "---------------------------------------------------"

exit 0
