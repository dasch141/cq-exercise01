nextflow.enable.dsl = 2

params.url = null
params.infile = null
params.out = "$launchDir/output2"
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
        path infile
    output:
        path "sequence_*.fasta"

    script:
    """
    echo -n ">" > ${infile.getSimpleName()}.fasta
    cut -f 1 \${file} | cat >> ${infile.getSimpleName()}.fasta
    cut -f 2 \${file} | cat >> ${infile.getSimpleName()}.fasta
    done
    """
}

process countATG {
    publishDir "${params.out}", mode: 'copy', overwrite: true

    input:
        path infile
    output:
        path "atg_counts.txt"
    script:
    """
    echo -n '' > atg_counts.txt  # Initialize the output file
    grep -o "ATG" $infile | wc -l >> "atg_counts.txt"
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
    splitSeqs(fastaFileProcessed) | flatten | samToFasta() | countATG()
}