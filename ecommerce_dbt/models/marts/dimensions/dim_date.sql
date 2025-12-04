with dates as (
	select distinct invoice_timestamp::date as invoice_date
	from analytics.stg_ecommerce
), cleaned_dates as (
	select
		{{ dbt_utils.generate_surrogate_key(['invoice_date']) }} as date_id,
		invoice_date,
		extract(year from invoice_date) as year,
		extract(month from invoice_date) as month,
		extract(day from invoice_date) as day
	from dates
) select * from cleaned_dates



	