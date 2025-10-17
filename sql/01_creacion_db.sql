-- Creación del contenedor
DROP DATABASE IF EXISTS Olist;
CREATE DATABASE Olist
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE Olist;

-- Creación de las tablas

CREATE TABLE olist_customers (
    customer_id VARCHAR(255) NOT NULL,
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(255),
    customer_state VARCHAR(255),
    PRIMARY KEY(customer_id)
);

CREATE TABLE olist_geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(255)
);
CREATE INDEX idx_zip_code_prefix ON olist_geolocation (geolocation_zip_code_prefix);

CREATE TABLE olist_orders (
    order_id VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    order_status VARCHAR(255),
    order_purchase_timestamp DATETIME NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL,
    PRIMARY KEY(order_id),
    FOREIGN KEY(customer_id) REFERENCES olist_customers(customer_id)
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(255) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(255),
    payment_installments INT,
    payment_value DECIMAL(7,2),
    PRIMARY KEY(order_id, payment_sequential),
    FOREIGN KEY(order_id) REFERENCES olist_orders(order_id)
);

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(255) NOT NULL,
    order_id VARCHAR(255) NOT NULL,
    review_score INT,
    review_comment_title VARCHAR(255) NULL,
    review_comment_message TEXT NULL,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL,
    PRIMARY KEY(review_id),
    FOREIGN KEY(order_id) REFERENCES olist_orders(order_id)
);


CREATE TABLE olist_products (
    product_id VARCHAR(255) NOT NULL,
    product_category_name VARCHAR(255) NULL,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    PRIMARY KEY(product_id)
);

CREATE TABLE olist_sellers (
    seller_id VARCHAR(255) NOT NULL,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(255),
    seller_state VARCHAR(255),
    PRIMARY KEY(seller_id)
);

CREATE TABLE olist_order_items (
    order_id VARCHAR(255) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    seller_id VARCHAR(255) NOT NULL,
    shipping_limit_date DATETIME NULL,
    price DECIMAL(7,2),
    freight_value DECIMAL(5,2),
    PRIMARY KEY(order_id, order_item_id),
    FOREIGN KEY(order_id) REFERENCES olist_orders(order_id),
    FOREIGN KEY(product_id) REFERENCES olist_products(product_id),
    FOREIGN KEY(seller_id) REFERENCES olist_sellers(seller_id)
);
