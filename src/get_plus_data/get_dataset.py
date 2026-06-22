from pathlib import Path
import pandas

def read_csv(arq: str):
    
    path = Path(__file__).parent.parent.parent / "dataset" / arq
    
    try:
        dataframe = pandas.read_csv(path, sep=";")
        return dataframe
    
    except FileNotFoundError:
        print("Arquivo não encontrado!")
        return None
    
def get_column(dataframe, column_name: str):
    column = dataframe[column_name]
    
    return column

def get_lines(dataframe, key, value):
        return dataframe[dataframe[key] == value]