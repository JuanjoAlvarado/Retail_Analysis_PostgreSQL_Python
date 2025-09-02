-- Create a data base (execute connected to the server, not to an specific data base)
-- Later you can reconnect to your data base
CREATE DATABASE retail_analytics
WITH ENCODING 'UTF8' TEMPLATE template1;

-- Create schemas 
CREATE SCHEMA raw; --raw data from csv
CREATE SCHEMA stg; --staging: cleaning and typo
CREATE SCHEMA dw; -- data warehouse (dimension and facts tables)
CREATE SCHEMA rpt; -- for materialized views
