#!/bin/bash -e

#SBATCH --account 	 	massey03324
#SBATCH --job-name	 	provean_Pp_Ph_ACSS1
#SBATCH --cpus-per-task 	6
#SBATCH --mem		        18G
#SBATCH --time		        12:00:00
##SBATCH --mail-type	        ALL
##SBATCH --mail-user	        julien.gaspar93@gmail.com
#SBATCH --output	       	slurmout/julien_testing_conda.%j.out
#SBATCH --array			0-6



export TMPDIR=/nesi/nobackup/massey03324/PRO_TEMP/tmp_${SLURM_JOB_ID}
mkdir -p $TMPDIR
export TMPDIR

module purge
module load Miniconda3/4.9.2 BLASTDB/2020-01
source activate provean



#INPUT=/nesi/project/massey03324/Pp_Ph_5seq
INPUT=$PWD

TEMP=/nesi/nobackup/massey03324/PRO_TEMP
BLAST_CMD=/nesi/project/massey03324/.conda/envs/provean/bin
CD_HIT=/nesi/project/massey03324/.conda/envs/provean/bin

FASTAFILES="$INPUT/Input/"
MUTFILES="$INPUT/mutation_files/"

INPUTNAMES=( $FASTAFILES/*.fasta )
INPUTNAME=$(basename ${INPUTNAMES[SLURM_ARRAY_TASK_ID]%.*})


provean -q $FASTAFILES/${INPUTNAME}.fasta \
 -d /opt/nesi/db/blast/2020-01/nr \
 -v $MUTFILES/${INPUTNAME}.txt \
 --psiblast=$BLAST_CMD/psiblast \
 --cdhit=$CD_HIT/cd-hit \
 --blastdbcmd=$BLAST_CMD/blastdbcmd \
 --num_threads $SLURM_CPUS_PER_TASK --tmp_dir=$TEMP > $PWD/provean_outputs/${INPUTNAME}.out

#$cmd


