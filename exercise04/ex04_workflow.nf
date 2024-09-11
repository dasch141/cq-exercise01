nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.out="${launchDir}/results"
params.accession="SRR12022081"

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    val accession
  output:
    path "${accession}*"
  script:
  """
  prefetch $accession
  """
}

process splitTOfastq {
  publishDir params.out, mode :"copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    path infile
  output:
    path "${infile.baseName}*.fastq"
  script:
  """
  fastq-dump --split-3 ${infile}
  """
}

process statsFastq {
    publishDir params.out, mode :"copy", overwrite: true
    container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
    input:
        path infile
    output:
        path "${infile.baseName}.txt"
    script:
    """
    fastqutils stats ${infile} > ${infile.baseName}.txt
    """
}

workflow {
  prefetch(Channel.from(params.accession)) | splitTOfastq | flatten | statsFastq
}