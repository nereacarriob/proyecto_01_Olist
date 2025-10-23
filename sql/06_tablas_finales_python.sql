-- Tablas finales para Python

-- Tabla detalle ventas:

CREATE OR REPLACE VIEW v_detalle_ventas_mensual AS
SELECT
	v1.año_mes,
    v1.num_pedidos,
    v1.clientes_unicos,
    v1.sellers_unicos,
    v1.importe_total,
    v1.ticket_promedio,
    v1.items_totales,
    v1.revenue_por_item,
    v2.rating_avg_mensual,
    v2.pct_pedidos_con_review
FROM v_ventas_global v1
LEFT JOIN v_reviews_evolucion_temp v2 ON v1.año_mes = v2.año_mes
;

    
-- Tabla detalle de clientes:    
CREATE OR REPLACE VIEW v_detalle_clientes AS
SELECT
	v1.id_cliente_unico,
    v1.num_pedidos,
    v1.importe_total,
    v1.ticket_promedio,
    v1.primera_compra,
    v1.ultima_compra,
    v1.items_por_pedido_avg,
    v1.dias_entre_compras_avg,
    v1.num_categorias_compradas,
    v2.num_reviews_cliente,
    v2.ratio_pedidos_con_review,
    v3.tipo_cliente
FROM v_ventas_por_cliente v1 
LEFT JOIN v_reviews_avg_cliente v2 ON v1.id_cliente_unico = v2.id_cliente_unico
LEFT JOIN v_reviews_clientes_extremos v3 ON v1.id_cliente_unico = v3.id_cliente_unico


