# Criação do Subdataset de Filmes Exibidos em 2025

## Objetivo

Criar um subconjunto de dados contendo apenas os filmes exibidos nos cinemas brasileiros durante o ano de 2025.

Este subdataset será utilizado como base para a obtenção de informações complementares sobre as obras cinematográficas em fontes externas, como:

* Gênero;
* Duração;
* Ano de lançamento;
* Diretor;
* Classificação indicativa;
* Elenco;
* Produtora;
* País de origem;
* Outras características relevantes para análises posteriores.

---

# Motivação

O dataset original de bilheteria é composto por milhões de registros, onde cada linha representa uma sessão de exibição de um filme.

Consequentemente, um mesmo filme pode aparecer milhares de vezes no conjunto de dados.

Exemplo:

| CPB_ROE        | TITULO_BRASIL |
| -------------- | ------------- |
| E2400414300000 | MOANA 2       |
| E2400414300000 | MOANA 2       |
| E2400414300000 | MOANA 2       |
| E2400414300000 | MOANA 2       |

Para obter informações adicionais sobre cada obra não é necessário manter todas as sessões registradas, sendo suficiente possuir uma única ocorrência de cada filme.

---

# Critério de Seleção

Foram mantidos apenas registros classificados como:

```text
TIPO_EXIBICAO = Filme
```

Registros classificados como:

* Evento;
* Desconhecido;

foram excluídos desta etapa por não representarem obras cinematográficas individuais.

---

# Remoção de Duplicidades

Após a filtragem dos filmes, foram removidas as repetições utilizando os campos:

* CPB_ROE
* TITULO_BRASIL
* TITULO_ORIGINAL
* PAIS_OBRA

O campo `CPB_ROE` atua como identificador único da obra cinematográfica.

Dessa forma, cada filme passa a possuir apenas um registro no novo conjunto de dados.

---

# Implementação

```r
films_2025 <- dataset_bilheteria %>%
  filter(TIPO_EXIBICAO == "Filme") %>%
  distinct(
    CPB_ROE,
    TITULO_BRASIL,
    TITULO_ORIGINAL,
    PAIS_OBRA
  )
```

---

# Estrutura do Subdataset

O arquivo resultante contém as seguintes colunas:

| Coluna          | Descrição                                   |
| --------------- | ------------------------------------------- |
| CPB_ROE         | Identificador único da obra cinematográfica |
| TITULO_BRASIL   | Título utilizado para exibição no Brasil    |
| TITULO_ORIGINAL | Título original da obra                     |
| PAIS_OBRA       | País de origem da produção                  |

---

# Exportação

O subdataset foi armazenado no arquivo:

```text
filmes_exibidos_2025.csv
```

utilizando:

```r
write.csv2(
  films_2025,
  "filmes_exibidos_2025.csv",
  row.names = FALSE
)
```

---

# Resultado Esperado

O arquivo gerado contém uma lista única de todos os filmes exibidos nos cinemas brasileiros em 2025.

---