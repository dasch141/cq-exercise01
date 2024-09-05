nextflow.enable.dsl=2

params.out = "$launchDir/output"

process downloadFile {
    publishDir params.out, mode :"copy", overwrite: true
    output:
        path "batch1.fasta"

    """
    wget https://tinyurl.com/cqbatch1 -O batch1.fasta
    """
}

process countSequences {
    publishDir params.out, mode :"copy", overwrite: true
    input:
        path infile
    output:
        path "numseqs.txt"

    """
    grep ">" $infile | wc -l > numseqs.txt
    """
}

process splitSequences {
    publishDir params.out, mode:"copy", overwrite: true
    input:
        path infile
    output:
        path "*"

    """
    split -l 2 -d --additional-suffix=.fasta $infile part_
    """
}

process splitSequencesPython {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "seq_*.fasta"
  """
  python $projectDir/split.py $infile seq_
  """
}

process countBases {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}.basecount"
  """
  grep -v ">" $infile | wc -m > ${infile.getSimpleName()}.basecount
  """
}

workflow {
  downloadFile | splitSequences | flatten | countBases 
}