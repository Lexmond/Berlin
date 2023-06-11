# import os

# input_data = "input/sequences_{lineage}_{segment}.fasta"
# lineages, segments, = glob_wildcards(input_data)

# input_all = expand("input/sequences_{lineage}_{segment}.fasta", lineage=set(lineages), segment=set(segments))

# print(f"There are {len(input_all)} inputs")
# print(input_all)

from pathlib import Path

data_dir=Path('input')

gene_lookup = {'pb2':'PB2', 'pb1':'PB1', 'pa':'PA', 'ha':'HA1', 'np':'NP', 'na':'NA', 'ma':'MA', 'ns':'NS2'}

def input_func_all():
    l,l2,l3,l4 = [],[],[],[]
    for path in list(data_dir.glob("*.fasta")):
        _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
        # Get gene variable from dict.
        gene = gene_lookup[segment]
        l.append(f"output/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta")
        l2.append(f"output/{lineage}/{segment}/nextalign.aligned.fasta" )
        l3.append(f"output/aa_at_positions_for_{lineage}_{gene}.xlsx")
        l4.append(gene)
    # Return a dictionary
    return {"genes_translated" : l,
            "nt_segments_aligned" : l2,
            "excel_output" : l3,
            "gene": l4}

# def input_gene():
#     l = []
#     for path in list(data_dir.glob("*.fasta")):
#         _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
#         # Get gene variable from dict.
#         gene = gene_lookup[segment]
#         l.append(gene)
    
#     # Return list of gene.
#     return {"gene": l}

rule_all_input_dict = input_func_all()

print("Variables:")

print(rule_all_input_dict)
# print(expand(rule_all_input_dict["genes_translated"]))
# print(rule_all_input_dict["nt_segments_aligned"])
# print(rule_all_input_dict["excel_output"
# print(rule_all_input_dict["gene"])

rule all:
    input:  
        rule_all_input_dict["nt_segments_aligned"][2]


# Run Nextalign on raw nucleotide sequences as downloaded from GISAID
rule nextalign:
    input:     # Run sequences against specified reference datasets in Nextalign.
        sequences           = "input/sequences_{lineage}_{segment}.fasta",
        reference           = "_nextalign/data/flu_{lineage}_{segment}/reference.fasta",
        genemap             = "_nextalign/data/flu_{lineage}_{segment}/genemap.gff"

    output:    # Output files are saved in subfolders per lineage/segment combination.
        # genes_translated    = "output/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta",
        nt_segments_aligned = "output/{lineage}/{segment}/nextalign.aligned.fasta"
    # conda:
    #     "env/nextalign.yaml"
    shell:
        """
        nextalign run \
        --input-ref={input.reference} \
        --input-gene-map={input.genemap} \
        --output-all=output/{wildcards.lineage}/{wildcards.segment} \
        {input.sequences}
        """