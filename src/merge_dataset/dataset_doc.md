# Dataset: bilheteria_exibidora_2025.csv

## Descrição

O conjunto de dados **bilheteria_exibidora_2025.csv** contém informações detalhadas sobre sessões de exibição cinematográfica realizadas no Brasil durante o ano de 2025.

Cada registro representa uma sessão específica de exibição de um filme em uma determinada sala de cinema, contendo informações sobre a obra exibida, localização da sala, empresa exibidora e público presente.

O dataset foi gerado a partir da consolidação dos arquivos mensais disponibilizados para análise de bilheteria cinematográfica.

---

## Informações Gerais

| Característica        | Valor                              |
| --------------------- | ---------------------------------- |
| Arquivo               | bilheteria_exibidora_2025.csv    |
| Formato               | CSV                                |
| Número de registros   | 4.014.384                          |
| Número de atributos   | 18                                 |
| Tamanho aproximado    | 1 GB                               |
| Fonte | ANCINE |

---

## Estrutura dos Dados

### DATA_EXIBICAO

Data em que ocorreu a sessão de exibição.

**Tipo:** Data

**Exemplo:**

```text
01/01/2025
```

---

### SESSAO

Data e horário da sessão.

**Tipo:** Data/Hora

**Exemplo:**

```text
01/01/2025 12:30:00
```

---

### TITULO_ORIGINAL

Título original da obra cinematográfica.

**Tipo:** Texto

**Exemplo:**

```text
SONIC THE HEDGEHOG 3
```

---

### TITULO_BRASIL

Título comercial utilizado no Brasil.

**Tipo:** Texto

**Exemplo:**

```text
SONIC 3 - O FILME
```

---

### CPB_ROE

Código de registro da obra junto aos órgãos reguladores do setor audiovisual.

**Tipo:** Texto

**Exemplo:**

```text
E2400387600000
```

---

### AUDIO

Idioma ou modalidade de áudio da sessão.

**Tipo:** Categórico

Possíveis valores:

```text
DUBLADO
ORIGINAL
```

---

### LEGENDADA

Indica se a sessão foi exibida com legendas.

**Tipo:** Categórico

Possíveis valores:

```text
SIM
NÃO
```

---

### PAIS_OBRA

País de origem da obra cinematográfica.

**Tipo:** Texto

**Exemplos:**

```text
BRASIL
CANADÁ
ESTADOS UNIDOS
```

---

### REGISTRO_SALA

Identificador único da sala de exibição.

**Tipo:** Inteiro

**Exemplo:**

```text
5006685
```

---

### NOME_SALA

Nome comercial da sala de cinema.

**Tipo:** Texto

**Exemplo:**

```text
CINELAND 01
```

---

### PUBLICO

Quantidade de espectadores presentes na sessão.

**Tipo:** Inteiro

**Exemplo:**

```text
14
```

---

### REGISTRO_GRUPO_EXIBIDOR

Identificador do grupo exibidor responsável pelo cinema.

**Tipo:** Inteiro

Pode conter valores ausentes.

**Exemplo:**

```text
6000141
```

---

### REGISTRO_EXIBIDOR

Identificador da empresa exibidora.

**Tipo:** Inteiro

**Exemplo:**

```text
49295
```

---

### REGISTRO_COMPLEXO

Identificador do complexo cinematográfico.

**Tipo:** Inteiro

**Exemplo:**

```text
49296
```

---

### MUNICIPIO_SALA_COMPLEXO

Município onde está localizado o complexo de exibição.

**Tipo:** Texto

**Exemplo:**

```text
CAICÓ
```

---

### UF_SALA_COMPLEXO

Unidade Federativa (estado) onde está localizado o complexo.

**Tipo:** Texto

**Exemplo:**

```text
RN
```

---

### RAZAO_SOCIAL_EXIBIDORA

Razão social da empresa responsável pela exibição.

**Tipo:** Texto

**Exemplo:**

```text
CINELAND EXIBICAO CINEMATOGRAFICA LTDA
```

---

### CNPJ_EXIBIDORA

Cadastro Nacional da Pessoa Jurídica da exibidora.

**Tipo:** Texto

**Exemplo:**

```text
42.593.811/0001-93
```

---

## Exemplo de Registro

| Campo                   | Valor               |
| ----------------------- | ------------------- |
| DATA_EXIBICAO           | 01/01/2025          |
| SESSAO                  | 01/01/2025 10:00:00 |
| TITULO_ORIGINAL         | MOANA 2             |
| TITULO_BRASIL           | MOANA 2             |
| CPB_ROE                 | E2400414300000      |
| AUDIO                   | DUBLADO             |
| LEGENDADA               | NÃO                 |
| PAIS_OBRA               | CANADÁ              |
| REGISTRO_SALA           | 5006685             |
| NOME_SALA               | CINELAND 01         |
| PUBLICO                 | 14                  |
| REGISTRO_EXIBIDOR       | 49295               |
| MUNICIPIO_SALA_COMPLEXO | CAICÓ               |
| UF_SALA_COMPLEXO        | RN                  |

---
