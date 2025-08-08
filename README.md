# Análise Estratégica de E-commerce: Um Projeto Completo com SQL e Power BI

![Status](https://img.shields.io/badge/status-conclu%C3%ADdo-brightgreen)
![Linguagens](https://img.shields.io/badge/linguagens-SQL%2C%20DAX-blue)
![Ferramentas](https://img.shields.io/badge/ferramentas-SQL%20Server%2C%20Power%20BI-blueviolet)

##  Visão Geral do Projeto

Este projeto realiza uma análise exploratória completa sobre um grande dataset de e-commerce, com o objetivo de transformar dados brutos em insights estratégicos que respondam a "dores" centrais de um negócio de varejo digital. A jornada cobre desde a estruturação e limpeza de dados em um ambiente **SQL Server** até a criação de um dashboard interativo e gerencial no **Power BI**.

O foco não foi apenas gerar gráficos, mas sim demonstrar um fluxo de trabalho de análise de ponta a ponta, superando desafios reais como dados imperfeitos e a necessidade de traduzir perguntas de negócio em consultas e métricas eficazes.

## Perguntas de Negócio Respondidas

A análise foi guiada para responder a 5 perguntas estratégicas:

1.  Quais são as categorias de produtos mais vendidas?
2.  Qual a distribuição geográfica dos nossos clientes (Top 5 estados)?
3.  Qual a correlação entre o tempo de entrega e a satisfação do cliente?
4.  Qual é o ticket médio (valor médio por pedido) mensal ao longo do tempo?
5.  Quais são os métodos de pagamento mais utilizados pelos clientes?

## Dashboard Final

O resultado de toda a análise foi consolidado em um dashboard interativo no Power BI, projetado para fornecer uma visão 360° da performance do negócio.

![Dashboard Final do Projeto Olist](image_707e9a.png) 
*(Substitua 'image_707e9a.png' pelo nome do arquivo de imagem do seu dashboard no repositório)*

## Tech Stack Utilizada

* **Banco de Dados:** SQL Server
* **Linguagem de Consulta e Manipulação:** T-SQL
* **Ferramenta de BI e Visualização:** Microsoft Power BI
* **Linguagem de Fórmulas (BI):** DAX (Data Analysis Expressions)

## Como Utilizar Este Projeto

Para replicar esta análise, siga os passos abaixo:

### Pré-requisitos

* Microsoft SQL Server e SQL Server Management Studio (SSMS) instalados.
* Microsoft Power BI Desktop instalado.

### 1. Obtenção dos Dados

O dataset utilizado é o "Brazilian E-Commerce Public Dataset by Olist", disponível publicamente no Kaggle.
* [Link para o Dataset no Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Baixe os arquivos `.csv` para a sua máquina local.

### 2. Configuração do Banco de Dados

1.  Abra o SSMS e crie um novo banco de dados para o projeto:
    ```sql
    CREATE DATABASE DB_Olist_Analysis;
    GO
    USE DB_Olist_Analysis;
    GO
    ```
2.  Importe cada um dos arquivos `.csv` baixados para dentro do banco de dados. Utilize o **Import Flat File Wizard** do SSMS (clique direito no banco -> Tasks -> Import Flat File...).
3.  **Atenção aos Desafios Reais:** Durante a importação, foi necessário superar desafios comuns em projetos de dados:
    * **Tipos de Dados:** Validar e corrigir tipos de dados importados incorretamente (ex: uma coluna de valor monetário importada como texto).
    * **Nomes de Colunas:** Garantir que os cabeçalhos dos CSVs foram corretamente definidos como nomes de colunas nas tabelas. Em alguns casos, foi necessário renomear colunas com `sp_rename`.

### 3. Scripts SQL

A pasta `/SQL Scripts` (sugestão de organização) contém as queries T-SQL utilizadas para responder a cada uma das perguntas de negócio. Elas demonstram o uso de `JOINs`, `GROUP BY`, agregações (`COUNT`, `SUM`, `AVG`) e manipulação de datas (`DATEDIFF`).

### 4. Dashboard em Power BI

1.  Abra o arquivo `.pbix` contido neste repositório.
2.  Caso precise refazer a conexão, vá em `Transformar dados -> Configurações da fonte de dados` e aponte para o seu servidor SQL Server local.
3.  O dashboard utiliza os seguintes conceitos:
    * **Modelagem de Dados:** Relacionamentos foram criados para conectar as tabelas, com especial atenção às direções de filtro (Single vs. Both) para permitir os cálculos corretos.
    * **Colunas Calculadas e Medidas DAX:** Foram criadas métricas essenciais como `Tempo de Entrega (dias)` e `Avaliação Média Geral` usando fórmulas DAX.
    * **Filtros Avançados:** Utilização de filtros "Top N" para ranquear categorias e estados.
    * **Interatividade:** Inclusão de KPIs e Segmentação de Dados para permitir uma análise dinâmica por parte do usuário.

## Autor

* **Diego de Araújo Câmara**
* **LinkedIn:** https://www.linkedin.com/in/diego-araujo-camara/

---
