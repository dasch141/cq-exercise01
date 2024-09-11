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
7. publish output to a directory
    * can be done by adding it ot the process in the script
    * when the output should only work as input for further functions:
        * output: path "outputname"
    * when it is the final output, add this as well:
        * publishDir "path", mode: 'copy', overwrite: true

## Commands
* 