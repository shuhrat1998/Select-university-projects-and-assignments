#!/bin/bash
# 
# You should only work under the /scratch/users/<username> directory.
#
# Example job submission script
#
# -= Resources =-
#
#SBATCH --job-name=noise_remover
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=short
#SBATCH --qos=users
#SBATCH --time=00:30:00
#SBATCH --output=noise_remover_v2.out
#SBATCH --exclusive

#SBATCH --gres=gpu:tesla_k20m:1

################################################################################
##################### !!! DO NOT EDIT BELOW THIS LINE !!! ######################
################################################################################

## Load CUDA 10.1
echo "CUDA 10.1 loading.."
module load cuda/10.1

echo
#echo "============================== ENVIRONMENT VARIABLES ==============================="
#env
#echo "===================================================================================="
#echo
#echo

# Set stack size to unlimited
echo "Setting stack size to unlimited..."
ulimit -s unlimited
ulimit -l unlimited
ulimit -a
echo

################################################################################
##################### !!! DO NOT EDIT ABOVE THIS LINE !!! ######################
################################################################################

echo
echo "COMP 529 - Shukhrat Khuseynov - 0070495"
echo

echo "Running Job...!"
echo "==============================================================================="
echo "Running compiled binary..."
echo

./noise_remover_v2 -i coffee.pgm -iter 100 -o denoised_coffee.png

echo "The end."