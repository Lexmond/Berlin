configfile: "config.yaml"

wildcard_constraints:
    lineage = r'h1n1pdm|h3n2|vic|yam',
    segment = r'pb2|pb1|pa|ha|np|na|ma|ns',
    gene = r'HA1|NA'

GENE_LOOKUP = {
    'ha': 'HA1',
    'na': 'NA'
}

from pathlib import Path

input_dir = Path('input')

def input_func_all(segment_list):
    l,l2,l3,l4,l5,l6 = [],[],[],[],[],[]
    for path in list(input_dir.glob("*.fasta")):
        _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
        # Get gene variable from dict.
        if segment in segment_list:
            gene = GENE_LOOKUP[segment]
            l.append(f"output/_nextclade/{lineage}/{segment}/nextclade.tsv")
            l2.append(f"output/_nextclade/{lineage}/{segment}/nextclade.aligned.fasta" )
            l3.append(f"output/_nextclade/{lineage}/{segment}/nextclade_gene_{gene}.translation.fasta")
            l4.append(gene)
            l5.append(segment)
            l6.append(lineage)
    # Return a dictionary
    return {"nextclade_tsv" : l,
            "nextclade_aligned" : l2,
            "nextclade_gene_translated" : l3,
            "gene": l4,
            "segment": l5,
            "lineage": l6}

# Dictionary containing the 6 lists defined above in the function `input_func_all()` for 'HA' and 'NA'.
input_data = input_func_all(['ha', 'na'])

# Get the dictionary values as lists to expand on using zip later on...
SEGMENTS = input_data["segment"]
LINEAGES = input_data["lineage"]

rule all:
    input:
        expand("output/nextclade/{lineage}/{segment}/nextclade.csv", zip, lineage=LINEAGES, segment=SEGMENTS)
        
rule nextclade:
    input:  
        sequences = "input/sequences_{lineage}_{segment}.fasta",
        dataset = "_nextclade/data/flu_{lineage}_{segment}/"
    output: 
        folder = directory("output/nextclade/{lineage}/{segment}"),
        nextclade_csv = "output/nextclade/{lineage}/{segment}/nextclade.csv"
        # aa_fasta = "/output/_nextclade/flu_{lineage}_{segment}/nextclade_gene_{wildcards.gene}.translation.fasta"
    shell:
        """
        nextclade run \
        --input-dataset {input.dataset} \
        --output-all {output.folder} \
        {input.sequences}
        """