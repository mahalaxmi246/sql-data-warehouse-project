# Data Warehouse and Analytics Project

Welcome to my **Data Warehouse and Analytics Project** 🚀  
This project demonstrates an end-to-end **Data Engineering + Analytics** workflow — from raw data ingestion to a clean star schema and SQL-based insights.

It’s built as a **portfolio project**, showing real-world best practices in:
- Data Warehousing (Medallion Architecture)
- ETL Development
- Data Cleaning & Transformation
- Data Modeling (Star Schema)
- SQL Analytics & Reporting

---

## 🏗️ Data Architecture

This project follows the **Medallion Architecture** approach with **Bronze**, **Silver**, and **Gold** layers:

![Data Architecture]<img width="1038" height="534" alt="image" src="https://github.com/user-attachments/assets/a02d16c8-03c1-44c3-87ff-2eb7dcd10be8" />


### 🔸 Bronze Layer (Raw)
- Stores raw data exactly as received from source systems
- Data is ingested from **CSV files** into **SQL Server**
- No transformations are applied here

### ⚪ Silver Layer (Cleaned + Standardized)
- Cleans and prepares the data for analytics
- Handles:
  - Missing values
  - Duplicates
  - Standardization
  - Data type corrections
  - Basic normalization

### 🟡 Gold Layer (Business-Ready)
- Stores final curated data
- Modeled in a **Star Schema**
- Optimized for analytics, dashboards, and reporting

---

## 📖 Project Overview

This project includes:

1. **Data Architecture**
   - Designing a modern data warehouse using the Medallion approach (Bronze → Silver → Gold)

2. **ETL Pipelines**
   - Extracting raw data from multiple sources
   - Cleaning and transforming it
   - Loading it into a structured warehouse

3. **Data Modeling**
   - Designing Fact and Dimension tables
   - Building a reporting-ready star schema

4. **Analytics & Reporting**
   - SQL-based analysis and reporting for business insights

---

## 🎯 Skills Demonstrated

This repository highlights practical experience in:

- SQL Development (SQL Server)
- Data Warehousing
- ETL Pipeline Development
- Data Cleaning & Transformation
- Star Schema Modeling
- Data Analytics (SQL Reporting)

---

## 🛠️ Tools Used

All tools used are free:

- **SQL Server Express** (Database Engine)
- **SQL Server Management Studio (SSMS)** (GUI)
- **Draw.io** (Architecture + Modeling diagrams)
- **GitHub** (Version control + portfolio)
- **Notion** (Project planning template)

---

## 🚀 Project Requirements

### 🏗️ Data Warehouse (Data Engineering)

#### Objective
Build a modern data warehouse using SQL Server to consolidate sales data and enable analytical reporting.

#### Specifications
- **Data Sources:** Two source systems (ERP + CRM) provided as CSV files  
- **Data Quality:** Resolve quality issues before analysis  
- **Integration:** Merge both sources into one clean analytical model  
- **Scope:** Only latest dataset is required (no historization)  
- **Documentation:** Clear model documentation for analytics and stakeholders  

---

### 📊 BI Analytics & Reporting (Data Analysis)

#### Objective
Generate SQL-based insights for:
- Customer Behavior
- Product Performance
- Sales Trends

(Additional details are available in `docs/requirements.md`.)

---

## 📂 Repository Structure

```bash
data-warehouse-project/
│
├── datasets/                           # Raw datasets (ERP and CRM)
│
├── docs/                               # Documentation and diagrams
│   ├── etl.drawio                      # ETL techniques and process
│   ├── data_architecture.drawio        # Medallion architecture diagram
│   ├── data_catalog.md                 # Dataset metadata and field descriptions
│   ├── data_flow.drawio                # Data flow diagram
│   ├── data_models.drawio              # Star schema model diagram
│   ├── naming-conventions.md           # Naming rules for tables/columns
│
├── scripts/                            # SQL scripts for each layer
│   ├── bronze/                         # Raw ingestion scripts
│   ├── silver/                         # Cleaning & transformation scripts
│   ├── gold/                           # Star schema + reporting models
│
├── tests/                              # Data validation + quality checks
│
├── README.md                           # Project documentation
├── LICENSE                             # MIT License
├── .gitignore                          # Ignored files for Git
└── requirements.txt                    # Dependencies
```

---

## 📌 How to Run This Project (Quick Steps)

1. Install **SQL Server Express**
2. Install **SQL Server Management Studio (SSMS)**
3. Create a new database
4. Run scripts in this order:
   - `scripts/bronze/`
   - `scripts/silver/`
   - `scripts/gold/`
5. Run analytics queries to generate insights

---

## 🛡️ License

This project is licensed under the **MIT License**.  
You are free to use, modify, and share it with proper attribution.

---

## 👩‍💻 About Me

Hi! I’m **Mahalaxmi Somisetty**, an Information Technology student passionate about:

- Data Engineering  
- SQL Development  
- Data Warehousing  
- Analytics and Reporting  

This project is part of my learning and portfolio journey toward data roles.
---
