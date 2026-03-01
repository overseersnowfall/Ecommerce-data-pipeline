-- SCHEMA: silver_layer
/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    along side with child tables if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS silver_layer;

DROP TABLE IF EXISTS silver_layer.order_items CASCADE;
DROP TABLE IF EXISTS silver_layer.order_payments CASCADE;
DROP TABLE IF EXISTS silver_layer.order_reviews CASCADE;
DROP TABLE IF EXISTS silver_layer.orders CASCADE;
DROP TABLE IF EXISTS silver_layer.products CASCADE;
DROP TABLE IF EXISTS silver_layer.sellers CASCADE;
DROP TABLE IF EXISTS silver_layer.customers CASCADE;
DROP TABLE IF EXISTS silver_layer.geolocation CASCADE;
DROP TABLE IF EXISTS silver_layer.product_category_name_translation CASCADE;

CREATE TABLE silver_layer.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver_layer.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver_layer.products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver_layer.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES silver_layer.customers(customer_id)
);

CREATE TABLE silver_layer.order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
        REFERENCES silver_layer.orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES silver_layer.products(product_id),

    FOREIGN KEY (seller_id)
        REFERENCES silver_layer.sellers(seller_id)
);

CREATE TABLE silver_layer.order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value NUMERIC(10,2),

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
        REFERENCES silver_layer.orders(order_id)
);

CREATE TABLE silver_layer.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
	PRIMARY KEY (review_id, order_id)
);

CREATE TABLE silver_layer.geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC(10,6),
    geolocation_lng NUMERIC(10,6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

CREATE TABLE silver_layer.product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);