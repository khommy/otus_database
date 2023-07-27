# Проанализировать план выполнения запроса, заценить на чем теряется время

## Исходный запрос взят на примере урока для базы AdentureWorks

```sh
select SQL_CALC_FOUND_ROWS 
	ord.orderYear, 
	ord.orderMonth, 
	orderSum.start_order AS start_order,
	orderSum.finish_order AS finish_order,
	COALESCE(orderSum.TotalSUM, 0) as TotalSUM, 
	COALESCE(orderSum.TotalQ,0) as TotalQ
from (
	select distinct
		 year(OrderDate) as orderYear
		,month(OrderDate) as orderMonth
	from SalesOrderHeader ord 
) ord

LEFT JOIN (
			SELECT 
				YEAR(ord1.OrderDate) as orderYear1
				, MONTH(ord1.OrderDate) as orderMonth1
                , Min(ord1.OrderDate) AS start_order
                , Max(ord1.OrderDate) AS finish_order             
                , SUM(orddetail.orderqty*orddetail.unitprice) AS TotalSUM              
                , SUM(orddetail.orderqty) AS TotalQ
           FROM SalesOrderHeader ord1 
		   join SalesOrderDetail orddetail on ord1.SalesOrderID = orddetail.SalesOrderID 		           
           GROUP BY YEAR(ord1.OrderDate), MONTH(ord1.OrderDate)
		   HAVING SUM(orddetail.orderqty) < 3000
           ) as orderSum 
			on orderSum.orderMonth1 = ord.orderMonth
			and orderSum.orderYear1 = ord.orderYear
order by ord.orderYear, ord.orderMonth;
 ```
 ## Простой Explain
![Рис 1](https://github.com/khommy/otus_database/blob/main/30_Профилирование/image/explain.PNG)

Описание:
запросы SELECT является частью подзапроса внутри выражения FROM
select 3 из warnings 
2	DERIVED	ord	all	в процессе выполнения запроса сканируется таблица целиком. 
3 	DERIVED ord1 eq_ref соединение по первичному ключу
3	DERIVED	orddetail ALL в процессе выполнения запроса сканируется таблица целиком. Отсутствуют индексы
Внешнее соединение
select 2
1	PRIMARY	<derived3>	ref	внешнее соединение по первичному ключу к select 3
'ord.orderYear,ord.orderMonth'
select 1
1	PRIMARY	<derived2>		ALL	Using filesort
При итоговой сортировке сканируется все целеком

![Рис 2](https://github.com/khommy/otus_database/blob/main/30_Профилирование/image/warnings.PNG)

 ## Формат json
Если кратко , то отсюда видно также отсутствие индексов и высокие косты при отборе данных, проблемные узлы отбор данных по таблицам 
```sh
{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "427424.90"
    },
    "ordering_operation": {
      "using_filesort": true,
      "cost_info": {
        "sort_cost": "313992.60"
      },
      "nested_loop": [
        {
          "table": {
            "table_name": "ord",
            "access_type": "ALL",
            "rows_examined_per_scan": 31399,
            "rows_produced_per_join": 31399,
            "filtered": "100.00",
            "cost_info": {
              "read_cost": "394.99",
              "eval_cost": "3139.90",
              "prefix_cost": "3534.89",
              "data_read_per_join": "490K"
            },
            "used_columns": [
              "orderYear",
              "orderMonth"
            ],
            "materialized_from_subquery": {
              "using_temporary_table": true,
              "dependent": false,
              "cacheable": true,
              "query_block": {
                "select_id": 2,
                "cost_info": {
                  "query_cost": "3244.15"
                },
                "duplicates_removal": {
                  "using_temporary_table": true,
                  "using_filesort": false,
                  "table": {
                    "table_name": "ord",
                    "access_type": "ALL",
                    "rows_examined_per_scan": 31399,
                    "rows_produced_per_join": 31399,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "104.25",
                      "eval_cost": "3139.90",
                      "prefix_cost": "3244.15",
                      "data_read_per_join": "22M"
                    },
                    "used_columns": [
                      "SalesOrderID",
                      "OrderDate"
                    ]
                  }
                }
              }
            }
          }
        },
        {
          "table": {
            "table_name": "orderSum",
            "access_type": "ref",
            "possible_keys": [
              "<auto_key0>"
            ],
            "key": "<auto_key0>",
            "used_key_parts": [
              "orderYear1",
              "orderMonth1"
            ],
            "key_length": "10",
            "ref": [
              "ord.orderYear",
              "ord.orderMonth"
            ],
            "rows_examined_per_scan": 10,
            "rows_produced_per_join": 313992,
            "filtered": "100.00",
            "cost_info": {
              "read_cost": "78498.15",
              "eval_cost": "31399.26",
              "prefix_cost": "113432.30",
              "data_read_per_join": "14M"
            },
            "used_columns": [
              "orderYear1",
              "orderMonth1",
              "start_order",
              "finish_order",
              "TotalSUM",
              "TotalQ"
            ],
            "materialized_from_subquery": {
              "using_temporary_table": true,
              "dependent": false,
              "cacheable": true,
              "query_block": {
                "select_id": 3,
                "cost_info": {
                  "query_cost": "54427.70"
                },
                "grouping_operation": {
                  "using_temporary_table": true,
                  "using_filesort": false,
                  "nested_loop": [
                    {
                      "table": {
                        "table_name": "orddetail",
                        "access_type": "ALL",
                        "rows_examined_per_scan": 120541,
                        "rows_produced_per_join": 120541,
                        "filtered": "100.00",
                        "cost_info": {
                          "read_cost": "184.25",
                          "eval_cost": "12054.10",
                          "prefix_cost": "12238.35",
                          "data_read_per_join": "16M"
                        },
                        "used_columns": [
                          "SalesOrderID",
                          "SalesOrderDetailID",
                          "OrderQty",
                          "UnitPrice"
                        ]
                      }
                    },
                    {
                      "table": {
                        "table_name": "ord1",
                        "access_type": "eq_ref",
                        "possible_keys": [
                          "PRIMARY"
                        ],
                        "key": "PRIMARY",
                        "used_key_parts": [
                          "SalesOrderID"
                        ],
                        "key_length": "4",
                        "ref": [
                          "adventureworks.orddetail.SalesOrderID"
                        ],
                        "rows_examined_per_scan": 1,
                        "rows_produced_per_join": 120541,
                        "filtered": "100.00",
                        "cost_info": {
                          "read_cost": "30135.25",
                          "eval_cost": "12054.10",
                          "prefix_cost": "54427.70",
                          "data_read_per_join": "87M"
                        },
                        "used_columns": [
                          "SalesOrderID",
                          "OrderDate"
                        ]
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      ]
    }
  }
}
```
# Оптимизация запроса на основе EXPLAIN ANALYZE
Данные на left join из таблицы orderdetail отбираются первичному ключу, сканируется 121317 строк, за время 56.1
все данные соединяются и помещаются во временную таблицу за время 115, затем снова сканируются полностью и 
фильтруются (sum(orddetail.OrderQty) < 3000) за время 252
Полное сканирование таблицы ord - 20.4 вставка во временную таблицу с дедупликацией (сжатие данных с исключением повторений)
материализауия сортировка и полное соединение данных слева. 
И на все время выполнения 285 для 37 строк за 1 цикл
```sh
-> Nested loop left join  (cost=138857 rows=0) (actual time=285..285 rows=37 loops=1)
    -> Sort: ord.orderYear, ord.orderMonth  (cost=60359..60359 rows=31399) (actual time=33.7..33.7 rows=37 loops=1)
        -> Table scan on ord  (cost=9919..10314 rows=31399) (actual time=33.5..33.5 rows=37 loops=1)
            -> Materialize  (cost=9919..9919 rows=31399) (actual time=33.5..33.5 rows=37 loops=1)
                -> Table scan on <temporary>  (cost=6384..6779 rows=31399) (actual time=33.3..33.3 rows=37 loops=1)
                    -> Temporary table with deduplication  (cost=6384..6384 rows=31399) (actual time=33.3..33.3 rows=37 loops=1)
                        -> Table scan on ord  (cost=3244 rows=31399) (actual time=0.493..20.4 rows=31465 loops=1)
    
    -> Index lookup on orderSum using <auto_key0> (orderYear1=ord.orderYear, orderMonth1=ord.orderMonth)  (cost=0.25..2.5 rows=10) (actual time=6.8..6.8 rows=0.297 loops=37)
        -> Materialize  (cost=0..0 rows=0) (actual time=252..252 rows=11 loops=1)
            -> Filter: (sum(orddetail.OrderQty) < 3000)  (actual time=252..252 rows=11 loops=1)
                -> Table scan on <temporary>  (actual time=252..252 rows=37 loops=1)
                    -> Aggregate using temporary table  (actual time=252..252 rows=37 loops=1)
                        -> Nested loop inner join  (cost=54428 rows=120541) (actual time=0.365..115 rows=121317 loops=1)
                            -> Table scan on orddetail  (cost=12238 rows=120541) (actual time=0.137..56.1 rows=121317 loops=1)
                            -> Single-row index lookup on ord1 using PRIMARY (SalesOrderID=orddetail.SalesOrderID)  (cost=0.25 rows=1) (actual time=373e-6..389e-6 rows=1 loops=121317)
```

## Промежуточный запрос, данные left join вынесены в отдельное CTE, добавлены индексы 
```sh
desc analyze  
with orderSum as (
	SELECT 
		_year as orderYear1
		, _month as orderMonth1
		, Min(ord1.OrderDate) AS start_order
		, Max(ord1.OrderDate) AS finish_order             
		, SUM(orddetail.orderqty*orddetail.unitprice) AS TotalSUM              
		, SUM(orddetail.orderqty) AS TotalQ
	FROM SalesOrderHeader ord1 
	join SalesOrderDetail orddetail on ord1.SalesOrderID = orddetail.SalesOrderID 		           
	GROUP BY _year, _month
	HAVING SUM(orddetail.orderqty) < 3000
)

select SQL_CALC_FOUND_ROWS 
	ord.orderYear, 
	ord.orderMonth, 
	orderSum.start_order AS start_order,
	orderSum.finish_order AS finish_order,
	COALESCE(orderSum.TotalSUM, 0) as TotalSUM, 
	COALESCE(orderSum.TotalQ,0) as TotalQ
from (
	select distinct
		 _year as orderYear
		,_month as orderMonth
	from SalesOrderHeader ord 
) ord

LEFT JOIN orderSum 
	on orderSum.orderMonth1 = ord.orderMonth
	and orderSum.orderYear1 = ord.orderYear
order by ord.orderYear, ord.orderMonth;

```
Время выполнения с 285 сократилось до 231 для 38 строк за 1 цикл
итоговая сортировка сократилась с 33 до 16,7 из за того, что при отборе данных перед сортировкой был использован покрывающий индекс
Covering index scan on ord using idx_func
 Уже лучше, но не идеал!!!

```sh
-> Nested loop left join  (cost=138857 rows=0) (actual time=231..231 rows=38 loops=1)
    -> Sort: ord.orderYear, ord.orderMonth  (cost=60359..60359 rows=31399) (actual time=16.7..16.7 rows=38 loops=1)
        -> Table scan on ord  (cost=9919..10314 rows=31399) (actual time=16.6..16.6 rows=38 loops=1)
            -> Materialize  (cost=9919..9919 rows=31399) (actual time=16.6..16.6 rows=38 loops=1)
                -> Table scan on <temporary>  (cost=6384..6779 rows=31399) (actual time=16.6..16.6 rows=38 loops=1)
                    -> Temporary table with deduplication  (cost=6384..6384 rows=31399) (actual time=16.6..16.6 rows=38 loops=1)
                        -> Covering index scan on ord using idx_func  (cost=3244 rows=31399) (actual time=0.231..11.5 rows=31465 loops=1)
    -> Index lookup on orderSum using <auto_key0> (orderYear1=ord.orderYear, orderMonth1=ord.orderMonth)  (cost=0.25..2.5 rows=10) (actual time=5.64..5.64 rows=0.289 loops=38)
        -> Materialize CTE ordersum  (cost=0..0 rows=0) (actual time=214..214 rows=11 loops=1)
            -> Filter: (sum(orddetail.OrderQty) < 3000)  (actual time=214..214 rows=11 loops=1)
                -> Table scan on <temporary>  (actual time=214..214 rows=38 loops=1)
                    -> Aggregate using temporary table  (actual time=214..214 rows=38 loops=1)
                        -> Nested loop inner join  (cost=54428 rows=120541) (actual time=0.0717..104 rows=121317 loops=1)
                            -> Table scan on orddetail  (cost=12238 rows=120541) (actual time=0.0504..40.8 rows=121317 loops=1)
                            -> Single-row index lookup on ord1 using PRIMARY (SalesOrderID=orddetail.SalesOrderID)  (cost=0.25 rows=1) (actual time=406e-6..423e-6 rows=1 loops=121317)
```

## Итоговый запрос cte pfзисала во временную таблицу, со сроком жизни данного запроса ( удалится после выаолнения запросов, висеть в памяти не будет), на нее повесила индекс, на год и месяц и индекс на количество ед. товара, чтобы отфильтровать строки

```sh
drop temporary table if exists  tmp_orderSum;
CREATE TEMPORARY TABLE tmp_orderSum
(INDEX idx_year_month (orderYear1, orderMonth1), INDEX idx_TotalQ(TotalQ))

SELECT 
	 _year as orderYear1
	, _month as orderMonth1
	, Min(ord1.OrderDate) AS start_order
	, Max(ord1.OrderDate) AS finish_order             
	, SUM(orddetail.orderqty*orddetail.unitprice) AS TotalSUM              
	, SUM(orddetail.orderqty) AS TotalQ
FROM SalesOrderHeader ord1 
join SalesOrderDetail orddetail 
on ord1.SalesOrderID = orddetail.SalesOrderID 		           
GROUP BY _year, _month;

EXPLAIN ANALYZE
select SQL_CALC_FOUND_ROWS 
	ord._year as orderYear, 
	ord._month as orderMonth, 
	orderSum.start_order AS start_order,
	orderSum.finish_order AS finish_order,
	COALESCE(orderSum.TotalSUM, 0) as TotalSUM, 
	COALESCE(orderSum.TotalQ,0) as TotalQ
from (select distinct _year, _month from SalesOrderHeader) ord 
LEFT JOIN (select orderYear1, orderMonth1,start_order,finish_order,TotalSUM ,TotalQ from tmp_orderSum where TotalQ < 3000) orderSum    
    on orderSum.orderMonth1 = ord._month
	and orderSum.orderYear1 = ord._year
order by ord._year, ord._month;
```
Время выполнения всего запроса сократилось до 12.1 для 38 строк за 1 цикл, по сравнению с 1 запросом и 2 раза


```sh 
-> Nested loop left join  (cost=71349 rows=31399) (actual time=12..12.1 rows=38 loops=1)
    -> Sort: ord._year, ord._month  (cost=60359..60359 rows=31399) (actual time=12..12 rows=38 loops=1)
        -> Table scan on ord  (cost=9919..10314 rows=31399) (actual time=12..12 rows=38 loops=1)
            -> Materialize  (cost=9919..9919 rows=31399) (actual time=12..12 rows=38 loops=1)
                -> Table scan on <temporary>  (cost=6384..6779 rows=31399) (actual time=12..12 rows=38 loops=1)
                    -> Temporary table with deduplication  (cost=6384..6384 rows=31399) (actual time=12..12 rows=38 loops=1)
                        -> Covering index scan on SalesOrderHeader using idx_func  (cost=3244 rows=31399) (actual time=0.0355..6.95 rows=31465 loops=1)
    -> Filter: (tmp_ordersum.TotalQ < 3000)  (cost=0.25 rows=1) (actual time=0.00282..0.00299 rows=0.289 loops=38)
        -> Index lookup on tmp_orderSum using idx_year_month (orderYear1=ord._year, orderMonth1=ord._month)  (cost=0.25 rows=1) (actual time=0.00233..0.00278 rows=1 loops=38)
```