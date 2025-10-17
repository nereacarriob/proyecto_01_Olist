-- OBJETIVO: KPIS REVIEWS

-- Rating promedio global:

CREATE OR REPLACE VIEW v_reviews_avg_global AS
SELECT 
	ROUND(AVG(r.review_score),2) AS rating_avg_global,
    COUNT(r.review_id) AS num_reviews_global,
	COUNT(r.review_id) / COUNT(o.order_id) * 1.0 AS ratio_pedidos_con_review
FROM olist_orders o
LEFT JOIN olist_order_reviews r ON r.order_id = o.order_id;

-- Rating promedio por categoría de producto:

CREATE OR REPLACE VIEW v_reviews_avg_cat_producto AS
SELECT 
	p.product_category_name AS categoria_producto,
	AVG(r.review_score) AS rating_avg_cat_producto,
    COUNT(r.review_score) AS num_reviews_cat_producto
FROM olist_products p
JOIN olist_order_items i ON p.product_id = i.product_id 
JOIN olist_order_reviews r ON i.order_id = r.order_id
GROUP BY categoria_producto;
    
-- Rating promedio por cliente:

CREATE OR REPLACE VIEW v_reviews_avg_cliente AS
SELECT
	c.customer_unique_id AS id_cliente_unico,
    COUNT(DISTINCT o.order_id) AS num_pedidos,
    COUNT(r.review_id) AS num_reviews_cliente,
    COUNT(r.review_id) / COUNT(DISTINCT o.order_id) * 1.0 AS ratio_pedidos_con_review,
	ROUND(AVG(r.review_score), 2) AS rating_avg_cliente
FROM olist_customers c
JOIN olist_orders o ON c.customer_id = o.customer_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
GROUP BY customer_unique_id;

-- Rating promedio por vendedor:

CREATE OR REPLACE VIEW v_reviews_avg_vendedor AS

SELECT
	s.seller_id AS id_vendedor,
	AVG(r.review_score) AS rating_avg_vendedor,
    COUNT(r.review_score) AS num_reviews_vendedor
FROM olist_sellers s
JOIN olist_order_items i ON s.seller_id = i.seller_id
JOIN olist_order_reviews r ON i.order_id = r.order_id
GROUP BY s.seller_id;


-- Distribución de ratings:

CREATE OR REPLACE VIEW v_reviews_rating_distribucion AS
SELECT 
	review_score,
    COUNT(*) AS num_reviews,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_order_reviews) AS pct_reviews
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Evolución temporal de reviews

CREATE OR REPLACE VIEW v_reviews_evolucion_temp AS
WITH reviews_mensuales AS (
SELECT 
	DATE_FORMAT(review_creation_date, '%Y-%m') AS año_mes,
    ROUND(AVG(review_score), 2) as rating_avg_mensual,
    COUNT(*) AS num_reviews
FROM olist_order_reviews
GROUP BY año_mes
),
pedidos_mensuales AS (
SELECT 
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS año_mes,
    COUNT(*) AS num_pedidos
FROM olist_orders
GROUP BY año_mes
)

SELECT 
	r.año_mes,
    r.rating_avg_mensual,
    r.num_reviews,
    p.num_pedidos,
    ROUND(r.num_reviews / NULLIF(p.num_pedidos, 0) * 100, 2) AS pct_pedidos_con_review
FROM reviews_mensuales r 
LEFT JOIN pedidos_mensuales p ON r.año_mes = p.año_mes
ORDER BY r.año_mes;

-- Clientes con más críticos y más positivos
CREATE OR REPLACE VIEW v_reviews_clientes_extremos AS
SELECT 
    id_cliente_unico,
    num_pedidos,
    num_reviews_cliente,
    rating_avg_cliente,
    CASE 
        WHEN rating_avg_cliente <= 2 THEN 'Crítico'
        WHEN rating_avg_cliente >= 4.5 THEN 'Muy positivo'
        ELSE 'Neutro'
    END AS tipo_cliente
FROM v_reviews_avg_cliente;
