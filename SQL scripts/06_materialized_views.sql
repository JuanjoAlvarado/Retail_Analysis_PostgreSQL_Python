-- Monthly Sales by Country
CREATE MATERIALIZED VIEW rpt.mv_monthly_sales_country AS 
SELECT
    DATE_TRUNC('month', f.invoice_ts)::date AS month,
    co.country,
    SUM(
        CASE
            WHEN is_return
                THEN -line_amount
            ELSE line_amount
        END
    ) AS net_sales
FROM
    dw.fact_sales AS f 
JOIN dw.dim_country AS co 
    ON co.country_key = f.country_key
GROUP BY 
    1, 2
;

CREATE INDEX ON rpt.mv_monthly_sales_country (month, country);


-- RFM (Recency, Frequency, Monetary) with NTILE
CREATE MATERIALIZED VIEW rpt.mv_rfm AS
WITH base AS (
    SELECT
        c.customer_key,
        CURRENT_DATE - MAX(f.date_key) AS recency_days,
        COUNT(DISTINCT f.invoice_no) AS frequency,
        SUM(
            CASE
                WHEN f.is_return
                    THEN -f.line_amount
                ELSE f.line_amount
            END
        ) AS monetary 
    FROM
        dw.fact_sales AS f 
    JOIN dw.dim_customer AS c
        ON c.customer_key = f.customer_key
    GROUP BY
        c.customer_key
)
SELECT *,
    NTILE(5) OVER (
        ORDER BY
            recency_days ASC
    ) AS r_score,
    NTILE(5) OVER (
        ORDER BY
            frequency DESC
    ) AS f_score,
    NTILE(5) OVER (
        ORDER BY
            monetary DESC
    ) AS m_score
FROM
    base
;


-- Retention series by month of first purchase
CREATE MATERIALIZED VIEW rpt.mv_series AS
WITH first_order AS (
    SELECT
        customer_key,
        MIN(DATE_TRUNC('month', invoice_ts)) AS series_month
    FROM
        dw.fact_sales
    GROUP BY
        1
),
activity AS (
    SELECT
        f.customer_key,
        DATE_TRUNC('month', f.invoice_ts) AS activity_month
    FROM
        dw.fact_sales AS f
    GROUP BY
        1, 2
)
SELECT
    fo.series_month::date,
    activity_month::date,
    EXTRACT(MONTH FROM age(activity_month, fo.series_month))::INTEGER AS months_since,
    COUNT(DISTINCT a.customer_key) AS active_customers
FROM
    first_order AS fo
JOIN activity AS a
    ON a.customer_key = fo.customer_key
GROUP BY
    1, 2, 3
;


-- Market Basket
CREATE MATERIALIZED VIEW rpt.basket_pairs AS
WITH lines AS (
    SELECT
        invoice_no,
        product_key
    FROM
        dw.fact_sales
    WHERE NOT is_return
    GROUP BY
        1, 2
),
pairs AS (
    SELECT
        l1.product_key AS product_a,
        l2.product_key AS product_b,
        COUNT(*) AS co_occur
    FROM
        lines AS l1
    JOIN lines AS l2
        ON l1.invoice_no = l2.invoice_no
            AND l1.product_key < l2.product_key
    GROUP BY
        1, 2
)
SELECT
    p.*,
    pa.description AS product_a_desc,
    pb.description AS product_b_desc
FROM
    pairs AS p
JOIN dw.dim_product AS pa
    ON pa.product_key = p.product_a
JOIN dw.dim_product AS pb
    ON pb.product_key = p.product_b
;