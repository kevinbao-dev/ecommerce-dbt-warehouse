# Ecommerce Warehouse — dbt Project Overview:

This project uses **dbt** to model and transform an e-commerce transaction dataset into an analytical star schema.
It involves staging, dimension modeling, and a fact table with revenue and order analysis (referencing product, customer, and date dimensions).

## Summary

Converting a raw, publicly sourced e-commerce dataset into well-documented and tested analytical models using dbt to 
demonstrate data engineering best practices.

- Dimensional modeling (conformed dimensions, fact table)
- Dbt testing to ensure data quality
- Dbt documentation and lineage
- Concise grain definition
  
## Source Data

- This dataset is sourced from the UCI Online Retail dataset and contains real transactions between 2010 and 2011 from a UK-based online retailer.
- **Source**: <https://www.kaggle.com/datasets/carrie1/ecommerce-data/data>
  
## How To Run
- Python 3.10+
- dbt-core (**Recommendation**: install via virtual environment)
- PostgreSQL (local or remote)
- Git

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/kevinbao-dev/ecommerce-dbt-analytics.git
cd ecommerce-dbt-analytics
```
### 2️⃣ Create, Activate Virtual Environment and Install Dependencies
```bash
python -m venv venv
source venv/bin/activate    # Mac / Linux
venv\Scripts\activate.bat   # Windows, CMD
venv\Scripts\activate.PS1   # Windows, PowerShell
```
Then:
```
pip install -r requirements.txt
```

### 3️⃣ Connect to Postgres and create the raw schema + table:
- Connect to Postgres however you prefer (DBeaver, pgAdmin, psql) and create the necessary schema + tables:
```sql
CREATE DATABASE ecommerce;
CREATE SCHEMA raw;
CREATE TABLE raw.raw_ecommerce (...);
```
- **Recommendation**: Using DBeaver or pgAdmin, import CSV directly into the raw schema. The data can be found in the repository under `/data/data.csv`.

### 4️⃣ Configure local dbt Profile
- Edit your local profiles.yml and configure the values to work with your database setup. For example:

```yaml
ecommerce_dbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: <localhost>
      user: <user>
      password: <password>
      port: 5432
      dbname: ecommerce
      schema: analytics
```

### 5️⃣ Verify the connection using dbt:

```bash
dbt debug
```

### 6️⃣ Build, Test Models, and Explore Documentation
```bash
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Warehouse

The project follows the standardized dbt warehouse model:

raw → staging → dimensions → fact


## Grain Definitions
- **Fact:** one row per product per order line: `invoice_no` + `stock_code`
- **Dimensions:** one row per uniquely identified business entity: customer, product, and date

## ⭐ Star Schema
<img width="761" height="661" alt="star_schema" src="https://github.com/user-attachments/assets/be17c24e-2c6b-4973-97dd-2a3714360fea" />

> The fact table contains measures (revenue, quantity) and foreign keys to the conformed dimensions (customer, date, product).

## Lineage Graph
<img width="879" height="700" alt="ecommerce_dbt_lineage_graph" src="https://github.com/user-attachments/assets/1a0df4dc-558b-4297-8340-2d690d8e8efe" />

> Generated automatically by `dbt docs`

## 📊 Fact Model Documentation
<img width="1767" height="1186" alt="fct_order_lines" src="https://github.com/user-attachments/assets/38e5bb59-02bc-4718-b4a4-529803ab6e26" />

> Column-level metadata and applied tests for the order lines fact table

## DBT Data Quality Tests

> To ensure data quality, the following dbt tests were configured and passed: 

| Test Type | Purpose |
|----------|---------|
| `not_null` | Validate that required fields are present |
| `relationships` | Validates foreign key references |
| `unique_combination_of_columns` | Validate uniqueness - fact table grain |

This demonstrates:

- Valid dimension references  
- No duplicate business events  

## 🧠 Business Logic and Fact Table Source Code

- Duplicate line items aggregated to match grain (e.g. max(customer_id), sum(revenue) - aggregating and enforcing uniqueness of grain)
- Derivation of a new revenue value: `quantity * unit_price`
- Surrogate keys adopted across all entities - generated using dbt_utils (`customer_id`, `date_id`, `product_id`)
  
```
with source as (
	select 
		invoice_no,
		stock_code,
		invoice_timestamp,
		customer_id,
		unit_price,
		quantity
	from {{ ref('stg_ecommerce') }}
), joined as (
	select
		source.invoice_no,
		source.stock_code,
		source.quantity,
		source.unit_price,
		(unit_price * quantity) as revenue,
		dim_customer.customer_id as customer_id,
		dim_product.product_id as product_id,
		dim_date.date_id as date_id
	from source 
	left join {{ ref('dim_customer') }} dim_customer
		on source.customer_id = dim_customer.customer_code
	left join {{ ref('dim_date') }} dim_date 
		on source.invoice_timestamp::date = dim_date.invoice_date
	left join {{ ref('dim_product') }} dim_product 
		on source.stock_code = dim_product.stock_code
), deduped as ( 
	select 
		invoice_no,
		stock_code,
		sum(quantity) as quantity,
		min(unit_price) as unit_price,
		sum(revenue) as revenue,
		max(customer_id) as customer_id,
		max(product_id) as product_id,
		max(date_id) as date_id
	from joined
	group by invoice_no, stock_code
) select * from deduped
```


