# Linux OS scripts and configs
André Guerra<br>
Department of Chemistry<br>
Queen's University<br>
May, 2026<br>
a[dot]guerra[at]queensu[dot]ca<br>

## Summary
This section contains some scripts and configurations for Linux OS. 

### Custom aliases
The script `.custom_aliases` contains aliases to facilitate commands on Linux. Currently, it contains movement aliases (listing, changing between directories and combinations of both in one command).

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