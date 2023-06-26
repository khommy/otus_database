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

