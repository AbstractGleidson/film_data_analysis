# ==================================================================
# Mescla os dados de bilheteria cada semana em um arquivo .csv unico
# ==================================================================

library(dplyr)

# Define area de trabalho
dataset_dir <- Sys.getenv("FILM_DATASET_EX_DIR") # pega a variavel de ambiente do dir de trabalho 
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
dados_exibidora <- bind_rows(
  lapply(
    files,
    read.csv2,
    stringsAsFactors = FALSE 
  )
)

# Verifica o dataset lido os arquivos em files
head(dados_exibidora)
names(dados_exibidora)
length(dados_exibidora)
nrow(dados_exibidora)

# Salva o dataset merge em um arquivo .csv
write.csv2(
  dados_exibidora,
  "bilheteria_exibidora_2025.csv",
  row.names = FALSE
)
