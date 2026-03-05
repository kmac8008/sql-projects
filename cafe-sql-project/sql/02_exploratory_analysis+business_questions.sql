# Cafe Sales Exploratory Analysis Using SQL

-- Summarize data with descriptive statistics
-- Mean, median, mode, average, sum, standard deviation

# How many total orders are there?

SELECT COUNT(*) as total_orders
FROM cafe_staging;

# What is the total revenue?

SELECT SUM(total_spent) as total_revenue
FROM cafe_staging;

# Calculate average total spent, amount of items bought and price per unit at each location.

SELECT location, 
ROUND(AVG(total_spent),2) as avg_total, 
ROUND(AVG(quantity),2) as avg_quantity, 
ROUND(AVG(price_per_unit),2) as avg_price_per_unit
FROM cafe_staging
GROUP BY location;

# Calculate mode for total spent (the most frequently occuring value)
-- First need to rank each value and then sort it

SELECT total_spent AS mode
FROM 
(
SELECT total_spent, RANK() OVER(ORDER BY COUNT(*) DESC) Ranking
FROM cafe_staging
GROUP BY total_spent
) as t
WHERE Ranking = 1;

# What is the most commonly ordered item?

SELECT item, SUM(quantity) AS total_quantity
FROM cafe_staging
GROUP BY item
ORDER BY total_quantity DESC
LIMIT 1;

# What is the most commonly ordered item for takeaway?

SELECT item, SUM(quantity) AS total_quantity
FROM cafe_staging
WHERE location = 'Takeaway'
GROUP BY item
ORDER BY total_quantity DESC
LIMIT 1;

# What is the most commonly ordered item for in-store?

SELECT item, SUM(quantity) AS total_quantity
FROM cafe_staging
WHERE location = 'In-store'
GROUP BY item
ORDER BY total_quantity DESC
LIMIT 1;

# What is the least ordered item?

SELECT item, SUM(quantity) AS total_quantity
FROM cafe_staging
GROUP BY item
ORDER BY total_quantity ASC
LIMIT 1;

# How much did people spend in-store versus takeaway?

SELECT location, SUM(total_spent) AS money_spent
FROM cafe_staging
WHERE location = 'Takeaway'
GROUP BY location
UNION 
SELECT location, SUM(total_spent)
FROM cafe_staging
WHERE location = 'In-store'
GROUP BY location
ORDER BY money_spent DESC;

# Which menu items generate the most revenue?

SELECT item, SUM(quantity*price_per_unit) AS revenue
FROM cafe_staging
GROUP BY item
ORDER BY revenue DESC;

# What day of the week generates the most revenue?

SELECT DAYNAME(transaction_date) AS day_of_week, SUM(total_spent) AS revenue
FROM cafe_staging
GROUP BY day_of_week
ORDER BY revenue DESC
LIMIT 1;

# What's the most common order size?

SELECT quantity, COUNT(quantity) AS times_ordered
FROM cafe_staging
GROUP BY quantity
ORDER BY times_ordered DESC;

# What percentage of orders are takeaway versus in-store?

SELECT 
    location,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM cafe_staging
GROUP BY location;

# How do number of transactions change month to month?

SELECT MONTH(transaction_date) as month, COUNT(transaction_id) AS sales, COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER(ORDER BY MONTH(transaction_date) ASC) AS change_in_sales
FROM cafe_staging
GROUP BY month
ORDER BY month ASC;

# How does revenue change month to month?

SELECT MONTH(transaction_date) as month, SUM(total_spent) AS revenue, SUM(total_spent) - LAG(SUM(total_spent),1) OVER(ORDER BY MONTH(transaction_date) ASC) AS change_in_revenue
FROM cafe_staging
GROUP BY month
ORDER BY month ASC;

# Which month had the highest revenue?

SELECT MONTH(transaction_date) as month, SUM(total_spent) AS revenue
FROM cafe_staging
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

# Are takeaway orders increasing over time?

SELECT MONTH(transaction_date) as month, COUNT(transaction_ID) AS takeaway_orders, COUNT(transaction_ID) - LAG(COUNT(transaction_ID),1) OVER(ORDER BY MONTH(transaction_date)) AS change_in_orders
FROM cafe_staging
WHERE location = 'Takeaway'
GROUP BY month
ORDER BY month;

# Rank the top 5 best-selling menu items

SELECT item, 
SUM(quantity) AS quantity_sold, 
RANK() OVER(ORDER BY SUM(quantity) DESC) AS ranking
FROM cafe_staging
GROUP BY item
LIMIT 5;


# Which items are more popular for takeaway than in-store?

SELECT item, 
SUM(CASE WHEN location = 'Takeaway' then quantity ELSE 0 END) as items_takeaway,
SUM(CASE WHEN location = 'In-store' then quantity ELSE 0 END) as items_instore
FROM cafe_staging
GROUP BY item
HAVING SUM(CASE WHEN location = 'Takeaway' then quantity ELSE 0 END) > SUM(CASE WHEN location = 'In-store' then quantity ELSE 0 END)
ORDER BY items_takeaway;

