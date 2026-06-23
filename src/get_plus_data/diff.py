import pandas as pd
from get_dataset import read_csv

if __name__ == "__main__":
    dataframe_ex = read_csv("filmes_exibidos_2025.csv")
    new_data_frame = read_csv("filmes_exibidos_plus1.csv")

    diff = dataframe_ex.merge(
        res[["CPB_ROE"]],
        on="CPB_ROE",
        how="left",
        indicator=True
    )

    linhas_faltantes = diff[diff["_merge"] == "left_only"]

    print(linhas_faltantes)