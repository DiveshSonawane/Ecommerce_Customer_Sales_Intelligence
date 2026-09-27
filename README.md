# E-Commerce Customer & Sales Intelligence

## 📊 Project Overview

An end-to-end SQL analytics project built using the Brazilian Olist e-commerce dataset to analyze customer behavior, sales performance, products, payments, delivery operations, and business KPIs.

The project demonstrates practical SQL skills required for Data Analyst and Business Analyst roles, including data validation, multi-table joins, aggregations, CTEs, window functions, ranking, time-series analysis, and customer segmentation.

---

## 🎯 Business Problem

E-commerce businesses generate large volumes of transactional data across customers, orders, products, payments, and logistics.

The objective of this project is to transform raw transactional data into actionable business insights by answering questions such as:

* How much revenue is being generated over time?
* What is the average order value?
* Which products and categories generate the most revenue?
* How many customers are repeat customers?
* What is the customer repeat-purchase rate?
* Which payment methods are most frequently used?
* How effectively are orders being delivered?
* Which states generate the highest revenue?
* Who are the highest-value customers?
* How does revenue change month over month?
* What percentage of revenue is contributed by individual customers or categories?

---

## 🗂️ Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The analysis uses five primary tables:

| Table          | Records |
| -------------- | ------: |
| Customers      |  99,441 |
| Orders         |  99,441 |
| Order Items    | 112,650 |
| Order Payments | 103,886 |
| Products       |  32,340 |

The raw CSV files are not included in this repository.

---

## 🛠️ Tools & Technologies

* MySQL 8.0
* MySQL Workbench
* MySQL Shell
* SQL
* Git
* GitHub

---

## 🗄️ Database Structure

```text
Customers
    │
    │ customer_id
    ▼
Orders
    │
    ├──────────────► Order Items
    │                  │
    │                  ▼
    │               Products
    │
    └──────────────► Order Payments
```

---

## 🔍 Project Workflow

### 1. Database & Data Loading

Created the `ecommerce_analytics` MySQL database and imported the Olist datasets into relational tables.

### 2. Data Quality Analysis

Performed validation checks including:

* Duplicate primary-key checks
* NULL-value analysis
* Orphan-record detection
* Referential consistency checks
* Revenue and payment-value validation
* Order-status validation

### 3. Business Analysis

Analyzed:

* Total orders
* Total customers
* Revenue
* Freight costs
* Average Order Value
* Order status
* Cancellation rate
* Monthly revenue
* Customer purchasing behavior
* Product performance
* Category performance
* Payment methods
* Geographic performance
* Delivery performance

### 4. Advanced SQL Analysis

Implemented:

* Common Table Expressions (CTEs)
* Window functions
* `RANK()`
* `ROW_NUMBER()`
* `LAG()`
* Running totals
* Month-over-month growth
* Revenue contribution
* Customer segmentation
* Top-N analysis
* Conditional aggregation

---

## 📈 Key Findings

### Customer Behavior

* 96,096 unique customers were identified.
* 2,997 customers were classified as repeat customers.
* 93,099 customers were classified as one-time customers.
* Repeat-customer rate was approximately 3.12%.

### Sales Performance

* Total item revenue analyzed: approximately ₹13.59M in dataset currency.
* Average Order Value: approximately ₹137.75 based on the project's order-level revenue calculation.
* Revenue analysis showed strong growth throughout the main 2017–2018 sales period.

### Order Status

The majority of orders were delivered, with smaller proportions in shipped, canceled, unavailable, invoiced, processing, created, and approved states.

### Delivery

Delivery performance was evaluated by comparing actual customer delivery dates with estimated delivery dates.

### Customer Analytics

Customer-level revenue ranking and purchase-frequency analysis were performed to identify high-value and repeat purchasing behavior.

---

## 📁 SQL Files

### `01_schema.sql`

Creates the database tables and defines the relational structure.

### `02_data_quality_audit.sql`

Contains data validation and quality-control queries.

### `03_business_analysis.sql`

Contains business-focused analysis including sales, customers, products, payments, delivery, and geographic analysis.

### `04_advanced_sql.sql`

Contains advanced SQL techniques including CTEs, window functions, ranking, running totals, month-over-month analysis, and segmentation.

---

## 🧠 SQL Skills Demonstrated

```text
SELECT
WHERE
GROUP BY
ORDER BY
HAVING
CASE WHEN
JOIN
LEFT JOIN
COUNT
COUNT DISTINCT
SUM
AVG
ROUND
COALESCE
DATEDIFF
DATE_FORMAT
CTEs
Window Functions
RANK
ROW_NUMBER
LAG
Running Totals
Time-Series Analysis
Customer Segmentation
Revenue Analysis
Data Quality Validation
```

---

## 💼 Business Value

This project demonstrates how SQL can be used to move from raw transactional data to structured business insights.

The analysis can support decisions related to:

* Customer retention
* Revenue monitoring
* Product/category performance
* Payment behavior
* Delivery operations
* Geographic expansion
* Customer segmentation
* Sales performance monitoring

---

## 🚀 Future Improvements

Potential extensions include:

* Power BI dashboard
* Automated ETL pipeline
* Data warehouse implementation
* Advanced customer lifetime value analysis
* Cohort analysis
* RFM customer segmentation
* Automated reporting
* Python-based exploratory analysis

---

## 👨‍💻 Author

**Divesh Sonawane**

Computer Engineering Graduate | Data Analyst | SQL | Python | Power BI

---

## 📌 Project Status

**Completed — SQL Analytics Version**

Future enhancements may include BI visualization and advanced data-engineering components.
