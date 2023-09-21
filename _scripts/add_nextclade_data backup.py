import pandas as pd

# Import generated Excel file from rule 'get_positions'
excel_output = snakemake.input.excel_output

# Import generated csv file from 'nextclade'
nextclade_csv = snakemake.input.nextclade_csv

# Set the path and name of the final exported Excel output file.
excel_with_clades = snakemake.output.excel_with_clades


# Read Excel sheet with pandas and store Dataframe in 'xlsx'
xlsx = pd.read_excel(excel_output, sheet_name="Sheet1")

# Read csv sheet with pandas and store Dataframe in 'csv'
csv = pd.read_csv(nextclade_csv, sep=";")

# Get 'seqName' and 'clade' columns from the csv data
csv_name_clade_columns = csv[['seqName', 'clade']]

# Join two df's by sequence name
joined = xlsx.set_index('Sequence').join(
    csv_name_clade_columns.set_index('seqName'))

# Move the 'clade' column so it is next to the sequence name
col = joined.pop('clade')
joined.insert(0, 'clade', col)

# Finally, export the new Excel file with the added clade column.
joined.to_excel(excel_with_clades, sheet_name="Sheet1")
