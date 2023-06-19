use adventureworks;
SET sql_mode = 'ONLY_FULL_GROUP_BY';

-- группировки с ипользованием CASE, HAVING, ROLLUP,GROUPING() :
-- with cte (terrname,orderYear,TotalQuant,Income,minunitprice,maxunitprice) as (
SELECT 
	case 
		when GROUPING(territory.Name, YEAR(ord.OrderDate)) = 3 then 'Total all'
		when GROUPING(territory.Name, YEAR(ord.OrderDate)) = 1 then concat_ws (' ', 'Total by', Territory.Name)
		else Territory.Name
    end  terrname
	,YEAR(ord.OrderDate) as orderYear    
    ,SUM(orddetail.orderqty)  AS TotalQuant
    ,cast(sum(orddetail.orderqty*orddetail.unitprice) as decimal (15,2)) as Income
	,min(orddetail.unitprice)  AS minunitprice
    ,max(orddetail.unitprice) AS maxunitprice
FROM SalesOrderHeader ord 
join SalesOrderDetail orddetail   
on ord.SalesOrderID = orddetail.SalesOrderID 
join salesterritory Territory on Territory.TerritoryID = ord.TerritoryID
where ord.OnlineOrderFlag = 1 -- только online заказы
group by  Territory.Name, YEAR(ord.OrderDate) with rollup
HAVING sum(orddetail.orderqty*orddetail.unitprice) > 600000
order by territory.Name, YEAR(ord.OrderDate)
;
-- 2, 3,4 пункт

select 
productcategory.name
-- , product.name
, count(product.productID) cnt -- кол-во предложений т.е. количество товаров в каждой категории
, min(product.listprice)  minPrice -- минимальноя цена предложения по категории
, max(product.listprice)  maxPrice -- максимальная цена предложения по категории
             
FROM product	
join ProductSubcategory 
	on ProductSubcategory.ProductSubcategoryID = product.ProductSubcategoryID
join productcategory
	on productcategory.ProductCategoryID = ProductSubcategory.ProductCategoryID
group by productcategory.name with rollup
;

