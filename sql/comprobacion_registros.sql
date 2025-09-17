SELECT 'customers' AS tabla, COUNT(*) FROM olist_customers
UNION ALL
SELECT 'geolocation' AS tabla, COUNT(*) FROM olist_geolocation
UNION ALL
SELECT 'order_items' AS tabla, COUNT(*) FROM olist_order_items
UNION ALL
SELECT 'order_opayments' AS tabla, COUNT(*) FROM olist_order_payments
UNION ALL 
SELECT 'order_reviews' AS tabla, COUNT(*) FROM olist_order_reviews
UNION ALL
SELECT 'orders' AS tabla, COUNT(*) FROM olist_orders
UNION ALL 
SELECT 'products' AS tabla, COUNT(*) FROM olist_products
UNION ALL
SELECT 'sellers' AS tabla, COUNT(*) FROM olist_sellers