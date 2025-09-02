-- No sales with negative price
SELECT
    COUNT(*) AS no_valid
FROM
    dw.fact_sales
WHERE
    unit_price < 0
;

-- Synchronized fact and dimension tables
SELECT
    COUNT(*) AS orphans
FROM
    dw.fact_sales AS f
LEFT JOIN dw.dim_product AS p
    ON p.product_key = f.product_key
WHERE
    p.product_key IS NULL
;

-- Date consistent with dim_date table
SELECT
    COUNT(*) AS not_valid
FROM
    dw.fact_sales AS f
LEFT JOIN dw.dim_date AS d
    ON d.date_key = f.date_key
WHERE
    d.date_key IS NULL
;