SET GLOBAL local_infile = 1;

-- Carga CSV olist_customers
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_customers_dataset.csv'
INTO TABLE olist_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Carga CSV olist_geolocation
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Carga CSV olist_orders
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_orders_dataset.csv'
INTO TABLE olist_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	order_id, 
    customer_id, 
    order_status, 
    @order_purchase_timestamp, 
    @order_approved_at, 
    @order_delivered_carrier_date, 
    @order_delivered_customer_date, 
    @order_estimated_delivery_date
)
SET
order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
order_approved_at = NULLIF(@order_approved_at, ''),
order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');

-- Carga CSV olist_payments
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Carga CSV olist_order_reviews
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Carga CSV olist_products
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_products_dataset.csv'
INTO TABLE olist_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    @product_category_name,
    @product_name_length,
    @product_description_length,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
)
SET 
    product_category_name = NULLIF(@product_category_name, ''),
    product_name_length = NULLIF(@product_name_length, ''),
    product_description_length = NULLIF(@product_description_length, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');

-- Carga CSV olist_sellers
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_sellers_dataset.csv'
INTO TABLE olist_sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Carga CSV olist_order_items
LOAD DATA LOCAL INFILE '/Users/nereacarrio/Documents/1_PORTFOLIO/01_Olist/DATASETS/olist_dataset_raw/olist_order_items_dataset.csv'
INTO TABLE olist_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
