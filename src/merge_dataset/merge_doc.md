# Mesclagem de Arquivos CSV da Bilheteria de Exibição

## Objetivo

Este script tem como objetivo consolidar diversos arquivos CSV contendo dados mensais de bilheteria de exibição cinematográfica em um único conjunto de dados, facilitando análises estatísticas e exploração dos dados ao longo do ano.

---

## Dependências

O script utiliza o pacote `dplyr` para realizar a concatenação dos dados.

```r
library(dplyr)
```
---

## Variável de ambiente

Todos os arquivos CSV devem estar localizados no diretório apontado pela variável de ambiente:

```text
FILM_DATASET_EX_DIR
```

Todos os arquivos devem possuir o mesmo conjunto de colunas.

---

## Funcionamento do Script

### 1. Carregamento da variável de ambiente

Obtém o diretório onde os arquivos CSV estão armazenados.

```r
dataset_dir <- Sys.getenv("FILM_DATASET_EX_DIR")
```

Em seguida, define o diretório de trabalho:

```r
setwd(dataset_dir)
```

---

### 2. Localização dos arquivos CSV

Lista todos os arquivos com extensão `.csv` presentes no diretório atual.

```r
files <- list.files(
  pattern = "\\.csv$",
  full.names = TRUE
)
```

Parâmetros utilizados:

| Parâmetro           | Descrição                                     |
| ------------------- | --------------------------------------------- |
| `pattern="\\.csv$"` | Seleciona apenas arquivos com extensão `.csv` |
| `full.names=TRUE`   | Retorna o caminho completo dos arquivos       |

---

### 3. Leitura e união dos arquivos

Todos os arquivos são carregados utilizando `read.csv2()` e armazenados em um único data frame.

```r
dados_exibidora <- bind_rows(
  lapply(
    files,
    read.csv2,
    stringsAsFactors = FALSE
  )
)
```

Processo executado:

1. Percorre todos os arquivos encontrados.
2. Lê cada arquivo CSV.
3. Armazena os resultados em uma lista.
4. Concatena todas as linhas utilizando `bind_rows()`.

---

### 4. Exportação do conjunto consolidado

Salva o resultado da mesclagem em um único arquivo CSV.

```r
write.csv2(
  dados_exibidora,
  "bilheteria_exibidora_2025.csv",
  row.names = FALSE
)
```

Arquivo gerado:

```text
bilheteria_exibidora_2025.csv
```

---

## Resultado

Ao final da execução, será gerado um único arquivo contendo todos os registros dos arquivos mensais:

```text
bilheteria_exibidora_2025.csv
```