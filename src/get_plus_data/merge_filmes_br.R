# ==================================================================
# Mescla os dados de bilheteria cada semana em um arquivo .csv unico
# ==================================================================

library(dplyr)

# Define area de trabalho
dataset <- Sys.getenv("FILM_DATASET_DIR_BR") # pega a variavel de ambiente do dir de trabalho 
print(dataset_dir) # Verifica de carregou corretamente 
setwd(dataset_dir)

# Pega todos os caminhos dos arquivos .csv
files <- list.files(
  pattern = "\\.csv$", 
  full.names = TRUE
)

# Verifica os cominhos 
length(files)
head(files)

# Ler todos os arquivos em files e cria um dataset unico
dados_filmes_registrados <- bind_rows(
  lapply(
    files,
    read.csv2,
    stringsAsFactors = FALSE 
  )
)

# Verifica o dataset lido os arquivos em files
head(dados_filmes_registrados)
names(dados_filmes_registrados)
length(dados_filmes_registrados)
nrow(dados_filmes_registrados)

# Salva o dataset merge em um arquivo .csv
write.csv2(
  dados_filmes_registrados,
  "filmes_registrados_brasileiros.csv",
  row.names = FALSE
)
