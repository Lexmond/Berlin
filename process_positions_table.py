import pandas as pd


def process_dataframe(df):
    # Drop columns with only one unique value and column names starting with 'pos'
    columns_to_drop = []
    for col in df.columns:
        if col.startswith('Pos'):
            unique_values = df[col].nunique()
            if unique_values <= 1:
                columns_to_drop.append(col)

    df = df.drop(columns=columns_to_drop)

    # Group rows by sorting similarity of values within 'Pos' columns
    pos_columns = [col for col in df.columns if col.startswith('Pos')]
    df['similarity'] = df[pos_columns].apply(
        lambda row: ''.join(sorted(row)), axis=1)
    df = df.sort_values(by='similarity').drop(
        columns='similarity').reset_index(drop=True)

    return df


# Example usage:
data = {
    'Sequence': ['EPI_ISL_17770545', 'EPI_ISL_18101627', 'EPI_ISL_18101688', 'EPI_ISL_18101691', 'EPI_ISL_18044681', 'EPI_ISL_18219234'],
    'clade': ['6B.1A.5a.2a', '6B.1A.5a.2a', '6B.1A.5a.2a', '6B.1A.5a.2a', '6B.1A.5a.2a', '6B.1A.5a.2a'],
    'Pos 87': ['N', 'N', 'N', 'N', 'N', 'N'],
    'Pos 90': ['C', 'C', 'C', 'C', 'C', 'C'],
    'Pos 91': ['Y', 'Y', 'Y', 'Y', 'Y', 'Y'],
    'Pos 137': ['P', 'P', 'S', 'S', 'S', 'S'],
    'Pos 142': ['K', 'K', 'K', 'R', 'R', 'R'],
    'Pos 216': ['T', 'T', 'T', 'A', 'T', 'T']
}

df = pd.DataFrame(data)
result_df = process_dataframe(df)
print(result_df)
