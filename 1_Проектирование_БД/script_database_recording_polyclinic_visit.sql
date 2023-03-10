CREATE TABLE IF NOT EXISTS public.adress (
    adress_id bigint NOT NULL DEFAULT nextval('adress_adress_id_seq'::regclass),
    adress_index bigint NOT NULL,
    adress_country_id bigint NOT NULL,
    adress_rgn_id bigint NOT NULL,
    adress_city_id bigint NOT NULL,
    adress_town_id bigint,
    adress_street_id bigint,
    adress_house text COLLATE pg_catalog."default",
    adress_corpus text COLLATE pg_catalog."default",
    adress_flat text COLLATE pg_catalog."default",
    address_name text COLLATE pg_catalog."default",
    CONSTRAINT adress_pkey PRIMARY KEY (adress_id)
);

CREATE TABLE IF NOT EXISTS public.city (
    city_id bigint NOT NULL,
    city_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    rgn_id bigint NOT NULL,
    CONSTRAINT city_pkey PRIMARY KEY (city_id)
);

CREATE TABLE IF NOT EXISTS public.country (
    country_id bigint NOT NULL,
    country_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT country_pkey PRIMARY KEY (country_id)
);

CREATE TABLE IF NOT EXISTS public.diags (
    diag_id bigint NOT NULL DEFAULT nextval('diags_diag_id_seq'::regclass),
    diag_pid bigint NOT NULL DEFAULT nextval('diags_diag_pid_seq'::regclass),
    diaglevel_id integer,
    diag_code text COLLATE pg_catalog.ucs_basic NOT NULL,
    diag_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT diags_pkey PRIMARY KEY (diag_id),
    CONSTRAINT diags_diag_code_key UNIQUE (diag_code),
    CONSTRAINT diags_diag_name_key UNIQUE (diag_name)
);

CREATE TABLE IF NOT EXISTS public.doctors (
    doctor_id bigint NOT NULL DEFAULT nextval('doctors_doctor_id_seq'::regclass),
    person_id bigint NOT NULL DEFAULT nextval('doctors_person_id_seq'::regclass),
    doctor_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    mo_id bigint NOT NULL DEFAULT nextval('doctors_mo_id_seq'::regclass),
    num_room integer NOT NULL,
    work_begdate timestamp without time zone,
    work_enddate timestamp without time zone,
    occupancy_type_id smallint NOT NULL,
    CONSTRAINT doctors_pkey PRIMARY KEY (doctor_id)
);

CREATE TABLE IF NOT EXISTS public.finish (
    finish_id integer NOT NULL,
    finish_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT finish_pkey PRIMARY KEY (finish_id)
);

CREATE TABLE IF NOT EXISTS public.medorganisation (
    mo_id bigint NOT NULL DEFAULT nextval('medorganisation_mo_id_seq'::regclass),
    mo_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    org_id bigint NOT NULL DEFAULT nextval('medorganisation_org_id_seq'::regclass),
    CONSTRAINT medorganisation_pkey PRIMARY KEY (mo_id)
);

CREATE TABLE IF NOT EXISTS public.oplata (
    oplata_id integer NOT NULL,
    oplata_name text COLLATE pg_catalog.ucs_basic,
    CONSTRAINT oplata_pkey PRIMARY KEY (oplata_id)
);

CREATE TABLE IF NOT EXISTS public.org (
    org_id bigint NOT NULL DEFAULT nextval('org_org_id_seq'::regclass),
    org_code integer NOT NULL,
    org_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    org_urardess_id bigint NOT NULL DEFAULT nextval('org_org_urardess_id_seq'::regclass),
    org_pochtardess_id bigint NOT NULL DEFAULT nextval('org_org_pochtardess_id_seq'::regclass),
    CONSTRAINT org_pkey PRIMARY KEY (org_id)
);

CREATE TABLE IF NOT EXISTS public.person_polis (
    person_polis_id integer NOT NULL DEFAULT nextval('person_polis_person_polis_id_seq'::regclass),
    polis_begdate timestamp without time zone,
    polis_enddate timestamp without time zone,
    polis_type_id integer NOT NULL,
    polis_ser text COLLATE pg_catalog.ucs_basic,
    polis_num bigint,
    org_id bigint NOT NULL DEFAULT nextval('person_polis_org_id_seq'::regclass),
    CONSTRAINT person_polis_pkey PRIMARY KEY (person_polis_id)
);

CREATE TABLE IF NOT EXISTS public.persons (
    person_id bigint NOT NULL DEFAULT nextval('persons_person_id_seq'::regclass),
    person_surname character varying(100) COLLATE pg_catalog."default" NOT NULL,
    person_firstname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    person_secname character varying(100) COLLATE pg_catalog."default",
    person_birthday timestamp without time zone,
    person_polis_id bigint NOT NULL,
    person_begdate timestamp without time zone NOT NULL,
    person_enddate timestamp without time zone,
    phone_num bigint,
    adress_reg_id bigint NOT NULL DEFAULT nextval('persons_adress_reg_id_seq'::regclass),
    adress_fact_id bigint NOT NULL DEFAULT nextval('persons_adress_fact_id_seq'::regclass),
    card_num bigint,
    CONSTRAINT persons_pkey PRIMARY KEY (person_id)
);

CREATE TABLE IF NOT EXISTS public.polis_type (
    polis_type_id integer NOT NULL,
    polis_type_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT polis_type_pkey PRIMARY KEY (polis_type_id)
);

CREATE TABLE IF NOT EXISTS public.polyclinic_case (
    polyclinic_case_id bigint NOT NULL DEFAULT nextval('polyclinic_case_polyclinic_case_id_seq'::regclass),
    person_id bigint NOT NULL DEFAULT nextval('polyclinic_case_person_id_seq'::regclass),
    policlinic_case_begdate timestamp without time zone NOT NULL,
    policlinic_case_enddate timestamp without time zone,
    diag_id bigint NOT NULL DEFAULT nextval('polyclinic_case_diag_id_seq'::regclass),
    diag_pid bigint NOT NULL DEFAULT nextval('polyclinic_case_diag_pid_seq'::regclass),
    card_num bigint NOT NULL,
    mo_id bigint NOT NULL DEFAULT nextval('polyclinic_case_mo_id_seq'::regclass),
    result_type_id integer,
    finish_id smallint,
    CONSTRAINT polyclinic_case_pkey PRIMARY KEY (polyclinic_case_id)
);

CREATE TABLE IF NOT EXISTS public.policlinic_visit (
    policlinic_visit_id bigint NOT NULL DEFAULT nextval('polyclinic_visit_polyclinic_visit_id_seq'::regclass),
    policlinic_visit_pid bigint NOT NULL DEFAULT nextval('polyclinic_visit_polyclinic_visit_pid_seq'::regclass),
    policlinic_visit_count smallint,
    visit_begdate timestamp without time zone,
    visit_enddate timestamp without time zone,
    oplata_id integer,
    diag_id bigint NOT NULL DEFAULT nextval('polyclinic_visit_diag_id_seq'::regclass),
    CONSTRAINT policlinic_visit_pkey PRIMARY KEY (policlinic_visit_id)
);

CREATE TABLE IF NOT EXISTS public.recording (
    recording_id bigint NOT NULL DEFAULT nextval('recording_recording_id_seq'::regclass),
    doctor_id bigint NOT NULL DEFAULT nextval('recording_doctor_id_seq'::regclass),
    person_id bigint NOT NULL DEFAULT nextval('recording_person_id_seq'::regclass),
    recording_begdate timestamp without time zone,
    recording_factdate timestamp without time zone,
    recordtype_id smallint NOT NULL,
    polyclinic_case_id bigint NOT NULL DEFAULT nextval('recording_polyclinic_case_id_seq'::regclass),
    mo_id integer NOT NULL DEFAULT nextval('recording_mo_id_seq'::regclass),
    CONSTRAINT recording_pkey PRIMARY KEY (recording_id)
);

CREATE TABLE IF NOT EXISTS public.result_type (
    result_type_id integer NOT NULL,
    result_type_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT result_type_pkey PRIMARY KEY (result_type_id)
);

CREATE TABLE IF NOT EXISTS public.rgn (
    rgn_id bigint NOT NULL,
    rgn_name text COLLATE pg_catalog."default" NOT NULL,
    country_id bigint NOT NULL,
    CONSTRAINT rgn_pkey PRIMARY KEY (rgn_id)
);

CREATE TABLE IF NOT EXISTS public.street (
    street_id bigint NOT NULL,
    street_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    CONSTRAINT street_pkey PRIMARY KEY (street_id)
);

CREATE TABLE IF NOT EXISTS public.town (
    town_id bigint NOT NULL,
    town_name text COLLATE pg_catalog.ucs_basic NOT NULL,
    city_id bigint NOT NULL,
    CONSTRAINT town_pkey PRIMARY KEY (town_id)
);

CREATE TABLE IF NOT EXISTS public.occupancy_type (
    occupancy_type_id smallint NOT NULL,
    occupancy_type_name text NOT NULL,
    PRIMARY KEY (occupancy_type_id)
);

CREATE TABLE IF NOT EXISTS public.occupancy_type (
    occupancy_type_id smallint NOT NULL,
    occupancy_type_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT occupancy_type_pkey PRIMARY KEY (occupancy_type_id)
);

ALTER TABLE IF EXISTS public.adress 
    ADD CONSTRAINT fk_adress_city_id FOREIGN KEY (adress_city_id)
    REFERENCES public.city (city_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.adress
    ADD CONSTRAINT fk_adress_country_id FOREIGN KEY (adress_country_id)
    REFERENCES public.country (country_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.adress
    ADD CONSTRAINT fk_adress_rgn_id FOREIGN KEY (adress_rgn_id)
    REFERENCES public.rgn (rgn_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.adress
    ADD CONSTRAINT fk_adress_street_id FOREIGN KEY (adress_street_id)
    REFERENCES public.street (street_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.adress
    ADD CONSTRAINT fk_adress_town_id FOREIGN KEY (adress_town_id)
    REFERENCES public.town (town_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.city
    ADD CONSTRAINT fk_rgn_id FOREIGN KEY (rgn_id)
    REFERENCES public.rgn (rgn_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.diags
    ADD CONSTRAINT fk_diag_pid FOREIGN KEY (diag_pid)
    REFERENCES public.diags (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.doctors
    ADD CONSTRAINT fk_mo_id FOREIGN KEY (mo_id)
    REFERENCES public.medorganisation (mo_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.doctors
    ADD CONSTRAINT fk_person_id FOREIGN KEY (person_id)
    REFERENCES public.persons (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.doctors
    ADD CONSTRAINT fk_occupancy_type_id FOREIGN KEY (occupancy_type_id)
    REFERENCES public.occupancy_type (occupancy_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.medorganisation
    ADD CONSTRAINT fk_org_id FOREIGN KEY (org_id)
    REFERENCES public.org (org_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.org
    ADD CONSTRAINT fk_org_pochtardess_id FOREIGN KEY (org_pochtardess_id)
    REFERENCES public.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.org
    ADD CONSTRAINT fk_urardess_id FOREIGN KEY (org_urardess_id)
    REFERENCES public.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.person_polis
    ADD CONSTRAINT fk_person_polis_org_id FOREIGN KEY (org_id)
    REFERENCES public.org (org_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.person_polis
    ADD CONSTRAINT fk_person_polis_type_id FOREIGN KEY (polis_type_id)
    REFERENCES public.polis_type (polis_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.persons
    ADD CONSTRAINT fk_adress_fact_id FOREIGN KEY (adress_fact_id)
    REFERENCES public.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.persons
    ADD CONSTRAINT fk_adress_reg_id FOREIGN KEY (adress_reg_id)
    REFERENCES public.adress (adress_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.persons
    ADD CONSTRAINT fk_person_polis_id FOREIGN KEY (person_polis_id)
    REFERENCES public.person_polis (person_polis_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_id FOREIGN KEY (diag_id)
    REFERENCES public.diags (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_pid FOREIGN KEY (diag_pid)
    REFERENCES public.diags (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_finish_id FOREIGN KEY (finish_id)
    REFERENCES public.finish (finish_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_person_id FOREIGN KEY (person_id)
    REFERENCES public.persons (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_card_num FOREIGN KEY (card_num)
    REFERENCES public.persons (card_num) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_result_type_id FOREIGN KEY (result_type_id)
    REFERENCES public.result_type (result_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
	
ALTER TABLE IF EXISTS public.policlinic_visit
    ADD CONSTRAINT fk_oplata_id FOREIGN KEY (oplata_id)
    REFERENCES public.oplata (oplata_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_pid FOREIGN KEY (policlinic_visit_pid)
    REFERENCES public.polyclinic_case (polyclinic_case_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_diag_id FOREIGN KEY (diag_id)
    REFERENCES public.diags (diag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.recording
    ADD CONSTRAINT fk_recording_doctor_id FOREIGN KEY (doctor_id)
    REFERENCES public.doctors (doctor_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.recording
    ADD CONSTRAINT fk_recording_mo_id FOREIGN KEY (mo_id)
    REFERENCES public.medorganisation (mo_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.recording
    ADD CONSTRAINT fk_recording_person_id FOREIGN KEY (person_id)
    REFERENCES public.persons (person_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.recording
    ADD CONSTRAINT fk_recording_policlinic_case_id FOREIGN KEY (polyclinic_case_id)
    REFERENCES public.polyclinic_case (polyclinic_case_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.rgn
    ADD CONSTRAINT fk_country_id FOREIGN KEY (country_id)
    REFERENCES public.country (country_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.town
    ADD CONSTRAINT fk_city_id FOREIGN KEY (city_id)
    REFERENCES public.city (city_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
	
ALTER TABLE IF EXISTS public.persons 
	ADD CONSTRAINT check_person_birthday 
	CHECK (person_birthday > '1910-01-01'::timestamp);

ALTER TABLE IF EXISTS public.persons 
	ADD CONSTRAINT check_person_enddate 
	CHECK (person_enddate > person_begdate or person_enddate is null); 

ALTER TABLE IF EXISTS public.doctors
	ADD CONSTRAINT check_num_room
	CHECK (num_room > 0);

ALTER TABLE IF EXISTS public.doctors
	ADD CONSTRAINT check_work_begdate
	CHECK (work_begdate > '1945-01-01'::timestamp);
	
ALTER TABLE IF EXISTS public.doctors
	ADD CONSTRAINT check_work_enddate
	CHECK (coalesce(work_enddate, current_date) >= work_begdate);	

ALTER TABLE IF EXISTS public.recording
	ADD CONSTRAINT check_recording_begdate
	CHECK (recording_begdate >= current_date);
	
ALTER TABLE IF EXISTS public.recording
	ADD CONSTRAINT check_recording_factdate
	CHECK (coalesce(recording_factdate,current_date) >= recording_begdate);	

ALTER TABLE IF EXISTS public.polyclinic_case
	ADD CONSTRAINT check_polyclinic_case_diag_pid
	CHECK (finish_id = 1);	

ALTER TABLE IF EXISTS public.polyclinic_case
	ADD CONSTRAINT check_polyclinic_case_result_type_id
	CHECK (finish_id = 1);
	
ALTER TABLE IF EXISTS public.polyclinic_visit
	ADD CONSTRAINT check_polyclinic_visit_visit_enddate
	CHECK (visit_enddate >= visit_begdate);
