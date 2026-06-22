from get_dataset import read_csv, get_column, get_lines
import pandas
from pathlib import Path

if __name__ == "__main__":
    
    path = Path(__file__).parent.parent.parent / "dataset"
    
    dataframe_br = read_csv("filmes_registrados_brasileiros.csv")
    dataframe_es = read_csv("filmes_registrados_estrangeiras.csv")
    dataframe_ex = read_csv("filmes_exibidos_2025.csv")
    
    line = dataframe_es[dataframe_es["ROE"] == "E2400414300000"]
    
    cpb_roes = get_column(
        dataframe=dataframe_ex,
        column_name="CPB_ROE"
    )
    
    dataframe_result = pandas.DataFrame()
    
    for cpb_roe in cpb_roes: 

        line_br = get_lines(dataframe_br, key="CPB", value=cpb_roe)
        line_es = get_lines(dataframe_es, key="ROE", value=cpb_roe)
        
        if not line_br.empty:
            dataframe_result = pandas.concat([dataframe_result, line_br])
        
        if not line_es.empty:
            dataframe_result  = pandas.concat([dataframe_result, line_es])
    
    print(f"Encontrados: {len(dataframe_result)}")
    print(f"Filmes no total: {len(dataframe_ex)}")

    print(dataframe_result.head(5))
    
    dataframe_result.to_csv(path / "filmes_exbidos_plus.csv")