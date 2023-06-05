-- Общие принципы смены типов данных
-- 1. Везде первичный ключ id UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY как аналог serial;
-- 2. Для таблиц, в которых не важно как храниться время в полях, на поля проставлен тип данных datetime,для таблицы recording время храним отдельно стипом time, т.к. это время на бирке
-- 3. text переведен в varchar с количеством символов для экономии
-- 4. везде с целочисленными типами проставлено свойство UNSIGNED, т.к. они всегда положительные
-- 5. В таблицу person добален атрибут person_attribute с типлом данных json, произведена вставка данных и вставка и изменение данных

CREATE DATABASE IF NOT EXISTS recorging_clinic;
ALTER DATABASE recorging_clinic CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

SET default_storage_engine = INNODB;
use recorging_clinic;

CREATE TABLE IF NOT EXISTS recorging_clinic.adress (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,-- переписан на псевданим т.к. так быстрее
	adress_index integer UNSIGNED NOT NULL,
	adress_country enum('russia', 'belarus', 'kz' ) NOT NULL,
	adress_rgn_id integer UNSIGNED NOT NULL,
	adress_city_id integer UNSIGNED NOT NULL,
	adress_town_id integer UNSIGNED,
	adress_street_id integer UNSIGNED,
	adress_house_id integer UNSIGNED,
	adress_corpus_id integer UNSIGNED,
	adress_flat_id integer UNSIGNED,
	address_name varchar(250), -- смена типа на varchar(250) в кодировке utf8mb4
	address_insdate datetime, -- -- смена типа
	address_update datetime -- -- смена типа
);

CREATE TABLE IF NOT EXISTS recorging_clinic.doctor (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY, -- переписан на псевданим т.к. так быстрее
    person_id bigint UNSIGNED NOT NULL,
    doctor_name varchar(250),
    mo_id bigint UNSIGNED,
    num_room integer UNSIGNED NOT NULL,
    work_begdate datetime,
    work_enddate datetime,
    occupancy_type enum('osn', 'sovm'), -- смена типа, убрала ссылку на справочную таблицу благодаря типу данных 
	doctor_insdate datetime, -- смена типа данных
	doctor_update datetime -- смена типа данных
);

CREATE TABLE IF NOT EXISTS recorging_clinic.person (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	person_surname varchar(100) NOT NULL, -- смена кодировки
	person_firstname varchar(100) NOT NULL,  -- смена кодировки
	person_secname varchar(100) NOT NULL, -- смена кодировки
	person_birthday datetime,-- смена типа данных
	person_polis_id bigint UNSIGNED NOT NULL,
	person_begdate datetime,-- смена типа данных
	person_enddate datetime,-- смена типа данных	
	adress_reg_id bigint UNSIGNED,
	adress_fact_id bigint UNSIGNED,
	person_card_id bigint UNSIGNED,
    person_attribute json
);

-- 2. Задание работа с JSON
INSERT INTO recorging_clinic.person(
	person_surname,
	person_firstname,
	person_secname,
	person_birthday,
    person_polis_id,
	person_attribute
)
VALUES(
	'Иванов',
	'Иван',
    'Иванович',
    '1987-01-19',
    '1',
	'{"phone": "89194459875", "email": "ivanovii@rambler.ru",
      "passport": {"ser": "1125", "num": "897584", "data": "20110101", "orgvid": "Отделом УФМС России"}}'
);

select * 
from recorging_clinic.person;
SELECT JSON_TYPE(person_attribute) FROM recorging_clinic.person;

select 
	JSON_EXTRACT(`person_attribute` , '$.passport.ser'),
	`person_attribute` -> '$.passport.num',
	`person_attribute` -> '$.email'
from recorging_clinic.person
where 1=1
	  or JSON_EXTRACT(`person_attribute` , '$.passport.ser') = '1125'
	 or `person_attribute` -> '$.passport.num' > 0    
;

UPDATE recorging_clinic.person
SET `person_attribute` = JSON_INSERT(
	`person_attribute` ,
	'$.code' ,
	'2222'
)
-- select * from recorging_clinic.person
WHERE id = 1;
    
UPDATE recorging_clinic.person
SET `person_attribute` = JSON_REPLACE(
	`person_attribute` ,
	'$.code' ,
	'3333'
)
select * from recorging_clinic.person
WHERE id = 1;
    

CREATE TABLE IF NOT EXISTS person_card (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	card_num varchar(10) NOT NULL,
	mo_id bigint UNSIGNED,
	card_begdate datetime, -- смена типа данных
	card_enddate datetime, -- смена типа данных
	card_insdate datetime, -- смена типа данных
	card_update datetime -- смена типа данных
);

CREATE TABLE IF NOT EXISTS mo (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	mo_name MEDIUMTEXT NOT NULL, -- смена типа текст на  MEDIUMTEXT 
	org_id bigint UNSIGNED NOT NULL	
);

CREATE TABLE IF NOT EXISTS org (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    org_code integer UNSIGNED NOT NULL,
    org_name text ,
    org_uradress_id bigint UNSIGNED NOT NULL,
    org_pochtadress_id bigint UNSIGNED NOT NULL,
	org_insdate datetime,
	org_update datetime,
    recviziti json    
);

CREATE TABLE IF NOT EXISTS person_polis (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	polis_begdate datetime,
	polis_enddate datetime,
	polis_type enum('Old', 'Edin', 'Vrem') NOT NULL,
	polis_ser varchar(10),
	polis_num bigint UNSIGNED not null,
	org_id bigint UNSIGNED NOT NULL,
	polis_insdate datetime,
	polis_update datetime	
);

CREATE TABLE IF NOT EXISTS polyclinic_case (
    id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    person_id bigint UNSIGNED NOT NULL,
    policlinic_case_begdate datetime NOT NULL,
    policlinic_case_enddate datetime,
    diag_id bigint UNSIGNED NOT NULL,
    diag_pid bigint UNSIGNED NOT NULL,
    person_card_id bigint NOT NULL,
    mo_id bigint UNSIGNED NOT NULL,
    result_type enum('vizdor','neizmen','oslojznen'),
    finish enum('zaktit', 'nezakrit') NOT NULL,
	polyclinic_insdate datetime,
	polyclinic_update datetime
   );

CREATE TABLE IF NOT EXISTS policlinic_visit (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    policlinic_visit_pid bigint UNSIGNED NOT NULL,
    policlinic_visit_count integer UNSIGNED,
    visit_begdate datetime,
    visit_enddate datetime,
    oplata enum('oms', 'dms', 'money') not null,
    diag_id bigint UNSIGNED NOT NULL,
	policlinic_visit_insdate datetime,
	policlinic_visit_update datetime
   );
   
   CREATE TABLE IF NOT EXISTS recording (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    doctor_id bigint UNSIGNED NOT NULL,
    person_id bigint UNSIGNED NOT NULL,
    recording_begdate datetime,
    recording_begtime time,
    recording_factdate datetime,
    recording_facttime time,
    recordtype enum('registrator','internet', 'terminal', 'prilojz') NOT NULL,
    polyclinic_case_id bigint UNSIGNED NOT NULL,
    mo_id integer UNSIGNED NOT NULL,
	recording_insdate datetime,
	recording_update datetime
);

CREATE TABLE IF NOT EXISTS rgn (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	rgn_name  varchar(200) NOT NULL,
	country enum('russia', 'belarus', 'kz' ) NOT NULL
);

CREATE TABLE IF NOT EXISTS city (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	city_name  varchar(200) NOT NULL,
	rgn_id bigint UNSIGNED NOT NULL	
);

CREATE TABLE IF NOT EXISTS town (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	town_name varchar(200) NOT NULL,
	city_id bigint UNSIGNED NOT NULL	
);

CREATE TABLE IF NOT EXISTS street (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	street_name varchar(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS house (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	house_name varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS corpus (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	corpus_name varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS flat (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	flat_name varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS diag (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	diag_pid integer UNSIGNED NOT NULL,
	diaglevel_id integer UNSIGNED,
	diag_code varchar(10) UNIQUE,
	diag_name varchar(300) UNIQUE	
);


