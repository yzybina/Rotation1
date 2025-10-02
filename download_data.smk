# Snakefile for downloading Mamiellales SRA datasets after searching for all SRA entries for this order
# using fasterq-dump

TAXIDS = [
    "296587",   # Micromonas commoda
    "70448",    # Ostreococcus tauri
    "41875",    # Bathycoccus prasinos
    "564608"    # Micromonas pusilla CCMP1545
]

SPECIES = [
    "Micromonas commoda",
    "Ostreococcus tauri",
    "Bathycoccus prasinos",
    "Micromonas pusilla CCMP1545"
]

SAMPLES = [
    "SRR1300453"
]

rule all:
    input:
        expand("data/{sample}_1.fastq", sample=SAMPLES),
        expand("data/{sample}_2.fastq", sample=SAMPLES),
        expand("edirect_results/{taxid}.sra.txt", taxid=TAXIDS),
        expand("metadata/{sample}_metadata.tsv", sample=SAMPLES)

#fetch runinfo csv file for a given taxid
#runinfo is useful summary but not full metadata that would be needed
rule fetch_runinfo:
    output:
        "edirect_results/{taxid}.runinfo.csv"
    params:
        species=lambda wildcards: SPECIES[TAXIDS.index(wildcards.taxid)]

    shell:
        """
        esearch -db sra -query '(txid{wildcards.taxid}[Organism] OR "{params.species}"[All Fields]) AND "biomol rna"[Properties]' \
        | efetch -format runinfo > {output} || true
        """

#extract SRA run accessions from the runinfo csv file
rule extract_srrs:
    input:
        "edirect_results/{taxid}.runinfo.csv"
    output:
        "edirect_results/{taxid}.sra.txt"
    shell:
        """
        cut -d',' -f1 {input} | grep -E '^SRR' > {output} || true
        """

#frefetch SRA files using prefetch
rule download_sra:
    output:
        "data/{sample}.sra"
    shell:
        "prefetch {wildcards.sample} --output-file {output}"

#convert SRA files to paired-end fastq files using fasterq-dump
rule fastq_from_sra:
    input:
        "data/{sample}.sra"
    output:
        "data/{sample}_1.fastq",
        "data/{sample}_2.fastq"
    shell:
        "fasterq-dump --split-files --threads 4 -O data {input}"

#fetch full metadata using pysradb
rule metadata:
   output:
       "metadata/{sample}_metadata.tsv"
   shell:
       """
       pysradb metadata {wildcards.sample} --expand > {output}
       """




