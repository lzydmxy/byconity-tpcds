-- query76
SELECT channel,
               col_name,
               d_year,
               d_qoy,
               i_category,
               count(*)             sales_cnt,
               sum(ext_sales_price) sales_amt
FROM   (SELECT 'store'            AS channel,
               'ss_hdemo_sk'      col_name,
               d_year,
               d_qoy,
               i_category,
               ss_ext_sales_price ext_sales_price
        FROM   tpcds.store_sales,
               tpcds.item,
               tpcds.date_dim
        WHERE  ss_hdemo_sk IS NULL
               AND ss_sold_date_sk = d_date_sk
               AND ss_item_sk = i_item_sk
        UNION ALL
        SELECT 'web'              AS channel,
               'ws_ship_hdemo_sk' col_name,
               d_year,
               d_qoy,
               i_category,
               ws_ext_sales_price ext_sales_price
        FROM   tpcds.web_sales,
               tpcds.item,
               tpcds.date_dim
        WHERE  ws_ship_hdemo_sk IS NULL
               AND ws_sold_date_sk = d_date_sk
               AND ws_item_sk = i_item_sk
        UNION ALL
        SELECT 'catalog'          AS channel,
               'cs_warehouse_sk'  col_name,
               d_year,
               d_qoy,
               i_category,
               cs_ext_sales_price ext_sales_price
        FROM   tpcds.catalog_sales,
               tpcds.item,
               tpcds.date_dim
        WHERE  cs_warehouse_sk IS NULL
               AND cs_sold_date_sk = d_date_sk
               AND cs_item_sk = i_item_sk) foo
GROUP  BY channel,
          col_name,
          d_year,
          d_qoy,
          i_category
ORDER  BY channel,
          col_name,
          d_year,
          d_qoy,
          i_category
LIMIT 100
