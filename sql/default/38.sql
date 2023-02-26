-- query38
WITH g1 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   tpcds.store_sales,
               tpcds.date_dim,
               tpcds.customer
        WHERE  store_sales.ss_sold_date_sk = date_dim.d_date_sk
               AND store_sales.ss_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
), g2 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   tpcds.catalog_sales,
               tpcds.date_dim,
               tpcds.customer
        WHERE  catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
               AND catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
), g3 AS (
        SELECT DISTINCT c_last_name,
                        c_first_name,
                        d_date
        FROM   tpcds.web_sales,
               tpcds.date_dim,
               tpcds.customer
        WHERE  web_sales.ws_sold_date_sk = date_dim.d_date_sk
               AND web_sales.ws_bill_customer_sk = customer.c_customer_sk
               AND d_month_seq BETWEEN 1188 AND 1188 + 11
)
SELECT count(*)
FROM   g1
JOIN g2 ON g1.c_last_name = g2.c_last_name AND g1.c_first_name = g2.c_first_name AND g1.d_date = g2.d_date
JOIN g3 ON g1.c_last_name = g3.c_last_name AND g1.c_first_name = g3.c_first_name AND g1.d_date = g3.d_date
LIMIT 100
