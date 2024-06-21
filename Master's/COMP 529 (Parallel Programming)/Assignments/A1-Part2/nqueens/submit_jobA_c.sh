#!/bin/bash
#
# You should only work under the /scratch/users/<username> directory.
#
# Example job submission script
#
# -= Resources =-
#
#SBATCH --job-name=nqueensA_c
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=short
#SBATCH --time=00:30:00
#SBATCH --output=nqueensA_c.out
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
echo "*** Experiment (c) - Test of different sizes ***"
echo
echo "./nqueens_parA -n [13, 14, 15]" 
echo "Threads: 32"
echo

export OMP_NESTED=true
export KMP_AFFINITY=verbose,granularity=fine,compact
export OMP_NUM_THREADS=32

echo "N = 13:"
./nqueens_parA -n 13
echo

echo "N = 14:"
./nqueens_parA -n 14
echo

echo "N = 15:"
./nqueens_parA -n 15
echo



echo "The end."