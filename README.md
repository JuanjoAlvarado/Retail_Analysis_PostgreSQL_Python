# 🛒 Online Retail Analysis

This project demonstrates an **intermediate-level data analytics pipeline** using **PostgreSQL, SQL (via SQLTools in VS Code), and Python**.  

It follows a **layered ETL approach** (`RAW → STAGING/CLEANING → CORE → REPORTING`) and ends with visualizations in Python.


## 🚀 Technologies
- **PostgreSQL** (data storage and SQL queries)
- **SQLTools extension** in VS Code (SQL IDE integration)
- **Python** (`pandas`, `matplotlib`, `sqlalchemy`) for analysis and visualization
- **GitHub** for version control and collaboration


## 📂 Project Structure

 📂 Online_Retail_Analysis

- 📂 **data/**
  - 📄 OnlineRetail.csv
  - 📝 (README con enlaces de descarga)
  
- 📂 **python/**
  - 📄 viz_dashboard.py  

- 📂 **sql/**
  - 📄 00_create_db_and_schemas.sql  
  - 📄 01_raw_tables.sql  
  - 📄 02_load_raw.sql  
  - 📄 02_staging.sql  
  - 📄 03_staging_cleaning.sql  
  - 📄 04_dw_model.sql  
  - 📄 05_constraints_indexes.sql  
  - 📄 06_materialized_views.sql  
  - 📄 07_analysis_queries.sql  
  - 📄 08_quality_tests.sql  

- 📂 **notebooks/** _(Opcional: Jupyter Notebooks para exploración)_

- 📄 README.md → Documentación del proyecto  
- 📄 .gitignore → Ignorar archivos innecesarios  

## 📊 Dataset
We use the **[Online Retail Dataset](https://archive.ics.uci.edu/ml/datasets/online+retail)** from the UCI Machine Learning Repository.  
This dataset contains transactions from a UK-based online retailer (2010–2011).

> ⚠️ Due to size limitations, raw data is not included in this repo.  
> Please download from the [UCI repository](https://archive.ics.uci.edu/ml/datasets/online+retail) and place it in the `data/` folder.


## 🔧 Setup Instructions

### 1️⃣ Database Setup (PostgreSQL)
1. Create a new database:
   ```sql
   CREATE DATABASE retail_analytics;
   ```
** Run the SQL scripts in the order shown in "Project Structure" section.

2. Create and activate a virtual environment:
    ```python
    python -m venv venv
    ```
    Activate: Windows
    ```python
    .\venv\Scripts\activate
    ```
    Activate: Linux/Mac
    ```python
    source venv/bin/activate
    ```

Install dependencies: 
Python Libraries: **pip install** *pandas, matplotlib.pyplot, sqlalchemy*


## Visualization Example

**Run the Python script:**

- *Python scripts/viz_dashboard.py*


Example chart (Top 10 countries by sales in the last 12 months of available data)

## 📈 Analysis Goals

- Clean and standardize raw transactional data.

- Create structured reporting layers (monthly sales, country-level summaries).

- Identify sales trends by country and product category.

- Build reproducible visualizations with Python.

## 📌 Future Improvements

- Automate ETL process with Airflow or dbt.

- Deploy interactive dashboards using Streamlit or Power BI.

- Extend dataset with additional years or related retail data.

## 👨‍💻 Author

Developed by Juan José Alvarado as part of a data analytics learning project.
Feel free to fork, contribute, or provide feedback! 🚀