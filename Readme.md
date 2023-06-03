# `Project Outline Berlin`


## Objective:

> Make a `Snakemake pipeline` that outputs a dataframe or an Excel sheet that show which amino acid is present at a given position per lineage and segment of influenza viruses. Hereby trying to make a somewhat more flexible tool, so it could also be applied to other lineages than used here such as H5N1 or H7N9 lineages.
>
> FASTA files may contain nucloetide seqeunces from segments of influenza virus subtypes `H1N1pdm`, `H3N2`, `B-Vic` and `B-Yam` downloaded from GISAID.
>
> This FASTA file will first be processed by `Nextclade` (for `HA` & `NA` segments) and `Nextalign` (for `PB2`, `PB1`, `PA`, `NP`, `MA` & `NS` segments). Here, input nucleotide sequences are aligned to their appropriate reference genomes. Translated alignments are truncated to the sequence length representing the viral functional protein.
> 
> `Nextclade` and `Nextalign` both output aligned nucleotide sequences and aligned amino acid sequences that are truncated according to a correct numbering used for annotation.
>
>   **Reference for HA numbering:**<br/>
>Burke DF and Smith DJ (2014) <br/>A standardised numbering for all subtypes of Influenza A hemaggluttin (HA) sequences. <br/>Plos One 9(11): e112302 <br/>DOI: 10.1371/journal.pone.0112302 <br/>[Reference table](https://antigenic-cartography.org/surveillance/evergreen/HAnumbering/)
>
> Python scripts will than process the output files from `Nextclade` and `Nextalign` and finally output tables where rows are represented by the input sequence names and where columns represent correctly numbered amino acids posititions within the analysed segment.

## Input and output files



### INPUT FILES

1. Downloaded FASTA files from GISAID with nucleotide sequences and headers that are formatted like:

```
Isolate ID | Isolate name | Type | Lineage | Segment | Passage details/history | Collection date
```

**Example fasta header:**    
```
>EPI_ISL_342146|A/Netherlands/00322/2019|A_/_H1N1|pdm09|HA|Original|2019-02-06
```

2. Lists of amino acid positions per viral protein sequences grouped by subtype and gene segment.       
    Applying an Excel spreadsheet as a provided input might give more flexibility in use of the final pipeline.


    *Example input table:*

lineage | segment | position
--------|---------|---------
H1N1pdm | HA      | 156
H1N1pdm | HA      | 158
H1N1pdm | HA      | 162
H1N1pdm | NA      | 274
H1N1pdm | PA      | 31
H3N2    | HA      | 145
H3N2    | HA      | 184
H3N2    | HA      | 185
etc...  | etc...  | etc...


3. Datasets that are used for `Nextclade` and `Nextalign`to run:

- **Nextalign input files:**
    - `_nextalign/data/flu_h1n1pdm_pa/genemap.gff`
    - `_nextalign/data/flu_h1n1pdm_pa/reference.fasta`
    - `_nextalign/data/flu_h1n1pdm_pa/sequences.fasta`

<br/>

- **Nextclade input files:**
    - `_nextclade/data/flu_h1n1pdm_ha/primers.cvs`
    - `_nextclade/data/flu_h1n1pdm_ha/genemap.gff`
    - `_nextclade/data/flu_h1n1pdm_ha/qc.json`
    - `_nextclade/data/flu_h1n1pdm_ha/reference.fasta`
    - `_nextclade/data/flu_h1n1pdm_ha/sequences.fasta`
    - `_nextclade/data/flu_h1n1pdm_ha/tag.json`
    - `_nextclade/data/flu_h1n1pdm_ha/tree.json`
    - `_nextclade/data/flu_h1n1pdm_ha/virus_properties.json`







### OUTPUT FILES

- `Nextclade` and `Nextalign` should give outputs in defined folders that are named in convention with their lineage and segment (`output/Nextclade/H1N1/PB1/`).

- **Nextclade output files:**
    - `output/Nextclade/H1N1/HA/nextclade.csv` (Contains additional clade information)
    - `output/Nextclade/H1N1/HA/nextclade.aligned.fasta.fasta`
    - `output/Nextclade/H1N1/HA/nextclade_gene_HA1.translation.fasta`
    - `output/Nextclade/H1N1/HA/nextclade_gene_HA2.translation.fasta`
    - `output/Nextclade/H1N1/HA/nextclade_gene_SigPep.translation.fasta.fasta`

<br/>

 - **Nextalign output files:**
    - `output/Nextalign/H1N1/PA/nextalign.aligned.fasta`
    - `output/Nextalign/H1N1/PA/nextalign_gene_PA.translation.fasta`


2. Dataframe or Excel sheet with listing what amino acids are present for given positions per sequence in the final protein alignments. For HA and NA clades could be included to complement the output data of AA's per position.





## NOTE | Conda Configuration

### Conda set-up within arm-64 installation of conda.
Conda packages are installed within an osx-arm64 architecture (Intel) subdirectory of conda installation that runs osx-arm64 architecture (Apple M1/2).
In order for the `Snakemake`, `Nextclade` and `Nextalign` packages to work, they should run using a Conda environment that supports osx-64 packages.

This is where we tell Conda that we want our environment to use x86 architecture rather than the native ARM64 architecture. We can do that with following lines of code, which create and activate a new conda environment called `berlin`:

```
CONDA_SUBDIR=osx-64 conda create --name berlin python=3.10
conda activate berlin
conda config --env --set subdir osx-64
```

- The first line creates the environment. We simply set the CONDA_SUBDIR environment variable to indicate that conda should create the ennvironment with an osx-64 Python executable. 
- The second line activates the environment, and the third line ensures that conda installs osx-64 versions of packages into the environment.

> This new environment will now be able to use dependencies with osx-64 builds.