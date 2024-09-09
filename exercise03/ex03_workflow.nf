nextflow.enable.dsl = 2

params.out = "$launchDir/output"

process downloadFile {
    publishDir params.out, mode :"copy", overwrite: true
    output:
        path "seqs_orig.sam"

    """
    wget https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam -O seqs_orig.sam
    """
}

process cutColumns {
    publishDir params.out, mode :"copy", overwrite: true
    input:
        path seqs_orig
    output:
        path "seqs.fasta"

    script:
    """
    cut -f 1,10 $seqs_orig | grep -v "^@" > seqs.fasta
    """
}

workflow {
  filechannel = downloadFile()
  cutColumns(filechannel)
}