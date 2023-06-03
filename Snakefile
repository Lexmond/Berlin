from pathlib import Path

data_dir=Path('input')
# prefixes=[p.stem for p in data_dir.glob('sequences_*_*.fasta')]

# Lineages and Segments in input files for Nextalign or Nextclade.
# lineages = ['h1n1pdm', 'h3n2', 'vic', 'yam']
# segments = ['pb2', 'pb1', 'pa', 'ha', 'np', 'na', 'ma', 'ns']


# Genes in output files from Nextalign or Nextclade.
genes    = ['PB2', 'PB1', 'PA', 'HA1', 'NP', 'NA', 'MA', 'NS2'] # any() ????
gene_lookup = {'pb2':'PB2', 'pb1':'PB1', 'pa':'PA', 'ha':'HA1', 'np':'NP', 'na':'NA', 'ma':'MA', 'ns':'NS2'}

def input_func_all():
    l,l2 = [],[]
    for path in list(data_dir.glob("*.fasta"))[:1]:
        _, lineage, segment = path.stem.split('_') # sequences_h1n1pdm_ha.fasta
        l.append(f"_nextalign/output/{lineage}/{segment}/nextalign_gene_{gene_lookup[segment]}.translation.fasta")
        l2.append(f"_nextalign/output/{lineage}/{segment}/nextalign.aligned.fasta" )
    return {"genes_translated" : l, "nt_segments_aligned" : l2 }

wildcard_constraints:
    lineage = "[A-Za-z0-9]{3,7}",
    segment = "[A-Za-z0-9]{2,3}"


# Specify what output files should be generated or what rules to be run.
rule all:
    input: 
       unpack(input_func_all)
        # genes_translated = expand(
        #     f"_nextalign/output/{lineage}/{segment}/nextalign_gene_{gene_lookup[segment]}.translation.fasta" for prefix in prefixes,
        #     lineage=lineages,
        #     segment=segments,
        #     gene=genes
        #     ),
        # nt_segments_aligned = expand(
        #     f"_nextalign/output/{lineage}/{segment}/nextalign.aligned.fasta" for prefix in prefixes,
        #     lineage=lineages,
        #     segment=segments
        #     )




# Run Nextalign on raw nucleotide sequences as downloaded from GISAID
rule nextalign:
    input:     # Run sequences against specified reference datasets in Nextalign.
        sequences           = "input/sequences_{lineage}_{segment}.fasta",
        reference           = "_nextalign/data/flu_{lineage}_{segment}/reference.fasta",
        genemap             = "_nextalign/data/flu_{lineage}_{segment}/genemap.gff"

    output:    # Output files are saved in subfolders per lineage/segment combination.
        genes_translated    = "_nextalign/output/{lineage}/{segment}/nextalign_gene_{gene}.translation.fasta",
        nt_segments_aligned = "_nextalign/output/{lineage}/{segment}/nextalign.aligned.fasta"
    conda:
        "env/nextalign.yaml"
    shell:
        """
        nextalign run \
        --input-ref={input.reference} \
        --input-gene-map={input.genemap} \
        --output-all=output/ \
        {input.sequences}
        """




# Create a table per lineage and segment to output what 
rule get_positions:
    input:
        aa_fasta        = rules.nextalign.output.genes_translated,
        positions_table = 'input/positions_by_lineage_and_segment.xlsx',
        filter_lineage  = '{wildcards.lineage}',
        filter_segment  = '{wildcards.gene}'
    output:
        excel_output    = 'output/aa_at_positions_for_{wildcards.lineage}_{wildcards.gene}.xlsx'
    conda:
        "env/get_position.yaml"
    script:
        "scripts/get_positions.py"


