nextflow.enable.dsl = 2

params.url = null
params.infile = null
params.out = "$launchDir/output"
params.temp = "$launchDir/download"
params.name = "seqs_orig"

process downloadFile {
    storeDir params.temp
    input:
        val params.url
    output:
        path "${params.name}.sam"

    """
    wget ${params.url} -O ${params.name}.sam
    """
}

process cutColumns {
    publishDir params.out, mode :"copy", overwrite: true
    input:
        path infile
    output:
        path "seqs.sam"

    script:
    """
    cut -f 1,10 $infile | grep -v "^@" > seqs.sam
    """
}
 process splitSeqs {
    publishDir params.out, mode :"copy", overwrite: true
    input:
        path infile
    output:
        path "sequence_*.sam"
    """
    split -d -l 1 --additional-suffix .sam $infile sequence_
    """
 }

process samToFasta {
    publishDir params.out, mode: "copy", overwrite: true
    input:
        path sam_files
    output:
        path "sequence_*.fasta"

    script:
    """
    for file in ${sam_files}
    do
        base=\$(basename \${file} .sam)
        echo -n ">" > \${base}.fasta
        cut -f 1 \${file} | cat >> \${base}.fasta
        cut -f 2 \${file} | cat >> \${base}.fasta
    done
    """
}

process countATG {
    publishDir "${params.out}", mode: 'copy', overwrite: true

    input:
        path fasta_files

    output:
        path "atg_counts.txt"

    script:
    """
    echo -n '' > atg_counts.txt  # Initialize the output file
    for file in \$(ls -1 $fasta_files)
    do
        count=\$(grep -o 'ATG' \$file | wc -l)
        echo \$file': '\$count >> atg_counts.txt
    done
    """
}


workflow {
    if(params.url != null && params.infile == null) {
        fastafile = downloadFile(Channel.from(params.url))
    } else if(params.infile != null && params.url == null) {
        fastafile = Channel.fromPath(params.infile)
    } else {
        print "Error: Please provide either --url or --infile"
        System.exit(0)
    }
    
    fastaFileProcessed = cutColumns(fastafile)
    splitSeqResults = splitSeqs(fastaFileProcessed)
    samToFastaResults = samToFasta(splitSeqResults)
    countATG(samToFastaResults)
}