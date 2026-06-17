library(dplyr)

# Carrega variaveis de ambiente 
dataset_dir <- Sys.getenv("FILM_DATASET_DIR")
dataset_path <- Sys.getenv("DATASET_PATH") 
print(dataset_dir)
print(dataset_path)

# Define diretorio de trabalho
setwd(dataset_dir)

# Ler dataset
dataset_bilheteria <- read.csv2(dataset_path)

# Verifica colunas com dados NAN
nan_columns <- colSums(is.na(dataset_bilheteria))
print(nan_columns)

# Verifica colunas com dados vazios
empty_columns <- sapply(
  dataset_bilheteria,
  function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE)
)
print(empty_columns)

# Copia o valor de "TITULO_BRASIL" para "TITULO_ORIGINAL"
# Resolvendo problema de "TITULO_ORIGINAL" vazio
dataset_bilheteria <- dataset_bilheteria %>%
  mutate(
    TITULO_BRASIL = ifelse(
      is.na(TITULO_BRASIL) | trimws(TITULO_BRASIL) == "",
      TITULO_ORIGINAL,
      TITULO_BRASIL
    )
  )

# Verifica resultado da correção
empty_columns <- sapply(
  dataset_bilheteria,
  function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE)
)
print(empty_columns)

# Recorta o dataset pegando apenas as linhas com pais vazio
empty_country <- dataset_bilheteria[trimws(dataset_bilheteria$PAIS_OBRA) == "",]
head(empty_country)
nrow(empty_country)

# Verifica se as linhas com pais vazio sao eventos
dataset_bilheteria %>%
  filter(
    is.na(PAIS_OBRA) |
      trimws(PAIS_OBRA) == ""
  ) %>%
  distinct(TITULO_BRASIL) %>%
  arrange(TITULO_BRASIL)

# Classifica tipo de exibição em filme ou evento
dataset_bilheteria <- dataset_bilheteria %>%
  mutate(
    TIPO_EXIBICAO = ifelse(
      is.na(PAIS_OBRA) | trimws(PAIS_OBRA) == "",
      "Evento",
      "Filme"
    )
  )

head(dataset_bilheteria)

# Linhas sem titulo
empty_title <- dataset_bilheteria %>%
  filter(
    (is.na(TITULO_ORIGINAL) | trimws(TITULO_ORIGINAL) == "") &
      (is.na(TITULO_BRASIL) | trimws(TITULO_BRASIL) == "")
  )
print(empty_title)

# Verifica se as obras sem titulo sao a mesma
dataset_bilheteria %>%
  filter(CPB_ROE == "E1500664500000") %>%
  summarise(
    n_cpb = n_distinct(CPB_ROE),
    n_titulo_original = n_distinct(TITULO_ORIGINAL),
    n_titulo_brasil = n_distinct(TITULO_BRASIL)
  )

# Torna obras sem titulo, como "DESCONHECIDO"
dataset_bilheteria <- dataset_bilheteria %>%
  mutate(
    TITULO_ORIGINAL = ifelse(
      trimws(TITULO_ORIGINAL) == "",
      "DESCONHECIDO",
      TITULO_ORIGINAL
    ),
    TITULO_BRASIL = ifelse(
      trimws(TITULO_BRASIL) == "",
      "DESCONHECIDO",
      TITULO_BRASIL
    ),
    TIPO_EXIBICAO = ifelse(
      TITULO_BRASIL == "DESCONHECIDO",
      "DESCONHECIDO",
      TIPO_EXIBICAO
    )
  )

# Verifica se ainda tem titulos vazios
sum(trimws(dataset_bilheteria$TITULO_ORIGINAL) == "")
sum(trimws(dataset_bilheteria$TITULO_BRASIL) == "")

# Removendo colunas desnecessarias:
# REGISTRO_SALA
# NOME_SALA
# REGISTRO_GRUPO_EXIBIDOR
# REGISTRO_COMPLEXO
# CNPJ_EXIBIDORA
dataset_bilheteria <- dataset_bilheteria %>%
  select(
    -REGISTRO_SALA,
    -NOME_SALA,
    -REGISTRO_GRUPO_EXIBIDOR,
    -REGISTRO_COMPLEXO,
    -CNPJ_EXIBIDORA
  )

# Verificação final do dataset 
head(dataset_bilheteria)
names(dataset_bilheteria)

nan_columns <- colSums(is.na(dataset_bilheteria))
print(nan_columns)

# Verifica resultado da correção
empty_columns <- sapply(
  dataset_bilheteria,
  function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE)
)
print(empty_columns)

# Salva dataset limpo
write.csv2(
  dataset_bilheteria,
  "bilheteria_exibidora_2025_limpo.csv",
  row.names = FALSE
)