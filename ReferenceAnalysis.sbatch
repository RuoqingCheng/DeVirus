#!/bin/bash
#SBATCH -N 4  ###asking for 4 node
#SBATCH -p RM
#SBATCH --ntasks-per-node 28
#SBATCH --mem=120GB
#SBATCH -t 48:00:00
#SBATCH --output %j.log
source ./ReferenceAnalysis.bash "$1" "$2" "$3" "$4" "$5" "$6" "$7"
