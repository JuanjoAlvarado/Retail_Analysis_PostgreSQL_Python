-- DIMENSION
-- Clients (with surrogate key)
CREATE TABLE dw.dim_customer (
    customer_key    bigserial PRIMARY KEY,
    customer_id     VARCHAR(20) UNIQUE,
    first_country   VARCHAR(20),
    firt_seen_ts    timestamp
);

-- Products
CREATE TABLE dw.dim_product (
    product_key     bigserial PRIMARY KEY,
    stock_code      VARCHAR(20) UNIQUE,
    description     TEXT
);

-- Country
CREATE TABLE dw.dim_country (
    country_key     bigserial PRIMARY KEY,
    country         VARCHAR(60) UNIQUE
);

-- Date (calendar table)
CREATE TABLE dw.dim_date (
    date_key        date PRIMARY KEY,
    year            INTEGER,
    quarter         INTEGER,
    month           INTEGER,
    day             INTEGER,
    dow             INTEGER,
    month_name      TEXT
);


-- Populate Customer Table
INSERT INTO dw.dim_customer (
    customer_id,
    first_country,
    firt_seen_ts
)
SELECT
    customer_id,
    MIN(country) FILTER (WHERE country IS NOT NULL),
    MIN(invoice_ts)
FROM
    stg.transactions
WHERE
    customer_id IS NOT NULL
GROUP BY
    customer_id
ON CONFLICT (customer_id) DO NOTHING;

-- Populate Product table
INSERT INTO dw.dim_product (
    stock_code,
    description
)
SELECT
    stock_code,
    MIN(description)
FROM
    stg.transactions
GROUP BY
    stock_code
ON CONFLICT (stock_code) DO NOTHING;

-- Populate Country Table
INSERT INTO dw.dim_country (country)
SELECT
    DISTINCT country
FROM
    stg.transactions
WHERE
    country IS NOT NULL
ON CONFLICT (country) DO NOTHING;

-- Populate calendar table with date range of dataset
INSERT INTO dw.dim_date
SELECT
    d::date,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(ISODOW FROM d)::INTEGER,
    TO_CHAR(d, 'Mon')
FROM
    generate_series(
        '2010-01-01'::timestamp,
        '2012-12-31'::timestamp,
        interval '1 day'
    ) d;

-----------------------------------------------------
-- FACT
CREATE TABLE dw.fact_sales (
    sales_key       bigserial PRIMARY KEY,
    invoice_no      VARCHAR(20),
    customer_key    BIGINT REFERENCES dw.dim_customer(customer_key),
    product_key     BIGINT REFERENCES dw.dim_product(product_key),
    country_key     BIGINT REFERENCES dw.dim_country(country_key),
    date_key        date REFERENCES dw.dim_date(date_key),
    invoice_ts      timestamp NOT NULL,
    quantity        INTEGER NOT NULL,
    unit_price      NUMERIC(12, 2) NOT NULL,
    is_return       BOOLEAN NOT NULL,
    line_amount     NUMERIC(14, 2)
);

-- Populate Fact sales table
INSERT INTO dw.fact_sales (
    invoice_no,
    customer_key,
    product_key,
    country_key,
    date_key,
    invoice_ts,
    quantity,
    unit_price,
    is_return,
    line_amount
)
SELECT
    s.invoice_no,
    dc.customer_key,
    dp.product_key,
    dco.country_key,
    (s.invoice_ts)::date AS date_key,
    s.invoice_ts,
    s.quantity,
    s.unit_price,
    s.is_return,
    (s.quantity * s.unit_price)::NUMERIC(14, 2)
FROM
    stg.transactions AS s 
LEFT JOIN dw.dim_customer dc
    ON dc.customer_id = s.customer_id
LEFT JOIN dw.dim_product dp
    ON dp.stock_code = s.stock_code
LEFT JOIN dw.dim_country dco
    ON dco.country = s.country
;

