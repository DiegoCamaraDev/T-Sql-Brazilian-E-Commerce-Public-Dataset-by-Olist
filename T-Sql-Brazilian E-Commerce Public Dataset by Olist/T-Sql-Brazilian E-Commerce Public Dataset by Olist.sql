USE db_AnaliseOlist

--Quais são as categorias de produtos mais vendidas?

SELECT catego.product_category_name,
	   COUNT (*) AS quantidadeTotalDeVendas	   
FROM olist_order_items_dataset AS itens
inner join olist_products_dataset AS produto
	ON itens.product_id = produto.product_id
inner join product_category_name_translation AS catego
	ON produto.product_category_name = catego.product_category_name
GROUP BY catego.product_category_name
ORDER BY quantidadeTotalDeVendas  DESC

--Nossa categoria de produtos mais vendida, de longe, é Cama, Mesa e Banho, 
--com mais de 11 mil itens vendidos no período analisado. Em seguida, temos Beleza e Saúde e Esporte e Lazer. 
--Recomendo que nossas próximas campanhas de marketing e nossos esforços de gestão de estoque sejam focados 
--nessas três categorias para maximizar o retorno, pois elas representam nossa maior fonte de volume de vendas.

--Pergunta 2: Qual a distribuição geográfica dos nossos clientes (Top 10 estados)?

SELECT TOP 10 customer_state AS Estado,
		   count (*) AS QuantidadeDeClientes
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY QuantidadeDeClientes DESC

--Com essa simples tabela, podemos chegar a conclusões de negócio extremamente valiosas:
--Concentração Massiva: Nosso negócio tem uma concentração gigantesca no estado de São Paulo (SP),
--com quase 42 mil clientes. É, sem dúvida, nosso principal mercado.
--Força do Sudeste: O número de clientes em SP é mais de 3 vezes maior que o do segundo colocado,
--o Rio de Janeiro (RJ). Se somarmos SP, RJ e Minas Gerais (MG), vemos que a região Sudeste domina completamente nossas vendas.
--Presença no Sul: A região Sul também é muito relevante, com Rio Grande do Sul (RS), Paraná (PR) e Santa Catarina (SC) 
--aparecendo no top 10
--Oportunidades: Vemos o primeiro estado do Nordeste, a Bahia (BA), em 7º lugar. Isso pode indicar tanto uma presença já estabelecida
--quanto uma grande oportunidade de crescimento em outros estados da região. O Distrito Federal (DF) também se destaca
--Com essa análise, um gerente poderia, por exemplo, decidir criar uma campanha de marketing digital focada em SP para 
--fortalecer ainda mais nossa posição, ou talvez uma campanha com frete reduzido para o Nordeste para tentar expandir nossa base de clientes por lá.


-- Pergunta 3: Qual o tempo médio de entrega para cada nota de avaliação?
SELECT
    r.review_score AS Nota,
    COUNT(*) AS QuantidadeDeAvaliacoes,
    -- Usando AVG() para calcular a MÉDIA e DATEDIFF para achar a diferença em DIAS entre a compra e a entrega.
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS TempoMedioDeEntregaDias
FROM
    -- Começamos pela tabela de reviews, que é o nosso foco
    olist_order_reviews_dataset AS r
INNER JOIN
    -- E a conectamos com a tabela de pedidos para buscar as datas
    olist_orders_dataset AS o
    ON r.order_id = o.order_id -- A conexão é feita pelo 'order_id', que existe em ambas as tabelas
WHERE
    -- É importante analisar apenas os pedidos que já foram entregues, senão o cálculo de DATEDIFF dará erro.
    o.order_delivered_customer_date IS NOT NULL
GROUP BY
    r.review_score
ORDER BY
    Nota DESC;

--a conclusão é inegável. Podemos afirmar com 100% de certeza, baseados em dados:
--Correlação Direta e Fortíssima: Existe uma correlação direta e muito forte entre o tempo de entrega 
--e a satisfação do cliente. Quanto maior o tempo de entrega, menor a nota da avaliação.
--O Custo da Demora:
--Clientes que dão nota 5 (excelente) recebem seus produtos em média em 10 dias.
--Clientes que dão nota 1 (péssimo) recebem seus produtos em média em 21 dias.
--Ou seja, uma entrega que demora o dobro do tempo resulta na pior avaliação possível

-- Pergunta 4: Qual é o ticket médio (valor médio por pedido) mensal ao longo do tempo?
-- Com uma CTE (Common Table Expression)  primeiro calculamos o valor total de cada pedido.
-- A ideia é usar como uma tabela temporária que chamaremos de 'PedidosComValorTotal'.
WITH PedidosComValorTotal AS (
    SELECT
        p.order_id,
        SUM(p.payment_value) AS valor_total_pedido -- Somamos todos os pagamentos para cada order_id
    FROM
        olist_order_payments_dataset AS p
    GROUP BY
        p.order_id -- Agrupamos para garantir que a soma seja por pedido
)
SELECT
--Extraímos o ano e o mês da data da compra. O formato 'yyyy-MM' é ótimo para ordenar.
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS AnoMes,
-- Passo 3: Calculamos a MÉDIA do valor total dos pedidos para cada grupo de AnoMes.
-- Envelopamos a função AVG() com CAST() para formatar o resultado final.
    CAST(AVG(pvt.valor_total_pedido) AS DECIMAL(10, 2)) AS TicketMedio
FROM
-- Usamos a tabela principal de pedidos
    olist_orders_dataset AS o
INNER JOIN
-- E a conectamos com nossa tabela temporária que criamos com o WITH
    PedidosComValorTotal AS pvt
    ON o.order_id = pvt.order_id
GROUP BY
-- Agrupamos os resultados por AnoMes para que o AVG calcule a média mensal
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY
-- Ordenamos pelo AnoMes para ver a evolução cronológica
    AnoMes;



-- Pergunta 5: Quais são os métodos de pagamento mais utilizados pelos clientes?

SELECT
    payment_type AS MetodoDePagamento,
    COUNT(*) AS QuantidadeDeTransacoes,
    -- Adicionando a coluna de percentual para um insight mais rico
    CAST(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) 
        AS DECIMAL(10, 2)
    ) AS PercentualDoTotal

FROM
    olist_order_payments_dataset
-- Removendo a categoria "not_defined" para focar nos métodos de pagamento reais
WHERE
    payment_type != 'not_defined'

GROUP BY
    payment_type

ORDER BY
    QuantidadeDeTransacoes DESC;