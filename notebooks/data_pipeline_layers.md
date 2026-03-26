# Data Pipeline Layers

## Bronze Layer — Raw Data Ingestion

The Bronze layer is responsible for **ingesting raw data from source files into the database**.

In this project, the Bronze ingestion pipeline is implemented using **Python and Pandas**.

Key characteristics of this layer:

* Extract data from CSV files
* Load raw datasets into database tables
* Preserve the original data structure
* Minimal transformation
* Log pipeline execution for monitoring

The ingestion script performs:

* File detection and loading
* DataFrame creation using Pandas
* Database insertion
* Logging of loading times and row counts

Example Bronze tables:

* customers
* orders
* order_items
* order_payments
* order_reviews
* products
* sellers
* geolocation

This layer acts as the **source of truth for all raw data**.

---

## Silver Layer — Data Cleaning and Transformation

The Silver layer focuses on **data quality improvement and schema standardization**.

At this stage the raw data is cleaned and transformed into structured datasets suitable for modeling.

Transformations performed include:

* Data type corrections
* Removal of duplicate records
* Standardization of column formats
* Data validation
* Handling missing values

All transformations are implemented using **SQL ETL scripts and stored procedures**.

The Silver pipeline also includes **execution logging**, allowing monitoring of pipeline success or failure.

Example Silver tables:

* customers
* orders
* order_items
* order_payments
* order_reviews
* products
* sellers
* product_category_translation
* geolocation

These tables represent **trusted and clean datasets** used for downstream analytics.

---

## Gold Layer — Data Warehouse (Star Schema)

The Gold layer contains the **analytics-ready data warehouse**.

At this stage the cleaned Silver data is transformed into **dimensional models optimized for analytical queries**.

The warehouse follows a **Star Schema design**, consisting of fact and dimension tables.

### Dimension Tables

Dimension tables store descriptive attributes used to analyze business metrics.

Examples:

* dim_customers
* dim_products
* dim_sellers
* dim_date

### Fact Tables

Fact tables store measurable events and link to dimensions through surrogate keys.

Examples:

* fact_sales
* fact_payments
* fact_reviews

These tables allow efficient analytical queries such as:

* revenue trends over time
* product performance
* customer purchasing behavior
* seller performance
* payment method analysis

---

# Logging and Pipeline Monitoring

To simulate real production pipelines, the project includes a **logging system for ETL execution**.

The logging framework records:

* Pipeline name
* Table being processed
* Execution start time
* Execution end time
* Row counts
* Error messages

This enables:

* pipeline observability
* debugging
* execution tracking

Logging was implemented using SQL tables and stored procedures.

---
