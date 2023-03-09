--
-- Legal Notice 
-- 
-- This document and associated source code (the "Work") is a part of a 
-- benchmark specification maintained by the TPC. 
-- 
-- The TPC reserves all right, title, and interest to the Work as provided 
-- under U.S. and international laws, including without limitation all patent 
-- and trademark rights therein. 
-- 
-- No Warranty 
-- 
-- 1.1 TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE INFORMATION 
--     CONTAINED HEREIN IS PROVIDED "AS IS" AND WITH ALL FAULTS, AND THE 
--     AUTHORS AND DEVELOPERS OF THE WORK HEREBY DISCLAIM ALL OTHER 
--     WARRANTIES AND CONDITIONS, EITHER EXPRESS, IMPLIED OR STATUTORY, 
--     INCLUDING, BUT NOT LIMITED TO, ANY (IF ANY) IMPLIED WARRANTIES, 
--     DUTIES OR CONDITIONS OF MERCHANTABILITY, OF FITNESS FOR A PARTICULAR 
--     PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OF 
--     WORKMANLIKE EFFORT, OF LACK OF VIRUSES, AND OF LACK OF NEGLIGENCE. 
--     ALSO, THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT, 
--     QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR NON-INFRINGEMENT 
--     WITH REGARD TO THE WORK. 
-- 1.2 IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THE WORK BE LIABLE TO 
--     ANY OTHER PARTY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO THE 
--     COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST PROFITS, LOSS 
--     OF USE, LOSS OF DATA, OR ANY INCIDENTAL, CONSEQUENTIAL, DIRECT, 
--     INDIRECT, OR SPECIAL DAMAGES WHETHER UNDER CONTRACT, TORT, WARRANTY,
--     OR OTHERWISE, ARISING IN ANY WAY OUT OF THIS OR ANY OTHER AGREEMENT 
--     RELATING TO THE WORK, WHETHER OR NOT SUCH AUTHOR OR DEVELOPER HAD 
--     ADVANCE NOTICE OF THE POSSIBILITY OF SUCH DAMAGES. 
-- 
-- Contributors:
-- Gradient Systems
--

select * from call_center order by cc_call_center_id desc limit 100;
select * from catalog_page order by cp_catalog_page_id desc limit 100;
select * from catalog_returns order by cr_returned_date_sk desc limit 100;
select * from catalog_sales order by cs_sold_date_sk desc limit 100;
select * from customer_address order by ca_address_id desc limit 100;
select * from customer_demographics order by cd_demo_sk desc limit 100;
select * from customer order by c_customer_id desc limit 100;
select * from date_dim order by d_date_id desc limit 100;
select * from household_demographics order by hd_demo_sk desc limit 100;
select * from income_band order by ib_income_band_sk desc limit 100;
select * from inventory order by inv_item_sk desc limit 100;
select * from item order by i_item_id desc limit 100;
select * from promotion order by p_promo_id desc limit 100;
select * from reason order by r_reason_id desc limit 100;
select * from ship_mode order by sm_ship_mode_id desc limit 100;
select * from store_returns order by sr_returned_date_sk desc limit 100;
select * from store_sales order by ss_sold_date_sk desc limit 100;
select * from store order by s_store_id desc limit 100;
select * from time_dim order by t_time_id desc limit 100;
select * from warehouse order by w_warehouse_id desc limit 100;
select * from web_page order by wp_web_page_id desc limit 100;
select * from web_returns order by wr_returned_date_sk desc limit 100;
select * from web_sales order by ws_sold_date_sk desc limit 100;
select * from web_site order by web_site_id desc limit 100;