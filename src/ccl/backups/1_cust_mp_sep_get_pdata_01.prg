drop program 1_cust_mp_sep_get_pdata_01 go
create program 1_cust_mp_sep_get_pdata_01

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = 0

with OUTDEV, ENCOUNTER_IDS

; Based on respiratory MPage 1_mhn_mp_rt_patproc_03.prg - simplified for generic demographics
free record drec
record drec(
 	1 patientCnt = i4
	1 patient_list_id = f8
	1 name = vc
	1 description = vc
	1 patient_list_type_cd = f8
	1 owner_id = f8
	1 prsnl_access_cd = f8
	1 execution_dt_tm = dq8
	1 execution_status_cd = f8
	1 execution_status_disp = vc
	1 arguments[*]
		2 argument_name = vc
		2 argument_value = vc
		2 parent_entity_name = vc
		2 parent_entity_id = f8
	1 encntr_type_filters[*]
		2 encntr_type_cd = f8
	1 patients[*]
		2 person_id = f8
		2 person_name = vc
		2 encntr_id = f8
		2 facility = vc
		2 unit = vc
		2 roomBed = vc
		2 age = vc
		2 gender = vc
		2 admission_date = vc
		2 patient_class = vc
		2 isDischarged = i1
		2 fin = vc
		2 mrn = vc
		2 powerplans[*]
			3 pp_powerplan_name = vc
			3 pp_patient_name = vc
			3 pp_fin_number = vc
			3 pp_type = vc
			3 pp_group_id = f8
			3 pp_pathway_id = f8 ; troy
			3 pp_pathway_catalog_id = f8 ; troy
			3 phase [*]
				4 p_status = vc
				4 p_facility = vc
				4 p_phase_name = vc
				4 p_provider_name = vc
				4 p_entered_by = vc
				4 p_order_date = vc
				4 p_phase_id = f8
				4 p_pcg_id = f8
				4 p_phase_cnt = i4
				4 p_disc_comp_order_cnt = i4
				4 p_prescription_ord_cnt = i4
				4 p_total_order_cnt = i4
				4 p_completed_ind = i2
				4 p_phase_type = vc
				4 p_group_num = f8
				4 p_parent_phase_disp_desc = vc
				4 p_parent_phase_desc = vc
				4 p_cat_group_id = f8
				4 p_parent_name = vc
				4 orders [*]
					5 o_order_id = f8
					5 o_order_mnemonic = vc
					5 o_order_status = vc
					5 o_order_catalog_cd = f8
					5 o_order_synonym_id = f8
					5 o_order_cnt = i4
					4 subphases [*]
					5 subphase_ids = f8
	1 status_data
		2 status = c1
		2 message = vc
		2 subeventstatus[1]
			3 operationname = c25
			3 operationstatus = c1
			3 targetobjectname = c25
			3 targetobjectvalue = vc
)

; Variables for processing
declare cnt = i4 with noconstant(0)
declare num_patients = i4 with noconstant(0)
declare pt_idx = i4 with noconstant(0)
declare age_years = i4 with noconstant(0)


; sepsis data variables

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare mf_FIN_CD = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare ml_pp_cnt = i4 with protect, noconstant(0)
;declare mf_PERSON_ID = f8 with protect, constant(cnvtreal($f_person_id))
;declare mf_ENCNTR_ID = f8 with protect, constant(cnvtreal($f_encntr_id))
declare ml_phase_cnt = i4 with protect, noconstant(0)
declare subphase_cnt = i4 with protect, noconstant(0)
declare ml_ord_cnt = i4 with protect, noconstant(0)
declare planned_cd = f8 with protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
declare initiated_cd = f8 with protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"))
declare discontinued_cd = f8 with protect, constant(uar_get_code_by("MEANING",14281,"DISCONTINUED"))
declare completed_cd = f8 with protect, constant(uar_get_code_by("MEANING", 14281,"COMPLETED"))
declare mf_PHARM_CD = f8 with protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
declare powerplan_pos = i4 with protect , noconstant ( 0 )
declare subphase_pos = i4 with protect , noconstant ( 0 )
declare careplan_pos = i4 with protect , noconstant ( 0 )
declare current_size = i4 with protect , noconstant ( 0 )

/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
declare mark_phase_complete_sub(p1 = i4, p2 = i4) = null with protect




call echo(build("Processing encounter IDs: ", $ENCOUNTER_IDS))

; Get basic patient demographics using the encounter IDs
select into "nl:"
from
    encounter e,
    person p,
    encntr_alias ea
plan e
    where e.encntr_id = $ENCOUNTER_IDS
    and e.active_ind = 1
join p
    where p.person_id = e.person_id
    and p.active_ind = 1
join ea
    where ea.encntr_id = outerjoin(e.encntr_id)
    and ea.encntr_alias_type_cd = outerjoin(1077.0)  ; FIN alias type
    and ea.data_status_cd = outerjoin(25.00)         ; Active data status
    and ea.end_effective_dt_tm > outerjoin(sysdate)  ; Still effective

head report
    cnt = 0
    stat = alterlist(drec->patients, 10)

detail
    cnt = cnt + 1

    ; Resize array if needed
    if (cnt > size(drec->patients, 5))
        stat = alterlist(drec->patients, cnt + 10)
    endif

    ; Store basic patient demographics
    drec->patients[cnt].encntr_id = e.encntr_id
    drec->patients[cnt].person_id = e.person_id
    drec->patients[cnt].person_name = p.name_full_formatted

    ; Location information
    drec->patients[cnt].facility = trim(uar_get_code_display(e.loc_facility_cd), 3)
    drec->patients[cnt].unit = trim(uar_get_code_display(e.loc_nurse_unit_cd), 3)
    drec->patients[cnt].roomBed = build(
        uar_get_code_display(e.loc_room_cd),
        "-",
        uar_get_code_display(e.loc_bed_cd)
    )

    ; Patient classification and demographics
    drec->patients[cnt].patient_class = trim(uar_get_code_display(e.encntr_class_cd), 3)
    drec->patients[cnt].gender = trim(uar_get_code_display(p.sex_cd), 3)

    ; Calculate age
    age_years = cnvtint((sysdate - p.birth_dt_tm) / 365.25)
    if (age_years >= 0 and age_years <= 150)
        drec->patients[cnt].age = cnvtstring(age_years)
    else
        drec->patients[cnt].age = ""
    endif

    ; Admission date
    if (e.reg_dt_tm > 0)
        drec->patients[cnt].admission_date = format(e.reg_dt_tm, "MM/DD/YYYY;;Q")
    else
        drec->patients[cnt].admission_date = ""
    endif

    ; Financial identifiers
    if (ea.alias > " ")
        drec->patients[cnt].fin = trim(ea.alias, 3)
    else
        drec->patients[cnt].fin = ""
    endif

    ; MRN - would need additional query for person_alias if required
    drec->patients[cnt].mrn = ""

    ; Discharge status
    if (e.disch_dt_tm > 0)
        drec->patients[cnt].isDischarged = 1
    else
        drec->patients[cnt].isDischarged = 0
    endif

foot report
    num_patients = cnt

    ; Resize the array to actual size
    if (cnt > 0)
        stat = alterlist(drec->patients, cnt)
    else
        stat = alterlist(drec->patients, 0)
    endif
with nocounter, format, time = 400

call echo(build("Found ", num_patients, " patients from encounter IDs"))

; Get sepsis order information
select into "nl:"
	patients_person_id = drec->patients[d1.seq].person_id
	, patients_encntr_id = drec->patients[d1.seq].encntr_id

from
	(dummyt   d1  with seq = size(drec->patients, 5))
  ,pathway pw
  ,act_pw_comp a
  ,pw_comp_action pca
  ,orders o
  ,person p
  ,encntr_alias ea
  ,prsnl pr
  ,prsnl pr1
  ,encounter e
  ,pathway_action pa

plan d1

join e where e.encntr_id = drec->patients[d1.seq].encntr_id

;plan p where p.person_id = mf_PERSON_ID

join pw ;get all phase types
where pw.pw_status_cd in (planned_cd,initiated_cd)
and pw.active_ind = 1

;and pw.person_id = p.person_id
and pw.encntr_id = e.encntr_id

and pw.pw_group_desc = "ED Severe Sepsis - ADULT"

and pw.type_mean in ("CAREPLAN", "PHASE", "SUBPHASE")
join a
where a.pathway_id=outerjoin(pw.pathway_id)
and a.parent_entity_name=outerjoin("ORDERS")
join pca
where pca.act_pw_comp_id=outerjoin(a.act_pw_comp_id)
and pca.parent_entity_id=outerjoin(a.parent_entity_id)
and pca.parent_entity_name=outerjoin("ORDERS")
join o ;links orders to phase
where o.order_id=outerjoin(a.parent_entity_id)
and o.originating_encntr_id=outerjoin(a.originating_encntr_id)
join pa
where pa.pathway_id = pw.pathway_id
and pa.pw_status_cd !=0
join pr ;links "last entered by" personel
where pr.person_id = pa.action_prsnl_id
join pr1 ;links provider to phase
where pr1.person_id = pa.provider_id
join ea
where ea.encntr_id = pw.encntr_id
and ea.encntr_alias_type_cd = 1077.000000 ;fin cd
and ea.active_ind = 1
and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
;join e
;where e.encntr_id = ea.encntr_id
join p
where p.person_id = e.person_id
order by
pw.pathway_id
,pw.pw_status_cd
,o.order_id
,pw.pw_group_desc
,pw.description, 0 ;get distinct plans based on order by items

head report
ml_pp_cnt = 0
head pw.pw_cat_group_id ;group each powerplan
call echo(pw.pathway_id)
ml_pp_cnt += 1
if(mod(ml_pp_cnt,50) = 1 or ml_pp_cnt = 1)

call alterlist(drec->patients[d1.seq].powerplans, ml_pp_cnt + 49)

endif
ms_pp_name_disp = substring(1,50,pw.pw_group_desc)
ms_pat_name_disp = substring(1,30,p.name_full_formatted)
ms_fin_nbr_disp = substring(1,15,cnvtalias(ea.alias, ea.alias_pool_cd))
drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_powerplan_name = ms_pp_name_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_patient_name = ms_pat_name_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_fin_number = ms_fin_nbr_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_group_id = pw.pw_cat_group_id

drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_pathway_catalog_id = pw.pathway_catalog_id
drec->patients[d1.seq].powerplans[ml_pp_cnt].pp_pathway_id = pw.pathway_id

ml_phase_cnt = 0
head pw.pathway_id ;group each phase to powerplan
ml_phase_cnt = ml_phase_cnt + 1
if (mod(ml_phase_cnt,20) = 1 or ml_phase_cnt = 1)
call alterlist(drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase, ml_phase_cnt + 19)
endif
ms_pp_phase_disp = substring(1,50,pw.description)
if(pw.parent_phase_desc not in ("", null))
ms_parent_phase_disp_desc = substring(1,50,pw.pw_group_desc) ; this displays in powerchart
ms_parent_phase_desc = substring(1,50,pw.parent_phase_desc)  ; this displays in powerplan tool
else
ms_parent_phase_disp_desc = ""
ms_parent_phase_desc = ""
endif
ms_provider_name_disp = substring(1,30,pr1.name_full_formatted)
ms_phys_name_disp = substring(1,30,pr.name_full_formatted)
ms_pp_status_disp = substring(1,15,uar_get_code_display(pw.pw_status_cd))
ms_ord_date_disp = format(pa.updt_dt_tm, "MM/DD/YYYY;;D")
ms_fac_disp = substring(1,15,uar_get_code_display(e.loc_facility_cd))
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_entered_by = ms_phys_name_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_phase_name = ms_pp_phase_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_phase_id = pw.pathway_id
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_pcg_id = pw.pathway_catalog_id
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_provider_name = ms_provider_name_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_order_date = ms_ord_date_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_facility = ms_fac_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_status = ms_pp_status_disp
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_phase_type = pw.type_mean
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_cat_group_id = pw.pw_cat_group_id
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_group_num= pw.pw_group_nbr

drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_parent_phase_disp_desc= ms_parent_phase_disp_desc
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_parent_phase_desc= ms_parent_phase_desc
ml_ord_cnt = 0
head o.order_id ;group each order to phase
if (o.synonym_id != 0)
ml_ord_cnt = ml_ord_cnt + 1
if (mod(ml_ord_cnt,20) = 1 or ml_ord_cnt = 1)
call alterlist(drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders, ml_ord_cnt + 19)
endif
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_id = o.order_id
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_mnemonic = o.order_mnemonic
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_catalog_cd = o.catalog_cd
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_synonym_id = o.synonym_id
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_status =
uar_get_code_display(o.dept_status_cd)
if(ml_phase_cnt > 0 and ml_ord_cnt > 0)
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders[ml_ord_cnt].o_order_cnt = ml_ord_cnt
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_total_order_cnt =
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_total_order_cnt +1
if (o.dept_status_cd in (completed_cd, discontinued_cd));keep count of discontinued, completed orders
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_disc_comp_order_cnt =
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_disc_comp_order_cnt + 1
endif
if (o.catalog_type_cd = mf_PHARM_CD) ;keep count of prescription orders
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_prescription_ord_cnt =
drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt].p_prescription_ord_cnt + 1
endif
endif
endif
foot pw.pw_cat_group_id
call alterlist(drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase, ml_phase_cnt)
foot pw.pathway_id
call alterlist(drec->patients[d1.seq].powerplans[ml_pp_cnt]->phase[ml_phase_cnt]->orders, ml_ord_cnt)
foot report
call alterlist(drec->patients[d1.seq].powerplans, ml_pp_cnt)
for (powerplan_pos =1 to size(drec->patients[d1.seq].powerplans,5))
for(careplan_pos = 1 to size(drec->patients[d1.seq].powerplans[powerplan_pos].phase, 5))
if(drec->patients[d1.seq].powerplans[powerplan_pos].phase[careplan_pos].p_phase_type != "SUBPHASE")
call mark_phase_complete_sub(powerplan_pos,careplan_pos)
for(subphase_pos = 1 to size(drec->patients[d1.seq].powerplans[powerplan_pos].phase, 5))
if(drec->patients[d1.seq].powerplans[powerplan_pos].phase[subphase_pos].p_phase_type = "SUBPHASE")
call mark_phase_complete_sub(powerplan_pos,subphase_pos)
;linking subphase to parent phase if same group number and group cat id
;and if the subphase parent phase desc matches parent phase desc
if((drec->patients[d1.seq].powerplans[powerplan_pos].phase[subphase_pos].p_group_num =
drec->patients[d1.seq].powerplans[powerplan_pos].phase[careplan_pos].p_group_num)and
(drec->patients[d1.seq].powerplans[powerplan_pos].phase[subphase_pos].p_cat_group_id=
drec->patients[d1.seq].powerplans[powerplan_pos].phase[careplan_pos].p_cat_group_id) and
(drec->patients[d1.seq].powerplans[powerplan_pos].phase[subphase_pos].p_parent_phase_desc=
drec->patients[d1.seq].powerplans[powerplan_pos].phase[careplan_pos].p_phase_name)
)
current_size = size(drec->patients[d1.seq].powerplans[powerplan_pos]->phase[careplan_pos]->subphases, 5)
; Increase the size of the subphases list by one to accommodate the new subphase id
call alterlist(drec->patients[d1.seq].powerplans[powerplan_pos]->phase[careplan_pos]->subphases, current_size + 1)
; Assign the new subphase id to the last element of the subphases list
drec->patients[d1.seq].powerplans[powerplan_pos]->phase[careplan_pos]->subphases[current_size + 1].subphase_ids =
drec->patients[d1.seq].powerplans[powerplan_pos].phase[subphase_pos].p_phase_id
endif
endif
endfor
endif
endfor
endfor
subroutine mark_phase_complete_sub(p1,p2) ;this is checking for case where plan is stuck in initiated phase, but is completed.
;if all non prescription orders in the end phase(completed, discontinued), then phase is complete
if(drec->patients[d1.seq].powerplans[p1].phase[p2].p_disc_comp_order_cnt =
drec->patients[d1.seq].powerplans[p1].phase[p2].p_total_order_cnt and
drec->patients[d1.seq].powerplans[p1].phase[p2].p_total_order_cnt > 0)
drec->patients[d1.seq].powerplans[p1].phase[p2].p_completed_ind = 1
endif
;if all orders in the phase are prescription, then phase is complete
if(drec->patients[d1.seq].powerplans[p1].phase[p2].p_prescription_ord_cnt =
drec->patients[d1.seq].powerplans[p1].phase[p2].p_total_order_cnt and
drec->patients[d1.seq].powerplans[p1].phase[p2].p_total_order_cnt > 0)
drec->patients[d1.seq].powerplans[p1].phase[p2].p_completed_ind = 1
endif
end

WITH NOCOUNTER, UAR_CODE(D),time=400,FORMAT(DATE,"@SHORTDATETIME")



; Check if we have any patients
if (num_patients = 0)
    set drec->status_data.status = "Z"
    set drec->status_data.message = "No patients found with the provided encounter IDs."
    set drec->patientCnt = 0

    set _memory_reply_string = cnvtrectojson(drec, 4)
    call echojson(drec, $1)
    go to exit_script
endif

; Set basic info
set drec->patient_list_id = 0
set drec->name = "Generic Patient List"
set drec->description = "Basic patient demographics"
set drec->patientCnt = num_patients
set drec->status_data.status = "S"
set drec->status_data.message = build("Found ", num_patients, " patients with basic demographics")

; Return the data
set _memory_reply_string = cnvtrectojson(drec, 4)
call echo(_memory_reply_string)
call echojson(drec, $1)

;1_cust_mp_sep_get_pdata_01 "MINE", 114259401 go

#exit_script
end go


