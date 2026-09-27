-- Step 1: Verify all the tables together 
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers

UNION ALL

SELECT 'products', COUNT(*) FROM products

UNION ALL

SELECT 'orders', COUNT(*) FROM orders

UNION ALL

SELECT 'order_items', COUNT(*) FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*) FROM order_payments;

-- Step 2: Check Duplicate Primary Keys
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Step 3: Order Item Uniqueness
SELECT order_id, order_item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Step 4: Payment uniqueness
SELECT order_id, payment_sequential, COUNT(*) AS duplicate_count
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- step 5: Check NULLs In Customers
SELECT 
	SUM(customer_id IS NULL) AS null_customer_id,
    SUM(customer_unique_id IS NULL) AS null_customer_unique_id,
    SUM(customer_zip_code_prefix IS NULL) AS null_zip,
    SUM(customer_city IS NULL) AS null_city,
    SUM(customer_state IS NULL) AS null_state
FROM customers;

-- step 6: Check NULLs in orders
SELECT 
	SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_status IS NULL) AS null_status,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase_stamp,
    SUM(order_approved_at IS NULL) AS null_approved_date,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier_date,
    SUM(order_delivered_customer_date IS NULL) AS null_delivery_date,
    SUM(order_estimated_delivery_date IS NULL) AS null_estimated_date
FROM orders;

-- step 7: Check Financial values 
SELECT 
	MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight
FROM order_items;

SELECT 
	MIN(payment_value) AS min_payment,
    MAX(payment_value) AS max_payment,
    AVG(payment_value) AS avg_payment
FROM order_payments;

-- step 8: check order Statuses
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Step 9 : orphan data check
SELECT COUNT(*) AS orphan_orders
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT 
	COUNT(*) AS missing_product_rows,
    COUNT(DISTINCT oi.product_id) AS missing_product_ids,
    ROUND(SUM(oi.price), 2) AS affected_item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS affected_freight
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;



-- why 611 products are absent ?
SELECT
    oi.product_id,
    COUNT(*) AS order_item_count,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
GROUP BY oi.product_id
ORDER BY item_revenue DESC
LIMIT 20;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_approved_at IS NULL) AS missing_approved,
    SUM(order_delivered_carrier_date IS NULL) AS missing_carrier,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;