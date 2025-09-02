-- Create table in the "stg" schema with the proper variable type
DROP TABLE IF EXISTS stg.transactions;
CREATE TABLE stg.transactions (
    invoice_no  VARCHAR(20),
    stock_code  VARCHAR(20),
    description TEXT,
    quantity    INTEGER,
    invoice_ts  TIMESTAMP,
    unit_price  NUMERIC(12, 2),
    customer_id VARCHAR(20),
    country     VARCHAR(60),
    is_return   BOOLEAN,
    row_source  TEXT
);

-- Insert into the table a basic cleaned data
WITH cleaned AS (
    SELECT
        NULLIF(TRIM(invoice_no), '') AS invoice_no,
        NULLIF(TRIM(stock_code), '') AS stock_code,
        NULLIF(TRIM(description), '') AS description,
        NULLIF(TRIM(customer_id), '') AS customer_id,
        NULLIF(TRIM(country), '') AS country,
        -- Filter non numeric values: quantity -> integer
       CASE
          WHEN quantity ~ '^-?\d+$' 
            THEN quantity::INT
            ELSE NULL
        END AS quantity_clean,
        -- TIME STAMP format MM/DD/YYYY HH:MI
        TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI') AS invoice_ts,
        -- Filter non numeric values: unit_price -> numeric
        CASE
            WHEN unit_price ~ '^-?\d+(\.\d+)?$' THEN unit_price::NUMERIC(12, 2)
            ELSE NULL
        END AS unit_price,
        -- Returns: quantity is negative or invoice_no starts with "C"
        CASE
            WHEN (quantity ~ '^-?\d+$' AND quantity::INTEGER < 0)
                OR (invoice_no ILIKE 'C%') THEN TRUE ELSE FALSE
        END AS is_return,

        'raw.transacions_raw'::TEXT AS row_source
    FROM raw.transactions_raw
)
INSERT INTO stg.transactions(
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_ts,
    unit_price,
    customer_id,
    country,
    is_return,
    row_source
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity_clean,  
    invoice_ts,
    unit_price,
    customer_id,
    country,
    is_return,
    row_source
FROM cleaned
WHERE invoice_no IS NOT NULL
    AND stock_code IS NOT NULL
    AND invoice_ts IS NOT NULL
    AND unit_price IS NOT NULL
;

-- Check data and manage 
-- Duplicated ROWS
SELECT
    invoice_no,
    stock_code,
    invoice_ts,
    COUNT(*)
FROM
    stg.transactions
GROUP BY 1, 2, 3
HAVING COUNT(*)>1;

-- Suspicious Values
SELECT
    COUNT(*) AS qty_leq_zero
FROM
    stg.transactions
WHERE
    (quantity <= 0) AND (is_return = FALSE);

-- Key null values
SELECT
    SUM(
        CASE
            WHEN customer_id IS NULL
                THEN 1
            ELSE 0
        END
    ) AS null_customers,
    SUM(
        CASE
            WHEN description IS NULL
                THEN 1
            ELSE 0
        END
    ) AS null_desc
FROM
    stg.transactions;