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

## Commands
* 