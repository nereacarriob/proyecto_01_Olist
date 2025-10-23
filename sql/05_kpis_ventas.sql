-- OBJETIVO: KPIS VENTAS

-- Ventas totales:
CREATE OR REPLACE VIEW v_ventas_global AS
WITH pagos_agrupados AS (
SELECT 
	order_id,
	SUM(payment_value) AS pago_total
FROM olist_order_payments
GROUP BY order_id
),
items_agrupados AS (
SELECT 
	order_id,
	COUNT(order_item_id) AS items_por_pedido,
    COUNT(DISTINCT seller_id) AS sellers_por_pedido
FROM olist_order_items
GROUP BY order_id
)

SELECT 
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS año_mes, 
    COUNT(DISTINCT o.order_id) AS num_pedidos,
	COUNT(c.customer_unique_id) AS clientes_unicos,
    SUM(p.pago_total) AS importe_total,
    ROUND(SUM(p.pago_total) / COUNT(DISTINCT o.order_id), 2) AS ticket_promedio,
	SUM(i.sellers_por_pedido) AS sellers_unicos,
    SUM(i.items_por_pedido) AS items_totales,
    ROUND(SUM(i.items_por_pedido) / COUNT(DISTINCT o.order_id), 2) AS items_por_pedido_avg, 
    ROUND(SUM(p.pago_total) / SUM(i.items_por_pedido), 2) AS revenue_por_item
FROM olist_orders o
LEFT JOIN pagos_agrupados p ON o.order_id = p.order_id
LEFT JOIN items_agrupados i ON o.order_id = i.order_id
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY año_mes;

-- Nº pedidos por cliente:
CREATE OR REPLACE VIEW v_ventas_por_cliente AS
WITH pagos_agrupados AS (
SELECT 
	order_id,
	SUM(payment_value) AS pago_total
FROM olist_order_payments
GROUP BY order_id),
items_agrupados AS (
SELECT 
	i.order_id,
	COUNT(i.order_item_id) AS items_por_pedido,
    COUNT(DISTINCT p.product_category_name) AS num_categorias
FROM olist_order_items i
LEFT JOIN olist_products p ON i.product_id = p.product_id
GROUP BY order_id
)

SELECT 
	c.customer_unique_id AS id_cliente_unico, 
    COUNT(DISTINCT o.order_id) AS num_pedidos,
	SUM(p.pago_total) AS importe_total,
    ROUND(SUM(p.pago_total) / COUNT(DISTINCT o.order_id), 2) AS ticket_promedio,
	SUM(i.items_por_pedido) AS items_totales,
    ROUND(SUM(i.items_por_pedido) / COUNT(DISTINCT o.order_id), 2) AS items_por_pedido_avg,
    SUM(i.num_categorias) AS num_categorias_compradas,
    MIN(o.order_purchase_timestamp) AS primera_compra,
    MAX(o.order_purchase_timestamp) AS ultima_compra,
    DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) / NULLIF(COUNT(DISTINCT o.order_id) - 1, 0) AS dias_entre_compras_avg
FROM olist_customers c
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
LEFT JOIN pagos_agrupados p ON o.order_id = p.order_id
LEFT JOIN items_agrupados i ON o.order_id = i.order_id
GROUP BY id_cliente_unico;


-- Productos más vendidos y con mayor revenue:
CREATE OR REPLACE VIEW v_ventas_por_producto AS
SELECT 
	product_id, 
    COUNT(DISTINCT order_id) AS num_pedidos, 
    COUNT(order_item_id) AS num_unidades_vendidas,
    SUM(price) AS importe_total, 
    ROUND(SUM(price) / COUNT(order_item_id), 2) AS revenue_por_producto
FROM olist_order_items
GROUP BY product_id;
