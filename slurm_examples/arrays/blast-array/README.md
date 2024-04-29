# BLAST : Split the sequences and run individual queries
 
This option utilises the Slurm array option which allows us to submit hundreds or thousands of jobs via a single script. 
 
* First step is to generate input query files from a single fasta file. This can be done in multiple ways and the easiest option is to use `faSplit` tool provided by ucsc. We don't provide it as a module as it is a single file
    * It can be downloaded with `wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/faSplit` ( no installations were required). 
* You can call it directly from that path or copy it to anywhere you prefer

```bash
$ ./faSplit 

faSplit - Split an fa file into several files.
usage:
   faSplit how input.fa count outRoot
where how is either 'about' 'byname' 'base' 'gap' 'sequence' or 'size'.  
Files split by sequence will be broken at the nearest fa record boundary. 
Files split by base will be broken at any base.  
Files broken by size will be broken every count bases.
```
 
We can use quite a few options here to split the read from split by `base`, `bytessize`.  In this instance, I suppose we can use split by sequence. Let's say we want to split it to 500 chunks and save those chunks into a new folder call inputblast. ( 500 is just an example, you can split it to as many as you prefer.  If you want to explore a higher number, I recommend keeping it to 12,000 or less - Primarily for Slurm array limits).  Then the command is

```
$ faSplit sequence MasurcaPolcaRedundansPurgeDups.fasta 500 inputblast/MasurcaPolcaRedundansPurgeDups_
```
 
This will create 500 individual files in **inputblast/** directory  where the file names will be `faa_plate1_00.fa`, `faa_plate1_01.fa` ,`faa_plate1_02.fa` ,................`faa_plate1_499`.fa
Now we can use the following Slurm array script to launch 500 individual jobs for each chunk with 4CPUs and 2G per job . (4G and 24 hour time limit is just an assumption). .
Ideally, run few chunks first to see whether the resource request is sufficient. Mainly to avoid out of memory errors and time outs.
I am using the hypothetical paths **/nesi/nobackup/nesi99999/blast/inputblast** ( path to input files after the above split) , **/nesi/nobackup/nesi99999/blast/outputs** path to save outputs, **/nesi/nobackup/nesi99999/blast/logs** path to save slurm logs.

```bash
#!/bin/bash -e

#SBATCH --account        nesi99999
#SBATCH --job-name       blast_fastaSplit
#SBATCH --cpus-per-task  4
#SBATCH --mem            2G
#SBATCH --time           24:00:00
#SBATCH --array          0-499
#SBATCH --output         logs/%A_%a.out

date;hostname;pwd

module load BLASTDB/2023-01
module load BLAST/2.13.0-GCC-11.3.0
DB=nt
 
export INPUT_DIR=/nesi/nobackup/nesi99999/blast/inputblast
export OUTPUT_DIR=/nesi/nobackup/nesi99999/blast/outputs
export LOG_DIR=/nesi/nobackup/nesi99999/blast/logs
 
RUN_ID=$(( $SLURM_ARRAY_TASK_ID + 1 ))
 
QUERY_FILE=$( ls ${INPUT_DIR} | sed -n ${RUN_ID}p )
QUERY_NAME="${QUERY_FILE%.*}"
 
QUERY="${INPUT_DIR}/${QUERY_FILE}"
OUTPUT="${OUTPUT_DIR}/${QUERY_NAME}.out"
 
echo -e "Command:\nblastn –query ${QUERY} –db nt –out ${OUTPUT} -outfmt 6 -max_target_seqs 1 -num_threads $SLURM_CPUS_PER_TASK"
 
blastn -query ${QUERY} -db nt -out ${OUTPUT} -outfmt 6 -max_target_seqs 1 -num_threads $SLURM_CPUS_PER_TASK 
 
date
```