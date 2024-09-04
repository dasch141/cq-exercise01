# Commands we run after nextflow installation

# putting nextflow into a linux path for easier running

1.  ls -la
    * showing the installed files
2.  nextflow
    * should return that command cannot be found
3. ./nextflow
    * with this it should work
4. echo $PATH
    * shows the accessible paths
5. sudo mv nextflow /usr/local/bin/
    * copies nextflow to one of these paths
6. nextflow
    * now it should run nextflow without ./