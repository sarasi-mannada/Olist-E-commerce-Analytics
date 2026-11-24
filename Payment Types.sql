
SELECT
    payment_type,

    COUNT(*) AS total_payments,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS payment_percentage,

    ROUND(
        SUM(NULLIF(payment_value, '')::NUMERIC),
        2
    ) AS total_payment_value

FROM public.olist_order_payments_dataset

GROUP BY payment_type

ORDER BY total_payments DESC;
