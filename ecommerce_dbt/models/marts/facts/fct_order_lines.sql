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