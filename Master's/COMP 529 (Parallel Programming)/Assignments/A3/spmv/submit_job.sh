#!/bin/bash
#
# You should only work under the /scratch/users/<username> directory.
#
# Example job submission script
#
# -= Resources =-
#
#SBATCH --job-name=spmv
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=short
#SBATCH --time=00:30:00
#SBATCH --output=spmv.out

################################################################################
##################### !!! DO NOT EDIT ABOVE THIS LINE !!! ######################
################################################################################

echo
echo "COMP 529 - Shukhrat Khuseynov - 0070495"
echo

# Set stack size to unlimited
echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

# Required information
echo "LSCPU:"
echo
lscpu
echo

echo "Running Job...!"
echo "==============================================================================="
echo "Running compiled binary..."
echo

#serial version
echo "Serial version..."
echo
build/spmv_serial Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
build/spmv_serial Flan_1565/Flan_1565.mtx 20
echo

echo
echo "==============="
echo

#parallel version (processes)
echo "Parallel version with 1 process"
echo
mpirun -np 1 build/spmv_p1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 1 build/spmv_p1 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 2 processes"
echo
mpirun -np 2 build/spmv_p1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 2 build/spmv_p1 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 4 processes"
echo
mpirun -np 4 build/spmv_p1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 4 build/spmv_p1 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 8 processes"
echo
mpirun -np 8 build/spmv_p1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 8 build/spmv_p1 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 16 processes"
echo
mpirun -np 16 build/spmv_p1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 16 build/spmv_p1 Flan_1565/Flan_1565.mtx 20
echo

echo
echo "==============="
echo

#parallel version (processes and threads)
export KMP_AFFINITY=verbose,granularity=fine,compact
echo

echo "Parallel version with 1 process and 16 threads"
export OMP_NUM_THREADS=16
echo
mpirun -np 1 build/spmv_p2 16 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 1 build/spmv_p2 16 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 2 processes and 8 threads"
export OMP_NUM_THREADS=8
echo
mpirun -np 2 build/spmv_p2 8 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 2 build/spmv_p2 8 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 4 processes and 4 threads"
export OMP_NUM_THREADS=4
echo
mpirun -np 4 build/spmv_p2 4 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 4 build/spmv_p2 4 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 8 processes and 2 threads"
export OMP_NUM_THREADS=2
echo
mpirun -np 8 build/spmv_p2 2 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 8 build/spmv_p2 2 Flan_1565/Flan_1565.mtx 20
echo

echo "Parallel version with 16 processes and 1 thread"
export OMP_NUM_THREADS=1
echo
mpirun -np 16 build/spmv_p2 1 Cube_Coup_dt6/Cube_Coup_dt6.mtx 20
echo
mpirun -np 16 build/spmv_p2 1 Flan_1565/Flan_1565.mtx 20
echo

echo "The end."