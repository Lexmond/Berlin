configfile: "config.yaml"

wildcard_constraints:
    lineage = r'h1n1pdm|h3n2|vic|yam',
    segment = r'pb2|pb1|pa|ha|np|na|ma|ns'

from pathlib import Path

data_dir=Path('input')

gene_lookup = config["gene_lookup"]

def input_func_all():
    l,l2,l3,l4,l5,l6 = [],[],[],[],[],[]
    for path in list(data_dir.glob("*.fasta")):
        _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
        # Get gene variable from dict.
        gene = gene_lookup[segment]
        l.append(f"output/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta")
        l2.append(f"output/{lineage}/{segment}/nextalign.aligned.fasta" )
        l3.append(f"output/{lineage}/{segment}/aa_at_positions_for_{gene}.xlsx")
        l4.append(gene)
        l5.append(segment)
        l6.append(lineage)
    # Return a dictionary
    return {"genes_translated" : l,
            "nt_segments_aligned" : l2,
            "excel_output" : l3,
            "gene": l4,
            "segment": l5,
            "lineage": l6}


# Dictionary containing the 6 lists defined above in the function `input_func_all()`
input_data = input_func_all()

# Get the dictionary values as lists to expand on using zip later on...
GENES = input_data["gene"]
SEGMENTS = input_data["segment"]
LINEAGES = input_data["lineage"]


rule all:
    input:
        expand("output/nextalign/{lineage}/{segment}/nextalign.aligned.fasta", zip, lineage=LINEAGES, segment=SEGMENTS)

# Run Nextalign on raw nucleotide sequences as downloaded from GISAID
rule nextalign:
    input:     # Run sequences against specified reference datasets in Nextalign.
        sequences           = "input/sequences_{lineage}_{segment}.fasta",
        reference           = "_nextalign/data/flu_{lineage}_{segment}/reference.fasta",
        genemap             = "_nextalign/data/flu_{lineage}_{segment}/genemap.gff"

    output:    # Output files are saved in subfolders per lineage/segment combination.
        folder = directory("output/nextalign/{lineage}/{segment}"),
        aligned = "output/nextalign/{lineage}/{segment}/nextalign.aligned.fasta"
        # genes_translated    = "output/{lineage}/{segment}/nextalign_gene_{wildcards.gene}.translation.fasta",
        # aligned = directory("output/{wildcards.lineage}/{wildcards.segment}")
        # nt_segments_aligned = "output/{lineage}/{segment}/nextalign.aligned.fasta"
    shell:
        """
        nextalign run \
        --input-ref={input.reference} \
        --input-gene-map={input.genemap} \
        --output-all {output.folder} \
        {input.sequences}
        """