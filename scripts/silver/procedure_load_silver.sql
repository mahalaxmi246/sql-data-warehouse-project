/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.

    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/

USE DataWareHouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME, 
        @end_time DATETIME, 
        @batch_start_time DATETIME, 
        @batch_end_time DATETIME; 

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- =====================================================
        -- Load: silver.crm_cust_info
        -- =====================================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cust_id,
            cust_key,
            cust_firstname,
            cust_lastname,
            cust_marital_status,
            cust_gndr,
            cust_create_date
        )
        SELECT
            cust_id,
            cust_key,
            TRIM(cust_firstname) AS cust_firstname,
            TRIM(cust_lastname) AS cust_lastname,
            CASE 
                WHEN UPPER(TRIM(cust_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cust_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cust_marital_status,
            CASE 
                WHEN UPPER(TRIM(cust_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cust_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cust_gndr,
            cust_create_date
        FROM (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY cust_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cust_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- =====================================================
-- Load: silver.crm_prd_info (FINAL CORRECT VERSION)
-- =====================================================
SET @start_time = GETDATE();

PRINT '>> Truncating Table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info;

PRINT '>> Inserting Data Into: silver.crm_prd_info';

WITH prd AS (
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key_clean,
        TRIM(prd_nm) AS prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt
    FROM bronze.crm_prd_info
),
prd_versions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY prd_key_clean
            ORDER BY prd_start_dt DESC
        ) AS rn_latest,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key_clean
            ORDER BY prd_start_dt
        ) AS next_start_dt
    FROM prd
)
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    cat_id,
    prd_key_clean AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    CASE 
        WHEN rn_latest = 1 THEN NULL
        ELSE DATEADD(DAY, -1, next_start_dt)
    END AS prd_end_dt
FROM prd_versions;



        -- =====================================================
        -- Load: silver.crm_sales_details
        -- =====================================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR(8), sls_order_dt))
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR(8), sls_ship_dt))
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR(8), sls_due_dt))
            END AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 
                     OR sls_sales != sls_quantity * ABS(sls_price) 
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN (sls_quantity * ABS(sls_price)) / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- =====================================================
        -- Load: silver.erp_cust_az12
        -- =====================================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cust_cid,
            cust_bdate,
            cust_gndr
        )
        SELECT
            CASE
                WHEN cust_cid LIKE 'NAS%' THEN SUBSTRING(cust_cid, 4, LEN(cust_cid))
                ELSE cust_cid
            END AS cust_cid,
            CASE
                WHEN cust_bdate > GETDATE() THEN NULL
                ELSE cust_bdate
            END AS cust_bdate,
            CASE
                WHEN UPPER(TRIM(cust_gndr)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(cust_gndr)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS cust_gndr
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- =====================================================
        -- Load: silver.erp_loc_a101
        -- =====================================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- =====================================================
        -- Load: silver.erp_px_cat_g1v2
        -- =====================================================
        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            px_id,
            px_cat,
            px_subcat,
            px_maintenance
        )
        SELECT
            px_id,
            px_cat,
            px_subcat,
            px_maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- =====================================================
        -- Batch Completed
        -- =====================================================
        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END;
GO
