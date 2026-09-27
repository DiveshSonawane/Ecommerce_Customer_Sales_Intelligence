-- Step 1: Total Orders
SELECT COUNT(*) AS total_orders FROM orders;

-- step 2: Total Customers
SELECT COUNT(*) AS total_customers FROM customers;

-- step 3: Total Products
SELECT COUNT(*) AS total_products FROM products; 

-- step 4: Total items sold
SELECT COUNT(*) AS total_items FROM order_items;

-- step 5: Total item revenue 
SELECT 
	ROUND(SUM(price), 2) AS total_item_revenue
FROM order_items;

-- step 6: Total freight
SELECT 
	ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;

-- step 7: Total payment value
SELECT 
	ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments;

-- step 8: Average item price
SELECT 
	ROUND(AVG(price), 2) AS average_item_price
FROM order_items;

-- 1. Combining all into one to get KPI values
SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM customers) AS total_customer_records,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM order_items) AS total_order_items,
    (SELECT ROUND(SUM(price), 2) FROM order_items) AS total_item_revenue,
    (SELECT ROUND(SUM(freight_value), 2) FROM order_items) AS total_freight,
    (SELECT ROUND(SUM(payment_value), 2) FROM order_payments) AS total_payment_value,
    (SELECT ROUND(AVG(price), 2) FROM order_items) AS average_item_price;
    
    
-- 2. Average Order value
SELECT 
	ROUND(SUM(oi.price)/COUNT(DISTINCT oi.order_id), 2)
    AS  average_order_value
FROM order_items oi;

-- 3. Revenue Order By Status
SELECT order_status, COUNT(*) AS order_count, 
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2)
    AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 4. Cancellation Rate
SELECT 
	COUNT(CASE WHEN order_status = 'canceled' THEN 1 END)
		AS canceled_orders,
	COUNT(*) AS total_orders,
    ROUND(
		COUNT(CASE WHEN order_status = 'canceled' THEN 1 END)
        * 100.0 / COUNT(*), 2)
        AS cancellation_rate
	FROM orders;


-- 5. Monthly Revenue (How did sales change over time?)
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS item_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;
    
    
-- 6. Monthly Order Volume
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY
    month;
    
-- 7. MONTHLY REVENUE + PREVIOUS MONTH
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT
    month,
    revenue,

    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,

    ROUND(
        (revenue - LAG(revenue) OVER (
            ORDER BY month
        ))
        * 100.0
        /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY month
            ),
            0
        ),
        2
    ) AS revenue_growth_percentage

FROM monthly_revenue
ORDER BY month;


-- 8. Order level Revenue
WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue,
        SUM(freight_value) AS freight_value,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_revenue;



-- 9. MONTHLY REVENUE — ORDER LEVEL
WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue,
        SUM(freight_value) AS freight_value,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(r.item_revenue), 0), 2) AS item_revenue,
    ROUND(COALESCE(SUM(r.freight_value), 0), 2) AS freight,
    ROUND(COALESCE(SUM(r.order_value), 0), 2) AS total_order_value
FROM orders o
LEFT JOIN order_revenue r
    ON o.order_id = r.order_id
GROUP BY
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY
    month;
    
    

-- 10. MONTHLY AOV 
WITH order_revenue AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items
    GROUP BY order_id
)

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    ROUND(COALESCE(SUM(r.order_value), 0), 2) AS total_order_value,
    ROUND(
        COALESCE(SUM(r.order_value), 0) / COUNT(*),
        2
    ) AS average_order_value
FROM orders o
LEFT JOIN order_revenue r
    ON o.order_id = r.order_id
GROUP BY
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY
    month;
    


-- 11 UNIQUE CUSTOMERS
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- 12. ORDERS PER UNIQUE CUSTOMERS
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_unique_id
ORDER BY
    total_orders DESC;
    


-- 13. ONE TIME VS REPEAT CUSTOMERS
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY
    customer_count DESC;
    


-- 14. REPEAT CUSTOMER RATE
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) AS one_time_customers,

    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate

FROM customer_orders;


-- 15. CUSTOMER REVENUE
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_unique_id
ORDER BY
    total_revenue DESC
LIMIT 20;



-- 16. AVERAGE REVENUE PER CUSTOMER
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    COUNT(*) AS customers_with_revenue,
    ROUND(AVG(total_revenue), 2) AS average_customer_revenue,
    ROUND(MAX(total_revenue), 2) AS highest_customer_revenue
FROM customer_revenue;



-- 17. CUSTOMER PURCHASE FREQUENCY
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders = 2 THEN '2 Orders'
        WHEN total_orders = 3 THEN '3 Orders'
        WHEN total_orders = 4 THEN '4 Orders'
        ELSE '5+ Orders'
    END AS purchase_frequency,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE
        WHEN total_orders = 1 THEN '1 Order'
        WHEN total_orders = 2 THEN '2 Orders'
        WHEN total_orders = 3 THEN '3 Orders'
        WHEN total_orders = 4 THEN '4 Orders'
        ELSE '5+ Orders'
    END
ORDER BY
    customer_count DESC;
    
    
-- 18. TOP PRODUCTS BY REVENUE
SELECT
    oi.product_id,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight
FROM order_items oi
GROUP BY oi.product_id
ORDER BY revenue DESC
LIMIT 20;


-- 19. CATEGORY PERFORMANCE
SELECT
    COALESCE(p.product_category_name, 'Unknown') AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    COALESCE(p.product_category_name, 'Unknown')
ORDER BY revenue DESC
LIMIT 20;



-- 20. CATEGORY REVENUE SHARE
WITH category_revenue AS (
    SELECT
        COALESCE(p.product_category_name, 'Unknown') AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    LEFT JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        COALESCE(p.product_category_name, 'Unknown')
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC
LIMIT 20;


-- 21. AVERAGE DELIVERY TIME
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE
    order_delivered_customer_date IS NOT NULL;
    
    
-- 22. DELIVERY PERFORMANCE
SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS avg_difference_days,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date
                     <= order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_pct

FROM orders
WHERE
    order_delivered_customer_date IS NOT NULL;
    
    
-- 23. PAYMENT METHOD ANALYSIS
SELECT
    payment_type,
    COUNT(*) AS payment_transactions,
    COUNT(DISTINCT order_id) AS unique_orders,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;


-- 24. PAYMENT INSTALLMENTS
SELECT
    payment_installments,
    COUNT(*) AS transactions,
    ROUND(SUM(payment_value), 2) AS total_payment,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- 25. REVENUE BY STATE
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_state
ORDER BY revenue DESC;


-- 26. TOP CITIES BY ORDERS
SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_city,
    c.customer_state
ORDER BY total_orders DESC
LIMIT 20;