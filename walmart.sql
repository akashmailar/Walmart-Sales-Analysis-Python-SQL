SELECT *
FROM walmart_database.walmart;

SELECT DISTINCT category
FROM walmart_database.walmart;

SELECT DISTINCT payment_method
FROM walmart_database.walmart;

SELECT COUNT(DISTINCT branch)
FROM walmart_database.walmart;

SELECT payment_method, COUNT(*)
FROM walmart_database.walmart
GROUP BY payment_method;

SELECT MAX(quantity)
FROM walmart_database.walmart;

SELECT MIN(quantity)
FROM walmart_database.walmart;

-- Business Problems

-- Q1. Find different payment methods and number of transactions, number of quantities sold. 

SELECT 
	payment_method, 
    COUNT(*) as no_of_transactions,
    SUM(quantity) as qty_sold
FROM walmart_database.walmart
GROUP BY payment_method;


-- Q2. Identify the highest-rated category in each branch, displaying the branch, category. 

SELECT *
FROM
	(SELECT
		branch, 
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking
	FROM walmart_database.walmart 
	GROUP BY branch, category
	ORDER BY branch, AVG(rating) DESC) as rating_table
WHERE ranking = 1;


-- Q3. Identify the busiest day for each branch based on the number of transactions.

UPDATE walmart_database.walmart
SET date = str_to_date(date, '%d-%m-%Y');

ALTER TABLE walmart_database.walmart
MODIFY date DATE;

SELECT *
FROM
	(SELECT 
		branch,
		dayname(date) as day_name,
		COUNT(payment_method) as no_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) as ranking
	FROM walmart_database.walmart
	GROUP BY branch, day_name
	ORDER BY branch, no_of_transactions DESC) as day_ranking
WHERE ranking = 1;


-- Q4. Calculate the total quantity of items sold per payment method. List payment method and total quantity.

SELECT 
	payment_method,
    SUM(quantity) as total_qty
FROM walmart_database.walmart
GROUP BY payment_method
ORDER BY total_qty DESC;


-- Q5. Determine the average, minimum and maximum rating of products for each city.
--     List the city, average rating, minimum rating and maximum rating.

SELECT 
	city,
    category,
    AVG(rating) as avg_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM walmart_database.walmart
GROUP BY city, category
ORDER BY city;


-- Q6. Calculate the total profit for each category by considering 
--     total profit as (unit_price * quantity * profit_margin).
--     List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
    SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart_database.walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q7. Determine the most common payment method for each branch. 
--     Display branch and the preferred payment method.

SELECT *
FROM
	(SELECT 
		branch,
		payment_method,
		count(payment_method) as total_payments,
		RANK() OVER(PARTITION BY branch ORDER BY count(payment_method) DESC) as ranking
	FROM walmart_database.walmart
	GROUP BY branch, payment_method
	ORDER BY branch, total_payments DESC) as payments
WHERE ranking = 1;


-- Q8. Categorize sales into 3 groups Morning, Afternoon, Evening.
--     Find out which of the shift has highest number of invoices.

ALTER TABLE walmart_database.walmart
MODIFY time TIME;

SELECT
	branch,
    CASE 
		WHEN hour(time) < 12 THEN 'morning'
        WHEN hour(time) BETWEEN 12 AND 17 THEN 'afternoon'
        ELSE 'Evening'
	END as shifts,
    COUNT(invoice_id) as no_of_invoices
FROM walmart_database.walmart
GROUP BY branch, shifts
ORDER BY branch, no_of_invoices DESC;


-- Q9. Identify 5 branch with highest decrease ratio in revenue compare to last year.
--     (current year 2023 and last year 2022)

WITH CTE1 AS (SELECT 
	branch,
    SUM(total) as total_sales_2022
FROM walmart_database.walmart
WHERE year(date) = 2022
GROUP BY branch
ORDER BY branch, total_sales_2022 DESC),

CTE2 AS (SELECT 
	branch,
    SUM(total) as total_sales_2023
FROM walmart_database.walmart
WHERE year(date) = 2023
GROUP BY branch
ORDER BY branch, total_sales_2023 DESC)

SELECT 
	CTE1.branch, 
    CTE1.total_sales_2022,
    CTE2.total_sales_2023,
    (CTE2.total_sales_2023 - CTE1.total_sales_2022) as revenue_compare,
    round((CTE1.total_sales_2022 - CTE2.total_sales_2023) / CTE1.total_sales_2022 * 100, 2) as decrease_ratio
FROM CTE1 INNER JOIN CTE2
ON CTE1.branch = CTE2.branch
ORDER BY decrease_ratio DESC
LIMIT 5;
