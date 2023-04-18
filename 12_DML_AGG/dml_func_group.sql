--Создайте таблицу и наполните ее данными
CREATE TABLE statistic(
player_name VARCHAR(100) NOT NULL,
player_id INT NOT NULL,
year_game SMALLINT NOT NULL CHECK (year_game > 0),
points DECIMAL(12,2) CHECK (points >= 0),
PRIMARY KEY (player_name,year_game)
);
--заполнить данными
INSERT INTO
statistic(player_name, player_id, year_game, points)
VALUES
('Mike',1,2018,18),
('Jack',2,2018,14),
('Jackie',3,2018,30),
('Jet',4,2018,30),
('Luke',1,2019,16),
('Mike',2,2019,14),
('Jack',3,2019,15),
('Jackie',4,2019,28),
('Jet',5,2019,25),
('Luke',1,2020,19),
('Mike',2,2020,17),
('Jack',3,2020,18),
('Jackie',4,2020,29),
('Jet',5,2020,27);

--написать запрос суммы очков с группировкой и сортировкой по годам 
select player_name,year_game, sum(points) points_sum
from statistic
group by 1,2
order by 1,2;

-- Добавила в cte имя игрока т.к. во 2 варианте сделала группировку по 2 столбцам
with cte_stat as (
select player_name,year_game, sum(points) points_sum
from statistic
group by 1,2
order by 1,2
)
--Простой вариант
--группировка и сортировака по годам 
, cte_group_easy as (
	select 
		coalesce(tab_group.year_game::text, 'Total all') r_tab
		,tab_group.sum_year 
	from (
		select year_game, sum(points_sum) sum_year 
		from cte_stat
		group by  year_game --rollup (year_game) -- убрала чтобы в оконных функциях корректно включить
		order by 1
	) tab_group
)

--Вариант с grouping sets
, cte_group_hard as (
	select 
			case 
			when gr = 0 then year_game::text
			when gr = 1 then 'Total by '|| player_name 
			when gr = 2 then 'Total for '|| year_game::text
			when gr = 3 then 'Total all'
			end as r_tab
			,points_sum::int
	from (
		select 
			player_name
			,year_game
			,grouping(player_name,year_game) gr
			,sum(points_sum) points_sum
		from cte_stat
		group by grouping sets (1,2,(1,2),())
		order by 1,2
	) as cte_group
)

--используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий.
, cte_lag_lead as (
	select  
		 cgh.r_tab::text
		,cgh.sum_year
		,lag(cgh.sum_year) over (order by cgh.r_tab) as _lag
		,lead(cgh.sum_year) over (order by cgh.r_tab) as _lead
	from cte_group_easy cgh
	union all (
	select 
		'Total all' as r_tab
		,sum(cgh.sum_year) sum_year
		,null _lag
		,null _lead
	from cte_group_easy cgh
	)
)
-- И от себя crosstab

SELECT * FROM crosstab( 
	$$ 
	select 
	coalesce(player_name,'Total_sum') as player_name 
	,coalesce(year_game::text,'Total_sum') as year_game
	, sum(points) points_sum
	from statistic
	group by cube (player_name,year_game)
	order by 1,2
	$$, 	

	$$ select y::text FROM generate_series(2018,2020) y
	union all 
	select 'Total_sum'::text
	$$ 
) AS ( 
  player_name text, "2018" text, "2019" text, "2020" text, "Total_sum" text
);


