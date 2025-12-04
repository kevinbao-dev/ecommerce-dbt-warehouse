with products as ( 
	select
		stock_code,
		description
	from analytics.stg_ecommerce
), deduped_products as (
	select
		stock_code,
		min(description) as description
	from products
	where stock_code is not null
	group by stock_code
) select
	{{ dbt_utils.generate_surrogate_key(['stock_code']) }} as product_id,
	stock_code,
	description
	from deduped_products
	
	
	
with customers as (
	select
		customer_id,
		country
	from analytics.stg_ecommerce
), deduped_customers as (
	select 
		customer_id,
		min(country) as country
	from customers
	where customer_id is not null
	group by customer_id
) select
	{{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_id,
	customer_id as customer_code,
	country
	from deduped_customers
	
	
	
	
	
	with customers as (
	select
		customer_id,
		country
	from analytics.stg_ecommerce
), deduped_customers as (
	select 
		customer_id,
		country
	from customers
	where customer_id is not null
	group by (customer_id, country)
) select count(*), customer_id from deduped_customers
group by customer_id
having count(*) > 1
