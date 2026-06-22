import requests
import pandas

IMDB_URL = "https://api.imdbapi.dev/search/titles?query="

def request_imdb(film: str):
    url = f"{IMDB_URL}{film}"
  
    response = requests.get(url)

    code = response.status_code
    
    if code == 200:
        films = dict(response.json())["titles"]
    else:
        films = [{code, film, "ERROR"}]
        
    return (code, films)