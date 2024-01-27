-- 1. Extract customer codes for Croma india

	SELECT * FROM dim_customer WHERE customer like "%croma%" AND market="india";


-- 2. Get all the sales transaction data from fact_sales_monthly table for that customer in the fiscal_year 2021

	SELECT * FROM fact_sales_monthly 
	WHERE 
            customer_code=90002002 AND
            YEAR(DATE_ADD(date, INTERVAL 4 MONTH))=2021 
	ORDER BY date asc
	LIMIT 100000;


-- 3. Replacing the function created in the step:b

	SELECT * FROM fact_sales_monthly 
	WHERE 
            customer_code=90002002 AND
            get_fiscal_year(date)=2021 
	ORDER BY date asc
	LIMIT 100000;



### Gross Sales Report:

-- 1. Perform joins to extract product information

	SELECT s.date, s.product_code, p.product, p.variant, s.sold_quantity 
	FROM fact_sales_monthly s
	JOIN dim_product p
        ON s.product_code=p.product_code
	WHERE 
            customer_code=90002002 AND 
    	    get_fiscal_year(date)=2021     
	LIMIT 1000000;


-- 2. Performing join with 'fact_gross_price' table with the above query and generating required fields

	SELECT 
    	    s.date, 
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
            ON g.fiscal_year=get_fiscal_year(s.date)
    	AND g.product_code=s.product_code
	WHERE 
    	    customer_code=90002002 AND 
            get_fiscal_year(s.date)=2021     
	LIMIT 1000000;


-- 3. Generate monthly gross sales report for Croma India for all the years

	SELECT 
            s.date, 
    	    SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
        ON g.fiscal_year=get_fiscal_year(s.date) AND g.product_code=s.product_code
	WHERE 
             customer_code=90002002
	GROUP BY date;


-- 4.Generate a yearly report for Croma India where there are two columns
	a. Fiscal Year
	b. Total Gross Sales amount In that year from Croma
		

	select
            get_fiscal_year(date) as fiscal_year,
            sum(round(sold_quantity*g.gross_price,2)) as yearly_sales
	from fact_sales_monthly s
	join fact_gross_price g
	on 
	    g.fiscal_year=get_fiscal_year(s.date) and
	    g.product_code=s.product_code
	where
	    customer_code=90002002
	group by get_fiscal_year(date)
	order by fiscal_year;


### Module: Pre-Invoice Discount Report

-- a. Include pre-invoice deductions in Croma detailed report

	SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
    	    ON g.fiscal_year=get_fiscal_year(s.date)
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=get_fiscal_year(s.date)
	WHERE 
	    s.customer_code=90002002 AND 
    	    get_fiscal_year(s.date)=2021     
	LIMIT 1000000;


-- b. Same report but all the customers

	SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
    	    ON g.fiscal_year=get_fiscal_year(s.date)
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=get_fiscal_year(s.date)
	WHERE 
    	    get_fiscal_year(s.date)=2021     
	LIMIT 1000000;



### Module: Performance Improvement - 1

-- a. creating dim_date and joining with this table and avoid using the function 'get_fiscal_year()' to reduce the amount of time taking to run the query

	SELECT 
    	    s.date, 
            s.customer_code,
            s.product_code, 
            p.product, p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_date dt
        	ON dt.calendar_date = s.date
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=dt.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=dt.fiscal_year
	WHERE 
    		dt.fiscal_year=2021     
	LIMIT 1500000;


### Module: Performance Improvement - 2

-- a. Added the fiscal year in the fact_sales_monthly table itself

	SELECT 
    	    s.date, 
            s.customer_code,
            s.product_code, 
            p.product, p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=s.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=s.fiscal_year
	WHERE 
    		s.fiscal_year=2021     
	LIMIT 1500000;


### Module: Database Views

-- a. Get the net_invoice_sales amount using the CTE's

	WITH cte1 AS (
		SELECT 
    		    s.date, 
    		    s.customer_code,
    		    s.product_code, 
                    p.product, p.variant, 
                    s.sold_quantity, 
                    g.gross_price as gross_price_per_item,
                    ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
                    pre.pre_invoice_discount_pct
		FROM fact_sales_monthly s
		JOIN dim_product p
        		ON s.product_code=p.product_code
		JOIN fact_gross_price g
    			ON g.fiscal_year=s.fiscal_year
    			AND g.product_code=s.product_code
		JOIN fact_pre_invoice_deductions as pre
        		ON pre.customer_code = s.customer_code AND
    			pre.fiscal_year=s.fiscal_year
		WHERE 
    			s.fiscal_year=2021) 
	SELECT 
      	    *, 
    	    (gross_price_total-pre_invoice_discount_pct*gross_price_total) as net_invoice_sales
	FROM cte1
	LIMIT 1500000;


-- a.  Now generate net_invoice_sales using the above created view "sales_preinv_discount"

	SELECT 
            *,
    	    (gross_price_total-pre_invoice_discount_pct*gross_price_total) as net_invoice_sales
	FROM gdb0041.sales_preinv_discount

-- b. Create a report for net sales

	SELECT 
            *, 
    	    net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
	FROM gdb0041.sales_postinv_discount;



### Module: Top Markets and Customers 

-- a.Get top 5 market by net sales in fiscal year 2021

	SELECT 
    	    market, 
            round(sum(net_sales)/1000000,2) as net_sales_mln
	FROM gdb0041.net_sales
	where fiscal_year=2021
	group by market
	order by net_sales_mln desc
	limit 5

  

### Module: Window Functions: OVER Clause

-- a.show % of total expense

	select 
             *,
    	     amount*100/sum(amount) over() as pct
	from random_tables.expenses 
	order by category;


-- b. Find customer wise net sales distibution per region for FY 2021

	with cte1 as (select 
	customer,
    region,
    round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales ns
join dim_customer dc on ns.customer_code=dc.customer_code
where
	ns.fiscal_year = 2021
group by customer, region)

select *,
	net_sales_mln*100/sum(net_sales_mln) over(partition by region) AS pct
	from cte1
order by region,net_sales_mln desc;


-- c.show % of total expense per category

	select 
            *,
    	    amount*100/sum(amount) over(partition by category) as pct
	from random_tables.expenses 
	order by category,  pct desc;


-- d. Show expenses per category till date

	select 
             *,
             sum(amount) over(partition by category order by date) as expenses_till_date
	from random_tables.expenses;


### Module: Window Functions: Using In a Real Time Task


-- a.find out customer wise net sales percentage contribution 

	with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc


### Module: Window Functions: ROW_NUMBER, RANK, DENSE_RANK

-- a.Show top 2 expenses in each category

	select * from 
	     (select 
                  *, 
    	          row_number() over (partition by category order by amount desc) as row_num
	      from random_tables.expenses) x
	where x.row_num<3


--  b.If two items have same expense then row_number doesnt work. Use dense_rank()

	select 
	     *,
             row_number() over (order by marks desc) as row_num,
             rank() over (order by marks desc) as rank_num,
             dense_rank() over (order by marks desc) as dense_rank_num
	from random_tables.student_marks;


-- c.Top 3 products from each division by total quantity sold in a given year

	with cte1 as (
			select 
				p.division,
				p.product,
				sum(sold_quantity) as total_qty
			from fact_sales_monthly s
			join dim_product p 
						on p.product_code=s.product_code
			where fiscal_year = 2021
			group by p.product),
	cte2 as(
			select *,
				dense_rank() over(partition by division order by total_qty desc) as d_rnk
			from cte1)

	select * from cte2 where d_rnk <=3


-- d.top 5 students according to marks

	with cte1 as(
		select 
			*,
    			row_number() over(order by marks desc) as rn,
    			rank() over(order by marks desc) as rnk,
    			dense_rank() over(order by marks desc) as d_rnk
		from random_tables.student_marks
		)

	select 
		*
	from cte1
	where 
		d_rnk<=5;

-- e.retrieve top 2 region by gross sale in FY 2021

	with cte1 as (
			select gs.market,
				dc.region,
				round(sum(gs.gross_price_total)/1000000,2) as gross_total_mln
			from gross_sales gs
			join dim_customer dc
						on dc.customer_code = gs.customer_code and
						dc.market = gs.market
			where fiscal_year = 2021
			group by market),
	cte2 as (
		select *,
			rank() over(partition by region order by gross_total_mln desc) as rnk
		from cte1 )
	select 
		* 
	from 
		cte2
	where 
		rnk<=2;


-- f.creating fact_act_est table for sold qty and forecast qty in same table

	create table fact_act_est
		(
		select 
			s.date,
			s.fiscal_year,
			s.product_code,
			s.customer_code,
			s.sold_quantity,
			f.forecast_quantity
		from fact_sales_monthly s
		left join fact_forecast_monthly f
			using(date, customer_code, product_code)
		union
		(
		select 
			f.date,
			f.fiscal_year,
			f.product_code,
			f.customer_code,
			s.sold_quantity,
			f.forecast_quantity
		from  fact_forecast_monthly f
		left join fact_sales_monthly s
			using(date, customer_code, product_code)
		);


-- g.Updating data with 0 where column have NULL 

	update fact_act_est
	set sold_quantity=0
	where sold_quantity is NULL;

-----------------------------------------------------------------------------------------------------------------------
	update fact_act_est
	set forecast_quantity=0
	where forecast_quantity is NULL;

-----------------------------------------------------------------------------------------------------------------------
Querying data for forecast accuracy

	with cte1 as 
	(
		select *,
			sum(forecast_quantity-sold_quantity) as net_error,
			sum(forecast_quantity-sold_quantity)*100/sum(forecast_quantity) as net_error_pct,
			sum(abs(forecast_quantity-sold_quantity)) as abs_error,
			sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_error_pct
		from fact_act_est s
		where fiscal_year=2021
		group by customer_code
	)
	select 
		cte1.*,
    		dc.customer,
    		if(abs_error_pct > 100,0, 100-abs_error_pct) as forecast_accuracy
	from cte1
	join dim_customer dc
		using(customer_code)
	order by forecast_accuracy asc;

------------------------------------------------------------------------------------------
--Query for report on forecast accuracy with dropping from 2020 to 2021

	with cte1 as 
		(
			select s.customer_code,
				dc.customer,
				dc.market,
				sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_error_pct_2020
			from fact_act_est s
        		join dim_customer dc using (customer_code)
			where fiscal_year=2020
		        group by customer_code
		),

	cte2 as
		(
			select s.customer_code,
				sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_error_pct_2021
			from fact_act_est s
			where fiscal_year=2021
        	group by customer_code
		)

		select 
			customer_code,
    			customer,
    			market,
    			if(abs_error_pct_2020 > 100,0, 100-abs_error_pct_2020) as forecast_accuracy_2020,
    			if(abs_error_pct_2021 > 100,0, 100-abs_error_pct_2021) as forecast_accuracy_2021
		from 
			cte1
    		join cte2 
			using (customer_code)
		having
			forecast_accuracy_2020 > forecast_accuracy_2021;
========================================================================================================================
========================================================================================================================
========================================================================================================================
