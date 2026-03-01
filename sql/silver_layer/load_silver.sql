CREATE OR REPLACE PROCEDURE silver_layer.load_silver_full()
LANGUAGE plpgsql
AS $$
DECLARE
    v_pipeline_name TEXT := 'silver_full_load';
    v_table_name TEXT;
    v_rows INTEGER;
    v_error TEXT;
BEGIN

    ------------------------------------------------------------------
    -- CUSTOMERS
    ------------------------------------------------------------------
    v_table_name := 'customers';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.customers CASCADE;

        INSERT INTO silver_layer.customers
        SELECT DISTINCT
            TRIM(customer_id),
            TRIM(customer_unique_id),
            LPAD(customer_zip_code_prefix::VARCHAR,5,'0'),
            INITCAP(TRIM(customer_city)),
            UPPER(TRIM(customer_state))
        FROM bronze_layer.customers
        WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> '';

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- SELLERS
    ------------------------------------------------------------------
    v_table_name := 'sellers';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.sellers CASCADE;

        INSERT INTO silver_layer.sellers
        SELECT DISTINCT
            TRIM(seller_id),
            LPAD(seller_zip_code_prefix::VARCHAR,5,'0'),
            INITCAP(TRIM(seller_city)),
            UPPER(TRIM(seller_state))
        FROM bronze_layer.sellers
        WHERE seller_id IS NOT NULL AND TRIM(seller_id) <> '';

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- PRODUCTS
    ------------------------------------------------------------------
    v_table_name := 'products';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.products CASCADE;

        INSERT INTO silver_layer.products
        SELECT DISTINCT
            TRIM(product_id),
            TRIM(product_category_name),
            product_name_lenght,
            product_description_lenght,
            product_photos_qty,
            product_weight_g,
            product_length_cm,
            product_height_cm,
            product_width_cm
        FROM bronze_layer.products
        WHERE product_id IS NOT NULL;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- CATEGORY TRANSLATION
    ------------------------------------------------------------------
    v_table_name := 'product_category_name_translation';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.product_category_name_translation CASCADE;

        INSERT INTO silver_layer.product_category_name_translation
        SELECT DISTINCT
            TRIM(product_category_name),
            TRIM(product_category_name_english)
        FROM bronze_layer.product_category_name_translation;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- GEOLOCATION
    ------------------------------------------------------------------
    v_table_name := 'geolocation';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.geolocation CASCADE;

        INSERT INTO silver_layer.geolocation
        SELECT DISTINCT
            LPAD(geolocation_zip_code_prefix::VARCHAR,5,'0'),
            geolocation_lat,
            geolocation_lng,
            INITCAP(TRIM(geolocation_city)),
            UPPER(TRIM(geolocation_state))
        FROM bronze_layer.geolocation;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- ORDERS
    ------------------------------------------------------------------
    v_table_name := 'orders';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.orders CASCADE;

        INSERT INTO silver_layer.orders
        SELECT DISTINCT
            TRIM(order_id),
            TRIM(customer_id),
            order_status,
            order_purchase_timestamp::TIMESTAMP,
            order_approved_at::TIMESTAMP,
            order_delivered_carrier_date::TIMESTAMP,
            order_delivered_customer_date::TIMESTAMP,
            order_estimated_delivery_date::TIMESTAMP
        FROM bronze_layer.orders
        WHERE order_id IS NOT NULL;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- ORDER ITEMS
    ------------------------------------------------------------------
    v_table_name := 'order_items';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.order_items CASCADE;

        INSERT INTO silver_layer.order_items
        SELECT DISTINCT
            TRIM(order_id),
            order_item_id,
            TRIM(product_id),
            TRIM(seller_id),
            shipping_limit_date::TIMESTAMP,
            price,
            freight_value
        FROM bronze_layer.order_items;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- PAYMENTS
    ------------------------------------------------------------------
    v_table_name := 'order_payments';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.order_payments CASCADE;

        INSERT INTO silver_layer.order_payments
        SELECT DISTINCT
            TRIM(order_id),
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        FROM bronze_layer.order_payments;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

    ------------------------------------------------------------------
    -- REVIEWS
    ------------------------------------------------------------------
    v_table_name := 'order_reviews';
    INSERT INTO logging.pipeline_log VALUES (DEFAULT, v_pipeline_name, v_table_name, 'STARTED', NULL, NOW(), NULL, NULL);

    BEGIN
        TRUNCATE TABLE silver_layer.order_reviews CASCADE;

        INSERT INTO silver_layer.order_reviews
        SELECT DISTINCT
            TRIM(review_id),
            TRIM(order_id),
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date::TIMESTAMP,
            review_answer_timestamp::TIMESTAMP
        FROM bronze_layer.order_reviews;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        UPDATE logging.pipeline_log
        SET status='SUCCESS', rows_affected=v_rows, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';

    EXCEPTION WHEN OTHERS THEN
        v_error := SQLERRM;
        UPDATE logging.pipeline_log
        SET status='FAILED', error_message=v_error, end_time=NOW()
        WHERE pipeline_name=v_pipeline_name AND table_name=v_table_name AND status='STARTED';
    END;

END;
$$;

CALL silver_layer.load_silver_full();