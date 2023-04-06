--
-- PostgreSQL database dump
--

-- Dumped from database version 14.6 (Debian 14.6-1.pgdg110+1)
-- Dumped by pg_dump version 14.6 (Debian 14.6-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dbo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dbo;


ALTER SCHEMA dbo OWNER TO postgres;

--
-- Name: sprav; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sprav;


ALTER SCHEMA sprav OWNER TO postgres;

--
-- Name: adress_adress_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.adress_adress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.adress_adress_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adress; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.adress (
    adress_id bigint DEFAULT nextval('dbo.adress_adress_id_seq'::regclass) NOT NULL,
    adress_index integer NOT NULL,
    adress_country_id integer NOT NULL,
    adress_rgn_id integer NOT NULL,
    adress_city_id integer NOT NULL,
    adress_town_id integer,
    adress_street_id integer,
    adress_house_id integer,
    adress_corpus_id integer,
    adress_flat_id integer,
    address_name text,
    address_insdate timestamp without time zone,
    address_update timestamp without time zone
);


ALTER TABLE dbo.adress OWNER TO postgres;

--
-- Name: doctor_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.doctor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.doctor_id_seq OWNER TO postgres;

--
-- Name: doctor; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.doctor (
    doctor_id bigint DEFAULT nextval('dbo.doctor_id_seq'::regclass) NOT NULL,
    person_id bigint NOT NULL,
    doctor_name text NOT NULL,
    mo_id bigint,
    num_room integer NOT NULL,
    work_begdate timestamp without time zone,
    work_enddate timestamp without time zone,
    occupancy_type_id integer NOT NULL,
    doctor_insdate timestamp without time zone,
    doctor_update timestamp without time zone,
    CONSTRAINT check_num_room CHECK ((num_room > 0)),
    CONSTRAINT check_work_begdate CHECK ((date_part('year'::text, age(((work_begdate)::date)::timestamp with time zone)) <= (70)::double precision)),
    CONSTRAINT check_work_enddate CHECK ((COALESCE(work_enddate, (CURRENT_DATE)::timestamp without time zone) >= work_begdate))
);


ALTER TABLE dbo.doctor OWNER TO postgres;

--
-- Name: mo_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.mo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.mo_id_seq OWNER TO postgres;

--
-- Name: medorganisation; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.medorganisation (
    mo_id bigint DEFAULT nextval('dbo.mo_id_seq'::regclass) NOT NULL,
    mo_name text NOT NULL COLLATE pg_catalog.ucs_basic,
    org_id bigint NOT NULL
);


ALTER TABLE dbo.medorganisation OWNER TO postgres;

--
-- Name: org_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.org_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.org_id_seq OWNER TO postgres;

--
-- Name: org; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.org (
    org_id bigint DEFAULT nextval('dbo.org_id_seq'::regclass) NOT NULL,
    org_code integer NOT NULL,
    org_name text NOT NULL,
    org_uradress_id bigint NOT NULL,
    org_pochtadress_id bigint NOT NULL,
    org_insdate timestamp without time zone,
    org_update timestamp without time zone
);


ALTER TABLE dbo.org OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.person_id_seq OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.person (
    person_id bigint DEFAULT nextval('dbo.person_id_seq'::regclass) NOT NULL,
    person_surname character varying(100) NOT NULL,
    person_firstname character varying(50) NOT NULL,
    person_secname character varying(100),
    person_birthday timestamp without time zone,
    person_polis_id bigint NOT NULL,
    person_begdate timestamp without time zone NOT NULL,
    person_enddate timestamp without time zone,
    phone_num bigint,
    adress_reg_id bigint,
    adress_fact_id bigint,
    person_card_id bigint,
    CONSTRAINT check_person_birthday CHECK ((date_part('year'::text, age(((person_birthday)::date)::timestamp with time zone)) <= (110)::double precision)),
    CONSTRAINT check_person_enddate CHECK (((person_enddate > person_begdate) OR (person_enddate IS NULL)))
);


ALTER TABLE dbo.person OWNER TO postgres;

--
-- Name: person_card_num_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.person_card_num_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.person_card_num_id_seq OWNER TO postgres;

--
-- Name: person_card; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.person_card (
    person_card_id bigint DEFAULT nextval('dbo.person_card_num_id_seq'::regclass) NOT NULL,
    card_num character varying(10),
    mo_id bigint,
    card_begdate timestamp without time zone,
    card_enddate timestamp without time zone,
    card_insdate timestamp without time zone,
    card_update timestamp without time zone
);


ALTER TABLE dbo.person_card OWNER TO postgres;

--
-- Name: person_polis_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.person_polis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.person_polis_id_seq OWNER TO postgres;

--
-- Name: person_polis; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.person_polis (
    person_polis_id integer DEFAULT nextval('dbo.person_polis_id_seq'::regclass) NOT NULL,
    polis_begdate timestamp without time zone,
    polis_enddate timestamp without time zone,
    polis_type_id integer NOT NULL,
    polis_ser text,
    polis_num bigint,
    org_id bigint NOT NULL,
    polis_insdate timestamp without time zone,
    polis_update timestamp without time zone
);


ALTER TABLE dbo.person_polis OWNER TO postgres;

--
-- Name: polyclinic_visit_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.polyclinic_visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.polyclinic_visit_id_seq OWNER TO postgres;

--
-- Name: policlinic_visit; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.policlinic_visit (
    policlinic_visit_id bigint DEFAULT nextval('dbo.polyclinic_visit_id_seq'::regclass) NOT NULL,
    policlinic_visit_pid bigint NOT NULL,
    policlinic_visit_count integer,
    visit_begdate timestamp without time zone,
    visit_enddate timestamp without time zone,
    oplata_id integer,
    diag_id bigint NOT NULL,
    policlinic_visit_insdate timestamp without time zone,
    policlinic_visit_update timestamp without time zone,
    CONSTRAINT check_polyclinic_visit_visit_enddate CHECK ((visit_enddate >= visit_begdate))
);


ALTER TABLE dbo.policlinic_visit OWNER TO postgres;

--
-- Name: polyclinic_case_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.polyclinic_case_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.polyclinic_case_seq OWNER TO postgres;

--
-- Name: polyclinic_case; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.polyclinic_case (
    polyclinic_case_id bigint DEFAULT nextval('dbo.polyclinic_case_seq'::regclass) NOT NULL,
    person_id bigint NOT NULL,
    policlinic_case_begdate timestamp without time zone NOT NULL,
    policlinic_case_enddate timestamp without time zone,
    diag_id bigint NOT NULL,
    diag_pid bigint NOT NULL,
    person_card_id bigint NOT NULL,
    mo_id bigint NOT NULL,
    result_type_id integer,
    finish_id integer,
    polyclinic_insdate timestamp without time zone,
    polyclinic_update timestamp without time zone,
    CONSTRAINT check_polyclinic_case_diag_pid CHECK ((finish_id = 1)),
    CONSTRAINT check_polyclinic_case_result_type_id CHECK ((finish_id = 1))
);


ALTER TABLE dbo.polyclinic_case OWNER TO postgres;

--
-- Name: recording; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.recording (
    recording_id bigint DEFAULT nextval('dbo.doctor_id_seq'::regclass) NOT NULL,
    doctor_id bigint NOT NULL,
    person_id bigint NOT NULL,
    recording_begdate timestamp without time zone,
    recording_factdate timestamp without time zone,
    recordtype_id integer NOT NULL,
    polyclinic_case_id bigint NOT NULL,
    mo_id integer NOT NULL,
    recording_insdate timestamp without time zone,
    recording_update timestamp without time zone,
    CONSTRAINT check_recording_begdate CHECK ((recording_begdate >= CURRENT_DATE)),
    CONSTRAINT check_recording_factdate CHECK ((COALESCE(recording_factdate, (CURRENT_DATE)::timestamp without time zone) >= recording_begdate))
);


ALTER TABLE dbo.recording OWNER TO postgres;

--
-- Name: recording_recording_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.recording_recording_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.recording_recording_id_seq OWNER TO postgres;

--
-- Name: adress_adress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adress_adress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adress_adress_id_seq OWNER TO postgres;

--
-- Name: recording_sprav_seq; Type: SEQUENCE; Schema: sprav; Owner: postgres
--

CREATE SEQUENCE sprav.recording_sprav_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sprav.recording_sprav_seq OWNER TO postgres;

--
-- Name: city; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.city (
    city_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    city_name text NOT NULL,
    rgn_id bigint NOT NULL
);


ALTER TABLE sprav.city OWNER TO postgres;

--
-- Name: corpus; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.corpus (
    corpus_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    corpus_name text NOT NULL
);


ALTER TABLE sprav.corpus OWNER TO postgres;

--
-- Name: country; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.country (
    country_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    country_name text NOT NULL
);


ALTER TABLE sprav.country OWNER TO postgres;

--
-- Name: diag; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.diag (
    diag_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    diag_pid integer NOT NULL,
    diaglevel_id integer,
    diag_code text NOT NULL,
    diag_name text NOT NULL
);


ALTER TABLE sprav.diag OWNER TO postgres;

--
-- Name: finish; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.finish (
    finish_id integer NOT NULL,
    finish_name text NOT NULL
);


ALTER TABLE sprav.finish OWNER TO postgres;

--
-- Name: flat; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.flat (
    flat_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    flat_name text NOT NULL
);


ALTER TABLE sprav.flat OWNER TO postgres;

--
-- Name: house; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.house (
    house_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    house_name text NOT NULL
);


ALTER TABLE sprav.house OWNER TO postgres;

--
-- Name: occupancy_type; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.occupancy_type (
    occupancy_type_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    occupancy_type_name text NOT NULL
);


ALTER TABLE sprav.occupancy_type OWNER TO postgres;

--
-- Name: oplata; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.oplata (
    oplata_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    oplata_name text
);


ALTER TABLE sprav.oplata OWNER TO postgres;

--
-- Name: polis_type; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.polis_type (
    polis_type_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    polis_type_name text NOT NULL
);


ALTER TABLE sprav.polis_type OWNER TO postgres;

--
-- Name: recordtype; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.recordtype (
    recordtype_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    recordtype_name text NOT NULL
);


ALTER TABLE sprav.recordtype OWNER TO postgres;

--
-- Name: result_type; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.result_type (
    result_type_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    result_type_name text NOT NULL COLLATE pg_catalog.ucs_basic
);


ALTER TABLE sprav.result_type OWNER TO postgres;

--
-- Name: rgn; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.rgn (
    rgn_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    rgn_name text NOT NULL,
    country_id bigint NOT NULL
);


ALTER TABLE sprav.rgn OWNER TO postgres;

--
-- Name: street; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.street (
    street_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    street_name text NOT NULL
);


ALTER TABLE sprav.street OWNER TO postgres;

--
-- Name: town; Type: TABLE; Schema: sprav; Owner: postgres
--

CREATE TABLE sprav.town (
    town_id integer DEFAULT nextval('sprav.recording_sprav_seq'::regclass) NOT NULL,
    town_name text NOT NULL,
    city_id bigint NOT NULL
);


ALTER TABLE sprav.town OWNER TO postgres;

--
-- Data for Name: adress; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.adress (adress_id, adress_index, adress_country_id, adress_rgn_id, adress_city_id, adress_town_id, adress_street_id, adress_house_id, adress_corpus_id, adress_flat_id, address_name, address_insdate, address_update) FROM stdin;
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.doctor (doctor_id, person_id, doctor_name, mo_id, num_room, work_begdate, work_enddate, occupancy_type_id, doctor_insdate, doctor_update) FROM stdin;
\.


--
-- Data for Name: medorganisation; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.medorganisation (mo_id, mo_name, org_id) FROM stdin;
\.


--
-- Data for Name: org; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.org (org_id, org_code, org_name, org_uradress_id, org_pochtadress_id, org_insdate, org_update) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.person (person_id, person_surname, person_firstname, person_secname, person_birthday, person_polis_id, person_begdate, person_enddate, phone_num, adress_reg_id, adress_fact_id, person_card_id) FROM stdin;
\.


--
-- Data for Name: person_card; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.person_card (person_card_id, card_num, mo_id, card_begdate, card_enddate, card_insdate, card_update) FROM stdin;
\.


--
-- Data for Name: person_polis; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.person_polis (person_polis_id, polis_begdate, polis_enddate, polis_type_id, polis_ser, polis_num, org_id, polis_insdate, polis_update) FROM stdin;
\.


--
-- Data for Name: policlinic_visit; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.policlinic_visit (policlinic_visit_id, policlinic_visit_pid, policlinic_visit_count, visit_begdate, visit_enddate, oplata_id, diag_id, policlinic_visit_insdate, policlinic_visit_update) FROM stdin;
\.


--
-- Data for Name: polyclinic_case; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.polyclinic_case (polyclinic_case_id, person_id, policlinic_case_begdate, policlinic_case_enddate, diag_id, diag_pid, person_card_id, mo_id, result_type_id, finish_id, polyclinic_insdate, polyclinic_update) FROM stdin;
\.


--
-- Data for Name: recording; Type: TABLE DATA; Schema: dbo; Owner: postgres
--

COPY dbo.recording (recording_id, doctor_id, person_id, recording_begdate, recording_factdate, recordtype_id, polyclinic_case_id, mo_id, recording_insdate, recording_update) FROM stdin;
\.


--
-- Data for Name: city; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.city (city_id, city_name, rgn_id) FROM stdin;
\.


--
-- Data for Name: corpus; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.corpus (corpus_id, corpus_name) FROM stdin;
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.country (country_id, country_name) FROM stdin;
\.


--
-- Data for Name: diag; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.diag (diag_id, diag_pid, diaglevel_id, diag_code, diag_name) FROM stdin;
\.


--
-- Data for Name: finish; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.finish (finish_id, finish_name) FROM stdin;
\.


--
-- Data for Name: flat; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.flat (flat_id, flat_name) FROM stdin;
\.


--
-- Data for Name: house; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.house (house_id, house_name) FROM stdin;
\.


--
-- Data for Name: occupancy_type; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.occupancy_type (occupancy_type_id, occupancy_type_name) FROM stdin;
\.


--
-- Data for Name: oplata; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.oplata (oplata_id, oplata_name) FROM stdin;
\.


--
-- Data for Name: polis_type; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.polis_type (polis_type_id, polis_type_name) FROM stdin;
\.


--
-- Data for Name: recordtype; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.recordtype (recordtype_id, recordtype_name) FROM stdin;
\.


--
-- Data for Name: result_type; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.result_type (result_type_id, result_type_name) FROM stdin;
\.


--
-- Data for Name: rgn; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.rgn (rgn_id, rgn_name, country_id) FROM stdin;
\.


--
-- Data for Name: street; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.street (street_id, street_name) FROM stdin;
\.


--
-- Data for Name: town; Type: TABLE DATA; Schema: sprav; Owner: postgres
--

COPY sprav.town (town_id, town_name, city_id) FROM stdin;
\.


--
-- Name: adress_adress_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.adress_adress_id_seq', 1, false);


--
-- Name: doctor_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.doctor_id_seq', 1, false);


--
-- Name: mo_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.mo_id_seq', 1, false);


--
-- Name: org_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.org_id_seq', 1, false);


--
-- Name: person_card_num_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.person_card_num_id_seq', 1, false);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.person_id_seq', 1, false);


--
-- Name: person_polis_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.person_polis_id_seq', 1, false);


--
-- Name: polyclinic_case_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.polyclinic_case_seq', 1, false);


--
-- Name: polyclinic_visit_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.polyclinic_visit_id_seq', 1, false);


--
-- Name: recording_recording_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: postgres
--

SELECT pg_catalog.setval('dbo.recording_recording_id_seq', 1, false);


--
-- Name: adress_adress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adress_adress_id_seq', 1, false);


--
-- Name: recording_sprav_seq; Type: SEQUENCE SET; Schema: sprav; Owner: postgres
--

SELECT pg_catalog.setval('sprav.recording_sprav_seq', 1, false);


--
-- Name: adress adress_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT adress_pkey PRIMARY KEY (adress_id);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (doctor_id);


--
-- Name: medorganisation medorganisation_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.medorganisation
    ADD CONSTRAINT medorganisation_pkey PRIMARY KEY (mo_id);


--
-- Name: org org_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.org
    ADD CONSTRAINT org_pkey PRIMARY KEY (org_id);


--
-- Name: person_card person_card_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person_card
    ADD CONSTRAINT person_card_pkey PRIMARY KEY (person_card_id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- Name: person_polis person_polis_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person_polis
    ADD CONSTRAINT person_polis_pkey PRIMARY KEY (person_polis_id);


--
-- Name: policlinic_visit policlinic_visit_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.policlinic_visit
    ADD CONSTRAINT policlinic_visit_pkey PRIMARY KEY (policlinic_visit_id);


--
-- Name: polyclinic_case polyclinic_case_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT polyclinic_case_pkey PRIMARY KEY (polyclinic_case_id);


--
-- Name: recording recording_pkey; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT recording_pkey PRIMARY KEY (recording_id);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- Name: corpus corpus_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.corpus
    ADD CONSTRAINT corpus_pkey PRIMARY KEY (corpus_id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: diag diag_diag_code_key; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.diag
    ADD CONSTRAINT diag_diag_code_key UNIQUE (diag_code);


--
-- Name: diag diag_diag_name_key; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.diag
    ADD CONSTRAINT diag_diag_name_key UNIQUE (diag_name);


--
-- Name: diag diag_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.diag
    ADD CONSTRAINT diag_pkey PRIMARY KEY (diag_id);


--
-- Name: finish finish_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.finish
    ADD CONSTRAINT finish_pkey PRIMARY KEY (finish_id);


--
-- Name: flat flat_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.flat
    ADD CONSTRAINT flat_pkey PRIMARY KEY (flat_id);


--
-- Name: house house_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.house
    ADD CONSTRAINT house_pkey PRIMARY KEY (house_id);


--
-- Name: occupancy_type occupancy_type_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.occupancy_type
    ADD CONSTRAINT occupancy_type_pkey PRIMARY KEY (occupancy_type_id);


--
-- Name: oplata oplata_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.oplata
    ADD CONSTRAINT oplata_pkey PRIMARY KEY (oplata_id);


--
-- Name: polis_type polis_type_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.polis_type
    ADD CONSTRAINT polis_type_pkey PRIMARY KEY (polis_type_id);


--
-- Name: recordtype recordtype_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.recordtype
    ADD CONSTRAINT recordtype_pkey PRIMARY KEY (recordtype_id);


--
-- Name: result_type result_type_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.result_type
    ADD CONSTRAINT result_type_pkey PRIMARY KEY (result_type_id);


--
-- Name: rgn rgn_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.rgn
    ADD CONSTRAINT rgn_pkey PRIMARY KEY (rgn_id);


--
-- Name: street street_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.street
    ADD CONSTRAINT street_pkey PRIMARY KEY (street_id);


--
-- Name: town town_pkey; Type: CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.town
    ADD CONSTRAINT town_pkey PRIMARY KEY (town_id);


--
-- Name: adress fk_adress_adress_corpus_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_adress_corpus_id FOREIGN KEY (adress_corpus_id) REFERENCES sprav.corpus(corpus_id);


--
-- Name: adress fk_adress_adress_flat_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_adress_flat_id FOREIGN KEY (adress_flat_id) REFERENCES sprav.flat(flat_id);


--
-- Name: adress fk_adress_adress_house_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_adress_house_id FOREIGN KEY (adress_house_id) REFERENCES sprav.house(house_id);


--
-- Name: adress fk_adress_city_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_city_id FOREIGN KEY (adress_city_id) REFERENCES sprav.city(city_id);


--
-- Name: adress fk_adress_country_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_country_id FOREIGN KEY (adress_country_id) REFERENCES sprav.country(country_id);


--
-- Name: person fk_adress_fact_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person
    ADD CONSTRAINT fk_adress_fact_id FOREIGN KEY (adress_fact_id) REFERENCES dbo.adress(adress_id);


--
-- Name: person fk_adress_reg_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person
    ADD CONSTRAINT fk_adress_reg_id FOREIGN KEY (adress_reg_id) REFERENCES dbo.adress(adress_id);


--
-- Name: adress fk_adress_rgn_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_rgn_id FOREIGN KEY (adress_rgn_id) REFERENCES sprav.rgn(rgn_id);


--
-- Name: adress fk_adress_street_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_street_id FOREIGN KEY (adress_street_id) REFERENCES sprav.street(street_id);


--
-- Name: adress fk_adress_town_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.adress
    ADD CONSTRAINT fk_adress_town_id FOREIGN KEY (adress_town_id) REFERENCES sprav.town(town_id);


--
-- Name: doctor fk_mo_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.doctor
    ADD CONSTRAINT fk_mo_id FOREIGN KEY (mo_id) REFERENCES dbo.medorganisation(mo_id);


--
-- Name: doctor fk_occupancy_type_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.doctor
    ADD CONSTRAINT fk_occupancy_type_id FOREIGN KEY (occupancy_type_id) REFERENCES sprav.occupancy_type(occupancy_type_id);


--
-- Name: policlinic_visit fk_oplata_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.policlinic_visit
    ADD CONSTRAINT fk_oplata_id FOREIGN KEY (oplata_id) REFERENCES sprav.oplata(oplata_id);


--
-- Name: medorganisation fk_org_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.medorganisation
    ADD CONSTRAINT fk_org_id FOREIGN KEY (org_id) REFERENCES dbo.org(org_id);


--
-- Name: org fk_org_pochtardess_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.org
    ADD CONSTRAINT fk_org_pochtardess_id FOREIGN KEY (org_pochtadress_id) REFERENCES dbo.adress(adress_id);


--
-- Name: person fk_person_card; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person
    ADD CONSTRAINT fk_person_card FOREIGN KEY (person_card_id) REFERENCES dbo.person_card(person_card_id);


--
-- Name: person_card fk_person_card_mo_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person_card
    ADD CONSTRAINT fk_person_card_mo_id FOREIGN KEY (mo_id) REFERENCES dbo.medorganisation(mo_id);


--
-- Name: doctor fk_person_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.doctor
    ADD CONSTRAINT fk_person_id FOREIGN KEY (person_id) REFERENCES dbo.person(person_id) ON DELETE CASCADE;


--
-- Name: person fk_person_polis_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person
    ADD CONSTRAINT fk_person_polis_id FOREIGN KEY (person_polis_id) REFERENCES dbo.person_polis(person_polis_id);


--
-- Name: person_polis fk_person_polis_org_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person_polis
    ADD CONSTRAINT fk_person_polis_org_id FOREIGN KEY (org_id) REFERENCES dbo.org(org_id);


--
-- Name: person_polis fk_person_polis_type_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.person_polis
    ADD CONSTRAINT fk_person_polis_type_id FOREIGN KEY (polis_type_id) REFERENCES sprav.polis_type(polis_type_id);


--
-- Name: policlinic_visit fk_policlinic_visit_diag_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_diag_id FOREIGN KEY (diag_id) REFERENCES sprav.diag(diag_id);


--
-- Name: policlinic_visit fk_policlinic_visit_pid; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.policlinic_visit
    ADD CONSTRAINT fk_policlinic_visit_pid FOREIGN KEY (policlinic_visit_pid) REFERENCES dbo.polyclinic_case(polyclinic_case_id);


--
-- Name: polyclinic_case fk_polyclinic_case_diag_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_id FOREIGN KEY (diag_id) REFERENCES sprav.diag(diag_id);


--
-- Name: polyclinic_case fk_polyclinic_case_diag_pid; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_diag_pid FOREIGN KEY (diag_pid) REFERENCES sprav.diag(diag_id);


--
-- Name: polyclinic_case fk_polyclinic_case_finish_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_finish_id FOREIGN KEY (finish_id) REFERENCES sprav.finish(finish_id);


--
-- Name: polyclinic_case fk_polyclinic_case_person_card_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_person_card_id FOREIGN KEY (person_card_id) REFERENCES dbo.person_card(person_card_id);


--
-- Name: polyclinic_case fk_polyclinic_case_person_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_person_id FOREIGN KEY (person_id) REFERENCES dbo.person(person_id);


--
-- Name: polyclinic_case fk_polyclinic_case_result_type_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.polyclinic_case
    ADD CONSTRAINT fk_polyclinic_case_result_type_id FOREIGN KEY (result_type_id) REFERENCES sprav.result_type(result_type_id);


--
-- Name: recording fk_recording_doctor_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT fk_recording_doctor_id FOREIGN KEY (doctor_id) REFERENCES dbo.doctor(doctor_id) ON DELETE CASCADE;


--
-- Name: recording fk_recording_mo_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT fk_recording_mo_id FOREIGN KEY (mo_id) REFERENCES dbo.medorganisation(mo_id);


--
-- Name: recording fk_recording_person_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT fk_recording_person_id FOREIGN KEY (person_id) REFERENCES dbo.person(person_id) ON DELETE CASCADE;


--
-- Name: recording fk_recording_policlinic_case_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT fk_recording_policlinic_case_id FOREIGN KEY (polyclinic_case_id) REFERENCES dbo.polyclinic_case(polyclinic_case_id);


--
-- Name: recording fk_recording_recordtype_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.recording
    ADD CONSTRAINT fk_recording_recordtype_id FOREIGN KEY (recordtype_id) REFERENCES sprav.recordtype(recordtype_id);


--
-- Name: org fk_urardess_id; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.org
    ADD CONSTRAINT fk_urardess_id FOREIGN KEY (org_uradress_id) REFERENCES dbo.adress(adress_id);


--
-- Name: city fk_city_rgn_id; Type: FK CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.city
    ADD CONSTRAINT fk_city_rgn_id FOREIGN KEY (rgn_id) REFERENCES sprav.rgn(rgn_id);


--
-- Name: diag fk_diag_pid; Type: FK CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.diag
    ADD CONSTRAINT fk_diag_pid FOREIGN KEY (diag_pid) REFERENCES sprav.diag(diag_id);


--
-- Name: rgn fk_rgn_country_id; Type: FK CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.rgn
    ADD CONSTRAINT fk_rgn_country_id FOREIGN KEY (country_id) REFERENCES sprav.country(country_id);


--
-- Name: town fk_town_city_id; Type: FK CONSTRAINT; Schema: sprav; Owner: postgres
--

ALTER TABLE ONLY sprav.town
    ADD CONSTRAINT fk_town_city_id FOREIGN KEY (city_id) REFERENCES sprav.city(city_id);


--
-- PostgreSQL database dump complete
--

