drop program 1_cust_mp_sep_get_pdata go
create program 1_cust_mp_sep_get_pdata

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

#exit_script
end go
