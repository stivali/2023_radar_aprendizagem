# Occupational Structure of Apprenticeships in Brazil (RAIS 2021)

**R code and supporting files for Stivali (2023), published in *Radar* (Ipea), issue 72.**

This repository documents the analysis underlying the short article *Estrutura ocupacional da aprendizagem: investimento em capital humano ou custo trabalhista?* (Occupational Structure of Apprenticeships: Investment in Human Capital or Labor Cost?). The article compares the occupational distribution of apprentices with that of other workers across the ten CNAE divisions with the largest numbers of apprentices in Brazil, using the **2021 Relação Anual de Informações Sociais (RAIS)**.

The analysis reports occupational concentration through the **Herfindahl–Hirschman Index (HHI/IHH)** and compares occupational distributions using correlation coefficients.

## Publication

Stivali, Matheus (2023). “Estrutura ocupacional da aprendizagem: investimento em capital humano ou custo trabalhista?” *Radar*, no. 72, Instituto de Pesquisa Econômica Aplicada (Ipea), April 2023. [https://doi.org/10.38116/radar72art4](https://doi.org/10.38116/radar72art4).

A copy of the published article is provided in [`paper/`](paper/). The publication can also be accessed through the DOI above.

## Repository structure

```text
.
├── README.md
├── .gitignore
├── AprendizagemRadar.Rproj
├── aux_data/
│   ├── CBO_SIT_03_2021.xlsx
│   └── divisaoCNAE.xlsx
├── code/
│   ├── Leitura RAIS 2021.R
│   └── Tabelas Aprendizagem.R
├── outputs/
│   ├── 1 - Proporção por ocupação.xlsx
│   └── 2 - Tabela_final.xlsx
└── paper/
    └── Stivali (2023) - Estrutura ocupacional da aprendizagem investimento em capital humano ou custo trabalhista.pdf
```

- **`code/Leitura RAIS 2021.R`** reads the original public RAIS 2021 text files, selects and standardizes variables, and writes partitioned Parquet datasets using `arrow`.
- **`code/Tabelas Aprendizagem.R`** reads the processed RAIS data and the auxiliary occupational/sector classification files, identifies the ten CNAE divisions with the most apprentices, and produces occupational distributions and comparison indicators.
- **`aux_data/`** contains the auxiliary tables for apprenticeship-eligible occupations (from the labor inspection authority, SIT) and CNAE division labels.
- **`outputs/`** contains spreadsheets produced during the analysis, including the final indicator table. These files are provided for inspection, not as proof of reproducibility across software environments.
- **`paper/`** contains the published note.

## Data and software

The underlying microdata are the **public RAIS 2021 employment records**, provided by the Brazilian Ministry of Labour through the [Programa de Disseminação das Estatísticas do Trabalho (PDET)](https://www.gov.br/trabalho-e-emprego/pt-br/assuntos/estatisticas-trabalho). **The raw RAIS files and intermediate Parquet datasets are not included in this repository**, given their size.

The scripts use **R** and packages including `tidyverse`, `arrow`, `vroom`, `fs`, `readxl`, `openxlsx`, and `here` (depending on the script). The historical analysis also used the `hhi` package; the revised table script may instead define the index calculation locally. Package requirements and paths should be checked against the particular script version before running.

### Execution order

1. Obtain the public RAIS 2021 employment files and extract them locally.
2. Run [`code/Leitura RAIS 2021.R`](code/Leitura%20RAIS%202021.R) to create the Parquet files, adapting the input/output directories to your computer.
3. Check the two Excel files in `aux_data/` and any paths used to locate them.
4. Run [`code/Tabelas Aprendizagem.R`](code/Tabelas%20Aprendizagem.R) to construct the indicators and tables.
5. Compare the output with **Table 1** of the published article.

**Note:** The scripts originated in 2023 and have been organized/revised in 2026. They may contain machine-specific paths and are not packaged as a one-command reproducible workflow. Parsing warnings in the RAIS import should be inspected if re-running the pipeline with different source files or software versions.

## Replication note: Pearson versus Spearman

The published article describes the correlation between occupational distributions as **Spearman's rank correlation**. During a review of the original code in November 2026, it was identified that the correlation reported in the published table had actually been calculated using **Pearson's correlation** because the `method = "spearman"` argument was placed outside the `cor()` call in the original script.

The original published values were subsequently reproduced, allowing this discrepancy to be identified. **The distinction matters for interpretation:** Pearson measures linear association between occupational shares, while Spearman measures association between their ranks. Any updated Spearman estimates should be distinguished from the published Pearson-based figures, rather than presented as values originally reported in the article.

## Scope

This repository preserves the code and supporting material for a descriptive policy analysis. It does not include the original RAIS microdata, and reproducing its results requires obtaining a compatible RAIS 2021 extract and matching the processing decisions used in the scripts.
