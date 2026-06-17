# Limpeza e Preparação dos Dados

## Objetivo

Realizar a limpeza e padronização do dataset `bilheteria_exibidora_2025.csv` antes das análises estatísticas sobre a preferência do público brasileiro por filmes nacionais e estrangeiros.

---

# 1. Verificação Inicial da Qualidade dos Dados

Foram realizadas duas verificações iniciais:

## Valores Ausentes (NA)

Identificação da quantidade de valores ausentes por coluna.

```r
colSums(is.na(dataset_bilheteria))
```

Objetivo:

- Identificar campos incompletos.
- Avaliar possíveis impactos na análise.
- Definir estratégias de tratamento.

---

## Strings Vazias

Identificação de campos preenchidos com texto vazio (`""`).

```r
sapply(
  dataset_bilheteria,
  function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE)
)
```

Objetivo:

- Detectar informações ausentes não representadas por `NA`.
- Padronizar o tratamento de dados faltantes.

---

# 2. Correção de Títulos Ausentes

Durante a inspeção dos dados foi observado que alguns registros possuíam o campo `TITULO_BRASIL` preenchido, enquanto o campo `TITULO_ORIGINAL` estava vazio.

Exemplo:

| TITULO_BRASIL | TITULO_ORIGINAL |
|-----------------|---------------|
| O AUTO DA COMPADECIDA 2 | |

Nestes casos, o valor de `TITULO_BRASIL` foi copiado para `TITULO_ORIGINAL`.

```r
TITULO_BRASIL = ifelse(
  is.na(TITULO_BRASIL) | trimws(TITULO_BRASIL) == "",
  TITULO_ORIGINAL,
  TITULO_BRASIL
)
```

### Justificativa
Os filmes sem `TITULO_ORIGINAL`  eram apenas os brasileiros, portanto o `TITULO_ORIGINAL` era o mesmo que `TITULO_BRASIL`.

---

# 3. Identificação de Eventos Não Cinematográficos

Foi identificado que determinados registros apresentavam o campo `PAIS_OBRA` vazio.

Exemplos encontrados:

- Eventos Esportivos
- Jogos Eletrônicos
- Mostras e Festivais
- Shows e Musicais

Esses registros não representam filmes individuais e, portanto, não podem ser classificados adequadamente como obras nacionais ou estrangeiras.

---

# 4. Criação da Variável `TIPO_EXIBICAO`

Foi criada uma nova variável categórica para distinguir filmes de eventos.

### Regra adotada

| Condição | Classificação |
|-----------|---------------|
| PAIS_OBRA preenchido | Filme |
| PAIS_OBRA vazio | Evento |

Implementação:

```r
TIPO_EXIBICAO = ifelse(
  is.na(PAIS_OBRA) | trimws(PAIS_OBRA) == "",
  "Evento",
  "Filme"
)
```

### Objetivo

Permitir que análises futuras possam:

- Considerar apenas filmes;
- Separar eventos de conteúdo cinematográfico;
- Evitar distorções nos indicadores de público e sessões.

---

# 5. Tratamento de Registros Sem Título

Foram identificados 13 registros que apresentavam simultaneamente:

- `TITULO_ORIGINAL` vazio;
- `TITULO_BRASIL` vazio.

Todos esses registros pertenciam à mesma obra:

| Campo | Valor |
|---------|---------|
| CPB_ROE | E1500664500000 |

Verificação realizada:

```r
n_distinct(CPB_ROE)
n_distinct(TITULO_ORIGINAL)
n_distinct(TITULO_BRASIL)
```

Resultado:

| Métrica | Valor |
|----------|----------|
| CPBs distintos | 1 |
| Títulos originais distintos | 1 |
| Títulos brasileiros distintos | 1 |

Concluiu-se que todos os registros pertenciam ao mesmo conteúdo não identificado.

---

# 6. Padronização de Registros Desconhecidos

Os registros sem título foram padronizados da seguinte forma:

| Coluna | Novo Valor |
|----------|----------|
| TITULO_ORIGINAL | DESCONHECIDO |
| TITULO_BRASIL | DESCONHECIDO |
| TIPO_EXIBICAO | DESCONHECIDO |

Implementação:

```r
TITULO_ORIGINAL = "DESCONHECIDO"
TITULO_BRASIL = "DESCONHECIDO"
TIPO_EXIBICAO = "DESCONHECIDO"
```

### Justificativa

Preservar os registros sem introduzir valores ausentes no dataset final.

---

# 7. Remoção de Colunas Não Utilizadas

Foram removidas colunas consideradas irrelevantes para os objetivos da pesquisa.

## Colunas Removidas

| Coluna | Motivo |
|----------|----------|
| REGISTRO_SALA | Identificador técnico da sala |
| NOME_SALA | Nome da sala de exibição |
| REGISTRO_GRUPO_EXIBIDOR | Identificador administrativo |
| REGISTRO_COMPLEXO | Identificador do complexo exibidor |
| CNPJ_EXIBIDORA | Informação cadastral |

Implementação:

```r
select(
  -REGISTRO_SALA,
  -NOME_SALA,
  -REGISTRO_GRUPO_EXIBIDOR,
  -REGISTRO_COMPLEXO,
  -CNPJ_EXIBIDORA
)
```

### Justificativa

Essas variáveis não contribuem para responder à pergunta central da pesquisa:

> Os brasileiros preferem filmes nacionais ou estrangeiros?

Além disso, sua remoção reduz o tamanho do dataset e simplifica as análises.

---

# 8. Verificação Final

Após todas as transformações foram executadas novas verificações para:

- Valores ausentes (`NA`);
- Strings vazias (`""`);
- Estrutura final do dataset.

```r
colSums(is.na(dataset_bilheteria))
```

```r
sapply(
  dataset_bilheteria,
  function(x) sum(trimws(as.character(x)) == "", na.rm = TRUE)
)
```

---

# Estrutura Final do Dataset

Após a limpeza, o conjunto de dados passou a conter as seguintes variáveis:

- DATA_EXIBICAO
- SESSAO
- TITULO_ORIGINAL
- TITULO_BRASIL
- CPB_ROE
- AUDIO
- LEGENDADA
- PAIS_OBRA
- PUBLICO
- REGISTRO_EXIBIDOR
- MUNICIPIO_SALA_COMPLEXO
- UF_SALA_COMPLEXO
- RAZAO_SOCIAL_EXIBIDORA
- TIPO_EXIBICAO

---

# Resultado

Ao final do processo, o dataset encontra-se:

- Padronizado;
- Sem títulos vazios;
- Com eventos identificados;
- Com variáveis administrativas removidas;
- Preparado para análises comparativas entre filmes nacionais e estrangeiros.