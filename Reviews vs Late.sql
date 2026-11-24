
WITH reviews_per_order AS (
    SELECT
        order_id,
        AVG(review_score::NUMERIC) AS review_score
    FROM public.olist_order_reviews_dataset
    WHERE TRIM(review_score) ~ '^[1-5]$'
    GROUP BY order_id
),

delivery_analysis AS (
    SELECT
        o.order_id,
        r.review_score,

        CASE
            WHEN
                o.order_delivered_customer_date::timestamp::date >
                o.order_estimated_delivery_date::timestamp::date
            THEN 1
            ELSE 0
        END AS is_late

    FROM public.olist_orders_dataset o

    JOIN reviews_per_order r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND NULLIF(TRIM(o.order_delivered_customer_date), '') IS NOT NULL
      AND NULLIF(TRIM(o.order_estimated_delivery_date), '') IS NOT NULL
)

SELECT
    CASE
        WHEN is_late = 1 THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(AVG(review_score), 2)
        AS avg_review_score,

    COUNT(*) FILTER (
        WHERE review_score <= 2
    ) AS low_review_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE review_score <= 2
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS low_review_percentage,

    ROUND(
        (
            SELECT CORR(review_score, is_late::NUMERIC)
            FROM delivery_analysis
        )::NUMERIC,
        3
    ) AS overall_correlation

FROM delivery_analysis

GROUP BY is_late
ORDER BY is_late;
