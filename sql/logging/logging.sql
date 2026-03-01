CREATE SCHEMA IF NOT EXISTS logging;

CREATE TABLE IF NOT EXISTS logging.pipeline_log (
    log_id SERIAL PRIMARY KEY,
    pipeline_name VARCHAR(100),
    table_name VARCHAR(100),
    status VARCHAR(20),
    rows_affected INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    error_message TEXT
);

SELECT * 
FROM logging.pipeline_log
ORDER BY log_id DESC;
