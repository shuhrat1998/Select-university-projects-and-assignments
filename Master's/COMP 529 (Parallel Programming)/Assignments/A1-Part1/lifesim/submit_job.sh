#!/bin/bash
#
# You should only work under the /scratch/users/<username> directory.
#
# Example job submission script
#
# -= Resources =-
#
#SBATCH --job-name=game-of-life-jobs
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=short
#SBATCH --time=00:30:00
#SBATCH --output=game-of-life.out
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


#serial version
#echo "Serial version:"
#echo
#echo "./life -n 2000 -i 500 -s 529 -p 0.2 -d"
#echo
#./life -n 2000 -i 500 -s 529 -p 0.2 -d
#echo

#parallel version
export OMP_NESTED=true
export KMP_AFFINITY=verbose,granularity=fine,compact

echo
echo "*** Experiment 1 (strong scaling) ***"
echo
echo "./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t [1, 2, 4, 8, 16, 32]"
echo

echo "Parallel version with 1 thread:"
export OMP_NUM_THREADS=1
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 1
echo

echo "Parallel version with 2 threads:"
export OMP_NUM_THREADS=2
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 2
echo

echo "Parallel version with 4 threads:"
export OMP_NUM_THREADS=4
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 4
echo

echo "Parallel version with 8 threads:"
export OMP_NUM_THREADS=8
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 8
echo

echo "Parallel version with 16 threads:"
export OMP_NUM_THREADS=16
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "Parallel version with 32 threads:"
export OMP_NUM_THREADS=32 
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 32
echo

echo
echo "*** Experiment 2 ***"
echo
echo "./life_parallel -n [2000, 4000, 6000, 8000, 10000] -i 500 -s 529 -p 0.2 -d -t 16"
echo

export OMP_NUM_THREADS=16

echo "Parallel version with n=2000:"
./life_parallel -n 2000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "Parallel version with n=4000:"
./life_parallel -n 4000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "Parallel version with n=6000:"
./life_parallel -n 6000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "Parallel version with n=8000:"
./life_parallel -n 8000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "Parallel version with n=10000:"
./life_parallel -n 10000 -i 500 -s 529 -p 0.2 -d -t 16
echo

echo "The end."