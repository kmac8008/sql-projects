# Cafe Sales Data Cleaning Using SQL

SELECT *
FROM dirty_cafe_sales;

-- Create staging table

CREATE TABLE cafe_staging
LIKE dirty_cafe_sales;

SELECT *
FROM cafe_staging;

INSERT cafe_staging
SELECT *;

-- Rename columns to have no spaces to make it easier to work with

ALTER TABLE cafe_staging
RENAME COLUMN `Transaction ID` TO transaction_id,
RENAME COLUMN Item TO item,
RENAME COLUMN Quantity TO quantity,
RENAME COLUMN `Price Per Unit` TO price_per_unit,
RENAME COLUMN `Total Spent` TO total_spent,
RENAME COLUMN `Payment Method` TO payment_method,
RENAME COLUMN `Location` TO location,
RENAME COLUMN `Transaction Date` TO transaction_date;

-- Remove any UNKNOWN, ERROR or blank values

DELETE 
FROM cafe_staging
WHERE transaction_date OR total_spent OR item OR payment_method OR Location = 'UNKNOWN'
	OR transaction_date OR total_spent OR item OR payment_method OR Location = ''
    OR transaction_date OR total_spent OR item OR payment_method OR Location = 'ERROR';

-- Check for any duplicate values.

SELECT *,
ROW_NUMBER () OVER(
PARTITION BY transaction_id, item, quantity, price_per_unit, total_spent, payment_method, location, transaction_date) AS row_num
FROM cafe_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY transaction_id, item, quantity, price_per_unit, total_spent, payment_method, location, transaction_date) AS row_num
FROM cafe_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- No duplicates were found. Now delete the row_num column.

ALTER TABLE cafe_staging
DROP COLUMN row_num;

-- Check column datatypes. Changed date column from 'text' to 'date'. Changed total_spent from text to int.

ALTER TABLE cafe_staging
MODIFY COLUMN transaction_date DATE;

ALTER TABLE cafe_staging
MODIFY COLUMN total_spent INT;