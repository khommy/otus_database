use adventureworks;
DELIMITER $
DROP PROCEDURE IF EXISTS `prof`$
CREATE PROCEDURE `prof`(
			 in _category varchar(50)
            ,in _productnumber varchar(50)
            ,in _color varchar(50)
            ,in _pricestart decimal(12,2)
			,in _priceend decimal(12,2)
            ,in _sort varchar(50)
			,in _lim1 integer
            ,in _lim2 integer
			)
BEGIN   
 
	set @_sql =     concat( '
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
			and trim(pmx.cultureid) = ''en'' ' ,
			'join ProductDescription pd 
				ON pmx.ProductDescriptionID = pd.ProductDescriptionID
			where 1=1'
	);

    if _category is not null 
		then
			SET @_sql := concat(@_sql, ' and trim(prodsubcateg.Name) = ',_category );
    end if;

	if _productnumber is not null 
		then
			SET @_sql := concat(@_sql, ' and trim(prod.productnumber) = ',_productnumber);
    end if;

	if _color is not null 
		then
			SET @_sql := concat(@_sql, ' and trim(prod.color) = ',_color);
    end if;

	if _pricestart is not null and  _priceend is not null 
		then
			SET @_sql := concat(@_sql, ' and cast(prod.ListPrice as UNSIGNED) between ',_pricestart, ' and ',_priceend);
    end if;

	if (_sort = 'category' or _sort is null)
		then
			set @_sql := concat(@_sql, ' order by prodsubcateg.Name');
	elseif _sort = 'productname' 
		then
			set @_sql := concat(@_sql, ' order by prod.name');
	elseif _sort = 'price'
		then 	
			set @_sql := concat(@_sql, ' order by prod.ListPrice');
    end if;
    
 
    set @_sql := concat(@_sql, ' limit ', _lim1, ',', _lim2);
	PREPARE stmt FROM @_sql;   
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;       
END$
DELIMITER ;   

use adventureworks;
call `prof` ('''Cranksets''', null,null,null,null,'category',1,20);