-- Create table with the csv structure
-- Every field as text to avoid format error 
-- when loading with the data
CREATE TABLE raw.transactions_raw(
    invoice_no text,
    stock_code text,
    description text,
    quantity text,
    invoice_date text,
    unit_price text,
    customer_id text,
    country text
);