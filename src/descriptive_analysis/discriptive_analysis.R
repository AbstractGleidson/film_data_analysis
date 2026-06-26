library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)

# Define area de trabalho
dataset <- Sys.getenv("FILM_DATASET_DIR") # pega a variavel de ambiente do dir de trabalho 
print(dataset_dir) # Verifica de carregou corretamente 
setwd(dataset_dir)

dados <- read.csv2("bilheteria_exibidora_2025_limpo.csv")

# Cria variável origem
dados <- dados %>%
  mutate(
    ORIGEM = ifelse(
      PAIS_OBRA == "BRASIL",
      "Brasileiro",
      "Estrangeiro"
    )
  )

# Quantidade de filmes brasileiros
filmes_brasileiros <- dados %>%
  filter(ORIGEM == "Brasileiro") %>%
  summarise(
    filmes = n_distinct(CPB_ROE)
  )

filmes_brasileiros

# Quantidade de filmes estranjeiros
filmes_estrangeiros <- dados %>%
  filter(ORIGEM == "Estrangeiro") %>%
  summarise(
    filmes = n_distinct(CPB_ROE)
  )

filmes_estrangeiros

# Quantidade total de filmes 
dados %>%
  summarise(
    total = n_distinct(CPB_ROE)
  )


# Quantidade de filmes por origem
filmes_origem <- dados %>%
  group_by(ORIGEM) %>%
  summarise(
    quantidade = n_distinct(CPB_ROE)
  ) %>%
  mutate(
    porcentagem = quantidade / sum(quantidade),
    rotulo = paste0(
      ORIGEM,
      "\n",
      percent(porcentagem, accuracy = 0.1)
    )
  )

ggplot(
  filmes_origem,
  aes(
    x = "",
    y = quantidade,
    fill = ORIGEM
  )
) +
  geom_col(
    width = 1,
    color = "white"
  ) +
  coord_polar("y") +
  geom_text(
    aes(label = rotulo),
    position = position_stack(vjust = 0.5),
    size = 5
  ) +
  theme_void() +
  labs(
    title = "Quantidade de filmes por origem"
  ) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    legend.position = "right"
  )

# Extrai a hora corretamente
dados <- dados %>%
  mutate(
    DATA_HORA = dmy_hms(SESSAO),
    HORA = hour(DATA_HORA)
  )

# ===============================
# FILMES BRASILEIROS
# ===============================

horarios_br <- dados %>%
  filter(ORIGEM == "Brasileiro") %>%
  count(HORA) %>%
  mutate(
    percentual = 100 * n / sum(n)
  ) %>%
  arrange(desc(n))

top5_br <- horarios_br$HORA[1:5]

horarios_br <- horarios_br %>%
  mutate(
    destaque = ifelse(
      HORA %in% top5_br,
      "Top 5",
      "Demais"
    )
  )

ggplot(
  horarios_br,
  aes(
    x = factor(HORA),
    y = percentual,
    fill = destaque
  )
) +
  geom_col() +
  geom_text(
    aes(
      label = paste0(round(percentual, 1), "%")
    ),
    vjust = -0.3,
    size = 3.5
  ) +
  scale_fill_manual(
    values = c(
      "Top 5" = "steelblue",
      "Demais" = "gray75"
    )
  ) +
  labs(
    title = "Distribuição dos horários das sessões brasileiras",
    x = "Horário",
    y = "Percentual das sessões (%)",
    fill = ""
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    )
  )

# ===============================
# FILMES ESTRANGEIROS
# ===============================

horarios_est <- dados %>%
  filter(ORIGEM == "Estrangeiro") %>%
  count(HORA) %>%
  mutate(
    percentual = 100 * n / sum(n)
  ) %>%
  arrange(desc(n))

top5_est <- horarios_est$HORA[1:5]

horarios_est <- horarios_est %>%
  mutate(
    destaque = ifelse(
      HORA %in% top5_est,
      "Top 5",
      "Demais"
    )
  )

ggplot(
  horarios_est,
  aes(
    x = factor(HORA),
    y = percentual,
    fill = destaque
  )
) +
  geom_col() +
  geom_text(
    aes(
      label = paste0(round(percentual, 1), "%")
    ),
    vjust = -0.3,
    size = 3.5
  ) +
  scale_fill_manual(
    values = c(
      "Top 5" = "firebrick",
      "Demais" = "gray75"
    )
  ) +
  labs(
    title = "Distribuição dos horários das sessões estrangeiras",
    x = "Horário",
    y = "Percentual das sessões (%)",
    fill = ""
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    )
  )

# Proporcoes das sessoes
sessoes <- dados %>%
  count(ORIGEM) %>%
  mutate(
    percentual = n / sum(n),
    rotulo = percent(
      percentual,
      accuracy = 0.1
    )
  )

ggplot(
  sessoes,
  aes(
    x = "",
    y = n,
    fill = ORIGEM
  )
) +
  geom_col(
    width = 1,
    color = "white"
  ) +
  coord_polar("y") +
  geom_text(
    aes(label = rotulo),
    position = position_stack(vjust = 0.5),
    size = 6,
    fontface = "bold"
  ) +
  labs(
    title = "Percentual das sessões por origem",
    fill = "Origem"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    legend.position = "right",
    legend.title = element_text(
      face = "bold"
    )

total_sessoes <- sum(sessoes$n)

cat("Quantidade de sessões brasileiras:", sessoes$n[sessoes$ORIGEM == "Brasileiro"], "\n")
cat("Quantidade de sessões estrangeiras:", sessoes$n[sessoes$ORIGEM == "Estrangeiro"], "\n")
cat("Quantidade total de sessões:",total_sessoes,"\n")

# Publico medio por sessao
dados %>%
  group_by(ORIGEM) %>%
  summarise(
    publico_medio = mean(PUBLICO)
  )

# Publico total 
dados %>%
  group_by(ORIGEM) %>%
  summarise(
    publico_total = sum(PUBLICO)
  )

# Publico por filme
dados %>%
  group_by(ORIGEM, CPB_ROE) %>%
  summarise(
    publico = sum(PUBLICO),
    .groups = "drop"
  ) %>%
  group_by(ORIGEM) %>%
  summarise(
    media_publico_filme = mean(publico)
  )

# Ocupacao media das sessoes
dados %>%
  group_by(ORIGEM) %>%
  summarise(
    publico_sessao = mean(PUBLICO),
    mediana = median(PUBLICO)
  )

# Estados que mais exibem filmes nacionais 
estados <- dados %>%
  group_by(UF_SALA_COMPLEXO) %>%
  summarise(
    total = n(),
    brasileiras = sum(ORIGEM == "Brasileiro"),
    percentual = 100 * brasileiras / total,
    .groups = "drop"
  ) %>%
  arrange(desc(percentual))

ggplot(
  estados,
  aes(
    x = reorder(UF_SALA_COMPLEXO, percentual),
    y = percentual,
    fill = percentual
  )
) +
  geom_col(width = 0.8) +
  geom_text(
    aes(
      label = paste0(
        round(percentual, 1),
        "%"
      )
    ),
    hjust = -0.1,
    size = 4
  ) +
  scale_fill_gradient(
    low = "#a1d99b",
    high = "#006d2c"
  ) +
  scale_y_continuous(
    limits = c(0, max(estados$percentual) * 1.1)
  ) +
  coord_flip() +
  labs(
    title = "Participação dos filmes brasileiros por estado",
    subtitle = "Percentual das sessões que correspondem a filmes nacionais",
    x = "Estado",
    y = "Percentual de sessões brasileiras"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "none",
    axis.text.y = element_text(
      face = "bold"
    )
  )

# Participacao dos estados na quantidad de sessoes
sessoes_estado <- dados %>%
  count(UF_SALA_COMPLEXO) %>%
  mutate(
    percentual = 100 * n / sum(n)
  ) %>%
  arrange(desc(percentual))

ggplot(
  sessoes_estado,
  aes(
    x = reorder(UF_SALA_COMPLEXO, percentual),
    y = percentual,
    fill = percentual
  )
) +
  geom_col(width = 0.8) +
  geom_text(
    aes(
      label = paste0(
        round(percentual, 1),
        "%"
      )
    ),
    hjust = -0.15,
    size = 4
  ) +
  scale_fill_gradient(
    low = "#9ecae1",
    high = "#08519c"
  ) +
  scale_y_continuous(
    limits = c(
      0,
      max(sessoes_estado$percentual) * 1.1
    )
  ) +
  coord_flip() +
  labs(
    title = "Participação das sessões de cinema por estado",
    subtitle = "Percentual das sessões realizadas em cada unidade federativa",
    x = "Estado",
    y = "Participação nas sessões (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "none",
    axis.text.y = element_text(
      face = "bold"
    )
  )

# Municipios que mais exibem filmes nacionais
dados %>%
  filter(ORIGEM == "Brasileiro") %>%
  count(MUNICIPIO_SALA_COMPLEXO) %>%
  arrange(desc(n))

# Publico por horario - Grafico de heatmap
publico_hora <- dados %>%
  group_by(ORIGEM, HORA) %>%
  summarise(
    publico_medio = mean(PUBLICO, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(
  publico_hora,
  aes(
    x = factor(HORA),
    y = ORIGEM,
    fill = publico_medio
  )
) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(
    aes(
      label = round(publico_medio, 1)
    ),
    size = 3.5,
    fontface = "bold"
  ) +
  scale_fill_gradient(
    low = "#deebf7",
    high = "#08519c",
    labels = comma
  ) +
  labs(
    title = "Público médio por horário das sessões",
    subtitle = "Comparação entre filmes brasileiros e estrangeiros",
    x = "Horário da sessão",
    y = "Origem",
    fill = "Público médio"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    panel.grid = element_blank()
  )

# Publico medio por horario - grafico de barras
ggplot(
  publico_hora,
  aes(
    x = factor(HORA),
    y = publico_medio,
    fill = ORIGEM
  )
) +
  geom_col(
    position = position_dodge(width = 0.9),
    width = 0.8
  ) +
  geom_text(
    aes(
      label = comma(round(publico_medio, 0))
    ),
    position = position_dodge(width = 0.9),
    vjust = -0.3,
    size = 3.2,
    fontface = "bold"
  ) +
  scale_y_continuous(
    labels = comma,
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Público médio por horário das sessões",
    subtitle = "Comparação entre filmes brasileiros e estrangeiros",
    x = "Horário da sessão",
    y = "Público médio por sessão",
    fill = "Origem"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    legend.position = "bottom",
    legend.title = element_text(
      face = "bold"
    )
  )

# Numero medio de sessoes por filmes - BloxPlot
sessoes_filme <- dados %>%
  group_by(ORIGEM, CPB_ROE) %>%
  summarise(
    sessoes = n(),
    .groups = "drop"
  )

ggplot(
  sessoes_filme,
  aes(
    x = ORIGEM,
    y = sessoes,
    fill = ORIGEM
  )
) +
  geom_boxplot(
    alpha = 0.7,
    outlier.alpha = 0.3
  ) +
  scale_y_log10(
    labels = scales::comma
  ) +
  labs(
    title = "Distribuição do número de sessões por filme",
    subtitle = "Cada ponto representa um filme",
    x = "Origem do filme",
    y = "Número de sessões (escala logarítmica)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "none"
  )

# Bloxplot - filmes sessao
ggplot(
  sessoes_filme,
  aes(
    x = ORIGEM,
    y = sessoes,
    fill = ORIGEM
  )
) +
  geom_violin(
    alpha = 0.5,
    trim = FALSE
  ) +
  geom_boxplot(
    width = 0.15,
    fill = "white"
  ) +
  scale_y_log10(
    labels = scales::comma
  ) +
  labs(
    title = "Distribuição do número de sessões por filme",
    subtitle = "Filmes brasileiros e estrangeiros",
    x = "Origem",
    y = "Número de sessões (escala log)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    legend.position = "none"
  )


############################################################
# PREPARAÇÃO DOS DADOS DOS FILMES
############################################################

filmes <- dados %>%
  group_by(ORIGEM, CPB_ROE) %>%
  summarise(
    sessoes = n(),
    publico_total = sum(PUBLICO),
    publico_medio = mean(PUBLICO),
    .groups = "drop"
  )

# Número de sessões versus público total
ggplot(
  filmes,
  aes(
    x = sessoes,
    y = publico_total,
    color = ORIGEM
  )
) +
  geom_point(
    alpha = 0.6,
    size = 2.5
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    linewidth = 1.2
  ) +
  scale_x_log10(labels = comma) +
  scale_y_log10(labels = comma) +
  labs(
    title = "Número de sessões versus público total",
    subtitle = "Cada ponto representa um filme",
    x = "Número de sessões (escala logarítmica)",
    y = "Público total (escala logarítmica)",
    color = "Origem"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "bottom"
  )

# Número de sessões versus público médio
ggplot(
  filmes,
  aes(
    x = sessoes,
    y = publico_medio,
    color = ORIGEM
  )
) +
  geom_point(
    alpha = 0.6,
    size = 2.5
  ) +
  geom_smooth(
    method = "loess",
    se = FALSE,
    linewidth = 1.2
  ) +
  scale_x_log10(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Número de sessões versus público médio",
    subtitle = "Desempenho médio das sessões",
    x = "Número de sessões (escala logarítmica)",
    y = "Público médio por sessão",
    color = "Origem"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "bottom"
  )

estados <- dados %>%
  group_by(UF_SALA_COMPLEXO) %>%
  summarise(
    total_sessoes = n(),
    brasileiras = sum(ORIGEM == "Brasileiro"),
    percentual_br = 100 * brasileiras / total_sessoes,
    participacao = 100 * total_sessoes / nrow(dados),
    .groups = "drop"
  )

media_nacional <- mean(estados$percentual_br)

# Mercado exibidor versus participação do cinema nacional
ggplot(
  estados,
  aes(
    x = participacao,
    y = percentual_br,
    label = UF_SALA_COMPLEXO
  )
) +
  geom_point(
    size = 5,
    color = "steelblue"
  ) +
  geom_text(
    nudge_y = 0.8,
    fontface = "bold",
    size = 4
  ) +
  geom_hline(
    yintercept = media_nacional,
    color = "red",
    linetype = "dashed"
  ) +
  labs(
    title = "Mercado exibidor versus participação do cinema nacional",
    subtitle = "A linha vermelha representa a média nacional",
    x = "Participação nas sessões do Brasil (%)",
    y = "Sessões brasileiras (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    )
  )


publico_hora <- dados %>%
  group_by(ORIGEM, HORA) %>%
  summarise(
    publico = mean(PUBLICO),
    .groups = "drop"
  )


# Público médio por horário
ggplot(
  publico_hora,
  aes(
    x = HORA,
    y = publico,
    color = ORIGEM,
    group = ORIGEM
  )
) +
  geom_line(
    linewidth = 1.3
  ) +
  geom_point(
    size = 4
  ) +
  geom_text(
    aes(
      label = round(publico, 1)
    ),
    vjust = -0.7,
    size = 3
  ) +
  labs(
    title = "Público médio por horário",
    subtitle = "Comparação entre filmes brasileiros e estrangeiros",
    x = "Hora da sessão",
    y = "Público médio",
    color = "Origem"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "bottom"
  )


# Quadrantes de desempenho
filmes_quad <- filmes %>%
  mutate(
    log_sessoes = log10(sessoes),
    log_publico = log10(publico_total)
  )

media_sessoes <- mean(filmes_quad$log_sessoes)
media_publico <- mean(filmes_quad$log_publico)

ggplot(
  filmes_quad,
  aes(
    x = log_sessoes,
    y = log_publico,
    color = ORIGEM
  )
) +
  geom_point(
    alpha = 0.6,
    size = 2.5
  ) +
  geom_vline(
    xintercept = media_sessoes,
    linetype = "dashed"
  ) +
  geom_hline(
    yintercept = media_publico,
    linetype = "dashed"
  ) +
  labs(
    title = "Quadrantes de desempenho dos filmes",
    subtitle = "Sessões versus público total",
    x = "Log do número de sessões",
    y = "Log do público total",
    color = "Origem"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold"
    ),
    plot.subtitle = element_text(
      hjust = 0.5
    ),
    legend.position = "bottom"
  )
