# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics. All tables reside in the `gold_layer` schema and are loaded via the `gold_layer.load_gold()` stored procedure, sourcing data from the `silver_layer`.

---

### 1. **gold_layer.dim_date**
- **Purpose:** Stores a calendar dimension derived from all relevant date fields across orders and reviews, enabling time-based analysis across any fact table.
- **Source:** `silver_layer.orders`, `silver_layer.order_reviews`
- **Columns:**

| Column Name   | Data Type | Description                                                                                   |
|---------------|-----------|-----------------------------------------------------------------------------------------------|
| date_key      | DATE      | Primary key. The calendar date, used as a foreign key reference in all fact tables.           |
| year          | INT       | The calendar year extracted from the date (e.g., 2017).                                       |
| quarter       | INT       | The quarter of the year (1–4).                                                                |
| month         | INT       | The numeric month of the year (1–12).                                                         |
| month_name    | TEXT      | The full name of the month (e.g., 'January').                                                 |
| day           | INT       | The day of the month (1–31).                                                                  |
| day_of_week   | INT       | The day of the week as a number (0 = Sunday, 6 = Saturday).                                  |
| day_name      | TEXT      | The full name of the day (e.g., 'Monday').                                                    |
| week_of_year  | INT       | The ISO week number within the year (1–53).                                                   |

---

### 2. **gold_layer.dim_customers**
- **Purpose:** Stores customer details enriched with geographic data, used to link customer identity across all fact tables.
- **Source:** `silver_layer.customers`
- **Columns:**

| Column Name              | Data Type    | Description                                                                                   |
|--------------------------|--------------|-----------------------------------------------------------------------------------------------|
| customer_key             | SERIAL       | Surrogate primary key uniquely identifying each customer record in the dimension table.       |
| customer_id              | TEXT         | The original transactional customer ID from the source system (unique per order).             |
| customer_unique_id       | TEXT         | A stable identifier representing the actual unique customer across multiple orders.           |
| customer_zip_code_prefix | VARCHAR(10)  | The first digits of the customer's postal (zip) code.                                         |
| customer_city            | TEXT         | The city where the customer is located.                                                       |
| customer_state           | TEXT         | The state or region where the customer is located.                                            |

---

### 3. **gold_layer.dim_products**
- **Purpose:** Stores product details including category, physical dimensions, and English category translations, enabling product-level analysis.
- **Source:** `silver_layer.products`, `silver_layer.product_category_name_translation`
- **Columns:**

| Column Name                    | Data Type | Description                                                                                   |
|--------------------------------|-----------|-----------------------------------------------------------------------------------------------|
| product_key                    | SERIAL    | Surrogate primary key uniquely identifying each product record in the dimension table.        |
| product_id                     | TEXT      | The original product identifier from the source system.                                       |
| product_category_name          | TEXT      | The product category name in its original language (Portuguese).                              |
| product_category_name_english  | TEXT      | The translated English name of the product category.                                          |
| product_name_length            | INT       | The character length of the product name as listed in the catalogue.                          |
| product_description_length     | INT       | The character length of the product description.                                              |
| product_photos_qty             | INT       | The number of photos published for the product listing.                                       |
| product_weight_g               | INT       | The weight of the product in grams.                                                           |
| product_length_cm              | INT       | The length of the product packaging in centimetres.                                           |
| product_height_cm              | INT       | The height of the product packaging in centimetres.                                           |
| product_width_cm               | INT       | The width of the product packaging in centimetres.                                            |

---

### 4. **gold_layer.dim_sellers**
- **Purpose:** Stores seller details with geographic information, enabling seller-level performance analysis.
- **Source:** `silver_layer.sellers`
- **Columns:**

| Column Name             | Data Type   | Description                                                                                   |
|-------------------------|-------------|-----------------------------------------------------------------------------------------------|
| seller_key              | SERIAL      | Surrogate primary key uniquely identifying each seller record in the dimension table.         |
| seller_id               | TEXT        | The original seller identifier from the source system.                                        |
| seller_zip_code_prefix  | VARCHAR(10) | The first digits of the seller's postal (zip) code.                                           |
| seller_city             | TEXT        | The city where the seller is located.                                                         |
| seller_state            | TEXT        | The state or region where the seller is located.                                              |

---

### 5. **gold_layer.fact_sales**
- **Purpose:** Central fact table capturing individual order line items, joining customers, products, sellers, and dates. Supports revenue, freight, and order fulfilment analysis.
- **Source:** `silver_layer.orders`, `silver_layer.order_items`, `silver_layer.customers`, `gold_layer.dim_customers`, `gold_layer.dim_products`, `gold_layer.dim_sellers`
- **Columns:**

| Column Name                  | Data Type     | Description                                                                                   |
|------------------------------|---------------|-----------------------------------------------------------------------------------------------|
| sales_key                    | SERIAL        | Surrogate primary key uniquely identifying each sales line item record.                       |
| order_id                     | TEXT          | The original order identifier from the source system.                                         |
| customer_key                 | INT           | Foreign key referencing `dim_customers`, identifying the purchasing customer.                 |
| product_key                  | INT           | Foreign key referencing `dim_products`, identifying the product sold.                         |
| seller_key                   | INT           | Foreign key referencing `dim_sellers`, identifying the seller fulfilling the order item.      |
| order_date_key               | DATE          | Foreign key referencing `dim_date` for the date the order was placed.                         |
| approval_date_key            | DATE          | Foreign key referencing `dim_date` for the date the order was approved.                       |
| delivered_carrier_date_key   | DATE          | Foreign key referencing `dim_date` for the date the order was handed to the carrier.          |
| delivered_customer_date_key  | DATE          | Foreign key referencing `dim_date` for the date the order was delivered to the customer.      |
| estimated_delivery_date_key  | DATE          | Foreign key referencing `dim_date` for the estimated delivery date at time of purchase.       |
| order_status                 | TEXT          | The status of the order (e.g., 'delivered', 'shipped', 'cancelled').                          |
| order_item_id                | INT           | The sequential item number within an order, used to distinguish multiple items per order.     |
| price                        | NUMERIC(10,2) | The price of the individual order item, excluding freight.                                    |
| freight_value                | NUMERIC(10,2) | The freight cost associated with delivering the order item.                                   |
| total_value                  | NUMERIC(10,2) | The combined total of price and freight value for the order item.                             |

---

### 6. **gold_layer.fact_payments**
- **Purpose:** Captures payment transactions per order, supporting payment method analysis, instalment tracking, and revenue reconciliation.
- **Source:** `silver_layer.order_payments`, `silver_layer.orders`, `silver_layer.customers`, `gold_layer.dim_customers`
- **Columns:**

| Column Name          | Data Type     | Description                                                                                   |
|----------------------|---------------|-----------------------------------------------------------------------------------------------|
| payment_key          | SERIAL        | Surrogate primary key uniquely identifying each payment record.                               |
| order_id             | TEXT          | The original order identifier from the source system.                                         |
| customer_key         | INT           | Foreign key referencing `dim_customers`, identifying the customer who made the payment.       |
| payment_date_key     | DATE          | Foreign key referencing `dim_date` for the date the payment was made (order purchase date).   |
| payment_sequential   | INT           | The sequence number of the payment, used when an order has multiple payment methods.          |
| payment_type         | TEXT          | The method of payment used (e.g., 'credit_card', 'boleto', 'voucher', 'debit_card').         |
| payment_installments | INT           | The number of instalments chosen by the customer for the payment.                             |
| payment_value        | NUMERIC(10,2) | The monetary value of this individual payment transaction.                                    |

---

### 7. **gold_layer.fact_reviews**
- **Purpose:** Stores customer review scores per order, enabling customer satisfaction analysis and seller/product quality monitoring.
- **Source:** `silver_layer.order_reviews`, `silver_layer.orders`, `silver_layer.customers`, `gold_layer.dim_customers`
- **Columns:**

| Column Name               | Data Type | Description                                                                                   |
|---------------------------|-----------|-----------------------------------------------------------------------------------------------|
| review_key                | SERIAL    | Surrogate primary key uniquely identifying each review record.                                |
| order_id                  | TEXT      | The original order identifier from the source system.                                         |
| customer_key              | INT       | Foreign key referencing `dim_customers`, identifying the customer who submitted the review.   |
| review_creation_date_key  | DATE      | Foreign key referencing `dim_date` for the date the review was created.                       |
| review_score              | INT       | The customer satisfaction score, rated on a scale of 1 (lowest) to 5 (highest).              |
