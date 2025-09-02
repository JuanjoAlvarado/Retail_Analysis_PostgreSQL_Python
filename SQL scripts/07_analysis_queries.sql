-- Top 10 Country by sales (last 12 months)
SELECT
    country,
    SUM(net_sales) AS sales_last_year
FROM
    rpt.mv_monthly_sales_country
WHERE
    month >= ((
        SELECT
            MAX(month)
        FROM
            rpt.mv_monthly_sales_country
    ) - INTERVAL '12 months')::date
GROUP BY
    country
ORDER BY
    sales_last_year DESC
LIMIT 10
;

-- RFM score and label
SELECT
    customer_key,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Great'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal'
        WHEN r_score <= 2 AND f_score <= 2
            THEN 'At Risk'
        ELSE 'Others'
    END AS segment
FROM
    rpt.mv_rfm
;

-- Monthly Global Tendency
SELECT
    month,
    SUM(net_sales) AS net_sales
FROM
    rpt.mv_monthly_sales_country
GROUP BY
    month
ORDER BY
    month
;

-- Pair Products bought with more frequency
SELECT
    product_a_desc,
    product_b_desc,
    co_occur
FROM
    rpt.basket_pairs
ORDER BY
    co_occur DESC
LIMIT 20
;
