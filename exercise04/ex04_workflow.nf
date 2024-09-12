nextflow.enable.dsl = 2

params.storeDir = "${launchDir}/cache"
params.out = "${launchDir}/results"
//params.srr = "SRR12022081"
params.srr = null

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    val params.srr
  output:
    path "${params.srr}*"
  script:
  """
  prefetch $params.srr
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
  if(params.srr != null) {
    sra_file = prefetch(Channel.from(params.srr))
  } else {
      print "Error: Please provide SRR: --srr SRR_number"
      System.exit(0)
  }
  splitTOfastq(sra_file) | flatten | statsFastq
}

//   prefetch(Channel.from(params.srr)) | splitTOfastq | flatten | statsFastq
