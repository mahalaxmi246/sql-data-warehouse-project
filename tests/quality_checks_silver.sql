/*
===============================================================================
Quality Checks 
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer.

Usage Notes:
    - Run these checks after loading the Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cust_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cust_key 
FROM silver.crm_cust_info
WHERE cust_key != TRIM(cust_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cust_marital_status 
FROM silver.crm_cust_info;

-- Data Standardization & Consistency
SELECT DISTINCT 
    cust_gndr
FROM silver.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Check for Invalid Dates (NULL is allowed, but not future beyond 2050)
-- Expectation: No Invalid Dates
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.crm_sales_details
WHERE (sls_order_dt IS NOT NULL AND (sls_order_dt < '1900-01-01' OR sls_order_dt > '2050-01-01'))
   OR (sls_ship_dt  IS NOT NULL AND (sls_ship_dt  < '1900-01-01' OR sls_ship_dt  > '2050-01-01'))
   OR (sls_due_dt   IS NOT NULL AND (sls_due_dt   < '1900-01-01' OR sls_due_dt   > '2050-01-01'));

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE (sls_order_dt IS NOT NULL AND sls_ship_dt IS NOT NULL AND sls_order_dt > sls_ship_dt)
   OR (sls_order_dt IS NOT NULL AND sls_due_dt  IS NOT NULL AND sls_order_dt > sls_due_dt);

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    cust_bdate 
FROM silver.erp_cust_az12
WHERE cust_bdate < '1924-01-01' 
   OR cust_bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    cust_gndr 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    *
FROM silver.erp_px_cat_g1v2
WHERE px_cat != TRIM(px_cat)
   OR px_subcat != TRIM(px_subcat)
   OR px_maintenance != TRIM(px_maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
    px_maintenance 
FROM silver.erp_px_cat_g1v2;
