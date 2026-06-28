# ==============================================================================
# SCRIPT DE ANÁLISE ESTATÍSTICA: MERCADO EXIBIDOR (2025)
# Disciplina: Probabilidade e Estatística
# ==============================================================================

# Pacotes necessários
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)

# Leitura do dataset
# ==============================================================================
# O CAMINHO DEVE SER SUBSTITUIDO PARA ONDE FOI SALVO O DATASET
# ==============================================================================
dados_brutos <- read.csv2("/home/abstract/program/film_data_analysis/dataset/bilheteria_exibidora_2025_limpo.csv")

# Dicionário de mapeamento regional
mapeamento_regioes <- c(
  "AC" = "Norte", "AP" = "Norte", "AM" = "Norte", "PA" = "Norte", 
  "RO" = "Norte", "RR" = "Norte", "TO" = "Norte",
  "AL" = "Nordeste", "BA" = "Nordeste", "CE" = "Nordeste", "MA" = "Nordeste", 
  "PB" = "Nordeste", "PE" = "Nordeste", "PI" = "Nordeste", "RN" = "Nordeste", 
  "SE" = "Nordeste",
  "DF" = "Centro-Oeste", "GO" = "Centro-Oeste", "MT" = "Centro-Oeste", "MS" = "Centro-Oeste",
  "ES" = "Sudeste", "MG" = "Sudeste", "RJ" = "Sudeste", "SP" = "Sudeste",
  "PR" = "Sul", "RS" = "Sul", "SC" = "Sul"
)

# Limpeza e engenharia de variáveis
dados <- dados_brutos %>% 
  filter(
    TIPO_EXIBICAO == "Filme",
    !is.na(UF_SALA_COMPLEXO), trimws(UF_SALA_COMPLEXO) != "",
    !is.na(SESSAO), trimws(SESSAO) != ""
  ) %>%
  mutate(
    ORIGEM    = factor(ifelse(PAIS_OBRA == "BRASIL", "Brasileiro", "Estrangeiro"), 
                       levels = c("Brasileiro", "Estrangeiro")),
    DATA_HORA = dmy_hms(SESSAO),
    HORA      = hour(DATA_HORA),
    REGIAO    = factor(mapeamento_regioes[UF_SALA_COMPLEXO])
  )

# Cores bases para fator regional 
cores <- c("Brasileiro" = "#1B9E77", "Estrangeiro" = "#D95F02")

# Tema dos gráficos, configuração padrão
tema_abnt <- theme_minimal(base_size = 12) +
  theme(
    legend.position   = "bottom",
    legend.title      = element_text(face = "bold"),
    axis.title        = element_text(face = "bold"),
    axis.text         = element_text(color = "black"),
    plot.title        = element_text(face = "bold", hjust = 0.5, size = 13),
    panel.grid.minor  = element_blank()
  )

#-------- Análise númerica inicial ---------

# Quantidade de filmes e sessões por origem
cat("\n--- ESTRUTURA GERAL DO MERCADO ---\n")
dados %>%
  group_by(ORIGEM) %>%
  summarise(Filmes_Unicos = n_distinct(CPB_ROE), Sessoes_Totais = n(), .groups = "drop") %>%
  print()

# Analise de concentração econômica
cat("\n--- ANÁLISE ECONÔMICA DE CONCENTRAÇÃO DE MERCADO (CR20) ---\n")
sessoes_filme <- dados %>%
  group_by(ORIGEM, CPB_ROE, TITULO_ORIGINAL) %>%
  summarise(sessoes = n(), .groups = "drop") %>% 
  arrange(desc(sessoes))

# 20 filmes mais exibidos
cat("\n---- 20 Filmes Mais Exibidos -----\n")
print(head(sessoes_filme, 20))

# CR20: concentração das sessões
total_mercado_sessoes <- sum(sessoes_filme$sessoes)
soma_top20_sessoes    <- sum(sessoes_filme$sessoes[1:20])
cr_20                 <- (soma_top20_sessoes / total_mercado_sessoes) * 100
cat(paste("Razão de Concentração (CR20):", round(cr_20, 2), "%\n"))



#-------- Análise descritiva ----------

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
  tema_abnt + 
  theme(axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())

# Gráfico 2: Proporção Sessões Totais
sessoes_totais_graf <- dados %>%
  count(ORIGEM) %>%
  mutate(
    percentual = n / sum(n), 
    rotulo = paste0(ORIGEM, "\n", percent(percentual, accuracy = 0.1))
  )

ggplot(sessoes_totais_graf, aes(x = "", y = n, fill = ORIGEM)) +
  geom_col(width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = rotulo), position = position_stack(vjust = 0.5), size = 4.5, fontface = "bold", color = "white") +
  scale_fill_manual(values = cores) +
  labs(fill = "Origem", title = "Gráfico 2: Distribuição percentual de sessões segundo a origem") +
  tema_abnt + 
  theme(axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())

# Gráfico 3: Eficiência Regional (Público Médio por Sessão)
regional_atratividade <- dados %>%
  filter(!is.na(PUBLICO), PUBLICO > 0, !is.na(REGIAO)) %>%
  group_by(REGIAO, ORIGEM) %>%
  summarise(publico_medio = mean(PUBLICO, na.rm = TRUE), .groups = "drop")

ggplot(regional_atratividade, aes(x = REGIAO, y = publico_medio, fill = ORIGEM)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.6, color = "black", size = 0.3) +
  geom_text(aes(label = round(publico_medio, 1)), 
            position = position_dodge(width = 0.75), vjust = -0.5, fontface = "bold", size = 3.5) +
  scale_fill_manual(values = cores) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(x = "Região do Complexo", y = "Público Médio por Sessão", fill = "Origem", title = "Gráfico 3: Eficiência de público por sessão nas macrorregiões") +
  tema_abnt

# Gráfico 4: Eficiência Temporal (Público Médio por Faixa Horária)
publico_hora_eficiencia <- dados %>% 
  filter(!is.na(PUBLICO), PUBLICO > 0) %>%
  group_by(ORIGEM, HORA) %>% 
  summarise(publico_medio = mean(PUBLICO, na.rm = TRUE), .groups = "drop")

ggplot(publico_hora_eficiencia, aes(x = HORA, y = publico_medio, color = ORIGEM)) +
  geom_line(linewidth = 1.2) + 
  geom_point(size = 2.5) +
  scale_color_manual(values = cores) + 
  scale_x_continuous(breaks = seq(0, 23, by = 2)) +
  labs(x = "Horário da Sessão (Hora do Dia)", y = "Público Médio por Sessão", color = "Origem", title = "Gráfico 4: Público médio por sessão ao longo das faixas horárias") +
  tema_abnt

# Gráfico 5: Boxplot de Dispersão e Concentração de Sessões
ggplot(sessoes_filme, aes(x = ORIGEM, y = sessoes, fill = ORIGEM)) +
  geom_boxplot(alpha = 0.8, outlier.shape = NA) +
  geom_point(
    data = sessoes_filme %>% group_by(ORIGEM) %>% filter(sessoes > (quantile(sessoes, 0.75) + 1.5 * IQR(sessoes))),
    aes(x = ORIGEM, y = sessoes), color = "black", size = 1.5, alpha = 0.5
  ) +
  scale_fill_manual(values = cores) + 
  scale_y_log10(labels = scales::comma) +
  labs(x = "Origem da Obra", y = "Sessões por Filme (Escala Logarítmica)", title = "Gráfico 5: Dispersão e assimetria do número de sessões por filme") +
  tema_abnt + 
  theme(legend.position = "none")

# Gráfico 6: Média Bruta Observada de Público 
dados_reais_agrupados <- dados %>%
  filter(!is.na(PUBLICO), PUBLICO > 0) %>%
  group_by(ORIGEM) %>% 
  summarise(publico_real_medio = mean(PUBLICO, na.rm = TRUE), .groups = "drop")

ggplot(dados_reais_agrupados, aes(x = ORIGEM, y = publico_real_medio, fill = ORIGEM)) +
  geom_col(width = 0.5, color = "black", size = 0.4) +
  geom_text(aes(label = round(publico_real_medio, 1)), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_fill_manual(values = cores) + 
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "Nacionalidade da Obra", y = "Público Médio por Sessão", title = "Gráfico 6: Público Médio por Sessão Segundo Origem da Obra") +
  tema_abnt + 
  theme(legend.position = "none")


# --------- TESTES DE HIPÓTESES ---------
cat("\n==== TESTE DE HIPÓTESES PARA MÉDIAS ====\n")
dados_validos <- dados %>% filter(!is.na(PUBLICO), PUBLICO > 0)

cat("\n TESTE F PARA HOMOGENEIDADE DE VARIÂNCIAS:\n")
var.test(PUBLICO ~ ORIGEM, data = dados_validos) %>% print()

cat("\n TESTE T DE AMOSTRAS INDEPENDENTES (Welch):\n")
t.test(PUBLICO ~ ORIGEM, data = dados_validos, alternative = "two.sided", var.equal = FALSE) %>% print()
