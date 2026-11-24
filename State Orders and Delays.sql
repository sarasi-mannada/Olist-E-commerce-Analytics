
WITH delivery_data AS (
    SELECT
        c.customer_state AS state,
        o.order_id,

        NULLIF(o.order_purchase_timestamp, '')::timestamp AS purchase_date,
        NULLIF(o.order_delivered_customer_date, '')::timestamp AS delivered_date,
        NULLIF(o.order_estimated_delivery_date, '')::timestamp AS estimated_date

    FROM public.olist_orders_dataset o
    JOIN public.olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
),

delivery_metrics AS (
    SELECT
        state,
        order_id,

        EXTRACT(EPOCH FROM (delivered_date - purchase_date))
            / 86400.0 AS delivery_days,

        GREATEST(
            EXTRACT(EPOCH FROM (delivered_date - estimated_date))
            / 86400.0,
            0
        ) AS delay_days,

        CASE
            WHEN delivered_date > estimated_date THEN 1
            ELSE 0
        END AS is_late

    FROM delivery_data

    WHERE purchase_date IS NOT NULL
      AND delivered_date IS NOT NULL
      AND estimated_date IS NOT NULL
)

SELECT
    state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * AVG(is_late), 2) AS late_delivery_pct

FROM delivery_metrics
GROUP BY state
ORDER BY total_orders DESC;
