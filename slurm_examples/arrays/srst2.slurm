#Create a file with file prefixes ( assuming all the files are in one folder)
 
Since you have both the forward and reverse, first step is to create a file with the prefixes OR the names of the isolates. We can call this file isolates.txt which can be generated with the following for loop ( this does not have to be done via a Slurm script. Simply run it as an interactive process on the terminal
 
for filename in *_1.fastq.gz
do
 base=$(basename ${filename} _1.fastq.gz)
 echo "${base}" >> prefixes-vertical.txt
 tr '\n' ' ' <prefixes-vertical.txt > isolates.txt
done
 
For an example,If I run the above for loop for  /nesi/nobackup/massey03742/sacnz_reads/testcopy/ , it will create the isolates.txt with 
 
$ cat isolates.txt
SRR17898856 SRR17898857 SRR17898859
 
Slurm array script 
 
Note - 
Following array script was written in a way where the submission directory will be the same isolates files. 
--array 0-2 is used as the test script is for 3 isolates ( as above) . Slurm arrays starts from 0. 
--cpus-per-task and --mem is per isoalte  .i.e. It will launch three separate Slurm jobs where each one will have the value assigned in those variables. Adjust as you need. 
 
Now to the array script, 
 
#!/bin/bash -e 

#SBATCH --job-name=srst2_test_cme
#SBATCH --output=slurmlog/%A.%a.out
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4                 
#SBATCH --account=nesi99999
#SBATCH --time=24:00:00   
#SBATCH --array 0-2

module purge
module load Apptainer

#Load the isolated file prefixes from the .txt files to a variable
export isolates=($(cat isolates.txt))

#write the input filenames to the standard output to check that everything ran according to expectations.
echo "${isolates[ $SLURM_ARRAY_TASK_ID ]}_1.fastq.gz ${isolates[ $SLURM_ARRAY_TASK_ID ]}_2.fastq.gz"


apptainer exec /opt/nesi/containers/SRST2/srst2-0.2.0.simg srst2 --threads ${SLURM_CPUS_PER_TASK} \
--input_pe ${isolates[ $SLURM_ARRAY_TASK_ID ]}_1.fastq.gz ${isolates[ $SLURM_ARRAY_TASK_ID ]}_2.fastq.gz \
--output results/${isolates[ $SLURM_ARRAY_TASK_ID ]} --log --gene_db seqs_clustered.fasta
