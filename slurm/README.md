# Slurm
André Guerra<br>
Department of Chemistry<br>
Queen's University<br>
May, 2026<br>
a[dot]guerra[at]queensu[dot]ca<br>

## Summary
[Slurm](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) is a job scheduler for Linux clusters that DRAC uses for resources management. DRAC clusters have a lot of hardware available to a lot of researchers. Submitting jobs to Slurm creates a virtual queue to organize the allocation of CPUs, memory, and GPUs available to users. DRAC's documentation on [running jobs](https://docs.alliancecan.ca/wiki/Running_jobs) explains several aspects of submitting jobs using Slurm.

## Submitting Jobs
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

