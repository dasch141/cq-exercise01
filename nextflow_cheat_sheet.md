# Nextflow Cheat Sheet

## Bash Script
1. naming
    * scriptname.nf
2. starting line
    * nextflow.enable.dsl=2
3. create functions
    * process function_name { """ commands """ }
4. executing functions
    * workflow { function_name() }
5. running bash scripts
    * nextflow run scriptname.nf
6. output
    * output is in the subfolder work
    * exact working directory can be found in the command output
    * starts with ff/randomnumbers (only the beginning)
    * use tab to get the complete number
    * example:
        * cd work/ff/7e47ed3656f8dafc513190c08e83ef
## Commands
* 