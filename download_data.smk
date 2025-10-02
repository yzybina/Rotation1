
# Snakefile for downloading Mamiellales SRA datasets after searching for all SRA entries for this order
# using fasterq-dump

TAXIDS = [
    "296587",   # Micromonas commoda
    "70448",    # Micromonas pusilla CCMP1545
    "41875",    # Ostreococcus tauri
    "564608"    # Bathycoccus prasinos
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

rule download_sra:
    output:
        "data/{sample}.sra"
    shell:
        "prefetch {wildcards.sample} -O data"

rule fastq_from_sra:
    input:
        "data/{sample}.sra"
    output:
        "data/{sample}_1.fastq",
        "data/{sample}_2.fastq"
    shell:
        "fasterq-dump --split-files --threads 4 -O data {input}"

rule metadata:
   output:
       "metadata/{sample}_metadata.tsv"
   shell:
       """
       pysradb metadata {wildcards.sample} --expand > {output}
       """

#fetch runinfo csv file for a given taxid
#runinfo is useful summary but not full metadata that would be needed
rule fetch_runinfo:
    output:
        "results/{taxid}.runinfo.csv"
    shell:
        """
        esearch -db sra -query 'txid{wildcards.taxid}[Organism] AND "biomol rna"[Properties]' \
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