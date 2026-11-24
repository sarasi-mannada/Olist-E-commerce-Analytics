
WITH cust AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS n_orders

    FROM public.olist_orders_dataset o

    JOIN public.olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status NOT IN
        ('canceled', 'unavailable')

    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS customers,

    SUM(
        CASE WHEN n_orders > 1 THEN 1 ELSE 0 END
    ) AS repeat_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN n_orders > 1 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_rate_pct

FROM cust;
