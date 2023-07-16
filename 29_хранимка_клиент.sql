use adventureworks;

DELIMITER $
DROP PROCEDURE IF EXISTS `productList`$
CREATE PROCEDURE
`productList` (
			 in _cultureid varchar(10)	
            ,in _category varchar(100)	
            ,in _productnumber varchar(100)	
            ,in _color varchar(30)
			,in _pricestart integer
            ,in _priceend integer 
            ,in _sort varchar(30)
            ,in _lim1 integer
            ,in _lim2 integer
			)   
    BEGIN    
   		select 
			prodsubcateg.Name as category
			,prod.productnumber
			,prod.name product
			,prod.ListPrice  Price    
			,prod.Style
			,prod.color
			,prod.size
			,trim(pmx.cultureid) as culture
			,pd.description
		FROM product prod
		join ProductSubcategory prodsubcateg
			on prodsubcateg.ProductSubcategoryID = prod.ProductSubcategoryID
		join productcategory prodcuteg
			on prodcuteg.ProductCategoryID = prodsubcateg.ProductCategoryID
		join ProductModel prodmodel
			on prod.ProductModelID = prodmodel.ProductModelID
		join ProductModelProductDescriptionCulture pmx 
			on prodmodel.ProductModelID = pmx.ProductModelID
			and trim(pmx.cultureid) = coalesce (_cultureid, 'en')
		join ProductDescription pd 
			ON pmx.ProductDescriptionID = pd.ProductDescriptionID
		where 1=1
		and (trim(prodsubcateg.Name) = _category or _category is null)
		and (trim(prod.productnumber) = _productnumber or _productnumber is null)
		and (trim(prod.color) =  _color or _color is null)
		and ( (cast(prod.ListPrice as UNSIGNED) between _pricestart and _priceend ) 
			or (_pricestart is null and _priceend is null)
			)
	order by	
		case 
			when _sort = 'category' or _sort is null then prodsubcateg.Name
			when _sort = 'productname' then prod.name
			when _sort = 'price' then prod.ListPrice
		 end
	limit _lim1, _lim2
;END$
DELIMITER ;                  
		  
-- call productList( 'en', null, null,null, 0, 2500 , null,1,2);