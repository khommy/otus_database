use adventureworks;

DELIMITER $
DROP PROCEDURE IF EXISTS `reportincome1`$
CREATE PROCEDURE
`reportincome1` (
			 in _day integer
            ,in _month integer 
            ,in _year integer
            ,in _terr integer
			,in _groupCat integer
			,in _product integer
			)   
    BEGIN 

		drop table if exists report;
		create table if not exists 
			report (
					terr text , 
					category text, 
					product text,
					income decimal(19,4),
					_day int,
					_month int,
					_year int
					);

		insert into report
		select 
			Territory.Name as terr,
			prodcuteg.Name as category,
			prod.name product,
			orddetail.orderqty*orddetail.unitprice income,
			DAYOFWEEK(ord.DueDate) as _day,
			month(ord.DueDate) _month,
			year(ord.DueDate) _year
		FROM SalesOrderHeader ord 
		join SalesOrderDetail orddetail 
			on ord.SalesOrderID = orddetail.SalesOrderID 
		join salesperson sp on sp.SalesPersonID = ord.SalesPersonID
		join product prod on orddetail.ProductID = prod.ProductID
		join ProductSubcategory prodsubcateg
			on prodsubcateg.ProductSubcategoryID = prod.ProductSubcategoryID
		join productcategory prodcuteg
			on prodcuteg.ProductCategoryID = prodsubcateg.ProductCategoryID
		join salesterritory Territory on Territory.TerritoryID = ord.TerritoryID   
		where 1=1
			and	(DAYOFWEEK(ord.DueDate) = _day or _day is null)
			and (month(ord.DueDate) = _month or _month is null)
			and ( year(ord.DueDate) = _year or _year is null);

	if _terr = 1 
		then 			
            select 
				case 
					when GROUPING(report.terr) = 1 
						then 'Total all' 
					else report.terr 
				end terr
				,sum(income) inc 
			from report
			group by report.terr with rollup
          
	;end if;	

	if _groupCat = 1
		then 		
            select 
				case 
					when GROUPING(report.category) = 1 
						then 'Total all' 
					else report.category
				end category
				,sum(income) inc 
			from report
			group by report.category with rollup
            
    ;end if;
    
    if _product = 1
		then 		  
            select 
				case 
					when GROUPING(report.product) = 1 
						then 'Total all' 
					else report.product
				end product
				,sum(income) inc 
			from report
			group by report.product with rollup
           
	;end if;
	
    if _terr !=1  and _groupCat !=1 and _product !=1
		then 
		select 	
			case 	
				when GROUPING(report.terr, report.category, report.product) = 7 
					then 'Total all'
				else report.terr
			end terr,			
			case 	
				when GROUPING(report.terr, report.category, report.product) = 3 
					then concat_ws (' ', 'Total by', report.terr)
				else report.category
			end  category,    			
			case 	
				when GROUPING(report.terr, report.category, report.product) = 1 
					then concat_ws (' ', 'Total by', report.category)
				else report.product
			end  product  
			,cast(sum(income) as decimal(10,2)) inc 
		from report
		group by report.terr, report.category, report.product with rollup
      
	;end if
	
;end$
DELIMITER ;  


-- call `reportincome1`( 1, 10, 2002,1,0,0);