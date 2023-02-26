-- query14
with 
  cross_items as (select i_item_sk ss_item_sk
 from item,
 (select iss.i_brand_id brand_id
     ,iss.i_class_id class_id
     ,iss.i_category_id category_id
 from store_sales
     ,item iss
     ,date_dim d1
 where ss_item_sk = iss.i_item_sk
   and ss_sold_date_sk = d1.d_date_sk
   and d1.d_year between 1999 AND 1999 + 2
 intersect 
 select ics.i_brand_id
     ,ics.i_class_id
     ,ics.i_category_id
 from catalog_sales
     ,item ics
     ,date_dim d2
 where cs_item_sk = ics.i_item_sk
   and cs_sold_date_sk = d2.d_date_sk
   and d2.d_year between 1999 AND 1999 + 2
 intersect
 select iws.i_brand_id
     ,iws.i_class_id
     ,iws.i_category_id
 from web_sales
     ,item iws
     ,date_dim d3
 where ws_item_sk = iws.i_item_sk
   and ws_sold_date_sk = d3.d_date_sk
   and d3.d_year between 1999 AND 1999 + 2)
 where i_brand_id = brand_id
      and i_class_id = class_id
      and i_category_id = category_id
) ,

  avg_sales as (select avg(quantity*list_price) average_sales
  from (select ss_quantity quantity
             ,ss_list_price list_price
       from store_sales
           ,date_dim
       where ss_sold_date_sk = d_date_sk
         and d_year between 1999 and 1999 + 2
       union all 
       select cs_quantity quantity 
             ,cs_list_price list_price
       from catalog_sales
           ,date_dim
       where cs_sold_date_sk = d_date_sk
         and d_year between 1999 and 1999 + 2 
       union all
       select ws_quantity quantity
             ,ws_list_price list_price
       from web_sales
           ,date_dim
       where ws_sold_date_sk = d_date_sk
         and d_year between 1999 and 1999 + 2) x) 
SELECT channel, 
               i_brand_id, 
               i_class_id, 
               i_category_id, 
               sum(sales), 
               sum(number_sales) 
FROM  (SELECT 'store'                          channel, 
              i_brand_id, 
              i_class_id, 
              i_category_id, 
              sum(ss_quantity * ss_list_price) sales, 
              count(*)                         number_sales 
       FROM   store_sales, 
              item, 
              date_dim 
       WHERE  ss_item_sk IN (SELECT ss_item_sk 
                             FROM   cross_items) 
              AND ss_item_sk = i_item_sk 
              AND ss_sold_date_sk = d_date_sk 
              AND d_year = 1999 + 2 
              AND d_moy = 11 
       GROUP  BY i_brand_id, 
                 i_class_id, 
                 i_category_id 
       HAVING sum(ss_quantity * ss_list_price) > (SELECT average_sales 
                                                  FROM   avg_sales) 
       UNION ALL 
       SELECT 'catalog'                        channel, 
              i_brand_id, 
              i_class_id, 
              i_category_id, 
              sum(cs_quantity * cs_list_price) sales, 
              count(*)                         number_sales 
       FROM   catalog_sales, 
              item, 
              date_dim 
       WHERE  cs_item_sk IN (SELECT ss_item_sk 
                             FROM   cross_items) 
              AND cs_item_sk = i_item_sk 
              AND cs_sold_date_sk = d_date_sk 
              AND d_year = 1999 + 2 
              AND d_moy = 11 
       GROUP  BY i_brand_id, 
                 i_class_id, 
                 i_category_id 
       HAVING sum(cs_quantity * cs_list_price) > (SELECT average_sales 
                                                  FROM   avg_sales) 
       UNION ALL 
       SELECT 'web'                            channel, 
              i_brand_id, 
              i_class_id, 
              i_category_id, 
              sum(ws_quantity * ws_list_price) sales, 
              count(*)                         number_sales 
       FROM   web_sales, 
              item, 
              date_dim 
       WHERE  ws_item_sk IN (SELECT ss_item_sk 
                             FROM   cross_items) 
              AND ws_item_sk = i_item_sk 
              AND ws_sold_date_sk = d_date_sk 
              AND d_year = 1999 + 2 
              AND d_moy = 11 
       GROUP  BY i_brand_id, 
                 i_class_id, 
                 i_category_id 
       HAVING sum(ws_quantity * ws_list_price) > (SELECT average_sales 
                                                  FROM   avg_sales)) y 
GROUP  BY channel, i_brand_id, i_class_id, i_category_id 
ORDER  BY channel, 
          i_brand_id, 
          i_class_id, 
          i_category_id
LIMIT 100 
