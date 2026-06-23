library(dplyr)

# Define área de trabalho
dataset_dir <- Sys.getenv("FILM_DATASET_DIR")
print(dataset_dir)
setwd(dataset_dir)

filmes <- read.csv2(
  "filmes_exibidos_plus.csv"
)

# Remove espaços em branco e converte "" para NA
filmes <- filmes %>%
  mutate(
    ROE = na_if(trimws(ROE), ""),
    CPB = na_if(trimws(CPB), "")
  )

# Se existir ROE, usa ROE.
# Caso contrário, usa CPB.
filmes <- filmes %>%
  mutate(
    CPB_ROE = coalesce(ROE, CPB)
  )

# Remove as colunas antigas
filmes <- filmes %>%
  select(
    -ROE,
    -CPB
  )

head(filmes)

# Salva o novo dataset
write.csv2(
  filmes,
  "filmes_exibidos_plus1.csv",
  row.names = FALSE
)
