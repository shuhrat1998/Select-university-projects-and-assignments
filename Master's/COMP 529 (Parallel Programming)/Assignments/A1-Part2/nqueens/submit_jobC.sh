#!/bin/bash
#
# You should only work under the /scratch/users/<username> directory.
#
# Example job submission script
#
# -= Resources =-
#
#SBATCH --job-name=nqueensC
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=short
#SBATCH --time=00:30:00
#SBATCH --output=nqueensC.out
#SBATCH --exclusive

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
echo "*** Experiment (a) - Scalability test ***"
echo
echo "./nqueens_[serC, parC] -n 20" 
echo "Threads: [1, 2, 4, 8, 16, 32]"
echo "Compact mapping scheme"
echo

#serial version
echo "Serial version C:"
./nqueens_serC -n 20
echo

echo "=========="
echo


#parallel version
export OMP_NESTED=true
export KMP_AFFINITY=verbose,granularity=fine,compact

echo "Parallel version C with 1 thread:"
export OMP_NUM_THREADS=1
./nqueens_parC -n 20
echo

echo "Parallel version C with 2 threads:"
export OMP_NUM_THREADS=2
./nqueens_parC -n 20
echo

echo "Parallel version C with 4 threads:"
export OMP_NUM_THREADS=4
./nqueens_parC -n 20
echo

echo "Parallel version C with 8 threads:"
export OMP_NUM_THREADS=8
./nqueens_parC -n 20
echo

echo "Parallel version C with 16 threads:"
export OMP_NUM_THREADS=16
./nqueens_parC -n 20
echo

echo "Parallel version C with 32 threads:"
export OMP_NUM_THREADS=32 
./nqueens_parC -n 20
echo

echo "=========="
echo



echo
echo "*** Experiment (b) - Thread binding test ***"
echo
echo "./nqueens_parC -n 20" 
echo "Threads: [1, 2, 4, 8, 16, 32]"
echo "Scatter mapping scheme"
echo

export KMP_AFFINITY=verbose,granularity=fine,scatter

echo "Parallel version C with 1 thread:"
export OMP_NUM_THREADS=1
./nqueens_parC -n 20
echo

echo "Parallel version C with 2 threads:"
export OMP_NUM_THREADS=2
./nqueens_parC -n 20
echo

echo "Parallel version C with 4 threads:"
export OMP_NUM_THREADS=4
./nqueens_parC -n 20
echo

echo "Parallel version C with 8 threads:"
export OMP_NUM_THREADS=8
./nqueens_parC -n 20
echo

echo "Parallel version C with 16 threads:"
export OMP_NUM_THREADS=16
./nqueens_parC -n 20
echo

echo "Parallel version C with 32 threads:"
export OMP_NUM_THREADS=32 
./nqueens_parC -n 20
echo



echo "The end."