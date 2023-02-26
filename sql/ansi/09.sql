-- query9
SELECT CASE
         WHEN (SELECT count(*)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 1 AND 20) > 3672 THEN
         (SELECT avg(ss_ext_list_price)
          FROM   tpcds.store_sales
          WHERE
         ss_quantity BETWEEN 1 AND 20)
         ELSE (SELECT avg(ss_net_profit)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 1 AND 20)
       END bucket1,
       CASE
         WHEN (SELECT count(*)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 21 AND 40) > 3392 THEN
         (SELECT avg(ss_ext_list_price)
          FROM   tpcds.store_sales
          WHERE
         ss_quantity BETWEEN 21 AND 40)
         ELSE (SELECT avg(ss_net_profit)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 21 AND 40)
       END bucket2,
       CASE
         WHEN (SELECT count(*)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 41 AND 60) > 32784 THEN
         (SELECT avg(ss_ext_list_price)
          FROM   tpcds.store_sales
          WHERE
         ss_quantity BETWEEN 41 AND 60)
         ELSE (SELECT avg(ss_net_profit)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 41 AND 60)
       END bucket3,
       CASE
         WHEN (SELECT count(*)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 61 AND 80) > 26032 THEN
         (SELECT avg(ss_ext_list_price)
          FROM   tpcds.store_sales
          WHERE
         ss_quantity BETWEEN 61 AND 80)
         ELSE (SELECT avg(ss_net_profit)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 61 AND 80)
       END bucket4,
       CASE
         WHEN (SELECT count(*)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 81 AND 100) > 23982 THEN
         (SELECT avg(ss_ext_list_price)
          FROM   tpcds.store_sales
          WHERE
         ss_quantity BETWEEN 81 AND 100)
         ELSE (SELECT avg(ss_net_profit)
               FROM   tpcds.store_sales
               WHERE  ss_quantity BETWEEN 81 AND 100)
       END bucket5
FROM   tpcds.reason
WHERE  r_reason_sk = 1
