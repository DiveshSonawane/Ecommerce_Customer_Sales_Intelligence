-- 1. CUSTOMER RANKING
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(revenue, 2) AS revenue,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM customer_revenue
ORDER BY revenue_rank
LIMIT 20;


-- 2. RUNNING REVENUE
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
        ),
        2
    ) AS cumulative_revenue

FROM monthly_revenue
ORDER BY month;



-- 3. MONTH-OVER-MONTH GROWTH
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

revenue_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_revenue
    FROM monthly_revenue
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_revenue, 2) AS previous_month_revenue,

    ROUND(
        (revenue - previous_revenue)
        * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_pct

FROM revenue_with_previous
ORDER BY month;




-- 4. TOP 3 PRODUCTS PER CATEGORY
WITH product_revenue AS (
    SELECT
        COALESCE(
            p.product_category_name,
            'Unknown'
        ) AS category,

        oi.product_id,

        SUM(oi.price) AS revenue

    FROM order_items oi

    LEFT JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        COALESCE(
            p.product_category_name,
            'Unknown'
        ),
        oi.product_id
),

ranked_products AS (
    SELECT
        category,
        product_id,
        revenue,

        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS product_rank

    FROM product_revenue
)

SELECT
    category,
    product_id,
    ROUND(revenue, 2) AS revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    category,
    product_rank;
    
    
-- 5. CUSTOMER SEGMENTATION
WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.price) AS revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_unique_id
)

SELECT
    CASE
        WHEN revenue >= 1000 THEN 'High Value'
        WHEN revenue >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,

    COUNT(*) AS customers,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(AVG(revenue), 2) AS avg_customer_revenue

FROM customer_metrics

GROUP BY
    CASE
        WHEN revenue >= 1000 THEN 'High Value'
        WHEN revenue >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END

ORDER BY total_revenue DESC;


-- 6. CUSTOMER REVENUE CONTRIBUTION
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_contribution_pct

FROM customer_revenue
ORDER BY revenue DESC
LIMIT 20;



-- 7. CATEGORY RANKING
WITH category_revenue AS (
    SELECT
        COALESCE(
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    LEFT JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        COALESCE(
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS category_rank

FROM category_revenue
ORDER BY category_rank;



-- 8. DELIVERY CLASSIFICATION
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END AS delivery_status,

    COUNT(*) AS order_count

FROM orders

GROUP BY
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END

ORDER BY order_count DESC;