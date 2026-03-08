CREATE OR REPLACE PROCEDURE gold_layer.load_gold_full()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_row_count INT;
    v_error TEXT;
BEGIN

    -- =========================================
    -- DIM_DATE
    -- =========================================
    v_start_time := clock_timestamp();

    BEGIN
        TRUNCATE TABLE gold_layer.dim_date CASCADE;

        INSERT INTO gold_layer.dim_date (
            date_key, year, quarter, month, month_name,
            day, day_of_week, day_name, week_of_year
        )
        SELECT DISTINCT
            d::DATE,
            EXTRACT(YEAR FROM d),
            EXTRACT(QUARTER FROM d),
            EXTRACT(MONTH FROM d),
            TO_CHAR(d, 'Month'),
            EXTRACT(DAY FROM d),
            EXTRACT(DOW FROM d),
            TO_CHAR(d, 'Day'),
            EXTRACT(WEEK FROM d)
        FROM (
            SELECT order_purchase_timestamp AS d FROM silver_layer.orders
            UNION
            SELECT order_approved_at FROM silver_layer.orders
            UNION
            SELECT order_delivered_carrier_date FROM silver_layer.orders
            UNION
            SELECT order_delivered_customer_date FROM silver_layer.orders
            UNION
            SELECT order_estimated_delivery_date FROM silver_layer.orders
            UNION
            SELECT review_creation_date FROM silver_layer.order_reviews
            UNION
            SELECT review_answer_timestamp FROM silver_layer.order_reviews
        ) all_dates
        WHERE d IS NOT NULL;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_date', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);

    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_date', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
    END;


    -- =========================================
    -- DIM_CUSTOMERS
    -- =========================================
    v_start_time := clock_timestamp();

    BEGIN
        TRUNCATE TABLE gold_layer.dim_customers RESTART IDENTITY CASCADE;

        INSERT INTO gold_layer.dim_customers (
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        )
        SELECT
            customer_id,
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state
        FROM silver_layer.customers;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_customers', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);

    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_customers', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
    END;


    -- =========================================
    -- DIM_PRODUCTS
    -- =========================================
    v_start_time := clock_timestamp();

    BEGIN
        TRUNCATE TABLE gold_layer.dim_products RESTART IDENTITY CASCADE;

        INSERT INTO gold_layer.dim_products (
            product_id,
            product_category_name,
            product_category_name_english,
            product_name_length,
            product_description_length,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        )
        SELECT
            p.product_id,
            p.product_category_name,
            ct.product_category_name_english,
            p.product_name_length,
            p.product_description_length,
            p.product_photos_qty,
            p.product_weight_g,
            p.product_length_cm,
            p.product_height_cm,
            p.product_width_cm
        FROM silver_layer.products p
        LEFT JOIN silver_layer.product_category_name_translation ct
            ON p.product_category_name = ct.product_category_name;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_products', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);

    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_products', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
    END;


    -- =========================================
    -- DIM_SELLERS
    -- =========================================
    v_start_time := clock_timestamp();

    BEGIN
        TRUNCATE TABLE gold_layer.dim_sellers RESTART IDENTITY CASCADE;

        INSERT INTO gold_layer.dim_sellers (
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        )
        SELECT
            seller_id,
            seller_zip_code_prefix,
            seller_city,
            seller_state
        FROM silver_layer.sellers;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_sellers', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);

    EXCEPTION WHEN OTHERS THEN
        v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'dim_sellers', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
    END;

	-- ============================
	-- Load fact_sales
	-- ============================
	
	v_start_time := NOW();
	
	BEGIN
		TRUNCATE TABLE gold_layer.fact_sales RESTART IDENTITY CASCADE;
		INSERT INTO gold_layer.fact_sales (
		    order_id,
		    customer_key,
		    product_key,
		    seller_key,
		    order_date_key,
		    approval_date_key,
		    delivered_carrier_date_key,
		    delivered_customer_date_key,
		    estimated_delivery_date_key,
		    order_status,
		    order_item_id,
		    price,
		    freight_value,
		    total_value
		)
		SELECT
		    oi.order_id,
		    dc.customer_key,
		    dp.product_key,
		    ds.seller_key,
		    DATE(o.order_purchase_timestamp),
		    DATE(o.order_approved_at),
		    DATE(o.order_delivered_carrier_date),
		    DATE(o.order_delivered_customer_date),
		    DATE(o.order_estimated_delivery_date),
		    o.order_status,
		    oi.order_item_id,
		    oi.price,
		    oi.freight_value,
		    oi.price + oi.freight_value
		FROM silver_layer.orders o
		JOIN silver_layer.order_items oi
		    ON o.order_id = oi.order_id
		JOIN silver_layer.customers c
		    ON o.customer_id = c.customer_id
		JOIN gold_layer.dim_customers dc
		    ON c.customer_unique_id = dc.customer_unique_id
		JOIN gold_layer.dim_products dp
		    ON oi.product_id = dp.product_id
		JOIN gold_layer.dim_sellers ds
	    	ON oi.seller_id = ds.seller_id;

		GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_sales', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);
	
	EXCEPTION WHEN OTHERS THEN

		v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_sales', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
	
	END;

	-- ============================
	-- Load fact_payments
	-- ============================
	
	v_start_time := NOW();
	
	BEGIN
		TRUNCATE TABLE gold_layer.fact_payments RESTART IDENTITY CASCADE;
		
		INSERT INTO gold_layer.fact_payments (
		    order_id,
		    customer_key,
		    payment_date_key,
		    payment_sequential,
		    payment_type,
		    payment_installments,
		    payment_value
		)
		SELECT
		    p.order_id,
		    dc.customer_key,
		    DATE(o.order_purchase_timestamp),
		    p.payment_sequential,
		    p.payment_type,
		    p.payment_installments,
		    p.payment_value
		FROM silver_layer.order_payments p
		JOIN silver_layer.orders o
		    ON p.order_id = o.order_id
		JOIN silver_layer.customers c
		    ON o.customer_id = c.customer_id
		JOIN gold_layer.dim_customers dc
		    ON c.customer_unique_id = dc.customer_unique_id;
			
		GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();
		
        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_payments', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);
		
	EXCEPTION WHEN OTHERS THEN

		v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_payments', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
	
	END;

	-- ============================
	-- Load fact_reviews
	-- ============================
	
	v_start_time := NOW();
	
	BEGIN
		TRUNCATE TABLE gold_layer.fact_reviews RESTART IDENTITY CASCADE;
		
		INSERT INTO gold_layer.fact_reviews (
		    order_id,
		    customer_key,
		    review_creation_date_key,
		    review_score
		)
		SELECT
		    r.order_id,
		    dc.customer_key,
		    DATE(r.review_creation_date),
		    r.review_score
		FROM silver_layer.order_reviews r
		JOIN silver_layer.orders o
		    ON r.order_id = o.order_id
		JOIN silver_layer.customers c
		    ON o.customer_id = c.customer_id
		JOIN gold_layer.dim_customers dc
		    ON c.customer_unique_id = dc.customer_unique_id;
			
		GET DIAGNOSTICS v_row_count = ROW_COUNT;
        v_end_time := clock_timestamp();

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_reviews', 'SUCCESS',
                v_row_count, v_start_time, v_end_time, NULL);
	
	EXCEPTION WHEN OTHERS THEN

		v_end_time := clock_timestamp();
        v_error := SQLERRM;

        INSERT INTO logging.pipeline_log
        VALUES (DEFAULT, 'gold_full_load', 'fact_reviews', 'FAILED',
                NULL, v_start_time, v_end_time, v_error);
	END;

END;
$$;

CALL gold_layer.load_gold_full();