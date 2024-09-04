# Commands we run after nextflow installation

# putting nextflow into a linux path for easier running

* ls -la
(showing the installed files)
* nextflow
(should return that command cannot be found)
* ./nextflow
(with this it should work)
* echo $PATH
(shows the accessible paths)
* sudo mv nextflow /usr/local/bin/
(copies nextflow to one of these paths)
* nextflow
(now it should run nextflow without ./)