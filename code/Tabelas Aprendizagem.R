###############################################################################
##
##  Estrutura ocupacional da aprendizagem:
##  investimento em capital humano ou custo trabalhista?
##
##  Cálculo dos indicadores e elaboração das tabelas
##
##  Matheus Stivali
##
##  Publicação: Radar nº 72, Ipea, abril de 2023
##  DOI: https://doi.org/10.38116/radar72art4
##
##  Código original: 2023
##  Revisão: 21/11/2026
##
##  Dados: RAIS 2021
##  Indicadores: Índice de Herfindahl-Hirschman (IHH)
##              e correlação de postos de Spearman
##
###############################################################################

library("tidyverse")
library("arrow")
# library("hhi")
library("here")

# Como o pacote hhi foi arquivado no CRAN, definimos a função
# diretamente aqui:
#                  Índice de Herfindahl-Hirschman
# Equivalente ao cálculo do pacote hhi, com proporções entre 0 e 1.

hhi <- function(x, s) {
  if (!is.data.frame(x)) {
    stop("'x' deve ser um data.frame")
  }
  
  d <- x[[s]]
  
  if (!is.numeric(d)) {
    stop("'s' deve identificar uma variável numérica")
  }
  
  if (any(d < 0, na.rm = TRUE)) {
    stop("As participações não podem ser negativas")
  }
  
  return(sum(d^2))
}

##############################################################################
##        CBOs avaliadas pela SIT para a quota de aprendizagem
##
## Arquivo fornecido pela SIT em 2023
##############################################################################
lista_sit <- readxl::read_excel(
  here("aux_data",
       "CBO_SIT_03_2021.xlsx"),
  sheet = "Ocupação resumo",
  skip = 1,
  col_names = c("CBO", "Desc", "Aprendiz", "CBO_strg")
  ) %>% 
  filter(Aprendiz == "Sim") %>%
  pull(CBO)

Nomes_CNAE <- readxl::read_excel(
  here("aux_data",
       "divisaoCNAE.xlsx"),
  sheet = "CNAE",
  col_names = c("cnae_div", "Divisao")
  )


##############################################################################
##            VÍNCULOS
##############################################################################
##  Criando a conexão com a pasta parquet
##  É necessário criar as conexões ano a ano, caso
##  contrário ela fica apenas com as variáveis comuns
##  em todos os arquivos
##############################################################################

rais2021 <- arrow::open_dataset(
  "D:/Data/RAIS/parquet/ano=2021/",
  format = "parquet")


##############################################################################
##             ESTABELECIMENTOS OBRIGADOS A CONTRATAR APRENDIZES
##############################################################################
##
# 1) Estabelecimentos com menos de 7 empregados. A explicação é que 
#    a SIT olha o máximo da legislação (15%), daí 0,15 * 7 = 1,05. Logo
#    estabelecimentos a partir de 7 empregados estariam obrigados
# 2) O Manual da Aprendizagem diz que Micro e EPP estão dispensadas da
#    contratação de aprendizes (art. 56 do decreto 9579/2018). Note que esses
#    não são obrigados, mas podem contratar.
#    Porte do estabelecimento
#    01 - Microempresa
#    02 - Pequeno porte
#    03 - Outros
#    04 - MEI
#
#  Na base pública da RAIS é possível identificar apenas se os trabalhadores
#  estão em um estabelecimento do SIMPLES ou não.
#
##############################################################################


##############################################################################
##              Identifica as ocupações com mais aprendizes
##############################################################################

ocupacoes <- rais2021 %>% 
  # Vínculos ativos em 31/12
  filter(ativo_3112 == TRUE) %>%
  # CBO na lista da SIT
  filter(cbo2002 %in% lista_sit, 
         # Contrato de aprendiz
         tp_vinc == 55) %>% 
  group_by(cbo2002) %>%
  summarise(total_oc = n()) %>%
  arrange(desc(total_oc)) %>%
  collect()

ocupacoes <- ocupacoes %>%
  mutate(prop = total_oc / sum(total_oc))


openxlsx::write.xlsx(
  ocupacoes, 
  file = here("outputs",
              "1 - Proporção por ocupação.xlsx"))          

rm(ocupacoes)


##############################################################################
##             Divisões CNAE com maior número de aprendizes
##############################################################################

top10cnae <- rais2021 %>% 
  # Vínculo ativo
  filter(ativo_3112 == TRUE,
         cbo2002 %in% lista_sit,
         tp_vinc == 55) %>%
  # Cria a variável de divisão CNAE
  mutate(cnae_div = as.integer(cnae20_cl) %/% 1000) %>%
  group_by(cnae_div) %>%
  summarise(nobs = n()) %>%
  collect() %>% 
  arrange(desc(nobs)) %>%
  mutate(pct_geral = nobs / sum(nobs))

  
trabalh_tot <- rais2021 %>%
  # Só vínculos ativos
  filter(ativo_3112 == TRUE,
         cbo2002 %in% lista_sit) %>%
  mutate(cnae_div = as.integer(cnae20_cl) %/% 1000) %>%
  # Apenas os nas CNAEs TOP10 de aprendizes
  filter(cnae_div %in% top10cnae$cnae_div[1:10]) %>%
  group_by(cnae_div, cbo2002) %>%
  summarise(tot_oc = n()) %>% 
  mutate(pct_geral = tot_oc / sum(tot_oc)) %>% 
  collect()


trabalh_apr <- rais2021 %>%
  # Só vínculos ativos
  filter(ativo_3112 == TRUE,
         cbo2002 %in% lista_sit) %>%
  mutate(cnae_div = as.integer(cnae20_cl) %/% 1000) %>%
  # Apenas os nas CNAEs TOP10 de aprendizes
  filter(cnae_div %in% top10cnae$cnae_div[1:10],
         tp_vinc == 55) %>%
  group_by(cnae_div, cbo2002) %>%
  summarise(tot_oc_ap = n()) %>%
  mutate(pct_aprend = tot_oc_ap / sum(tot_oc_ap)) %>% 
  collect()


final <- left_join(trabalh_tot, 
                   trabalh_apr, 
                   by = c("cnae_div", "cbo2002")) %>%
         mutate(across(where(is.numeric), ~tidyr::replace_na(.x,0)))

## Teste se as frações somam 100%
final %>% group_by(cnae_div) %>%
          summarise(soma_tot = sum(pct_geral), 
                    soma_apr = sum(pct_aprend))


##############################################################################
##                             IHH e SPEARMAN
##############################################################################

HHI <- final %>% 
  group_by(cnae_div) %>%
  summarise(hhi_g = sum(pct_geral^2), 
            hhi_a = sum(pct_aprend^2))

## Comparação com o cálculo da função do pacote hhi
compara <- HHI[HHI$cnae_div==45,] %>% 
  bind_rows(tibble(cnae_div = 45,
                   hhi_g = hhi(as.data.frame(final[final$cnae_div==45,]), 
                               "pct_geral"),
                   hhi_a = hhi(as.data.frame(final[final$cnae_div==45,]), 
                               "pct_aprend")
  )
  )

rm(compara)


corr_spearman <- final %>% 
  group_by(cnae_div) %>%
  summarise(cor_pearson = cor(pct_geral, 
                              pct_aprend, 
                              method = "pearson"),
            cor_spearman = cor(pct_geral, 
                               pct_aprend, 
                               method = "spearman"),
            )

Tabela <- left_join(HHI, 
                    corr_spearman, 
                    by = "cnae_div") %>%
  left_join(., 
            top10cnae, 
            by = "cnae_div") %>%
  left_join(., 
            Nomes_CNAE, 
            by = "cnae_div") %>%
  arrange(desc(pct_geral))

openxlsx::write.xlsx(Tabela, 
                     file = here("outputs",
                                 "2 - Tabela_final.xlsx"))
                     




