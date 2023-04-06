CREATE DATABASE recorging_clinic
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
CREATE TABLESPACE db_rec_space LOCATION '/data/ts_rec_clinic';
	
SELECT * FROM pg_tablespace;

CREATE SCHEMA dbo;
CREATE SCHEMA sprav;

CREATE SEQUENCE sprav.recording_sprav_seq START 1; -- Одна последовательность на все справочники
CREATE SEQUENCE dbo.adress_adress_id_seq START 1;
CREATE SEQUENCE dbo.doctor_id_seq START 1;
CREATE SEQUENCE dbo.person_id_seq START 1;
CREATE SEQUENCE dbo.mo_id_seq START 1;
CREATE SEQUENCE dbo.org_id_seq START 1;
CREATE SEQUENCE dbo.person_card_num_id_seq START 1;
CREATE SEQUENCE dbo.person_polis_id_seq START 1;
CREATE SEQUENCE dbo.polyclinic_case_seq START 1;
CREATE SEQUENCE dbo.polyclinic_visit_id_seq START 1;
CREATE SEQUENCE dbo.recording_recording_id_seq START 1;

CREATE TABLE IF NOT EXISTS dbo.adress (
	adress_id bigint NOT NULL DEFAULT nextval('dbo.adress_adress_id_seq'::regclass),
	adress_index integer NOT NULL,
	adress_country_id integer NOT NULL,
	adress_rgn_id integer NOT NULL,
	adress_city_id integer NOT NULL,
	adress_town_id integer,
	adress_street_id integer,
	adress_house_id integer,
	adress_corpus_id integer,
	adress_flat_id integer,
	address_name text COLLATE pg_catalog."default",
	address_insdate timestamp without time zone, -- дата загрузки
	address_update timestamp without time zone, -- дата обновления
	CONSTRAINT adress_pkey PRIMARY KEY (adress_id)
);

CREATE TABLE IF NOT EXISTS dbo.doctor (
    doctor_id bigint NOT NULL DEFAULT nextval(' dbo.doctor_id_seq'::regclass),
    person_id bigint NOT NULL,
    doctor_name text COLLATE pg_catalog."default" NOT NULL,
    mo_id bigint,
    num_room integer NOT NULL,
    work_begdate timestamp without time zone,
    work_enddate timestamp without time zone,
    occupancy_type_id integer NOT NULL,
	doctor_insdate timestamp without time zone,
	doctor_update timestamp without time zone,
    CONSTRAINT doctor_pkey PRIMARY KEY (doctor_id)
);

CREATE TABLE IF NOT EXISTS dbo.person (
	person_id bigint NOT NULL DEFAULT nextval('dbo.person_id_seq'::regclass),
	person_surname character varying(100) COLLATE pg_catalog."default" NOT NULL,
	person_firstname character varying(50) COLLATE pg_catalog."default" NOT NULL,
	person_secname character varying(100) COLLATE pg_catalog."default",
	person_birthday timestamp without time zone,
	person_polis_id bigint NOT NULL,
	person_begdate timestamp without time zone NOT NULL,
	person_enddate timestamp without time zone,
	phone_num bigint,
	adress_reg_id bigint ,
	adress_fact_id bigint,
	person_card_id bigint,
	CONSTRAINT person_pkey PRIMARY KEY (person_id)
);

CREATE TABLE IF NOT EXISTS dbo.person_card (
	person_card_id bigint NOT NULL DEFAULT nextval('dbo.person_card_num_id_seq'::regclass),
	card_num character varying(10),
	mo_id bigint,
	card_begdate timestamp without time zone,
	card_enddate timestamp without time zone,
	card_insdate timestamp without time zone,
	card_update timestamp without time zone,
	CONSTRAINT person_card_pkey PRIMARY KEY (person_card_id)
);

CREATE TABLE IF NOT EXISTS dbo.medorganisation (
	mo_id bigint NOT NULL DEFAULT nextval('dbo.mo_id_seq'::regclass),
	mo_name text COLLATE pg_catalog.ucs_basic NOT NULL,
	org_id bigint NOT NULL,
	CONSTRAINT medorganisation_pkey PRIMARY KEY (mo_id)
);

CREATE TABLE IF NOT EXISTS dbo.person_polis (
	person_polis_id integer NOT NULL DEFAULT nextval('dbo.person_polis_id_seq'::regclass),
	polis_begdate timestamp without time zone,
	polis_enddate timestamp without time zone,
	polis_type_id integer NOT NULL,
	polis_ser text COLLATE pg_catalog."default" ,
	polis_num bigint,
	org_id bigint NOT NULL,
	polis_insdate timestamp without time zone,
	polis_update timestamp without time zone,
	CONSTRAINT person_polis_pkey PRIMARY KEY (person_polis_id)
);

CREATE TABLE IF NOT EXISTS dbo.org (
    org_id bigint NOT NULL DEFAULT nextval('dbo.org_id_seq'::regclass),
    org_code integer NOT NULL,
    org_name text COLLATE pg_catalog."default" NOT NULL,
    org_uradress_id bigint NOT NULL,
    org_pochtadress_id bigint NOT NULL,
	org_insdate timestamp without time zone,
	org_update timestamp without time zone,
    CONSTRAINT org_pkey PRIMARY KEY (org_id)
);

CREATE TABLE IF NOT EXISTS dbo.polyclinic_case (
    polyclinic_case_id bigint NOT NULL DEFAULT nextval('dbo.polyclinic_case_seq'::regclass),
    person_id bigint NOT NULL,
    policlinic_case_begdate timestamp without time zone NOT NULL,
    policlinic_case_enddate timestamp without time zone,
    diag_id bigint NOT NULL,
    diag_pid bigint NOT NULL,
    person_card_id bigint NOT NULL,
    mo_id bigint NOT NULL,
    result_type_id integer,
    finish_id int,
	polyclinic_insdate timestamp without time zone,
	polyclinic_update timestamp without time zone,
    CONSTRAINT polyclinic_case_pkey PRIMARY KEY (polyclinic_case_id)
);

CREATE TABLE IF NOT EXISTS dbo.policlinic_visit (
    policlinic_visit_id bigint NOT NULL DEFAULT nextval('dbo.polyclinic_visit_id_seq'::regclass),
    policlinic_visit_pid bigint NOT NULL,
    policlinic_visit_count integer,
    visit_begdate timestamp without time zone,
    visit_enddate timestamp without time zone,
    oplata_id integer,
    diag_id bigint NOT NULL ,
	policlinic_visit_insdate timestamp without time zone,
	policlinic_visit_update timestamp without time zone,
    CONSTRAINT policlinic_visit_pkey PRIMARY KEY (policlinic_visit_id)
);

CREATE TABLE IF NOT EXISTS dbo.recording (
    recording_id bigint NOT NULL DEFAULT nextval('dbo.doctor_id_seq'::regclass),
    doctor_id bigint NOT NULL,
    person_id bigint NOT NULL,
    recording_begdate timestamp without time zone,
    recording_factdate timestamp without time zone,
    recordtype_id integer NOT NULL,
    polyclinic_case_id bigint NOT NULL,
    mo_id integer NOT NULL,
	recording_insdate timestamp without time zone,
	recording_update timestamp without time zone,
    CONSTRAINT recording_pkey PRIMARY KEY (recording_id)
);

CREATE TABLE IF NOT EXISTS sprav.country (
	country_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	country_name text COLLATE pg_catalog."default" NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.rgn (
	rgn_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	rgn_name text COLLATE pg_catalog."default" NOT NULL,
	country_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS sprav.city (
	city_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	city_name text COLLATE pg_catalog."default" NOT NULL,
	rgn_id bigint NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.town (
	town_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	town_name text COLLATE pg_catalog."default" NOT NULL,
	city_id bigint NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.street (
	street_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	street_name text COLLATE pg_catalog."default" NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.house (
	house_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	house_name text COLLATE pg_catalog."default" NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.corpus (
	corpus_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	corpus_name text COLLATE pg_catalog."default" NOT NULL	
);

CREATE TABLE IF NOT EXISTS sprav.flat (
	flat_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	flat_name text COLLATE pg_catalog."default" NOT NULL
);

CREATE TABLE IF NOT EXISTS sprav.polis_type (
 polis_type_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
 polis_type_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT polis_type_pkey PRIMARY KEY (polis_type_id)
);

CREATE TABLE IF NOT EXISTS sprav.diag (
	diag_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	diag_pid integer NOT NULL,
	diaglevel_id integer,
	diag_code text COLLATE pg_catalog."default" NOT NULL,
	diag_name text COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT diag_pkey PRIMARY KEY (diag_id),
	CONSTRAINT diag_diag_code_key UNIQUE (diag_code),
	CONSTRAINT diag_diag_name_key UNIQUE (diag_name)
);

CREATE TABLE IF NOT EXISTS sprav.finish (
	finish_id integer NOT NULL,
	finish_name text COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT finish_pkey PRIMARY KEY (finish_id)
	);

CREATE TABLE IF NOT EXISTS sprav.oplata (
	oplata_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
	oplata_name text COLLATE pg_catalog."default",
	CONSTRAINT oplata_pkey PRIMARY KEY (oplata_id)
);

CREATE TABLE IF NOT EXISTS sprav.result_type (
    result_type_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
    result_type_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT result_type_pkey PRIMARY KEY (result_type_id)
);

CREATE TABLE IF NOT EXISTS sprav.occupancy_type (
    occupancy_type_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
    occupancy_type_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT occupancy_type_pkey PRIMARY KEY (occupancy_type_id)
);

CREATE TABLE IF NOT EXISTS sprav.oplata (
 oplata_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
 oplata_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT oplata_pkey PRIMARY KEY (oplata_id)
);

CREATE TABLE IF NOT EXISTS sprav.recordtype (
 recordtype_id integer NOT NULL DEFAULT nextval('sprav.recording_sprav_seq'::regclass),
 recordtype_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT recordtype_pkey PRIMARY KEY (recordtype_id)
);


ALTER TABLE IF EXISTS sprav.country add CONSTRAINT country_pkey PRIMARY KEY (country_id);
ALTER TABLE IF EXISTS sprav.rgn add CONSTRAINT rgn_pkey PRIMARY KEY (rgn_id);
ALTER TABLE IF EXISTS sprav.city add CONSTRAINT city_pkey PRIMARY KEY (city_id);
ALTER TABLE IF EXISTS sprav.town add CONSTRAINT town_pkey PRIMARY KEY (town_id);
ALTER TABLE IF EXISTS sprav.street add CONSTRAINT street_pkey PRIMARY KEY (street_id);
ALTER TABLE IF EXISTS sprav.house add CONSTRAINT house_pkey PRIMARY KEY (house_id);
ALTER TABLE IF EXISTS sprav.corpus add CONSTRAINT corpus_pkey PRIMARY KEY (corpus_id);
ALTER TABLE IF EXISTS sprav.flat add CONSTRAINT flat_pkey PRIMARY KEY (flat_id);

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_country_id FOREIGN KEY (adress_country_id)
    REFERENCES sprav.country (country_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_rgn_id FOREIGN KEY (adress_rgn_id)
    REFERENCES sprav.rgn (rgn_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress 
    ADD CONSTRAINT fk_adress_city_id FOREIGN KEY (adress_city_id)
    REFERENCES sprav.city (city_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_town_id FOREIGN KEY (adress_town_id)
    REFERENCES sprav.town (town_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_street_id FOREIGN KEY (adress_street_id)
    REFERENCES sprav.street (street_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_adress_house_id FOREIGN KEY (adress_house_id)
    REFERENCES sprav.house (house_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_adress_corpus_id FOREIGN KEY (adress_corpus_id)
    REFERENCES sprav.corpus_id (corpus_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.adress
    ADD CONSTRAINT fk_adress_adress_flat_id FOREIGN KEY (adress_flat_id)
    REFERENCES sprav.flat (flat_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS sprav.rgn
    ADD CONSTRAINT fk_country_id FOREIGN KEY (country_id)
    REFERENCES sprav.country (country_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.town
    ADD CONSTRAINT fk_city_id FOREIGN KEY (city_id)
    REFERENCES sprav.city (city_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.city
    ADD CONSTRAINT fk_rgn_id FOREIGN KEY (rgn_id)
    REFERENCES sprav.rgn (rgn_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.doctor
    ADD CONSTRAINT fk_person_id FOREIGN KEY (person_id)
    REFERENCES dbo.person (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS dbo.doctor
    ADD CONSTRAINT fk_mo_id FOREIGN KEY (mo_id)
    REFERENCES dbo.medorganisation (mo_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.doctor
    ADD CONSTRAINT fk_occupancy_type_id FOREIGN KEY (occupancy_type_id)
    REFERENCES sprav.occupancy_type (occupancy_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person
    ADD CONSTRAINT fk_person_polis_id FOREIGN KEY (person_polis_id)
    REFERENCES dbo.person_polis (person_polis_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person
    ADD CONSTRAINT fk_adress_fact_id FOREIGN KEY (adress_fact_id)
    REFERENCES dbo.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person
    ADD CONSTRAINT fk_adress_reg_id FOREIGN KEY (adress_reg_id)
    REFERENCES dbo.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person
    ADD CONSTRAINT fk_person_card FOREIGN KEY (person_card_id)
    REFERENCES dbo.person_card (person_card_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person_card
    ADD CONSTRAINT fk_person_card_mo_id FOREIGN KEY (mo_id)
    REFERENCES dbo.medorganisation (mo_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.medorganisation
    ADD CONSTRAINT fk_org_id FOREIGN KEY (org_id)
    REFERENCES dbo.org (org_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person_polis
    ADD CONSTRAINT fk_person_polis_type_id FOREIGN KEY (polis_type_id)
    REFERENCES sprav.polis_type (polis_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.person_polis
    ADD CONSTRAINT fk_person_polis_org_id FOREIGN KEY (org_id)
    REFERENCES dbo.org (org_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.org
    ADD CONSTRAINT fk_org_pochtardess_id FOREIGN KEY (org_pochtadress_id)
    REFERENCES dbo.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.org
    ADD CONSTRAINT fk_urardess_id FOREIGN KEY (org_uradress_id)
    REFERENCES dbo.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_person_id FOREIGN KEY (person_id)
    REFERENCES dbo.person (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_id FOREIGN KEY (diag_id)
    REFERENCES sprav.diag (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_pid FOREIGN KEY (diag_pid)
    REFERENCES sprav.diag (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_result_type_id FOREIGN KEY (result_type_id)
    REFERENCES sprav.result_type (result_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_finish_id FOREIGN KEY (finish_id)
    REFERENCES sprav.finish (finish_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_person_card_id FOREIGN KEY (person_card_id)
    REFERENCES dbo.person_card (person_card_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.policlinic_visit
    ADD CONSTRAINT fk_oplata_id FOREIGN KEY (oplata_id)
    REFERENCES sprav.oplata (oplata_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_pid FOREIGN KEY (policlinic_visit_pid)
    REFERENCES dbo.polyclinic_case (polyclinic_case_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_diag_id FOREIGN KEY (diag_id)
    REFERENCES sprav.diag (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.recording
    ADD CONSTRAINT fk_recording_doctor_id FOREIGN KEY (doctor_id)
    REFERENCES dbo.doctor (doctor_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS dbo.recording
    ADD CONSTRAINT fk_recording_person_id FOREIGN KEY (person_id)
    REFERENCES dbo.person (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS dbo.recording
    ADD CONSTRAINT fk_recording_recordtype_id FOREIGN KEY (recordtype_id)
    REFERENCES sprav.recordtype (recordtype_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.recording
    ADD CONSTRAINT fk_recording_policlinic_case_id FOREIGN KEY (polyclinic_case_id)
    REFERENCES dbo.polyclinic_case (polyclinic_case_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS dbo.recording
    ADD CONSTRAINT fk_recording_mo_id FOREIGN KEY (mo_id)
    REFERENCES dbo.medorganisation (mo_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.rgn
    ADD CONSTRAINT fk_rgn_country_id FOREIGN KEY (country_id)
    REFERENCES sprav.country (country_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.city
    ADD CONSTRAINT fk_city_rgn_id FOREIGN KEY (rgn_id)
    REFERENCES sprav.rgn (rgn_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.town
    ADD CONSTRAINT fk_town_city_id FOREIGN KEY (city_id)
    REFERENCES sprav.city (city_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS sprav.diag
    ADD CONSTRAINT fk_diag_pid FOREIGN KEY (diag_pid)
    REFERENCES sprav.diag (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS dbo.person 
	ADD CONSTRAINT check_person_birthday 
	CHECK (date_part('year',age(person_birthday::date)) <= 110);
	
ALTER TABLE IF EXISTS dbo.person
	ADD CONSTRAINT check_person_enddate 
	CHECK (person_enddate > person_begdate or person_enddate is null); 

ALTER TABLE IF EXISTS dbo.doctor
	ADD CONSTRAINT check_num_room
	CHECK (num_room > 0);

ALTER TABLE IF EXISTS dbo.doctor
	ADD CONSTRAINT check_work_begdate
	CHECK ( date_part('year',age(work_begdate::date)) <= 70);
	
ALTER TABLE IF EXISTS dbo.doctor
	ADD CONSTRAINT check_work_enddate
	CHECK (coalesce(work_enddate, current_date) >= work_begdate);

ALTER TABLE IF EXISTS dbo.recording
	ADD CONSTRAINT check_recording_begdate
	CHECK (recording_begdate >= current_date);
	
ALTER TABLE IF EXISTS dbo.recording
	ADD CONSTRAINT check_recording_factdate
	CHECK (coalesce(recording_factdate,current_date) >= recording_begdate);	

ALTER TABLE IF EXISTS dbo.polyclinic_case
	ADD CONSTRAINT check_polyclinic_case_diag_pid
	CHECK (finish_id = 1);	

ALTER TABLE IF EXISTS dbo.polyclinic_case
	ADD CONSTRAINT check_polyclinic_case_result_type_id
	CHECK (finish_id = 1);
	
ALTER TABLE IF EXISTS dbo.policlinic_visit
	ADD CONSTRAINT check_polyclinic_visit_visit_enddate
	CHECK (visit_enddate >= visit_begdate);