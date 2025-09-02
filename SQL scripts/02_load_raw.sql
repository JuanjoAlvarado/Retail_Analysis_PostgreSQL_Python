-- Make FDW available to avoid depending \COPY (psql), only SQL
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER csv_server FOREIGN DATA WRAPPER file_fdw;

DROP FOREIGN TABLE IF EXISTS raw.transactions_csv_ext;
CREATE FOREIGN TABLE raw.transactions_csv_ext(
    invoice_no   text,
    stock_code   text,
    description  text,
    quantity     text,
    invoice_date text,
    unit_price   text,
    customer_id  text,
    country      text
) SERVER csv_server
OPTIONS (filename 'C:/Program Files/PostgreSQL/16/data/OnlineRetail.csv',
FORMAT 'csv', HEADER 'true', DELIMiTER ',', NULL '', ENCODING 'LATIN1');

INSERT INTO raw.transactions_raw
SELECT * FROM raw.transactions_csv_ext;