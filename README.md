# End-to-End E-commerce Data Engineering Pipeline

## Overview

This project demonstrates the design and implementation of a complete **end-to-end data engineering project** for an e-commerce dataset.

The pipeline ingests raw data, performs cleaning and transformation, and builds an analytics-ready data warehouse using a layered architecture. The goal is to simulate how production data engineering pipelines move data from raw ingestion to structured business intelligence datasets.

The project follows the **Medallion Architecture (Bronze → Silver → Gold)**, where data quality and structure progressively improve across layers.

The dataset used is the **Olist Brazilian E-commerce dataset**, which contains transactional data including customers, orders, products, payments, reviews, and sellers.

This project demonstrates practical data engineering concepts such as:

* Data ingestion pipelines
* Data cleaning and transformation
* Dimensional data modeling
* SQL-based ETL processes
* Pipeline logging and monitoring
* Version control and reproducibility

---

# Project Scope

The objective of this project is to build a realistic **data engineering pipeline** that mimics workflows used in modern data platforms.

The project covers the following stages:

1. **Raw data ingestion using python**

   * Load multiple CSV datasets
   * Maintain original data structure

2. **Data cleaning and standardization with PostgreSQL**

   * Remove duplicates
   * Cast appropriate data types
   * Handle inconsistent records

3. **Data warehouse modeling**

   * Transform normalized tables into dimensional models
   * Build fact and dimension tables

4. **Analytics-ready datasets**

   * Enable business insights through structured tables
   * Support common analytical queries

The result is a fully functional **data pipeline and warehouse architecture** capable of supporting reporting and business analytics.

---

# Dataset

The dataset used in this project comes from the **Olist Brazilian E-commerce dataset from Kaggle**.

It contains transactional information about an online marketplace including:

* Customers
* Orders
* Order Items
* Products
* Sellers
* Payments
* Reviews
* Geolocation data

The dataset simulates the operational data of an e-commerce platform, making it suitable for designing realistic data pipelines.
link to the dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

# Project Architecture

This project implements a **three-layer Medallion Architecture**:

Bronze → Silver → Gold

Each layer represents a stage in the data lifecycle, gradually improving the usability and quality of the data.

A visual architecture diagram illustrating the pipeline structure will be included below.

*(Insert architecture diagram here)*

---
# Project Structure

```
Ecommerce-data-pipeline/
│
├── data/                               # Raw datasets
│   └── raw/                             # Original CSV files used in the project but not save in github and igroned in gitignore due to large files
│
├── notebooks/                               # Project documentation
│   ├── data_architecture.drawio         # Overall Medallion architecture diagram
│   ├── data_flow.drawio                 # Pipeline flow (CSV → Bronze → Silver → Gold)
│   ├── star_schema.drawio               # Gold layer dimensional model
│   ├── data_catalog.md                  # Dataset description and column metadata
│   ├── pipeline_design.md               # Explanation of ETL design decisions
│   └── naming_conventions.md            # Naming standards for tables and columns
│
├── sql/                                # SQL transformations and warehouse scripts
│
│   ├── logging/                         # Pipeline logging infrastructure
│   │   └── logging.sql                  # Logging schema + pipeline_log table
│
│   ├── silver_layer/                          # Silver layer transformations
│   │   ├── ddl_silver.sql               # Create Silver tables
│   │   └── load_silver.sql              # Stored procedure to clean + load data
│
│   └── gold_layer/                            # Data warehouse layer
│       ├── ddl_gold.sql                 # Create dimension and fact tables
│       └── load_gold.sql                # Stored procedure for Gold layer loading
|
├── src/                                # Python code (Bronze ingestion pipeline)
│   ├── load_bronze.py                   # Main ingestion script with logging
│
├── .env                                # Where user password, database name, host name are saved and put in gitigrone
├── .env example                        # to show others the example format of how env file saved
│
├── README.md                           # Project documentation
├── .gitignore
└── LICENSE
```

---
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

# Technologies Used

| Technology | Purpose                          |
| ---------- | -------------------------------- |
| Python     | Bronze data ingestion            |
| Pandas     | Data extraction and loading      |
| PostgreSQL | Data warehouse database          |
| SQL        | Data transformation and modeling |
| Git        | Version control                  |
| GitHub     | Project repository               |

---

# Example Analytical Use Cases

The final Gold layer enables answering common business questions such as:

* What are the top selling product categories?
* Which sellers generate the most revenue?
* How does revenue change month-to-month?
* What payment methods are most common?
* How do review scores relate to sales performance?

These insights can easily be queried from the **fact and dimension tables in the Gold layer**.

---

# Future Improvements

Possible enhancements to extend this project include:

* Automating pipeline orchestration using Airflow
* Implementing incremental data loads
* Adding data quality checks and validation tests
* Deploying the pipeline to a cloud data warehouse
* Building dashboards using BI tools such as Power BI or Tableau
---

# What I Learned

Through this project I gained hands-on experience with:

* Designing scalable data pipelines
* Implementing medallion architecture
* Building dimensional data models
* Writing production-style SQL transformations
* Managing data workflows with version control

---

# Repository

GitHub Repository:

https://github.com/overseersnowfall/Ecommerce-data-pipeline

---
