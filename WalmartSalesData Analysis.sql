create database if not exists walmartsales;

CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

select * from walmartsales.sales;

-- ------------------------------------------------------------------------------------------------
-- ------- Feature Engineering -- ------------------------

-- time_of_day -- adding a new column names time_of_day to give insight of sales in the morning, 
-- afternoon and evening.

SELECT
	time,
    (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
    ) AS time_of_date
FROM sales;

-- adding the new time_of_date column into sales tables

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- Inserting data into new time_of_day column

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);

-- day_name --- add a new column named day_name that contains the extracted days of the week on 
-- which the given transaction took place (mon,tue,wed,thur,fri)

SELECT 
	date,
    DAYNAME(date)
FROM sales;

-- adding the new day_name column into sales tables

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

-- Inserting data into new day_name column

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name --- add a new column names month_name that contains the extracted months of the year 
-- on which the given transaction took place(jan,feb,mar)'/

SELECT
	date,
    MONTHNAME(date)
FROM sales;

-- adding the new day_name column into sales tables

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

-- Inserting data into new day_name column

UPDATE sales
SET month_name = MONTHNAME(date);

-- How many unique cities does the data have?
SELECT
	DISTINCT city 
FROM sales;

-- In which city is each branch?
SELECT
	DISTINCT branch
FROM sales;

-- -------------------------------------------------------------------------------
-- ------------------ Product Questions -----------------------------------------

-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT 
	payment_method,
    COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?
SELECT
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	month_name AS month,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT 
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;
    
-- What is the city with the largest revenue?
SELECT
	city,
    SUM(total) as total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;
    
-- What product line had the largest VAT?
SELECT
	product_line,
    AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Which branch sold more products than average product sold?
SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT
	product_line,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
	city,
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- How many unique customer types does the data have?
SELECT 
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT 
	customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(*) AS customer_count
FROM sales
GROUP BY customer_type
ORDER BY customer_count DESC;

-- What is the gender of most of the customers?
SELECT 
	gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch?
SELECT 
	gender,
    COUNT(*) AS gender_count
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_count DESC;
    
-- Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "B"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Top Selling Products by Total Revenue
-- top 10 best-selling products based on total revenue generated.
-- COGS = unitsPrice * quantity 
SELECT
	product_line,
    SUM(unit_price * quantity) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Profitable Branches
-- identify the branches that have the highest average gross profit margin.
SELECT
	branch,
    AVG(gross_margin_percentage) AS avg_gross_margin
FROM sales
GROUP BY branch
ORDER BY avg_gross_margin DESC;

-- Customer Spending Behavior
-- Analyze the distribution of total revenue by customer type to understand their spending behavior.
SELECT
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Effectiveness of Pricing Strategy
-- Investigate the impact of different pricing strategies by comparing the average gross profit 
-- margin across different price ranges (e.g., low, medium, high).

SELECT
	CASE
		WHEN unit_price < 50 THEN 'Low'
        WHEN unit_price >= 50 AND unit_price < 100 THEN 'Medium'
        ELSE 'High'
	END AS price_range,
    AVG(gross_margin_percentage) AS avg_gross_margin
FROM sales
GROUP BY price_range
ORDER BY price_range;

-- Seasonal Sales Patterns
-- Explore whether there are seasonal trends in revenue and profit margins by analyzing monthly 
-- or quarterly data.

-- Calculating average revenue and profit margins by month
-- Monthly Analysis:
SELECT
    EXTRACT(MONTH FROM date) AS month,
    AVG(total) AS avg_revenue,
    AVG(gross_margin_percentage) AS avg_margin
FROM
    sales
GROUP BY
    EXTRACT(MONTH FROM date)
ORDER BY
    month;

-- Calculating average revenue and profit margins by quarter
-- Quarterly Analysis:
SELECT
    CONCAT(EXTRACT(YEAR FROM date), ' Q', QUARTER(date)) AS quarter,
    AVG(total) AS avg_revenue,
    AVG(gross_margin_percentage) AS avg_margin
FROM
    sales
GROUP BY
    CONCAT(EXTRACT(YEAR FROM date), ' Q', QUARTER(date))
ORDER BY
    quarter;
 
-- Product Line Performance
-- Determine the average gross profit margin for each product line to identify the most 
-- profitable product categories.
SELECT 
	product_line,
    AVG(gross_margin_percentage) AS avg_margin
FROM sales
GROUP BY product_line
ORDER BY avg_margin DESC;

-- Payment Method Analysis
-- Comparing the gross profit margins for different payment methods (e.g., cash, credit card) 
-- to understand their impact on profitability.
SELECT
	payment_method,
    AVG(gross_margin_percentage) AS avg_margin
FROM sales
GROUP BY payment_method
ORDER BY avg_margin DESC;

-- Customer Lifetime Value
-- Calculate the lifetime value of customers by analyzing their cumulative spending and 
-- corresponding gross profit margins over time.
SELECT
	customer_type,
    SUM(total) AS cumulative_spending,
    AVG(gross_margin_percentage) AS avg_margin
FROM sales
GROUP BY customer_type
ORDER BY cumulative_spending DESC;

