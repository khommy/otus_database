use recorging_clinic;
SET @begdate=cast('2022-01-17' as date),
	@enddate = cast('2022-01-17' as date),
	@mo = 1,
    @doctor = 1;
    
#Запрос выводит записавшихся пациентов по конкретному врачу за период

select doctors.doctor_name
,record.recording_begdate
,record.recording_begtime
,CONCAT_WS(' ', person_surname,person_firstname,person_secname) fio
from recorging_clinic.recording record
left join doctor doctors on doctors.id=record.doctor_id
inner join person on doctors.person_id=person.id
where 1=1
and (doctors.id = @doctor or @doctor is null)
and (work_enddate >= @enddate or work_enddate is null) -- Врач работает в мед организации на момент окончания отчета
and occupancy_type = 'osn' -- основное место работы
and recording_begdate between @begdate and @enddate	


/*Напишите 5 запросов с WHERE с использованием разных
операторов, опишите для чего вам в проекте нужна такая выборка данных*/

# 1.Ищем все бирки на которые записались пациенты за период через EXISTS
SELECT *
FROM  recorging_clinic.recording record
WHERE EXISTS (
	SELECT * FROM person 
	WHERE record.person_id = person.id
	)
and recording_begdate between @begdate and @enddate	

# 2.Ищем все бирки на которые записались пациенты за период через IN 
SELECT *
FROM  recorging_clinic.recording record
WHERE record.person_id IN (
  SELECT person.id FROM person 
)
and recording_begdate between @begdate and @enddate	

#3. Поиск верных номеров телефонов
ALTER TABLE person ADD COLUMN phone_num VARCHAR(20);
select * 
from person
where phone_num REGEXP '^((\+7|7|8)+([0-9]){10})$'

#4 и 5 # Ищем все бирки на которые записались пациенты за период через IFNULL проверяем на не равенство 0
select * 
from recorging_clinic.recording record
where 1 = IF(record.person_id is not null,1,0)

select * 
from recorging_clinic.recording record
where IFNULL(record.person_id,0) !=0

