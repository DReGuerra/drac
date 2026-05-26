# HPC usage and management on DRAC systems
André Guerra<br>
Department of Chemistry<br>
Queen's University<br>
May, 2026<br>
a[dot]guerra[at]queensu[dot]ca<br>

## Objectives
The goal of this repository is to server as a reference guide and on-ramp resource for people learning to use the HPC resources available from the Digital Research Alliance of Canada (DRAC). More experienced users may also find some more advanced topics helpful and a source of sample scripts. The official documentation for DRAC can be found at: [https://docs.alliancecan.ca/wiki/Technical_documentation](https://docs.alliancecan.ca/wiki/Technical_documentation). This repository will not be an exhaustive reference, for that the reader should refer to the official DRAC documentation. Instead, this repository will clarify some important aspects and introduce workflows through some sample scripts. The reader can use and modify these scripts for their own workflows.

## Linux
### Custom aliases
The script `linux/.custom_aliases` contains aliases to facilitate commands on Linux. Currently, it contains movement aliases (listing, changing between directories and combinations of both in one command).

To include these aliases in your bash shell instance, add the following line to your `.bashrc` file:
```
source ~/.custom_aliases
```

### Storage
On DRAC we have a few different filesystems to use - see [here](https://docs.alliancecan.ca/wiki/Storage_and_file_management) for a full description. Disk usage can be seen using the command:
```
diskusage_report
```
Which outputs:
```
                   Description                Space           # of files
                 Home (username)         280 kB/47 GB              25/500k
              Scratch (username)         4096 B/18 TB              1/1000k
       Project (def-username-ab)       4096 B/9536 GB              2/500k
          Project (def-username)       4096 B/9536 GB              2/500k
```
Scratch storage is the fastest amd should be used for data generation during a compute job. This storage is intended to be temporary for data generation only - in fact, DRAC conducts periodic purges of data in these drives. So, it is your responsibility to transfer data from completed jobs to longer-term storage (e.g., Project), or for archiving (e.g., Nearline).

## Slurm
[Slurm](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) is a job scheduler for Linux clusters that DRAC uses for resources management. DRAC clusters have a lot of hardware available to a lot of researchers. Submitting jobs to Slurm creates a virtual queue to organize the allocation of CPUs, memory, and GPUs available to users. DRAC's documentation on [running jobs](https://docs.alliancecan.ca/wiki/Running_jobs) explains several aspects of submitting jobs using Slurm.

### Queue
This command asks for the queued jobs for `$USER` and it formats each of the columns that it wants returned and how many characters in length the content of each column should be - this is important for making it readable on your terminal window.
```
squeue --user=$USER --Format=username:.10,name:.20,jobid:.10,account:.15,numcpus:.6,minmemory:.12,state:.12,timelimit:.12,timeused:.12,reason:.10
```
This command asks for the queued jobs of all users in the accounts specified, and it also formats the output as the command above.
```
squeue --account=def-kevbot_cpu,def-fzadeh_cpu --Format=username:.10,name:.20,jobid:.10,account:.15,numcpus:.6,minmemory:.12,state:.12,timelimit:.12,timeused:.12,reason:.10
```

### Fair share score
Get the share score for all group members in the accounts specified:
```
sshare --accounts=def-kevbot_cpu,def-fzadeh_cpu -a -v --format=Account,User,NormShares,EffectvUsage,LevelFS
```
This returns:
```
Users requested:
        : all
Accounts requested:
        : def-kevbot_cpu
        : def-fzadeh_cpu
Account                    User  NormShares  EffectvUsage    LevelFS
-------------------- ---------- ----------- ------------- ----------
def-fzadeh_cpu                     0.000000      0.000001   0.006833
 def-fzadeh_cpu         aguerra    0.090909      0.000000        inf
 def-fzadeh_cpu         alnaba1    0.090909      0.000000        inf
 def-fzadeh_cpu             ecm    0.090909      0.000000        inf
 def-fzadeh_cpu        em23pff5    0.090909      0.000007 1.2521e+04
 def-fzadeh_cpu          fzadeh    0.090909      0.000000        inf
 def-fzadeh_cpu          legend    0.090909      0.999736   0.090933
 def-fzadeh_cpu          leilap    0.090909      0.000000        inf
 def-fzadeh_cpu         maxvanz    0.090909      0.000000        inf
 def-fzadeh_cpu        neelcc29    0.090909      0.000256 354.502870
 def-fzadeh_cpu           ohzde    0.090909      0.000000 4.6818e+05
 def-fzadeh_cpu           osaur    0.090909      0.000000        inf
def-kevbot_cpu                     0.000000      0.000000        inf
 def-kevbot_cpu         aguerra    1.000000      0.000000        inf
```
The share score and its effect on your queue time has two aspects: (1) it uses the account's total usage compared to other accounts, and (2) it uses your share score compared to your group members. From the return, you can see each user's individual score (LevelFS) and the score for the whole group. This can give you insight into how long you will queue relative to all users in the cluster and relative to your group members. There is an interesting page on competing group members on the [DRAC documentation](https://docs.alliancecan.ca/wiki/Managing_Slurm_accounts) - coordination between group members can significantly improve work throughput within the group.

## Hardware Architecture

