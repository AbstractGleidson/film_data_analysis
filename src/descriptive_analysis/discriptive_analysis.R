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

cat("Quantidade de sessões brasileiras:",
    sessoes$n[sessoes$ORIGEM == "Brasileiro"],
    "\n")

cat("Quantidade de sessões estrangeiras:",
    sessoes$n[sessoes$ORIGEM == "Estrangeiro"],
    "\n")

cat("Quantidade total de sessões:",
    total_sessoes,
    "\n")

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
    publico = sum(PUBLICO)
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
dados %>%
  filter(ORIGEM == "Brasileiro") %>%
  count(UF_SALA_COMPLEXO) %>%
  ggplot(
    aes(
      reorder(UF_SALA_COMPLEXO, n),
      n
    )
  ) +
  geom_col() +
  coord_flip()

# Municipios que mais exibem filmes nacionais
dados %>%
  filter(ORIGEM == "Brasileiro") %>%
  count(MUNICIPIO_SALA_COMPLEXO) %>%
  arrange(desc(n))

# Publico por horario
dados %>%
  group_by(ORIGEM, HORA) %>%
  summarise(
    publico = mean(PUBLICO)
  )

# Numero medio de sessoes por filmes 
dados %>%
  group_by(ORIGEM, CPB_ROE) %>%
  summarise(
    sessoes = n()
  ) %>%
  group_by(ORIGEM) %>%
  summarise(
    media_sessoes = mean(sessoes)
  )