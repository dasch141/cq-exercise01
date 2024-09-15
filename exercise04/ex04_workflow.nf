nextflow.enable.dsl = 2

params.storeDir = "${launchDir}/cache"
params.out = "${launchDir}/results_${params.srr}"
//params.srr = "SRR12022081"
params.srr = null
params.with_stats = false
params.with_fastqc = false
params.with_fastp = false

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
  publishDir "${params.out}/fastq_files", mode :"copy", overwrite: true
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
    publishDir "${params.out}/stats", mode: "copy", overwrite: true
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

process quality_ctrl {
  publishDir "${params.out}/fastqc", mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/fastqc%3A0.11.7--pl5.22.0_2"
  input:
    path infile
  output:
    path "${infile.baseName}_fastqc.*"
  """
  fastqc ${infile}
  """
// returns _fastqc.html and _fastqc.zip
}

process trimming {
  publishDir "${params.out}/fastp", mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--hadf994f_3"
  input:
    path infile
  output:
    path "${infile.baseName}_fastp.*"
  script:
  """
  fastp -i ${infile} -o ${infile.baseName}_fastp.fastq -j ${infile.baseName}_fastp.json -h ${infile.baseName}_fastp.html
  """
// returns fastp.html and fastp.json
// fastp [options] -i <input_file> -o <output_filename.fasp.fastq>
}

process print_outs {
  publishDir params.out, mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/multiqc%3A1.9--py_1"
  input:
    path trigger_file
  output:
    file "multiqc_{report,data}*"
  script:
  """
  multiqc ${params.out}
  """
}

workflow {
  if(params.srr != null) {
    sra_file = prefetch(Channel.from(params.srr))
  } else {
      print "Error: Please provide SRR: --srr SRR_number"
      System.exit(0)
  }
  fastqfile_channel = splitTOfastq(sra_file) | flatten
  if(params.with_stats) {
    statsFastq(fastqfile_channel)
  }
  if(params.with_fastqc && params.with_fastp) {    
    trim_channel = trimming(fastqfile_channel)
    con_channel = fastqfile_channel.concat(trim_channel).flatten()
    fastq_only_channel = con_channel.filter { file -> file.toString().endsWith('.fastq') }
    quality_ctrl(fastq_only_channel.flatten())
  } else {
  if(params.with_fastqc) {
    quality_ctrl(fastqfile_channel)
  }
  if(params.with_fastp) {
    trimming(fastqfile_channel)
  }
  }

  if(params.with_fastqc || params.with_fastp) {
  trigger_file = fastqfile_channel.first()  // Using a dummy file to trigger the process
  print_outs(trigger_file)
  }
}

// Run command:
// nextflow run ex04_workflow.nf -profile singularity --srr SRR12022081 --with_stats --with_fastqc --with_fastp


// Alternative:
// add when to the processes and let statsFastq and qualtity_ctrl run simultaniously on same input
//   when:
//   params.with_fastqc
//   workflow {
//   prefetch(Channel.from(params.srr)) | splitTOfastq | flatten | (statsFastq & quality_ctrl)
//   }