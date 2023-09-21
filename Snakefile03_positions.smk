from pathlib import Path

data_dir=Path('input')

gene_lookup = {
    'pb2': 'PB2',
    'pb1': 'PB1',
    'pa': 'PA',
    'ha': 'HA1',
    'np': 'NP',
    'na': 'NA',
    'ma': 'M1',
    'ns': 'NS2'
}

def input_func_all():
    l,l2,l3,l4,l5,l6 = [],[],[],[],[],[]
    for path in list(data_dir.glob("*.fasta")):
        _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
        # Get gene variable from dict.
        gene = gene_lookup[segment]
        l.append(f"output/nextalign/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta")
        l2.append(f"output/nextalign/{lineage}/{segment}/nextalign.aligned.fasta" )
        l3.append(f"output/positions/{lineage}/{segment}/aa_at_positions_for_{gene}.xlsx")
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

input_data = input_func_all()

# Get the dictionary values as lists to expand on using zip later on...
GENES = input_data["gene"]
SEGMENTS = input_data["segment"]
LINEAGES = input_data["lineage"]

rule all:
    input:
        expand("output/positions/{lineage}/{segment}/positions_aa_{lineage}_{gene}.xlsx", zip, lineage=LINEAGES, segment=SEGMENTS, gene=GENES),
        expand("output/positions/{lineage}/ha/positions_clades_aa_{lineage}_HA1.xlsx", zip, lineage=LINEAGES, segment=SEGMENTS)
        # rule_all_input_dict["excel_output"]

# Create a table per lineage and segment to output what 
rule get_positions:
    input:
        aa_fasta        = "output/nextalign/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta",
        # aa_fasta        = rules.nextalign.output.nt_segments_aligned,
        positions_table = "input/positions_by_lineage_and_segment.xlsx"
    output:
        excel_output    = "output/positions/{lineage}/{segment}/positions_aa_{lineage}_{gene}.xlsx"
    # conda:
    #     "env/get_position.yaml"
    script:
        "_scripts/get_positions.py"

rule add_nextclade_data:
    input:
        excel_output = "output/positions/{lineage}/ha/positions_aa_{lineage}_HA1.xlsx",
        nextclade_csv = "output/nextclade/{lineage}/ha/nextclade.csv"
    output:
        excel_with_clades = "output/positions/{lineage}/ha/positions_clades_aa_{lineage}_HA1.xlsx"
    script:
        "_scripts/add_nextclade_data.py"


