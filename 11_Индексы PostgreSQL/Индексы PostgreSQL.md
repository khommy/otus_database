## Индексы PostgreSQL
Домашнее задание выполнялось на демонмтрационной базе данных «Авиаперевозки».
Выбор базы продиктован объемом данных.
Например, в моей базе мало записей поэтому оптимизатору проще сканировать таблицы последовательно, чем отрабатывать по построенному индексу (я так думаю)

Например.

explain 
select * from dbo.person
where person_surname = 'Алтынцева' 
and person_firstname = 'Лидия' 
and person_secname = 'Евгеньевна';

```sh
"Seq Scan on person  (cost=0.00..1.05 rows=1 width=123)"
"  Filter: (((person_surname)::text = 'Алтынцева'::text) AND ((person_firstname)::text = 'Лидия'::text) AND ((person_secname)::text = 'Евгеньевна'::text))"
```

Поэтому самостоятельная работа выполнялась на базе demo «Авиаперевозки»

### 1. Создание индекса

Создала 2 отдельных индекса на таблицы bookings.bookings, bookings.tickets;

create index on bookings.bookings(book_ref);
create index on bookings.tickets (book_ref);
analyze bookings.boarding_passes;
analyze bookings.tickets;


при включениии условия поиска в блок where отрабатывает по индексу 

explain
select * from bookings.bookings b where book_ref = 'CB1DF3' ;
```sh
"Index Scan using bookings_book_ref_idx on bookings b  (cost=0.43..8.45 rows=1 width=21)"
"  Index Cond: (book_ref = 'CB1DF3'::bpchar)"
```
при join таблиц без условия, в запросе вызывается полная последовательность сканирования таблиц.

explain
select *
FROM bookings.bookings b
JOIN bookings.tickets t ON b.book_ref = t.book_ref		

```sh
"Hash Join  (cost=73316.98..264527.93 rows=2949857 width=125)"
"  Hash Cond: (t.book_ref = b.book_ref)"
"  ->  Seq Scan on tickets t  (cost=0.00..78913.57 rows=2949857 width=104)"
"  ->  Hash  (cost=34558.10..34558.10 rows=2111110 width=21)"
"        ->  Seq Scan on bookings b  (cost=0.00..34558.10 rows=2111110 width=21)"
"JIT:"
"  Functions: 10"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
```

explain
select *
FROM bookings.bookings b
JOIN bookings.tickets t ON b.book_ref = t.book_ref		
where b.book_ref = 'CB1DF3';

При включении фильтра по b.book_ref в условии join отработал по индексам 

```sh
"Nested Loop  (cost=0.86..20.93 rows=2 width=125)"
"  ->  Index Scan using bookings_book_ref_idx on bookings b  (cost=0.43..8.45 rows=1 width=21)"
"        Index Cond: (book_ref = 'CB1DF3'::bpchar)"
"  ->  Index Scan using tickets_book_ref_idx1 on tickets t  (cost=0.43..12.46 rows=2 width=104)"
"        Index Cond: (book_ref = 'CB1DF3'::bpchar)"
```
### Вывод: 

### 2. Индекс для полнотекстового поиска
Релизован на поле статус в таблице bookings.flights

```sh
create index on bookings.flights (status);
analyze bookings.flights;
vacuum bookings.flights;

explain
select 
FROM bookings.bookings b
JOIN bookings.tickets t ON b.book_ref = t.book_ref		
JOIN bookings.ticket_flights tf ON tf.ticket_no = t.ticket_no
JOIN bookings.flights f ON tf.flight_id = f.flight_id
join bookings.airports arr on f.arrival_airport = arr.airport_code
where f.status = 'Scheduled';

"Gather  (cost=210244.91..304799.28 rows=601158 width=0)"
"  Workers Planned: 2"
"  ->  Parallel Hash Join  (cost=209244.91..243683.48 rows=250482 width=0)"
"        Hash Cond: (b.book_ref = t.book_ref)"
"        ->  Parallel Seq Scan on bookings b  (cost=0.00..22243.29 rows=879629 width=7)"
"        ->  Parallel Hash  (cost=205134.88..205134.88 rows=250482 width=7)"
"              ->  Parallel Hash Join  (cost=122147.99..205134.88 rows=250482 width=7)"
"                    Hash Cond: (t.ticket_no = tf.ticket_no)"
"                    ->  Parallel Seq Scan on tickets t  (cost=0.00..61706.07 rows=1229107 width=21)"
"                    ->  Parallel Hash  (cost=117792.96..117792.96 rows=250482 width=14)"
"                          ->  Hash Join  (cost=3030.27..117792.96 rows=250482 width=14)"
"                                Hash Cond: (f.arrival_airport = arr.airport_code)"
"                                ->  Parallel Hash Join  (cost=3025.93..117104.32 rows=250482 width=18)"
"                                      Hash Cond: (tf.flight_id = f.flight_id)"
"                                      ->  Parallel Seq Scan on ticket_flights tf  (cost=0.00..104899.50 rows=3496650 width=18)"
"                                      ->  Parallel Hash  (cost=2912.76..2912.76 rows=9054 width=8)"
"                                            ->  Parallel Bitmap Heap Scan on flights f  (cost=175.58..2912.76 rows=9054 width=8)"
"                                                  Recheck Cond: ((status)::text = 'Scheduled'::text)"
"                                                  ->  Bitmap Index Scan on flights_status_idx1  (cost=0.00..171.73 rows=15392 width=0)"
"                                                        Index Cond: ((status)::text = 'Scheduled'::text)"
"                                ->  Hash  (cost=3.04..3.04 rows=104 width=4)"
"                                      ->  Seq Scan on airports arr  (cost=0.00..3.04 rows=104 width=4)"
"JIT:"
"  Functions: 34"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
```

Приведен большой пример для наглядности в блоке where стоит условие по отбору на поле status для этого отбора создалась битовая карта и происходит отбор по ней, для join соединений применяется паралельное сканирование и объединение без участия индекса.

### 3. Составной индекс 
На таблицу bookings.seats

```sh
Сканирование по битовой карте

create index on bookings.seats (aircraft_code,fare_conditions);
analyze bookings.seats;
explain
select *
FROM bookings.seats s
where aircraft_code = '319' and fare_conditions = 'Economy';

"Bitmap Heap Scan on seats s  (cost=5.29..14.78 rows=99 width=15)"
"  Recheck Cond: ((aircraft_code = '319'::bpchar) AND ((fare_conditions)::text = 'Economy'::text))"
"  ->  Bitmap Index Scan on seats_aircraft_code_fare_conditions_idx1  (cost=0.00..5.27 rows=99 width=0)"
"        Index Cond: ((aircraft_code = '319'::bpchar) AND ((fare_conditions)::text = 'Economy'::text))"

2 Пример Индексное сканирование
create index on bookings.flights(status,scheduled_departure);
analyze bookings.flights;

explain (costs off)
SELECT   status,scheduled_departure
FROM     bookings.flights
where status = 'Arrived' and  scheduled_departure > '2015-10-13';

"Index Only Scan using flights_status_scheduled_departure_idx on flights"
"  Index Cond: ((status = 'Arrived'::text) AND (scheduled_departure > '2015-10-13 00:00:00+00'::timestamp with time zone))"
```

### 4. Индекс на функции

```sh
create index on bookings.tickets(char_length(passenger_name));
analyze bookings.tickets;
explain
select * from bookings.tickets where char_length(passenger_name) > 20;

"Bitmap Heap Scan on tickets  (cost=195.28..35351.35 rows=17400 width=104)"
"  Recheck Cond: (char_length(passenger_name) > 20)"
"  ->  Bitmap Index Scan on tickets_char_length_idx  (cost=0.00..190.93 rows=17400 width=0)"
"        Index Cond: (char_length(passenger_name) > 20)"
```
### 5. Покрывающий индекс
Столкнулась с проблемой при создании покрывающего индекса

CREATE INDEX flights_status_scheduled_departure_idx1 ON bookings.flights(status,scheduled_departure)
INCLUDE (departure_airport);

И здесь возникла ошибка, которую не смогла исправить 

```sh
analyze bookings.flights;
explain
SELECT status,departure_airport
FROM bookings.flights  
where status = 'Arrived' and scheduled_departure > '2015-10-13' ;

"Seq Scan on flights  (cost=0.00..5847.00 rows=198166 width=12)"
"  Filter: ((scheduled_departure > '2015-10-13 00:00:00+00'::timestamp with time zone) AND ((status)::text = 'Arrived'::text))"
```

### 6. 
Столкнулась с проблемой при создании индекса для формата jsonb
```sh
CREATE INDEX ON bookings.tickets ((contact_data->'email'));
analyze bookings.tickets;
explain
SELECT * FROM bookings.tickets WHERE contact_data ->> 'email' = 'aaleksandrov1975@postgrespro.ru';

"Gather  (cost=1000.00..70328.60 rows=14751 width=104)"
"  Workers Planned: 2"
"  ->  Parallel Seq Scan on tickets  (cost=0.00..67853.50 rows=6146 width=104)"
"        Filter: ((contact_data ->> 'email'::text) = 'aaleksandrov1975@postgrespro.ru'::text)"
```
Также решить ее не смогла