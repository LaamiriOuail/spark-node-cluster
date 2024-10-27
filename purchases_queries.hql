-- purchases_queries.hql

-- Step 1: Create the purchases1 table
CREATE TABLE IF NOT EXISTS purchases1 (
  `date` STRING,
  temps STRING,
  magasin STRING,
  produit STRING,
  cout FLOAT,
  paiement STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;

-- Step 2: Load data into the purchases1 table
LOAD DATA LOCAL INPATH '/opt/purchases1.txt' OVERWRITE INTO TABLE purchases1;

-- Verify table creation
SHOW TABLES;

-- Check the row count in purchases1
SELECT COUNT(*) AS row_count FROM purchases1;

-- Show the structure of the purchases1 table
SHOW CREATE TABLE purchases1;

-- Step 3: Execute queries on the purchases1 table

-- 1. Get the total cost of all purchases
SELECT SUM(cout) AS total_cost FROM purchases1;

-- 2. Get the number of purchases made in each store
SELECT magasin, COUNT(*) AS num_purchases FROM purchases1 GROUP BY magasin;

-- 3. Get the total cost of purchases for each product
SELECT produit, SUM(cout) AS total_cost FROM purchases1 GROUP BY produit;

-- 4. Get the total cost of purchases for each product in each store
SELECT magasin, produit, SUM(cout) AS total_cost FROM purchases1 GROUP BY magasin, produit;

-- 5. Get the top 10 most-sold products in descending order
SELECT produit, COUNT(*) AS sales_count FROM purchases1 GROUP BY produit ORDER BY sales_count DESC LIMIT 10;

-- 6. Get the list of stores and their total sales cost in descending order
SELECT magasin, SUM(cout) AS total_sales FROM purchases1 GROUP BY magasin ORDER BY total_sales DESC;

-- 7. Get the number of sales made each day
SELECT date, COUNT(*) AS daily_sales FROM purchases1 GROUP BY date;

-- 8. Get the average cost of sales per product
SELECT produit, AVG(cout) AS average_cost FROM purchases1 GROUP BY produit;

-- 9. Get purchases made by payment method and their total cost
SELECT paiement, SUM(cout) AS total_cost FROM purchases1 GROUP BY paiement;

-- 10. Get the products most frequently sold on Mondays
SELECT produit, COUNT(*) AS sales_count 
FROM purchases1 
WHERE dayofweek(date) = 2  -- Assuming date is in a compatible format
GROUP BY produit ORDER BY sales_count DESC;
