# Walmart Data Analysis: SQL + Python 

## Project Overview

![Project Pipeline](https://github.com/akashmailar/Walmart-Sales-Analysis-Python-SQL/blob/main/Walmart%20Project.png)


This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. We utilize Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. The project is ideal for data analysts looking to develop skills in data manipulation, SQL querying, and data pipeline creation.

---

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, SQL (MySQL and PostgreSQL)
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas numpy sqlalchemy mysql-connector-python
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`.
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into MySQL
   - **Set Up Connections**: Connect to MySQL using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up tables in both MySQL using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
   - **Documentation**: Keep clear notes of each query's objective, approach, and results.

### 10. SQL Solved Queries:

- **Q1. Find different payment methods and number of transactions, number of quantities sold.**
```sql
SELECT 
	payment_method, 
	COUNT(*) as no_of_transactions,
	SUM(quantity) as qty_sold
FROM walmart_database.walmart
GROUP BY payment_method;
```

- **Q2. Identify the highest-rated category in each branch, displaying the branch, category.**
```sql
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
```

- **Q3. Identify the busiest day for each branch based on the number of transactions.**
```sql
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
```

- **Q4. Calculate the total quantity of items sold per payment method. List payment method and total quantity.**
```sql
SELECT 
	payment_method,
	SUM(quantity) as total_qty
FROM walmart_database.walmart
GROUP BY payment_method
ORDER BY total_qty DESC;
```

- **Q5. Determine the average, minimum and maximum rating of products for each city. List the city, average rating, minimum rating and maximum rating.**
```sql
SELECT 
	city,
	category,
	AVG(rating) as avg_rating,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating
FROM walmart_database.walmart
GROUP BY city, category
ORDER BY city;
```

- **Q6. Calculate the total profit for each category by considering total profit as (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.**
```sql
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart_database.walmart
GROUP BY category
ORDER BY total_profit DESC;
```

- **Q7. Determine the most common payment method for each branch. Display branch and the preferred payment method.**
```sql
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
```

- **Q8. Categorize sales into 3 groups Morning, Afternoon, Evening. Find out which of the shift has highest number of invoices.**
```sql
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
```

- **Q9. Identify 5 branch with highest decrease ratio in revenue compare to last year. (current year 2023 and last year 2022)**
```sql
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
```


### 11. Project Publishing and Documentation
   - **Documentation**: Maintain well-structured documentation of the entire process in Markdown or a Jupyter Notebook.
   - **Project Publishing**: Publish the completed project on GitHub or any other version control platform, including:
     - The `README.md` file (this document).
     - Jupyter Notebooks (if applicable).
     - SQL query scripts.
     - Data files (if possible) or steps to access them.

---

## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`
- **Kaggle API Key** (for data downloading)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.

---

## Project Structure

```plaintext
|-- data/                     # Raw data and transformed data
|-- sql_queries/              # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
|-- requirements.txt          # List of required Python libraries
|-- project.py                # Main script for loading, cleaning, and processing data
```
---

## Results and Insights

This section will include your analysis findings:
- **Sales Insights**: Key categories, branches with highest sales, and preferred payment methods.
- **Profitability**: Insights into the most profitable product categories and locations.
- **Customer Behavior**: Trends in ratings, payment preferences, and peak shopping hours.

## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.

---

## License

This project is licensed under the MIT License. 

---

## Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.

---
Thank You!
