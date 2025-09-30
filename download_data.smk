#this is a test
# Snakefile for downloading Ostreococcus tauri SRA datasets
# using fasterq-dump
#one more change for github test
# One SRA Id for O.tauri, to add more using edirect later
SAMPLES = [
    "SRR12345678"
]

rule all:
    input:
        expand("data/{sample}.fastq", sample=SAMPLES)

rule download_fastq:
    output:
        "data/{sample}.fastq"
    params:
        #suggested by chatgpt is 4 threads, what should I use when I run this on phoenix?
        extra="--threads 4 --progress --split-files"
    shell:
        """
        fasterq-dump {params.extra} -O data {wildcards.sample}
        # move or rename the output to match the rule expectation
        cat data/{wildcards.sample}*.fastq > {output}
        """
