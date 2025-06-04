IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
  DROP VIEW gold.dim_customers;

GO

CREATE VIEW gold.dim_customers AS
select ROW_NUMBER() over(ORDER BY ci.cst_id) AS customer_key
,ci.cst_id as customer_id,
ci.cst_key as customer_number
,ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
ci.cst_material_status as material_status
,ci.cst_create_date as create_date,
ca.bdate as birthdate,
case when ci.cst_gndr!='n/a' then ci.cst_gndr
     else coalesce(ca.gen,'n/a')
     end as gender
,la.cntry as country
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ca.cid=ci.cst_key
left join silver.erp_loc_a101 la
on la.cid=ci.cst_key

GO

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
  DROP VIEW gold.dim_products;

GO

create view gold.dim_products AS

select ROW_NUMBER() over(order by pn.prod_id) as product_key
,pn.prod_id as product_id
,pn.prod_key as product_number
,pn.prod_nm as product_name
,pn.cat_id as category_id
,pc.cat as category
,pc.subcat as subcategory
,pn.prod_line as product_line
,pn.prod_cost as product_cost
,pn.prod_start_dt as product_start_date
,pc.maintenance

from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id

GO

IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
  DROP VIEW gold.fact_sales ;

GO


create view gold.fact_sales as
SELECT
    sd.sls_ord_num as order_number,
    pr.product_key, --FK(dim_products)
    cr.customer_key, --FK(dim_customers)
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as shipping_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales,
    sd.sls_quantity as quantity,
    sd.sls_price as price
FROM silver.crm_sales_details AS sd
left join gold.dim_products pr
on pr.product_number=sd.sls_prd_key
left join gold.dim_customers cr
on cr.customer_id=sd.sls_cust_id


