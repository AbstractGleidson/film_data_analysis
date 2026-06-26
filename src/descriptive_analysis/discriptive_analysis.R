# ==============================================================================
# SCRIPT DE ANÁLISE ESTATÍSTICA: MERCADO EXIBIDOR DO CINEMA (2025)
# Disciplina: Probabilidade e Estatística - UFPI
# ==============================================================================

# Carregando pacotes
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)
library(lmtest)

# Configuração do diretório de trabalho
dataset_dir <- Sys.getenv("FILM_DATASET_DIR")
if(dataset_dir == "") stop("Variável de ambiente FILM_DATASET_DIR não definida.")
setwd(dataset_dir)

# Carga do conjunto de dados bruto
dados <- read.csv2("bilheteria_exibidora_2025_limpo.csv")

# Tratamento de dados e criação de variáveis suporte
dados <- dados %>% 
  filter(TIPO_EXIBICAO == "Filme") %>% 
  filter(!is.na(UF_SALA_COMPLEXO) & trimws(UF_SALA_COMPLEXO) != "")

dados <- dados %>%
  filter(!is.na(SESSAO) & trimws(SESSAO) != "") %>%
  mutate(
    ORIGEM = ifelse(PAIS_OBRA == "BRASIL", "Brasileiro", "Estrangeiro"),
    DATA_HORA = dmy_hms(SESSAO),
    HORA = hour(DATA_HORA)
  )

# Criação das variáveis de interesse temporal e demográfico
dados <- dados %>%
  mutate(
    ORIGEM = ifelse(PAIS_OBRA == "BRASIL", "Brasileiro", "Estrangeiro"),
    DATA_HORA = dmy_hms(SESSAO),
    HORA = hour(DATA_HORA)
  )

# Dicionário para as regiões
regioes <- c(
  "AC"="Norte", "AP"="Norte", "AM"="Norte", "PA"="Norte", "RO"="Norte", "RR"="Norte", "TO"="Norte",
  "AL"="Nordeste", "BA"="Nordeste", "CE"="Nordeste", "MA"="Nordeste", "PB"="Nordeste", "PE"="Nordeste", "PI"="Nordeste", "RN"="Nordeste", "SE"="Nordeste",
  "DF"="Centro-Oeste", "GO"="Centro-Oeste", "MT"="Centro-Oeste", "MS"="Centro-Oeste",
  "ES"="Sudeste", "MG"="Sudeste", "RJ"="Sudeste", "SP"="Sudeste",
  "PR"="Sul", "RS"="Sul", "SC"="Sul"
)
dados$REGIAO <- regioes[dados$UF_SALA_COMPLEXO]

# Identidade visual para os gráficos
cores <- c("Brasileiro" = "#1B9E77", "Estrangeiro" = "#D95F02")

# Tema customizado estruturado sob as normas da ABNT
tema_abnt <- theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "black"),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 13),
    panel.grid.minor = element_blank()
  )


#========= ANÁLISE NUMÉRICA INICIAL =========
cat("\n--- ESTRUTURA GERAL DO MERCADO ---\n")
filmes_resumo <- dados %>%
  group_by(ORIGEM) %>%
  summarise(
    filmes = n_distinct(CPB_ROE),
    sessoes = n(),
    .groups = "drop"
  )
print(filmes_resumo)

cat("\n--- COMPORTAMENTO HORÁRIO: MAIORES PÚBLICOS MÉDIOS ---\n")
publico_hora_num <- dados %>%
  group_by(ORIGEM, HORA) %>%
  summarise(publico_medio = mean(PUBLICO, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(publico_medio))
print(head(publico_hora_num, 5))

cat("\n--- ANÁLISE ECONÔMICA DE CONCENTRAÇÃO DE MERCADO (CR20) ---\n")
sessoes_filme <- dados %>%
  group_by(ORIGEM, CPB_ROE, TITULO_ORIGINAL) %>%
  summarise(sessoes = n(), .groups = "drop") %>% 
  arrange(desc(sessoes))

total_mercado_sessoes <- sum(sessoes_filme$sessoes)
soma_top20_sessoes <- sum(sessoes_filme$sessoes[1:20])
cr_20 <- (soma_top20_sessoes / total_mercado_sessoes) * 100
cat(paste("Razão de Concentração (CR20):", round(cr_20, 2), "%\n"))


#========= ANÁLISE DESCRITIVA GRÁFICA =========
# Gráfico 1: Proporção Filmes Únicos
filmes_origem <- dados %>%
  group_by(ORIGEM) %>%
  summarise(quantidade = n_distinct(CPB_ROE), .groups = "drop") %>%
  mutate(percentual = quantidade / sum(quantidade),
         rotulo = paste0(ORIGEM, "\n", percent(percentual, accuracy = 0.1)))

ggplot(filmes_origem, aes(x = "", y = quantidade, fill = ORIGEM)) +
  geom_col(width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = rotulo), position = position_stack(vjust = 0.5), size = 4.5, fontface = "bold", color = "white") +
  scale_fill_manual(values = cores) +
  labs(fill = "Origem", title = "Gráfico 1: Distribuição percentual de títulos segundo a origem") +
  tema_abnt + theme(axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())


# Gráfico 2: Proporção Sessões Totais
sessoes_totais_graf <- dados %>%
  count(ORIGEM) %>%
  mutate(percentual = n / sum(n), rotulo = percent(percentual, accuracy = 0.1))

ggplot(sessoes_totais_graf, aes(x = "", y = n, fill = ORIGEM)) +
  geom_col(width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = rotulo), position = position_stack(vjust = 0.5), size = 4.5, fontface = "bold", color = "white") +
  scale_fill_manual(values = cores) +
  labs(fill = "Origem", title = "Gráfico 2: Distribuição percentual de sessões segundo a origem") +
  tema_abnt + theme(axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())


# Gráfico 3: Participação Percentual Regional
regional_pct <- dados %>%
  group_by(REGIAO, ORIGEM) %>%
  summarise(sessoes = n(), .groups = "drop") %>%
  group_by(REGIAO) %>%
  mutate(percentual = 100 * sessoes / sum(sessoes))

ggplot(regional_pct, aes(x = REGIAO, y = percentual, fill = ORIGEM)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(round(percentual, 1), "%")), position = position_dodge(width = 0.8), vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = cores) +
  labs(x = "Região", y = "Participação das sessões (%)", fill = "Origem", title = "Gráfico 3: Distribuição regional de sessões segundo origem da obra") +
  tema_abnt


# Gráfico 4: Séries Temporais por Horário da Sessão
sessoes_hora <- dados %>% group_by(ORIGEM, HORA) %>% summarise(sessoes = n(), .groups = "drop")
ggplot(sessoes_hora, aes(x = HORA, y = sessoes, color = ORIGEM)) +
  geom_line(linewidth = 1.2) + geom_point(size = 3) +
  scale_color_manual(values = cores) + scale_y_continuous(labels = scales::comma) +
  labs(x = "Horário da Sessão", y = "Número de Sessões", color = "Origem", title = "Gráfico 4: Quantidade de sessões por faixa horária") +
  tema_abnt


# Gráfico 5: Boxplot de Dispersão de Sessões com Outliers Mapeados
ggplot(sessoes_filme, aes(x = ORIGEM, y = sessoes, fill = ORIGEM)) +
  geom_boxplot(alpha = 0.8, outlier.shape = NA) +
  geom_point(
    data = sessoes_filme %>% group_by(ORIGEM) %>% filter(sessoes > (quantile(sessoes, 0.75) + 1.5 * IQR(sessoes))),
    aes(x = ORIGEM, y = sessoes), color = "black", size = 1.5, alpha = 0.5
  ) +
  scale_fill_manual(values = cores) + scale_y_log10(labels = scales::comma) +
  labs(x = "Origem da Obra", y = "Sessões por Filme (Escala Logarítmica)", title = "Gráfico 5: Dispersão e assimetria do número de sessões por filme") +
  tema_abnt + theme(legend.position = "none")


# Gráfico 6: Média Bruta Observada de Público 
dados_reais_agrupados <- dados %>%
  filter(!is.na(PUBLICO) & PUBLICO > 0 & ORIGEM %in% c("Brasileiro", "Estrangeiro")) %>%
  group_by(ORIGEM) %>% summarise(publico_real_medio = mean(PUBLICO, na.rm = TRUE), .groups = "drop")

ggplot(dados_reais_agrupados, aes(x = ORIGEM, y = publico_real_medio, fill = ORIGEM)) +
  geom_col(width = 0.5, color = "black", size = 0.4) +
  geom_text(aes(label = round(publico_real_medio, 1)), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_fill_manual(values = cores) + scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "Nacionalidade da Obra", y = "Público Médio por Sessão", title = "Gráfico 6: Público Médio por Sessão Segundo Origem da Obra") +
  tema_abnt + theme(legend.position = "none")


#======== TESTES DE HIPÓTESES / INFERÊNCIA ========= 
cat("\n==== TESTE DE HIPÓTESES PARA MÉDIAS ====\n")

# Isolamento amostral 
dados_validos <- dados %>% filter(!is.na(PUBLICO) & PUBLICO > 0 & ORIGEM %in% c("Brasileiro", "Estrangeiro"))
cat("\n TESTE F PARA HOMOGENEIDADE DE VARIÂNCIAS:\n")
teste_variancia <- var.test(PUBLICO ~ ORIGEM, data = dados_validos)
print(teste_variancia)

cat("\n TESTE T DE SAMPLES INDEPENDENTES:\n")
teste_t_final <- t.test(PUBLICO ~ ORIGEM, data = dados_validos, alternative = "two.sided", var.equal = FALSE)
print(teste_t_final)


#======== REGRESSÃO LINEAR MULTIVARIÁVEL ==========
cat("EXECUTANDO MODELAGEM POR REGRESSÃO E DIAGNÓSTICO DE RESÍDUOS\n")

set.seed(42) # Assegura reprodutibilidade amostral

# Amostragem Estratificada para diminuir o esforço computacional
dados_reg <- dados %>%
  filter(!is.na(PUBLICO) & !is.na(HORA) & !is.na(REGIAO) & PUBLICO > 0) %>%
  mutate(
    ORIGEM = factor(ORIGEM, levels = c("Brasileiro", "Estrangeiro")),
    REGIAO = factor(REGIAO),
    HORA = factor(HORA),
    log_publico = log(PUBLICO)
  ) %>%
  group_by(ORIGEM) %>%
  slice_sample(n = 100000, replace = FALSE) %>% # Amostra representativa robusta
  ungroup()

# Ajuste por Mínimos Quadrados Ordinários (MQO)
modelo <- lm(log_publico ~ ORIGEM + HORA + REGIAO, data = dados_reg)
print(summary(modelo))

cat("\n--- DIAGNÓSTICO DE PRESSUPOSTOS DA REGRESSÃO  ---\n")
# Verificação Gráfica 
par(mfrow = c(2, 2))
plot(modelo)
par(mfrow = c(1, 1))

# Teste de Homocedasticidade de Breusch-Pagan 
cat("\nTeste de Breusch-Pagan:\n")
print(bptest(modelo))

# Teste de Independência de Resíduos de Durbin-Watson 
cat("\nTeste de Durbin-Watson:\n")
print(dwtest(modelo))

# Diagnóstico de Observações Influenciantes através da Distância de Cook 
cat("\nSumário Descritivo da Distância de Cook (Valores > 0.4 indicam anomalias):\n")
dist_cook <- cooks.distance(modelo)
print(summary(dist_cook))


# Construção gráfica com base nos dados previstos 
fator_smearing <- mean(exp(residuals(modelo)))
dados_reg$publico_previsto <- exp(predict(modelo)) * fator_smearing

previsto_graf <- dados_reg %>%
  group_by(ORIGEM) %>%
  summarise(publico_esperado = mean(publico_previsto), .groups = "drop")

ggplot(previsto_graf, aes(x = ORIGEM, y = publico_esperado, fill = ORIGEM)) +
  geom_col(width = 0.5, color = "black", size = 0.4) +
  geom_text(aes(label = round(publico_esperado, 1)), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_fill_manual(values = cores) + scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "Nacionalidade da Obra", y = "Público Esperado por Sessão (Modelo)", 
       title = "Gráfico 7: Efeitos marginais previstos para o público esperado por sessão") +
  tema_abnt + theme(legend.position = "none")
