-- Unit price can't be negative or 0
ALTER TABLE dw.fact_sales
    ADD CONSTRAINT chk_unit_price_pos CHECK (unit_price >= 0) 
;

-- Useful indexes
CREATE INDEX idx_fact_sales_date
    ON dw.fact_sales (date_key)
;

CREATE INDEX idx_fact_sales_customer
    ON dw.fact_sales (customer_key)
;

CREATE INDEX idx_fact_sales_product
    ON dw.fact_sales (product_key)
;

CREATE INDEX idx_fact_sales_country
    ON dw.fact_sales (country_key)
;
