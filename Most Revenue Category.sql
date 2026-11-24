
WITH category_sales AS (
    SELECT
        COALESCE(
            NULLIF(TRIM(p.product_category_name), ''),
            'Unknown'
        ) AS category,

        COUNT(DISTINCT oi.order_id) AS orders,

        SUM(
            NULLIF(TRIM(oi.price), '')::NUMERIC
        ) AS product_revenue,

        SUM(
            COALESCE(
                NULLIF(TRIM(oi.price), '')::NUMERIC, 0
            ) +
            COALESCE(
                NULLIF(TRIM(oi.freight_value), '')::NUMERIC, 0
            )
        ) AS total_revenue

    FROM public.olist_order_items_dataset oi

    JOIN public.olist_products_dataset p
        ON oi.product_id = p.product_id

    JOIN public.olist_orders_dataset o
        ON oi.order_id = o.order_id

    WHERE o.order_status NOT IN
        ('canceled', 'unavailable')

    GROUP BY 1
)

SELECT
    category,
    orders,

    ROUND(product_revenue, 0)
        AS product_revenue,

    ROUND(total_revenue, 0)
        AS total_revenue,

    ROUND(
        100.0 * product_revenue /
        NULLIF(SUM(product_revenue) OVER (), 0),
        1
    ) AS pct_of_revenue

FROM category_sales

ORDER BY product_revenue DESC

LIMIT 10;
