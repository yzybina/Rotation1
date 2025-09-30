#this is a test
# Snakefile for downloading Ostreococcus tauri SRA datasets
# using fasterq-dump

# List of accession IDs for O. tauri (replace with your own IDs)
SAMPLES = [
    "SRR12345678",
    "SRR12345679"
]

rule all:
    input:
        expand("data/{sample}.fastq", sample=SAMPLES)

rule download_fastq:
    output:
        "data/{sample}.fastq"
    params:
        # you can add options like --split-files for paired-end
        extra="--threads 4 --progress"
    shell:
        """
        fasterq-dump {params.extra} -O data {wildcards.sample}
        # move or rename the output to match the rule expectation
        cat data/{wildcards.sample}*.fastq > {output}
        """
