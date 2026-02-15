# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

---

## **Table of Contents**

1. [General Principles](#general-principles)  
2. [Schema Naming Conventions](#schema-naming-conventions)  
3. [Table Naming Conventions](#table-naming-conventions)  
   - [Bronze Rules](#bronze-rules)  
   - [Silver Rules](#silver-rules)  
   - [Gold Rules](#gold-rules)  
4. [Column Naming Conventions](#column-naming-conventions)  
   - [Business Columns](#business-columns)  
   - [Surrogate Keys](#surrogate-keys)  
   - [Technical Columns](#technical-columns)  
5. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)  

---

## **General Principles**

- **Naming Style:** Use `snake_case`, with lowercase letters and underscores (`_`) to separate words.
- **Language:** Use English for all names.
- **Avoid Reserved Words:** Do not use SQL reserved words as object names.
- **Consistency:** Naming must be consistent across Bronze → Silver → Gold.

---

## **Schema Naming Conventions**

Schemas represent the Medallion Architecture layers:

| Schema | Purpose |
|--------|---------|
| `bronze` | Raw ingestion layer (as-is from source files). |
| `silver` | Cleaned and standardized layer. |
| `gold` | Business-ready layer (Star Schema using dimensions and facts). |

---

## **Table Naming Conventions**

### **Bronze Rules**
- Bronze tables represent raw data loaded from source systems.
- Table names must start with the source system name.
- Table names must match the original source naming style.

**Pattern:**  
`<sourcesystem>_<entity>`

- `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`)  
- `<entity>`: Exact entity name from the source system  

**Examples:**
- `crm_cust_info` → Customer information from CRM
- `crm_prd_info` → Product information from CRM
- `crm_sales_details` → Sales transactions from CRM
- `erp_cust_az12` → Customer extra info from ERP
- `erp_loc_a101` → Customer location info from ERP
- `erp_px_cat_g1v2` → Product categories from ERP

---

### **Silver Rules**
- Silver tables represent cleaned, standardized, and transformed versions of Bronze tables.
- Table naming remains the same as Bronze for lineage clarity.

**Pattern:**  
`<sourcesystem>_<entity>`

**Examples:**
- `crm_cust_info`
- `crm_prd_info`
- `crm_sales_details`
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

---

### **Gold Rules**
- Gold objects represent business-ready analytical models (Star Schema).
- Names must use meaningful, business-aligned naming conventions.
- Gold tables/views must start with a category prefix.

**Pattern:**  
`<category>_<entity>`

- `<category>`: Describes the role of the table  
- `<entity>`: Business entity name  

**Examples:**
- `dim_customers` → Customer dimension
- `dim_products` → Product dimension
- `fact_sales` → Sales fact table

#### **Glossary of Category Prefixes**

| Prefix     | Meaning            | Example(s) |
|------------|--------------------|------------|
| `dim_`     | Dimension table    | `dim_customers`, `dim_products` |
| `fact_`    | Fact table         | `fact_sales` |
| `report_`  | Reporting object   | `report_sales_monthly`, `report_customers` |

---

## **Column Naming Conventions**

### **Business Columns**
- Column names must be clear and descriptive.
- Business columns should match the naming used in the project terminology.

**Examples:**
- `cust_id`, `cust_key`, `cust_firstname`, `cust_lastname`
- `cust_marital_status`, `cust_gndr`, `cust_create_date`
- `cust_cid`, `cust_bdate`
- `px_id`, `px_cat`, `px_subcat`, `px_maintenance`

---

### **Surrogate Keys**
- All surrogate keys in Gold dimension tables must use the suffix `_key`.

**Pattern:**  
`<entity>_key`

**Examples:**
- `customer_key` → Surrogate key for `dim_customers`
- `product_key` → Surrogate key for `dim_products`

---

### **Technical Columns**
- All technical metadata columns must start with the prefix `dwh_`.

**Pattern:**  
`dwh_<column_name>`

**Examples:**
- `dwh_create_date` → Timestamp of record creation in the warehouse
- `dwh_load_date` → Timestamp of record load into the warehouse (optional)

---

## **Stored Procedure Naming Conventions**

- Stored procedures used for loading data must follow the naming pattern:

**Pattern:**  
`load_<layer>`

- `<layer>`: Represents the layer being loaded

**Examples:**
- `load_bronze` → Loads raw source data into Bronze
- `load_silver` → Transforms Bronze into Silver
- `load_gold` → (Optional) Loads Gold objects if materialized
