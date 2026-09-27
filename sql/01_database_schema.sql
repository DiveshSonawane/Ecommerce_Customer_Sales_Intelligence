CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

SELECT DATABASE();

-- Customers Table
CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- Products Table
CREATE TABLE products(
	product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2), 
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

-- Orders Table
CREATE TABLE orders (
	order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    CONSTRAINT fk_orders_customer
		FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- Order_items Table
CREATE TABLE order_items(
	order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    
    PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order
		FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
	CONSTRAINT fk_items_product
		FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- Order_payments Table
CREATE TABLE order_payments(
	order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    
    PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order
		FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

SHOW TABLES;

DESCRIBE customers;

DESCRIBE products;

DESCRIBE orders;

DESCRIBE order_items;

DESCRIBE order_payments;

-- checking relationships
SELECT 
	TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
	AND REFERENCED_TABLE_NAME IS NOT NULL;
    
SELECT COUNT(*) AS customer_count FROM customers;

SELECT * FROM customers LIMIT 10;

SELECT COUNT(*) AS products_count FROM products;

SELECT COUNT(*) AS orders_count FROM orders;

SELECT COUNT(*) AS order_items_count FROM order_items;

SELECT COUNT(*) AS payment_count FROM order_payments;