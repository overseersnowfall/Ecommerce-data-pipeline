CREATE SCHEMA IF NOT EXISTS gold_layer;

DROP TABLE IF EXISTS gold_layer.fact_sales CASCADE;
DROP TABLE IF EXISTS gold_layer.fact_payments CASCADE;
DROP TABLE IF EXISTS gold_layer.fact_reviews CASCADE;
DROP TABLE IF EXISTS gold_layer.dim_customers CASCADE;
DROP TABLE IF EXISTS gold_layer.dim_products CASCADE;
DROP TABLE IF EXISTS gold_layer.dim_sellers CASCADE;
DROP TABLE IF EXISTS gold_layer.dim_date CASCADE;


CREATE TABLE IF NOT EXISTS gold_layer.dim_date (
    date_key DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    month_name TEXT,
    day INT,
    day_of_week INT,
    day_name TEXT,
    week_of_year INT
);

CREATE TABLE IF NOT EXISTS gold_layer.dim_customers (
    customer_key SERIAL PRIMARY KEY,
    customer_id TEXT UNIQUE,
    customer_unique_id TEXT,
    customer_zip_code_prefix VARCHAR(10),
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE IF NOT EXISTS gold_layer.dim_products (
    product_key SERIAL PRIMARY KEY,
    product_id TEXT UNIQUE,
    product_category_name TEXT,
    product_category_name_english TEXT,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE IF NOT EXISTS gold_layer.dim_sellers (
    seller_key SERIAL PRIMARY KEY,
    seller_id TEXT UNIQUE,
    seller_zip_code_prefix VARCHAR(10),
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE IF NOT EXISTS gold_layer.fact_sales (
    sales_key SERIAL PRIMARY KEY,
    order_id TEXT,
    
    customer_key INT REFERENCES gold_layer.dim_customers(customer_key),
    product_key INT REFERENCES gold_layer.dim_products(product_key),
    seller_key INT REFERENCES gold_layer.dim_sellers(seller_key),

    order_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    approval_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    delivered_carrier_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    delivered_customer_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    estimated_delivery_date_key DATE REFERENCES gold_layer.dim_date(date_key),

    order_status TEXT,
    order_item_id INT,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    total_value NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS gold_layer.fact_payments (
    payment_key SERIAL PRIMARY KEY,
    order_id TEXT,
    
    customer_key INT REFERENCES gold_layer.dim_customers(customer_key),
    payment_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS gold_layer.fact_reviews (
    review_key SERIAL PRIMARY KEY,
    order_id TEXT,
    
    customer_key INT REFERENCES gold_layer.dim_customers(customer_key),
    review_creation_date_key DATE REFERENCES gold_layer.dim_date(date_key),
    
    review_score INT
);