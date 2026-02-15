# Data Catalog for Gold Layer

## Overview
The **Gold Layer** is the business-level data representation, structured to support analytical and reporting use cases.  
It consists of **dimension tables** and **fact tables** (Star Schema) that provide clean, enriched, and business-ready data.

---

## 1. **gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.

### Columns

| Column Name     | Data Type     | Description |
|----------------|---------------|-------------|
| customer_key    | INT           | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id     | INT           | Unique numerical identifier assigned to each customer. |
| customer_number | NVARCHAR(50)  | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| first_name      | NVARCHAR(50)  | The customer's first name, as recorded in the system. |
| last_name       | NVARCHAR(50)  | The customer's last name or family name. |
| country         | NVARCHAR(50)  | The country of residence for the customer (e.g., Germany, United States). |
| marital_status  | NVARCHAR(50)  | The marital status of the customer (e.g., Married, Single, n/a). |
| gender          | NVARCHAR(50)  | The gender of the customer (e.g., Male, Female, n/a). |
| birthdate       | DATE          | The date of birth of the customer (YYYY-MM-DD). |
| create_date     | DATE          | The date when the customer record was created in the CRM system. |

---

## 2. **gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.

### Columns

| Column Name     | Data Type     | Description |
|----------------|---------------|-------------|
| product_key     | INT           | Surrogate key uniquely identifying each product record in the product dimension table. |
| product_id      | INT           | A unique identifier assigned to the product for internal tracking and referencing. |
| product_number  | NVARCHAR(50)  | A structured alphanumeric code representing the product, used for categorization or inventory. |
| product_name    | NVARCHAR(50)  | Descriptive name of the product. |
| category_id     | NVARCHAR(50)  | A unique identifier for the product's category, derived from the product key. |
| category        | NVARCHAR(50)  | High-level classification of the product (from ERP). |
| subcategory     | NVARCHAR(50)  | Detailed classification of the product within the category (from ERP). |
| maintenance     | NVARCHAR(50)  | Indicates whether the product requires maintenance (from ERP). |
| cost            | INT           | The cost or base price of the product. |
| product_line    | NVARCHAR(50)  | The product line or series (e.g., Road, Mountain, Touring). |
| start_date      | DATE          | The date when the product became active/available. |

---

## 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.

### Columns

| Column Name    | Data Type     | Description |
|---------------|---------------|-------------|
| order_number   | NVARCHAR(50)  | A unique alphanumeric identifier for each sales order (e.g., SO54496). |
| product_key    | INT           | Surrogate key linking the order to the product dimension table (`gold.dim_products`). |
| customer_key   | INT           | Surrogate key linking the order to the customer dimension table (`gold.dim_customers`). |
| order_date     | DATE          | The date when the order was placed. |
| shipping_date  | DATE          | The date when the order was shipped to the customer. |
| due_date       | DATE          | The date when the order payment was due. |
| sales_amount   | INT           | Total monetary value of the sale for the line item. |
| quantity       | INT           | Number of units ordered for the line item. |
| price          | INT           | Price per unit for the line item. |
