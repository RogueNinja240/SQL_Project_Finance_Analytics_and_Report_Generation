# SQL_Project_Finance_Analytics_and_Report_Generation

## Project Overview

This project is centered around Finance Analytics and Report Generation, focusing on delivering efficient and tailored reporting solutions to facilitate crucial decision-making. The implementation involves SQL, incorporating stored procedures, user-defined functions, and query optimization for a streamlined process.

## Key Features

**Tailored Reports:** Generate customized reports using input parameters like in_fiscal_year, in_top_n, and customer_code.

**Key Metrics:** Extract insightful metrics such as forecast accuracy, market badge, monthly gross sales for customers, and more.

**User-Friendly Design:** Prioritizing readability and simplicity in complex queries for easy comprehension.

## Project Structure

  **|-- /reports**

1.forecast_accuracy_by_fiscal_year.csv  
    
2.monthly_gross_sales_by_customer.csv
    
3.top_n_customer_by_netsales.csv
    
4.top_n_markets_by_netsales.csv

5.top_n_markets_by_region_and_gross_sales.csv

6.top_n_products_by_netsales.csv

7.top_n_products_per_division_qty_sold.csv
    
    
  **|-- /user_defined_functions**
    
1.get_fiscal_year.txt

2.get_fiscal_quarter.txt
    

    
  **|-- /views**
    
1.gross_sales_view.txt
    
2.net_sales_view.txt
    
3.sales_postinv_discount_view.txt

4.sales_preinv_discount_view.txt
    

    
  **|-- /stored procedures**
    
1. get_forecast_accuracy_sp.txt
    
2. get_market_badge_sp.txt
    
3. get_monthly_gross_sales_for_customer_sp.txt

4. get_top_n_customer_by_net_sales_sp.txt

5. get_top_n_markets_by_net_sales_sp.txt

6. get_top_n_products_per_division_by_qty_sold_sp.txt

7. top_n_markets_by_gross_sales_and_fiscal_year_sp.txt

8. top_n_products_by_netsales_sp.txt
    

    
  **|-- /Other Queries**
  
1. Queries Utilizing Window Functions, CTEs

## Usage
**1. Report Generation:**

Navigate to the queries directory and execute the relevant SQL files to generate reports. Customize input parameters such as in_fiscal_year, in_top_n, and customer_code as needed.

**2. Report Viewing:**
Access the generated reports from the report’s directory in CSV format.
