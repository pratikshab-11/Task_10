-----create_table----


select *  from sales


create table yearly_report(Year_id SERIAL PRIMARY KEY,
    report_year INTEGER NOT NULL,
    Year_rep_id VARCHAR NOT NULL,
    customer_name VARCHAR NOT NULL,
    product_id VARCHAR NOT NULL,
    product_name VARCHAR,
    total_sales_amount DOUBLE PRECISION,
    total_quantity_sold INTEGER,
    avg_discount DOUBLE PRECISION,
    total_profit DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT now()
    );

	CREATE OR REPLACE PROCEDURE yearly_sales_reports()
LANGUAGE plpgsql
AS $$
BEGIN

 INSERT INTO yearly_report (
        report_year,
       Year_rep_id ,
        customer_name,
        product_id,
        product_name,
        total_sales_amount,
        total_quantity_sold,
        avg_discount,
        total_profit
        )
SELECT
        EXTRACT(YEAR FROM s.order_date)::INT AS report_year,
        c.cust_id,c.customer_name,p.product_id, p.product_name,
        SUM(s.sales) AS total_sales_amount,
        SUM(s.qty) AS total_quantity_sold,
        AVG(s.discount) AS avg_discount,
        SUM(s.profit) AS total_profit
    FROM sales s
    INNER JOIN customer c ON s.cust_id = c.cust_id
    INNER JOIN product p ON s.product_id = p.product_id
    WHERE s.order_date IS NOT NULL
    GROUP BY report_year,p.product_id, c.cust_id, p.product_name
    ORDER BY report_year;
END;
$$;
------------------------------------
call yearly_sales_reports()


select * from yearly_report

SELECT * FROM yearly_report
WHERE report_year = 2016  
order by product_name ,customer_name;
--------------------------------------------
------------2nd_table----------



CREATE TABLE monthly_report(
    month_id   SERIAL PRIMARY KEY,
    report_year INTEGER NOT NULL,
    report_month INTEGER NOT NULL,
    cust_id VARCHAR NOT NULL,
    product_id VARCHAR NOT NULL,ship_mode varchar,
	ship_date date,
    total_sales_amount DOUBLE PRECISION,
    total_quantity_sold INTEGER,
    avg_discount DOUBLE PRECISION,
    total_profit DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT now()
    );
	

CREATE OR REPLACE PROCEDURE monthly_reports()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO monthly_report (
        report_year,
        report_month,
        cust_id,
        product_id,
        ship_mode,
        ship_date,
        total_sales_amount,
        total_quantity_sold,
        avg_discount,
        total_profit
    )
    SELECT
        EXTRACT(YEAR FROM s.order_date)::INT AS report_year,
        EXTRACT(MONTH FROM s.order_date)::INT AS report_month,
        c.cust_id,
        p.product_id,
        s.ship_mode,
        s.ship_date,
        SUM(s.sales) AS total_sales_amount,
        SUM(s.qty) AS total_quantity_sold,
        AVG(s.discount) AS avg_discount,
        SUM(s.profit) AS total_profit
    FROM sales s
    INNER JOIN customer c ON s.cust_id = c.cust_id
    INNER JOIN product p ON s.product_id = p.product_id
    WHERE s.order_date IS NOT NULL
    GROUP BY report_year, report_month, c.cust_id, p.product_id, s.ship_mode, s.ship_date
    ORDER BY report_year, report_month;
END;
$$;
call  monthly_reports()

drop procedure monthly_reports

select *  from monthly_report

SELECT * FROM monthly_report
WHERE report_year = 2014 AND report_month = 8
order by ship_mode
   


----------------------------


-----------------------------------CREATE TABLE  monthly_profit_report AS
SELECT
    report_year,
    report_month,
    cust_id,
    SUM(total_profit) AS total_profit,
    CASE 
        WHEN SUM(total_quantity_sold) = 0 THEN 0
        ELSE SUM(total_profit) / SUM(total_quantity_sold)
    END AS avg_profit_per_sale,
    SUM(total_sales_amount) AS total_sales_amount,
    SUM(total_quantity_sold) AS total_quantity_sold
FROM monthly_report
GROUP BY report_year, report_month, cust_id
ORDER BY report_year, report_month, cust_id;
-------------------------------------------------
CREATE TABLE sales_report_2015_by_month AS
SELECT
  report_month,
  round(SUM(total_sales_amount)) AS total_sales,
  round(SUM(total_quantity_sold)) AS total_quantity,
  AVG(avg_discount) AS avg_discount,
  round(SUM(total_profit)) AS total_profit
FROM monthly_report
WHERE report_year = 2015
GROUP BY report_month
ORDER BY report_month;


select * from sales_report_2015_by_month

-------------------------------------------------

SELECT
    s.ship_mode,
    SUM(s.sales) AS total_sales_amount,
    SUM(s.qty) AS total_quantity_sold,
    AVG(s.discount) AS avg_discount,
    SUM(s.profit) AS total_profit
FROM sales s
WHERE s.order_date IS NOT NULL
GROUP BY s.ship_mode
ORDER BY total_sales_amount asc;
------------------------------------------------------

SELECT
    report_year,
    report_month,
    cust_id,ship_mode,
    SUM(total_profit) AS total_profit,
    CASE 
        WHEN SUM(total_quantity_sold) = 0 THEN 0
        ELSE SUM(total_profit) / SUM(total_quantity_sold)
    END AS avg_profit_per_sale,
    SUM(total_sales_amount) AS total_sales_amount,
    SUM(total_quantity_sold) AS total_quantity_sold
FROM monthly_report
GROUP BY report_year, report_month, cust_i,ship_mode
ORDER BY report_year, report_month, cust_id,ship_mode;
