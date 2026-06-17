library(dplyr)

# Carrega variaveis de ambiente 
dataset_dir <- Sys.getenv("FILM_DATASET_DIR")
dataset_path <- Sys.getenv("DATASET_CLEAR_PATH") 
print(dataset_dir)
print(dataset_path)

# Define diretorio de trabalho
setwd(dataset_dir)

# Ler dataset
dataset_bilheteria <- read.csv2(dataset_path)

# Filtra apenas os filmes exibidos
films_2025 <- dataset_bilheteria %>%
  filter(TIPO_EXIBICAO == "Filme") %>%
  distinct(CPB_ROE, TITULO_BRASIL, TITULO_ORIGINAL, PAIS_OBRA)

# Verificacao
nrow(films_2025)
head(films_2025)

# Grava esse dataset
write.csv2(
  films_2025,
  "filmes_exibidos_2025.csv",
  row.names = FALSE
)
