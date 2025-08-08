USE db_AnaliseOlist

--Quais s�o as categorias de produtos mais vendidas?

SELECT catego.product_category_name,
	   COUNT (*) AS quantidadeTotalDeVendas	   
FROM olist_order_items_dataset AS itens
inner join olist_products_dataset AS produto
	ON itens.product_id = produto.product_id
inner join product_category_name_translation AS catego
	ON produto.product_category_name = catego.product_category_name
GROUP BY catego.product_category_name
ORDER BY quantidadeTotalDeVendas  DESC

--Nossa categoria de produtos mais vendida, de longe, � Cama, Mesa e Banho, 
--com mais de 11 mil itens vendidos no per�odo analisado. Em seguida, temos Beleza e Sa�de e Esporte e Lazer. 
--Recomendo que nossas pr�ximas campanhas de marketing e nossos esfor�os de gest�o de estoque sejam focados 
--nessas tr�s categorias para maximizar o retorno, pois elas representam nossa maior fonte de volume de vendas.

--Pergunta 2: Qual a distribui��o geogr�fica dos nossos clientes (Top 10 estados)?

SELECT TOP 10 customer_state AS Estado,
		   count (*) AS QuantidadeDeClientes
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY QuantidadeDeClientes DESC

--Com essa simples tabela, podemos chegar a conclus�es de neg�cio extremamente valiosas:
--Concentra��o Massiva: Nosso neg�cio tem uma concentra��o gigantesca no estado de S�o Paulo (SP),
--com quase 42 mil clientes. �, sem d�vida, nosso principal mercado.
--For�a do Sudeste: O n�mero de clientes em SP � mais de 3 vezes maior que o do segundo colocado,
--o Rio de Janeiro (RJ). Se somarmos SP, RJ e Minas Gerais (MG), vemos que a regi�o Sudeste domina completamente nossas vendas.
--Presen�a no Sul: A regi�o Sul tamb�m � muito relevante, com Rio Grande do Sul (RS), Paran� (PR) e Santa Catarina (SC) 
--aparecendo no top 10
--Oportunidades: Vemos o primeiro estado do Nordeste, a Bahia (BA), em 7� lugar. Isso pode indicar tanto uma presen�a j� estabelecida
--quanto uma grande oportunidade de crescimento em outros estados da regi�o. O Distrito Federal (DF) tamb�m se destaca
--Com essa an�lise, um gerente poderia, por exemplo, decidir criar uma campanha de marketing digital focada em SP para 
--fortalecer ainda mais nossa posi��o, ou talvez uma campanha com frete reduzido para o Nordeste para tentar expandir nossa base de clientes por l�.


-- Pergunta 3: Qual o tempo m�dio de entrega para cada nota de avalia��o?
SELECT
    r.review_score AS Nota,
    COUNT(*) AS QuantidadeDeAvaliacoes,
    -- Usando AVG() para calcular a M�DIA e DATEDIFF para achar a diferen�a em DIAS entre a compra e a entrega.
    AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS TempoMedioDeEntregaDias
FROM
    -- Come�amos pela tabela de reviews, que � o nosso foco
    olist_order_reviews_dataset AS r
INNER JOIN
    -- E a conectamos com a tabela de pedidos para buscar as datas
    olist_orders_dataset AS o
    ON r.order_id = o.order_id -- A conex�o � feita pelo 'order_id', que existe em ambas as tabelas
WHERE
    -- � importante analisar apenas os pedidos que j� foram entregues, sen�o o c�lculo de DATEDIFF dar� erro.
    o.order_delivered_customer_date IS NOT NULL
GROUP BY
    r.review_score
ORDER BY
    Nota DESC;

--a conclus�o � ineg�vel. Podemos afirmar com 100% de certeza, baseados em dados:
--Correla��o Direta e Fort�ssima: Existe uma correla��o direta e muito forte entre o tempo de entrega 
--e a satisfa��o do cliente. Quanto maior o tempo de entrega, menor a nota da avalia��o.
--O Custo da Demora:
--Clientes que d�o nota 5 (excelente) recebem seus produtos em m�dia em 10 dias.
--Clientes que d�o nota 1 (p�ssimo) recebem seus produtos em m�dia em 21 dias.
--Ou seja, uma entrega que demora o dobro do tempo resulta na pior avalia��o poss�vel

-- Pergunta 4: Qual � o ticket m�dio (valor m�dio por pedido) mensal ao longo do tempo?
-- Com uma CTE (Common Table Expression)  primeiro calculamos o valor total de cada pedido.
-- A ideia � usar como uma tabela tempor�ria que chamaremos de 'PedidosComValorTotal'.
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
--Extra�mos o ano e o m�s da data da compra. O formato 'yyyy-MM' � �timo para ordenar.
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS AnoMes,
-- Passo 3: Calculamos a M�DIA do valor total dos pedidos para cada grupo de AnoMes.
-- Envelopamos a fun��o AVG() com CAST() para formatar o resultado final.
    CAST(AVG(pvt.valor_total_pedido) AS DECIMAL(10, 2)) AS TicketMedio
FROM
-- Usamos a tabela principal de pedidos
    olist_orders_dataset AS o
INNER JOIN
-- E a conectamos com nossa tabela tempor�ria que criamos com o WITH
    PedidosComValorTotal AS pvt
    ON o.order_id = pvt.order_id
GROUP BY
-- Agrupamos os resultados por AnoMes para que o AVG calcule a m�dia mensal
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY
-- Ordenamos pelo AnoMes para ver a evolu��o cronol�gica
    AnoMes;



-- Pergunta 5: Quais s�o os m�todos de pagamento mais utilizados pelos clientes?

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
-- Removendo a categoria "not_defined" para focar nos m�todos de pagamento reais
WHERE
    payment_type != 'not_defined'

GROUP BY
    payment_type

ORDER BY
    QuantidadeDeTransacoes DESC;