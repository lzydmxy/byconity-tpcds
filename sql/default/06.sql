-- query6
SELECT a.ca_state state,
               count(*)   cnt
FROM   tpcds.customer_address a,
       tpcds.customer c,
       tpcds.store_sales s,
       tpcds.date_dim d,
       tpcds.item i
WHERE  a.ca_address_sk = c.c_current_addr_sk
       AND c.c_customer_sk = s.ss_customer_sk
       AND s.ss_sold_date_sk = d.d_date_sk
       AND s.ss_item_sk = i.i_item_sk
       AND d.d_month_seq = (SELECT DISTINCT ( d_month_seq )
                            FROM   tpcds.date_dim
                            WHERE  d_year = 1998
                                   AND d_moy = 7)
       AND i.i_current_price > 1.2 * (SELECT avg(j.i_current_price)
                                      FROM   tpcds.item j
                                      WHERE  j.i_category = i.i_category)
GROUP  BY a.ca_state
HAVING count(*) >= 10
ORDER  BY cnt
LIMIT 100
