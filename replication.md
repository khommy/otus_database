# Репликация

## Настроить физическую репликации между двумя кластерами базы данных

После настройки реплики смотрим 
select * from pg_stat_replication;

![Рис 1](https://github.com/khommy/otus_database/blob/main/18_Replication/image/step1.PNG)

После настройки реплики на мастер сервере создаем базу данных, и смотрим ее на реплике

![Рис 2](https://github.com/khommy/otus_database/blob/main/18_Replication/image/step2.PNG)

Создаем слот репликации 
SELECT pg_create_physical_replication_slot('standby_slot'); 
![Рис 3](https://github.com/khommy/otus_database/blob/main/18_Replication/image/step3.PNG)

select * from pg_replication_slots; 
![Рис 4](https://github.com/khommy/otus_database/blob/main/18_Replication/image/step4.PNG)

