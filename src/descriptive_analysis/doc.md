# Análise Descritiva da Exibição Cinematográfica Brasileira em 2025

## Objetivo

Esta análise tem como objetivo investigar a hipótese:

> "Os brasileiros realmente não gostam de filmes nacionais?"

Para responder essa questão, são analisados dados de exibição cinematográfica de 2025, comparando filmes brasileiros e estrangeiros sob diferentes perspectivas:

- Quantidade de filmes lançados;
- Quantidade de sessões;
- Público total;
- Público médio;
- Distribuição geográfica;
- Horários de exibição;
- Distribuição das sessões;
- Relação entre oferta e público.

---

# Preparação dos Dados

## Classificação da origem dos filmes

Os filmes foram classificados em:

- **Brasileiro:** quando `PAIS_OBRA = "BRASIL"`
- **Estrangeiro:** todos os demais países.

```r
dados <- dados %>%
  mutate(
    ORIGEM = ifelse(
      PAIS_OBRA == "BRASIL",
      "Brasileiro",
      "Estrangeiro"
    )
  )
```

---

## Extração do horário da sessão

O campo `SESSAO` possui data e hora completas.

Exemplo:

```
28/11/2025 23:59:00
```

Foi extraída apenas a hora da sessão para análises temporais.

```r
dados <- dados %>%
  mutate(
    DATA_HORA = dmy_hms(SESSAO),
    HORA = hour(DATA_HORA)
  )
```

---

# Quantidade de Filmes

Perguntas:

- Quantos filmes brasileiros existem?
- Quantos filmes estrangeiros existem?
- Qual a participação de cada grupo?

Foi utilizado:

```r
n_distinct(CPB_ROE)
```

para contar filmes únicos.

---

# Quantidade de Sessões

Perguntas:

- Quantas sessões foram destinadas a filmes nacionais?
- Quantas sessões foram destinadas a filmes estrangeiros?

A análise da quantidade de sessões é importante porque:

> Um filme pode ter pouco público simplesmente porque foi pouco exibido.

---

# Público

Foram calculadas:

- Público total;
- Público médio por sessão;
- Público médio por filme;
- Mediana de público.

Essas medidas permitem diferenciar:

- sucesso comercial;
- ocupação das salas;
- desempenho médio.

---

# Horários das Sessões

Os horários foram analisados para responder:

> Filmes brasileiros recebem horários menos atrativos?

Foram produzidos:

- distribuição dos horários;
- público médio por horário;
- comparação entre filmes brasileiros e estrangeiros.

---

# Distribuição Geográfica

Foram realizadas duas análises:

## Participação do cinema nacional por estado

Pergunta:

> Existem estados que exibem proporcionalmente mais filmes brasileiros?

---

## Participação das sessões por estado

Pergunta:

> Quais estados concentram o mercado exibidor brasileiro?

---

# Número de Sessões por Filme

O número de sessões de cada filme foi calculado:

```r
sessoes = n()
```

Isso permite responder:

- Filmes brasileiros recebem menos sessões?
- A distribuição é desigual?
- Existem poucos sucessos nacionais?

---

# Boxplot

O boxplot mostra:

- mediana;
- quartis;
- dispersão;
- outliers.

Foi utilizada escala logarítmica:

```r
scale_y_log10()
```

pois existem filmes com poucas sessões e blockbusters com milhares.

---

# Gráfico Violino

O gráfico violino complementa o boxplot mostrando:

- concentração da distribuição;
- densidade dos dados.

---

# Dispersão: Sessões × Público Total

Pergunta:

> Filmes brasileiros possuem menos público porque recebem menos sessões?

Cada ponto representa um filme.

Eixos em escala logarítmica:

- número de sessões;
- público total.

A linha de regressão permite observar tendências.

---

# Dispersão: Sessões × Público Médio

Pergunta:

> Filmes com mais sessões mantêm bons níveis de público?

Este gráfico avalia a eficiência da ocupação das sessões.

---

# Mercado Exibidor × Cinema Nacional

Pergunta:

> Estados maiores exibem menos filmes nacionais?

Variáveis:

- Eixo X: participação do estado nas sessões do país;
- Eixo Y: percentual de sessões brasileiras.

A linha horizontal representa a média nacional.

---

# Público Médio por Horário

Pergunta:

> Filmes brasileiros possuem desempenho inferior nos mesmos horários?

A comparação controla parcialmente o efeito do horário da sessão.

---

# Quadrantes de Desempenho

Foram utilizadas transformações logarítmicas:

```r
log10(sessoes)
log10(publico_total)
```

As médias definem quatro quadrantes.

## Superior direito

- muitas sessões;
- muito público.

Filmes de grande sucesso.

---

## Superior esquerdo

- poucas sessões;
- muito público.

Filmes potencialmente subexibidos.

---

## Inferior direito

- muitas sessões;
- pouco público.

Filmes com baixa eficiência comercial.

---

## Inferior esquerdo

- poucas sessões;
- pouco público.

Filmes com baixa visibilidade.

---

# Principais Perguntas da Pesquisa

1. Filmes brasileiros recebem menos sessões?
2. Filmes brasileiros possuem menor público médio?
3. O público médio das sessões é menor?
4. Os filmes nacionais recebem horários piores?
5. Existem estados que valorizam mais o cinema nacional?
6. O desempenho dos filmes nacionais melhora quando recebem mais sessões?
7. O problema está na demanda ou na oferta?

---

# Principais Resultados Esperados

Se os filmes brasileiros:

- recebem poucas sessões;
- aparecem em horários menos competitivos;
- possuem desempenho semelhante aos estrangeiros quando comparados em condições iguais;

então a hipótese:

> "Os brasileiros não gostam de filmes nacionais"

pode ser enfraquecida.

Por outro lado, se:

- recebem quantidade semelhante de sessões;
- ocupam horários equivalentes;
- possuem público consistentemente menor;

a hipótese pode ser fortalecida.

---

# Limitações da Análise

Esta análise não considera:

- orçamento dos filmes;
- campanhas de marketing;
- gênero cinematográfico;
- classificação indicativa;
- presença em franquias;
- número de salas por sessão.

Esses fatores podem influenciar significativamente o público.

---

# Conclusão

Os gráficos produzidos permitem separar dois fatores:

1. **Oferta**
   - quantidade de sessões;
   - horários;
   - distribuição geográfica.

2. **Demanda**
   - público;
   - ocupação das sessões;
   - desempenho dos filmes.
