--VIEW v_adress
CREATE VIEW v_adress AS
	select adress_id
	,adress.adress_index as _index
	,coalesce(country.country_name, '') as _country
	,coalesce(rgn.rgn_name, '') as rgn
	,coalesce(city.city_name, '') as city
	,coalesce(town.town_name, '') as town
	,coalesce(street.street_name, '') as street
	,coalesce(adress.adress_house, chr(45)) as house
	,coalesce(adress.adress_corpus, chr(45)) as corpus
	,coalesce(adress.adress_flat, chr(45)) as flat
	
	from public.adress adress 
	left join public.country country on adress_country_id = country.country_id
	left join public.rgn rgn on adress_rgn_id = rgn.rgn_id
	left join public.city city on adress_city_id = city.city_id
	left join public.town town on adress_town_id = town.town_id
	left join public.street street on adress_street_id = street.street_id

--FUNCTION
--Сводный Отчет по записи на поликлинический прием в разрезе Мед. организации и врача

-- FUNCTION: public.svod_recording(bigint, bigint, timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION IF EXISTS public.svod_recording(bigint, bigint, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION public.svod_recording(
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
				filter(where person_id is not null) as cnt_pers_busy
			,count(recording.person_id) as cnt_person
			,count(recording.person_id)
				filter(where recording_factdate is not null) as cnt_fact -- занятые бирки
			,count(polca_case.polyclinic_case_id) as cnt_polyclinic_case
			,count(polca_case.polyclinic_case_id) 
				filter(where polca_case.result_type_id = ANY('{1,2}'::integer[])) as cnt_result

			from recording
			left join lateral (
				select doctors.doctor_name,doctors.mo_id
				from doctors 
				where 1=1
				and doctors.doctor_id = recording.doctor_id
				and recording.mo_id = doctors.mo_id
				and coalesce(work_enddate, 'Infinity') >= now() -- Врач работает в мед организации на момент отчета
				and occupancy_type_id = 1 -- основное место работы
				) doc on true

			left join public.medorganisation mo on mo.mo_id = doc.mo_id
			left join lateral (
				select 
					concat_ws(' '
							  ,person_surname
							  ,person_firstname
							  ,person_secname
							 ) pers_fio		
				from public.persons persons
				cross join lateral (
						select 1 
						from public.person_polis polis
						where 1=1
						and polis.person_polis_id = persons.person_polis_id
						and coalesce(polis_enddate, 'Infinity') >= $4
						limit 1
					 ) polis 
				)pers on true

			left join lateral (	
				select polyclinic_case_id,result_type_id
				from public.polyclinic_case sluch
				join public.polyclinic_visit visit 
					on visit.polyclinic_visit_pid = sluch.polyclinic_case_id
					and finish_id = 1 -- случай закончен
				) polca_case on true
			where 1=1
			and recording_begdate between $3 and $4		
			and (recording.mo_id = $1 or recording.mo_id is null)
			and (recording.doctor_id = $2 or recording.mo_id is null)
			group by mo.mo_name,doc.doctor_name
			order by mo.mo_name,doc.doctor_name			
			; 
end;
$BODY$;

ALTER FUNCTION public.svod_recording(bigint, bigint, timestamp with time zone, timestamp with time zone)
OWNER TO postgres;
	
-- Список пациентов на прием
CREATE OR REPLACE FUNCTION public.list_recording_date(
	p_mo_id bigint DEFAULT NULL::bigint,
	p_doctor_id bigint DEFAULT NULL::bigint,
	p_date timestamp DEFAULT NULL::timestamp
	)	
    RETURNS TABLE(
		card_num text
		,pers_fio text
		,person_birthday bigint
		,cnt_all_internet bigint
		,cnt_all_registrator bigint, cnt_all_terminal bigint, cnt_pers_busy bigint, cnt_person bigint, cnt_fact bigint, cnt_polyclinic_case bigint, cnt_result bigint) 
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
			join persons on recording.person_id = persons.person_id
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
			; 
end;
$BODY$;

ALTER FUNCTION public.list_recording_date(bigint, bigint, timestamp with time zone)
    OWNER TO postgres;
