## 1. Поиск верной записи номера телефона без учёта регистра

```sh
select * 
from dbo.person
where dbo.person.phone_num ~* '^((\+7|7|8)+([0-9]){10})$'
```

## 2.Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN

Добавлена функция, которая выводит справочную информацию по пациенту, который записан на прием.
Связь таблиц изначально осуществляется inner join (join persons on persons.person_id=recording.person_id), 
чтобы отобрать только тех пациентов, которые записались на прием и исключить свободные бирки 
т.к. inner join оставляет только те данные, которые нашлись в обеих таблицах.
связь left join (в данном примере это left join v_adress adress on adress.adress_id = persons.adress_fact_id)
устанавливается, с целью найти адрес пациента, left join выбран потому что у пациента может быть не заполнен адрес, но самого пациента нам необходимо считать.

```sh
CREATE OR REPLACE FUNCTION public.list_recording_date(
	p_mo_id bigint DEFAULT NULL::bigint,
	p_doctor_id bigint DEFAULT NULL::bigint,	
	p_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
    RETURNS TABLE(card_num text, pers_fio text, person_birthday bigint, cnt_all_internet bigint, cnt_all_registrator bigint, cnt_all_terminal bigint, cnt_pers_busy bigint, cnt_person bigint, cnt_fact bigint, cnt_polyclinic_case bigint, cnt_result bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
begin
	return query
				select 
						card_num
						,concat_ws(' '
								  ,person_surname
								  ,person_firstname
								  ,person_secname
								 ) pers_fio
						,person_birthday
						,phone_num
						,concat_ws(', ',_index
								   ,_country
								   ,rgn
								   ,city
								   ,town
								   ,'ул. '||street
								   ,'д. '||house 
								   ,case when corpus = chr(45) then '' else 'корп. '||corpus end
								   ,'кв . '||flat
								  ) as adress_fact_name
						,polis.polis_type_name||', '||' Сер.:'||polis.polis_ser||' №:'||polis.polis_num||' Организация: '||org_name as polis

				from recording
				join persons on persons.person_id=recording.person_id
					
				join public.polyclinic_case sluch 
					on sluch.polyclinic_case_id = recording.polyclinic_case_id
				cross join lateral (
							select  polis_type.polis_type_name
									,polis.polis_ser
									,polis.polis_num
									,org.org_name
							from public.person_polis polis
							join public.polis_type polis_type 
								on polis.polis_type_id = polis_type.polis_type_id
							join public.org org 
								on polis.org_id = org.org_id
							where 1=1
							and polis.person_polis_id = persons.person_polis_id
							and coalesce(polis_enddate, 'Infinity') >= $3
							limit 1
						 ) polis 
				left join v_adress adress on adress.adress_id = persons.adress_fact_id
				
				where 1=1 
				and recording.doctor_id = $2 
				and recording.mo_id = $1 
				and recording.recording_begdate = $3
				order by concat_ws(' ',person_surname,person_firstname,person_secname) 
				; 
end;
$BODY$;
```

## 3.запрос на добавление данных с выводом информации о добавленных строках.

Простой пример на основе функции generate_series
задание (Добавление данных в справочную таблицу)

```sh
insert into sprav.house (house_name)
SELECT * FROM generate_series(101,200)
returning house_id, house_name;

insert into sprav.flat (flat_name)
SELECT * FROM generate_series(1,200)
returning flat_id, flat_name;
```
## 4. Запрос с обновлением данные посредством UPDATE FROM.

```sh
drop table if exists dbo.cnt_rec;
-- Таблица в которой будет храниться отчетная информация 
create table dbo.cnt_rec (
 mo_id integer
,doctor_id integer
,date_from timestamp
,date_to timestamp 
,mo_name text-- Наименование МО в которйо работает врач
,doctor_name text-- ФИО врача
,cnt_all integer-- общие бирки за период
,cnt_all_internet integer-- запись через интернет
,cnt_all_registrator integer-- запись через мед. регистратора
,cnt_all_terminal integer-- запись через терминал
,cnt_pers_busy integer-- занятые бирки людьми, которые записались
,cnt_person integer--количество людей, которые записались и пришли на прием
,cnt_fact integer-- занятые бирки
,cnt_polyclinic_case integer-- количество случаев открытых на записанных пациентов
,cnt_result integer-- количество закрытых случаев с типом выздоровел
);

-- Update через функцию тело функции ниже
insert into dbo.cnt_rec 
VALUES(1,  1, '2023-04-11'::timestamp,'2023-04-11'::timestamp, '', '', 0,0,0,0,0,0,0,0,0);
--select * from dbo.cnt_rec;
--select * from dbo.svod_recording(1, 1, '2023-04-11'::timestamp, '2023-04-11'::timestamp) as func

Update dbo.cnt_rec 
set  mo_name = func.mo_name
,doctor_name = func.doctor_name
,cnt_all = func.cnt_all
,cnt_all_internet = func.cnt_all_internet
,cnt_all_registrator = func.cnt_all_registrator
,cnt_all_terminal = func.cnt_all_terminal
,cnt_pers_busy = func.cnt_pers_busy
,cnt_person = func.cnt_person
,cnt_fact = func.cnt_fact
,cnt_polyclinic_case = func.cnt_polyclinic_case
,cnt_result = func.cnt_result
from dbo.svod_recording(1, 1, '2023-04-11'::timestamp, '2023-04-11'::timestamp) as func
where 1=1 -- здесь можно прописать условие на соединение таблиц, но в функции я не вывадила параметры
and mo_id  = 1
and doctor_id = 1
and date_from = '2023-04-11'::timestamp
and date_to = '2023-04-11'::timestamp

/*
CREATE OR REPLACE FUNCTION dbo.svod_recording(
	p_mo_id bigint DEFAULT NULL::bigint,
	p_doctor_id bigint DEFAULT NULL::bigint,
	p_date_from timestamp with time zone DEFAULT NULL::timestamp with time zone,
	p_date_to timestamp with time zone DEFAULT NULL::timestamp with time zone)
	RETURNS TABLE(mo_name text, doctor_name text, cnt_all bigint, cnt_all_internet bigint, cnt_all_registrator bigint, cnt_all_terminal bigint, cnt_pers_busy bigint, cnt_person bigint, cnt_fact bigint, cnt_polyclinic_case bigint, cnt_result bigint) 
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE PARALLEL UNSAFE
	ROWS 1000

AS $BODY$
begin
	return query
			select 
			 mo.mo_name			
			,doc.doctor_name
			,count(recording.recording_id) as cnt_all
			,count(recording.recording_id)
				filter(where recordtype_id  = 1) as cnt_all_internet
			,count(recording.recording_id)
				filter(where recordtype_id  = 2) as cnt_all_registrator
			,count(recording.recording_id)
				filter(where recordtype_id  = 3) as cnt_all_terminal
			,count(recording.recording_id)
				filter(where pers.person_id is not null) as cnt_pers_busy
			,count(recording.person_id) as cnt_person
			,count(recording.person_id)
				filter(where recording_factdate is not null) as cnt_fact -- занятые бирки
			,count(polca_case.polyclinic_case_id) as cnt_polyclinic_case
			,count(polca_case.polyclinic_case_id) 
				filter(where polca_case.result_type_id = ANY('{1,2}'::integer[])) as cnt_result

			from dbo.recording
			left join lateral (
				select doctors.doctor_name,doctors.mo_id
				from dbo.doctor doctors
				where 1=1
				and recording.mo_id = doctors.mo_id
				and doctors.doctor_id = recording.doctor_id				
				and coalesce(work_enddate, 'Infinity') >= now() -- Врач работает в мед организации на момент отчета
				and occupancy_type_id = 1 -- основное место работы
				) doc on true

			left join dbo.medorganisation mo on mo.mo_id = doc.mo_id
			cross join lateral (
				select persons.person_id 
				from dbo.person persons
				cross join lateral (
						select 1 
						from dbo.person_polis polis
						where 1=1
						and polis.person_polis_id = persons.person_polis_id
						and coalesce(polis_enddate, 'Infinity') >= $4
						limit 1
					 ) polis 
				)pers 

			left join lateral (	
				select polyclinic_case_id,result_type_id
				from dbo.polyclinic_case sluch
				join dbo.policlinic_visit visit 
					on visit.policlinic_visit_pid = sluch.polyclinic_case_id
					and finish_id = 1 -- случай закончен
				) polca_case on true
			where 1=1			
			and (recording.mo_id = $1 or recording.mo_id is null)
			and (recording.doctor_id = $2 or recording.mo_id is null)
			and recording_begdate between $3 and $4		
			group by mo.mo_name,doc.doctor_name
			order by mo.mo_name,doc.doctor_name			
			; 
end;
$BODY$;
*/
```
## 5. запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.

```sh
DELETE FROM dbo.recording USING dbo.doctor
  WHERE dbo.recording.doctor_id = dbo.doctor.doctor_id 
  AND coalesce(dbo.doctor.work_enddate,current_date) <= dbo.recording.recording_begdate
```

## COPY

Команда COPY позволяет прямо импортировать или экспортировать данные из таблиц БД во внешний файл bилииз внешнего файла в таблицу БД
команда COPY TO копирует данные создавая файл по ссылке на абсолютный путь
команда COPY FROM извлекает данные из файла по ссылке 

```sh
Например 
\copy (select count(*) from dbo.person) TO E'"C:\\Users\\Пользователь\\Desktop\\homework\\docker_rec_clinic\t.txt"';

команда \copy вызывается из psql, COPY из клиента 
```