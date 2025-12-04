# phase-2-sql-dbt

# 🛍️ Ecommerce Analytics — dbt Project

This project models an e-commerce transaction dataset using **dbt** to transform
raw CSV data into a complete analytical star schema. It includes staging,
dimensional modeling, and a fact table that supports revenue and order analysis
by product, customer, and date.

---

## 🎯 Objective

Convert a raw e-commerce dataset into **trusted**, **well-tested**, and **documented**
analytics models using modern data engineering and analytics engineering practices.

This project demonstrates:

- Dimensional modeling (facts + conformed dimensions)
- Data quality enforcement using dbt tests
- Automated documentation and lineage
- Clear business logic and grain definition

---

## 🗂️ Warehouse Structure

The project follows dbt's recommended model structure:

raw → staging → dimensions → fact

yaml
Copy code

📌 **Grain Definitions**
- **Fact:** one row per product per order line (`invoice_no` + `stock_code`)
- **Dimensions:** 1 row per unique business entity  
  (customer, product, date)

---

## ⭐ Star Schema

yaml
Copy code
  dim_customer
         |
         |
dim_product ---- fct_order_lines ---- dim_date
|
stg_ecommerce

yaml
Copy code

> The fact table contains measures (revenue, quantity)  
> and foreign keys to conformed dimensions.

---

## 🔍 Lineage Graph

> Generated automatically by `dbt docs`

📸 _Insert lineage screenshot here_

---

## 📊 Fact Model Documentation

> Column-level metadata + applied tests

📸 _Insert fct_order_lines documentation screenshot here_

---

## 🧪 Data Quality Tests

**dbt tests executed & passed:**

| Test Type | Purpose |
|----------|---------|
| `not_null` | Ensures required fields are present |
| `relationships` | Validates foreign key references |
| `unique_combination_of_columns` | Enforces fact table grain |

This ensures:

- No invalid dimension references  
- No duplicate business events  
- Accurate revenue analysis  

---

## 🧠 Key Business Logic

- Duplicate line items aggregated to match grain
- Revenue measure derived: `quantity * unit_price`
- Surrogate keys adopted across all entities
- Data validation built into every model

---

## ⚙️ How to Run

```bash
dbt deps            # Install dependencies (dbt-utils, etc.)
dbt run             # Build all models
dbt test            # Validate warehouse integrity
dbt docs generate   # Build documentation
dbt docs serve      # Launch docs site
🚀 Tech Used
Category	Tools
Transformation	dbt-core
Warehouse	PostgreSQL
Utilities	dbt-utils
Documentation	dbt Docs

📌 Learning Outcomes
Designed and built a reliable dimensional model

Developed SQL transformation logic in dbt using CTEs

Implemented extensive testing layer for data trust

Communicated architecture clearly via docs + lineage

🧭 Next Steps
Add more business metrics (AOV, invoice count per customer)

Expand dimensions with more descriptive attributes

Move pipeline into orchestration (Airflow / Prefect)

Add a 2-source dataset dbt project (Phase 2 Project #2)

👤 About
This project is part of my Data Engineering Roadmap
➡️ Phase 2: SQL Modeling + dbt

Feel free to reach out if you'd like to discuss the project!