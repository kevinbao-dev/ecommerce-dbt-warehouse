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
	