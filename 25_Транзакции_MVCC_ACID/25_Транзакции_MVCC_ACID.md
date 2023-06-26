# Установка СУБД MySql

## 1.Описать пример транзакции из своего проекта с изменением данных в нескольких таблицах. Реализовать в виде хранимой процедуры.
Хранимая процедура обновляет (исправляет) данные по МО прикреплениям в картах пациентов в зависимости от их возраста, т.к. взрослые и дети обслуживаются в разных МО

```sh
DROP PROCEDURE IF EXISTS upt_person_mo_age
DELIMITER //
CREATE PROCEDURE upt_person_mo_age ()
begin
    update recorging_clinic.person person
		left join recorging_clinic.person_card as person_card 
			using (id)
		left join recorging_clinic.mo mo 
			on mo.id = person_card.mo_id
		set person_card.mo_id = case 
									when TIMESTAMPDIFF(YEAR, person.person_birthday, CURDATE()) < 18 
										and mo.type_mo = 'adult'
										then 1
									when TIMESTAMPDIFF(YEAR, person.person_birthday, CURDATE()) >= 18
										and mo.type_mo = 'kids'
										then 2
									else person_card.mo_id = person_card.mo_id
								end                    
		where 
			TIMESTAMPDIFF(YEAR, person.person_birthday, CURDATE()) < 18 
            and mo.type_mo = 'adult' ;
end //
DELIMITER ;
```
## LOAD DATA

```sh 
use LoadDB;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

CREATE DATABASE LoadDB  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE Apparel(
Handle text NOT NULL,
Title text,
Body_HTML text
) ENGINE=INNODB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

select * from LoadDB.Apparel;

SHOW VARIABLES LIKE "secure_file_priv";

use LoadDB;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Apparel.csv'
INTO TABLE LoadDB.Apparel
CHARACTER SET cp1251
FIELDS TERMINATED BY ':'
LINES TERMINATED BY '\r\n'
IGNORE 2 LINES;
```

![Рис 1](https://github.com/khommy/otus_database/blob/main/25_Транзакции_MVCC_ACID/image/step1.PNG)

## mysqlimport

```sh
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

CREATE TABLE loaddb.jewelry(
Handle text,
Title text,
Body_HTML text
) ENGINE=INNODB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


mysqlimport -u root -p --ignore-lines=1 --lines-terminated-by="\r\n" --ignore loaddb 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\jewelry.csv'
```

Ошибка Error: 1146, Table 'loaddb.mysql' doesn't exist, when using table: MySQL Таблица точно есть 

  