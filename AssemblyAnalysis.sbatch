#!/bin/bash
#SBATCH -N 4  ###asking for 4 nodes
#SBATCH -p RM
#SBATCH --ntasks-per-node 28
#SBATCH --mem=120GB
#SBATCH -t 48:00:00
#SBATCH --output %j.log
source ./AssemblyAnalysis.bash "$1" "$2" "$3" "$4" "$5" "$6" "$7"
