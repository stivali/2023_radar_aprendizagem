##############################################################
##              LENDO OS DADOS DA RAIS 2021
##############################################################
##
##  Microdados de ftp://ftp.mtps.gov.br/pdet/microdados/
##  Lê os arquivos txt e cria os arquivos parquet
##
##  Matheus Stivali  -  versão 1: 06/01/2023
##
##############################################################

library("arrow")
library("vroom")
library("tidyverse")

# Listando os arquivos de vínculos
vinculos <- 
  fs::dir_ls("D:/Data/RAIS/2021/7z", 
             glob = "*RAIS_VINC*.txt")

# Obtendo os nomes das variáveis
RAIS_NO_2021 <- vroom("D:/Data/RAIS/2021/7z/RAIS_VINC_PUB_NORTE.txt",
                      delim = ";",
                      col_names = TRUE,
                      n_max = 10,
                      locale=locale(encoding="latin1"))
# > colnames(RAIS_NO_2021)
# [1] "Bairros SP"              "Bairros Fortaleza"       "Bairros RJ"              "Causa Afastamento 1"    
# [5] "Causa Afastamento 2"     "Causa Afastamento 3"     "Motivo Desligamento"     "CBO Ocupação 2002"      
# [9] "CNAE 2.0 Classe"         "CNAE 95 Classe"          "Distritos SP"            "Vínculo Ativo 31/12"    
# [13] "Faixa Etária"            "Faixa Hora Contrat"      "Faixa Remun Dezem (SM)"  "Faixa Remun Média (SM)" 
# [17] "Faixa Tempo Emprego"     "Escolaridade após 2005"  "Qtd Hora Contr"          "Idade"                  
# [21] "Ind CEI Vinculado"       "Ind Simples"             "Mês Admissão"            "Mês Desligamento"       
# [25] "Mun Trab"                "Município"               "Nacionalidade"           "Natureza Jurídica"      
# [29] "Ind Portador Defic"      "Qtd Dias Afastamento"    "Raça Cor"                "Regiões Adm DF"         
# [33] "Vl Remun Dezembro Nom"   "Vl Remun Dezembro (SM)"  "Vl Remun Média Nom"      "Vl Remun Média (SM)"    
# [37] "CNAE 2.0 Subclasse"      "Sexo Trabalhador"        "Tamanho Estabelecimento" "Tempo Emprego"          
# [41] "Tipo Admissão"           "Tipo Estab...42"         "Tipo Estab...43"         "Tipo Defic"             
# [45] "Tipo Vínculo"            "IBGE Subsetor"           "Vl Rem Janeiro SC"       "Vl Rem Fevereiro SC"    
# [49] "Vl Rem Março SC"         "Vl Rem Abril SC"         "Vl Rem Maio SC"          "Vl Rem Junho SC"        
# [53] "Vl Rem Julho SC"         "Vl Rem Agosto SC"        "Vl Rem Setembro SC"      "Vl Rem Outubro SC"      
# [57] "Vl Rem Novembro SC"      "Ano Chegada Brasil"      "Ind Trab Intermitente"   "Ind Trab Parcial"     

for(i in vinculos){
  
  message("Lendo: ", i)
  t0 <- Sys.time()
  
  temp <- 
    vroom(i,
          delim = ";",
          locale=locale(encoding="latin1", 
                        decimal_mark = ","),
          col_names = TRUE,
          col_select = c("Causa Afastamento 1",
                         "Causa Afastamento 2",
                         "Causa Afastamento 3",
                         "Motivo Desligamento",
                         "CBO Ocupação 2002",  
                         "CNAE 2.0 Classe",
                         "CNAE 95 Classe",
                         "Vínculo Ativo 31/12",
                         "Faixa Etária",
                         "Faixa Hora Contrat",
                         "Faixa Tempo Emprego",
                         "Escolaridade após 2005", 
                         "Qtd Hora Contr",
                         "Idade", 
                         "Ind CEI Vinculado", 
                         "Ind Simples",
                         "Mês Admissão",  
                         "Mês Desligamento",  
                         "Mun Trab", 
                         "Município",
                         "Nacionalidade",
                         "Natureza Jurídica",  
                         "Ind Portador Defic", 
                         "Qtd Dias Afastamento",
                         "Raça Cor", 
                         "Vl Remun Dezembro Nom",  
                         "Vl Remun Média Nom", 
                         "CNAE 2.0 Subclasse", 
                         "Sexo Trabalhador",
                         "Tamanho Estabelecimento",
                         "Tempo Emprego", 
                         "Tipo Admissão", 
                         "Tipo Estab...42",
                         "Tipo Estab...43", 
                         "Tipo Defic", 
                         "Tipo Vínculo", 
                         "IBGE Subsetor", 
                         "Vl Rem Janeiro SC",  
                         "Vl Rem Fevereiro SC", 
                         "Vl Rem Março SC", 
                         "Vl Rem Abril SC", 
                         "Vl Rem Maio SC", 
                         "Vl Rem Junho SC", 
                         "Vl Rem Julho SC", 
                         "Vl Rem Agosto SC",  
                         "Vl Rem Setembro SC", 
                         "Vl Rem Outubro SC",  
                         "Vl Rem Novembro SC",
                         "Ano Chegada Brasil", 
                         "Ind Trab Intermitente",
                         "Ind Trab Parcial"  
          ),
          col_types =  cols("Causa Afastamento 1" = col_integer(),
                            "Causa Afastamento 2" = col_integer(),
                            "Causa Afastamento 3" = col_integer(),
                            "Motivo Desligamento" = col_integer(),
                            "CBO Ocupação 2002" = col_integer(),
                            "CNAE 2.0 Classe" = col_integer(),
                            "CNAE 95 Classe" = col_integer(),
                            "Vínculo Ativo 31/12" = col_logical(),
                            "Faixa Etária" = col_integer(),
                            "Faixa Hora Contrat" = col_integer(),
                            "Faixa Tempo Emprego" = col_integer(),
                            "Escolaridade após 2005" = col_integer(),
                            "Qtd Hora Contr" = col_integer(),
                            "Idade" = col_integer(),
                            "Ind CEI Vinculado" = col_logical(),
                            "Ind Simples" = col_logical(),
                            "Mês Admissão" = col_integer(),
                            "Mês Desligamento" = col_integer(),
                            "Mun Trab" = col_integer(),
                            "Município" = col_integer(),
                            "Nacionalidade" = col_integer(),
                            "Natureza Jurídica" = col_integer(),
                            "Ind Portador Defic" = col_logical(),
                            "Qtd Dias Afastamento" = col_integer(),
                            "Raça Cor" = col_integer(),
                            "Vl Remun Dezembro Nom" = col_double(),
                            "Vl Remun Média Nom" = col_double(),
                            "CNAE 2.0 Subclasse" = col_integer(),
                            "Sexo Trabalhador" = col_integer(),
                            "Tamanho Estabelecimento" = col_integer(),
                            "Tempo Emprego" = col_double(),
                            "Tipo Admissão" = col_integer(),
                            "Tipo Estab...42" = col_integer(),
                            "Tipo Estab...43" = col_character(),
                            "Tipo Defic" = col_integer(),
                            "Tipo Vínculo" = col_integer(),
                            "IBGE Subsetor" = col_integer(),
                            "Vl Rem Janeiro SC" = col_double(),
                            "Vl Rem Fevereiro SC" = col_double(),
                            "Vl Rem Março SC" = col_double(),
                            "Vl Rem Abril SC" = col_double(),
                            "Vl Rem Maio SC" = col_double(),
                            "Vl Rem Junho SC" = col_double(),
                            "Vl Rem Julho SC" = col_double(),
                            "Vl Rem Agosto SC" = col_double(),
                            "Vl Rem Setembro SC" = col_double(),
                            "Vl Rem Outubro SC" = col_double(),
                            "Vl Rem Novembro SC" = col_double(),
                            "Ano Chegada Brasil" = col_integer(),
                            "Ind Trab Intermitente" = col_logical(),
                            "Ind Trab Parcial" = col_logical()
          )
    ) %>% 
    # Padronizando nomes
    rename(
      afast1 = "Causa Afastamento 1",
      afast2 = "Causa Afastamento 2",
      afast3 = "Causa Afastamento 3",
      mot_deslig = "Motivo Desligamento",
      cbo2002 = "CBO Ocupação 2002",
      cnae20_cl = "CNAE 2.0 Classe",
      cnae95_cl = "CNAE 95 Classe",
      ativo_3112 = "Vínculo Ativo 31/12",
      fx_etaria = "Faixa Etária",
      fx_horas = "Faixa Hora Contrat",
      fx_tempo = "Faixa Tempo Emprego",
      esc2005 = "Escolaridade após 2005",
      qtd_horas = "Qtd Hora Contr",
      idade = Idade,
      ind_cei = "Ind CEI Vinculado",
      ind_simples = "Ind Simples",
      mes_adm = "Mês Admissão",
      mes_deslig = "Mês Desligamento",
      cod_mun_trab = "Mun Trab",
      cod_mun = "Município",
      nac = "Nacionalidade",
      nat_jur = "Natureza Jurídica",
      ind_pcd = "Ind Portador Defic",
      qtd_dias_afast = "Qtd Dias Afastamento",
      raca_cor = "Raça Cor",
      vl_rem_dez = "Vl Remun Dezembro Nom",
      vl_rem_med = "Vl Remun Média Nom",
      cnae20_subcl = "CNAE 2.0 Subclasse",
      sexo = "Sexo Trabalhador",
      tam_estab = "Tamanho Estabelecimento",
      tempo_emp = "Tempo Emprego",
      tp_adm = "Tipo Admissão",
      tp_estab1 = "Tipo Estab...42",
      tp_estab2 = "Tipo Estab...43",
      tp_defic = "Tipo Defic",
      tp_vinc = "Tipo Vínculo",
      ibge_subsetor = "IBGE Subsetor",
      rem_jan = "Vl Rem Janeiro SC",
      rem_fev = "Vl Rem Fevereiro SC",
      rem_mar = "Vl Rem Março SC",
      rem_abr = "Vl Rem Abril SC",
      rem_mai = "Vl Rem Maio SC",
      rem_jun = "Vl Rem Junho SC",
      rem_jul = "Vl Rem Julho SC",
      rem_ago = "Vl Rem Agosto SC",
      rem_set = "Vl Rem Setembro SC",
      rem_out = "Vl Rem Outubro SC",
      rem_nov = "Vl Rem Novembro SC",
      ano_cheg = "Ano Chegada Brasil",
      ind_intermit = "Ind Trab Intermitente",
      ind_parcial = "Ind Trab Parcial") %>% 
    # Criando uma variável de ano e uf
    mutate(ano = 2021,
           uf = as.integer(cod_mun) %/% 10000) %>% 
    relocate(ano, ativo_3112, uf, cod_mun, sexo, raca_cor, tp_vinc) %>% 
    # Essa ordenação fará diferença no tamanho dos arquivos parquet e
    # no tempo de consulta aos mesmos.
    arrange(ativo_3112, uf, cod_mun, sexo, raca_cor)
  
  temp %>% 
    # Indica as variáveis para particionamento
    group_by(ano, ativo_3112, uf) %>% 
    # Grava o objeto em arquivos parquet seguindo o particionamento do group_by
    write_dataset(path = "D:/Data/RAIS/parquet/", 
                  format = "parquet",
                  compression = "gzip",
                  compression_level = 9)
  rm(temp)
  gc()
  
  message("OK em ", round(difftime(Sys.time(), t0, units="secs"), 1), "s")
}

rm(i, t0, vinculos)
gc()

# Teste
rais2021 <- open_dataset("D:/Data/RAIS/parquet/",
                         format = "parquet")

glimpse(rais2021)
sessionInfo()
