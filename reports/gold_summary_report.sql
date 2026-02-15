/*
===============================================================================
Gold Layer - Summary SQL Report
===============================================================================
Purpose:
    This script contains analytical queries built on the Gold Layer views.
    These queries can be used for reporting and business insights.

Views Used:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales
===============================================================================
*/

-- =====================================================
-- 1) Total Sales Summary
-- =====================================================
SELECT 
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    AVG(sales_amount * 1.0) AS avg_sales_per_line
FROM gold.fact_sales;


-- =====================================================
-- 2) Sales Trend by Year
-- =====================================================
SELECT
    YEAR(order_date) AS sales_year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY sales_year;


-- =====================================================
-- 3) Sales Trend by Month
-- =====================================================
SELECT
    FORMAT(order_date, 'yyyy-MM') AS sales_month,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY sales_month;


-- =====================================================
-- 4) Top 10 Customers by Total Sales
-- =====================================================
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key, c.first_name, c.last_name, c.country
ORDER BY total_sales DESC;


-- =====================================================
-- 5) Top 10 Products by Total Sales
-- =====================================================
SELECT TOP 10
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY 
    p.product_key, p.product_name, p.category, p.subcategory
ORDER BY total_sales DESC;


-- =====================================================
-- 6) Sales by Country
-- =====================================================
SELECT
    c.country,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;


-- =====================================================
-- 7) Sales by Product Category
-- =====================================================
SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;


-- =====================================================
-- 8) Sales by Product Line
-- =====================================================
SELECT
    p.product_line,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY total_sales DESC;


-- =====================================================
-- 9) Average Order Value (AOV)
-- =====================================================
SELECT
    SUM(sales_amount) * 1.0 / COUNT(DISTINCT order_number) AS avg_order_value
FROM gold.fact_sales;


-- =====================================================
-- 10) Top 10 Orders by Sales Amount
-- =====================================================
SELECT TOP 10
    order_number,
    SUM(sales_amount) AS order_total_sales
FROM gold.fact_sales
GROUP BY order_number
ORDER BY order_total_sales DESC;
