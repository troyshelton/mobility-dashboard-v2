drop program 1_cust_mp_gen_get_pids go
create program 1_cust_mp_gen_get_pids
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Patient List ID" = 12905149 

with OUTDEV, PATLST_ID
 
free record ptlst_request
record ptlst_request
(
	1 patient_list_id = f8
	1 patient_list_type_cd = f8
	1 best_encntr_flag = i2
	1 arguments[*]
		2 argument_name = vc
		2 argument_value = vc
		2 parent_entity_name = vc
		2 parent_entity_id = f8
	1 encntr_type_filters[*]
		2 encntr_type_cd = f8
)
 
free record ptlstencntr_reply
record ptlstencntr_reply(
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
		2 priority = i4
		2 active_ind = i2
		2 filter_ind = i2
		2 responsible_prsnl_id = f8
		2 responsible_prsnl_name = vc
		2 responsible_reltn_cd = f8
		2 responsible_reltn_disp = vc
		2 responsible_reltn_id = f8
		2 responsible_reltn_flag = i2
		2 organization_id = f8
		2 confid_level_cd = f8
		2 confid_level = i4
		2 birthdate = dq8
		2 birth_tz = i4
		2 end_effective_dt_tm = dq8
		2 service_cd = f8
		2 service_disp = c40
		2 gender_cd = f8
		2 gender_disp = c40
		2 temp_location_cd = f8
		2 temp_location_disp = c40
		2 vip_cd = f8
		2 visit_reason = vc
		2 visitor_status_cd = f8
		2 visitor_status_disp = c40
		2 deceased_date = dq8
		2 deceased_tz = i4
		2 facility = vc
		2 unit = vc
		2 roomBed = vc
		2 room = vc
		2 bed = vc
		2 sex = vc
		2 mrn = vc
		2 fin = vc
		2 age = vc
		2 med_service = vc
		2 tasks = vc
		2 meds = vc
		2 newOrders = i1
		2 ord_need_nurse_review_ind = i1
		2 ordrev_nurse_not_reviewed = i1
		2 isDischarged = i1
	1 status_data
		2 status = c1
		2 message = vc
		2 subeventstatus[1]
			3 operationname = c25
			3 operationstatus = c1
			3 targetobjectname = c25
			3 targetobjectvalue = vc
)
 
declare mi4_encntr_filtercnt  =  i4  with  noconstant (0)
declare mi4_arg_cnt  =  i4  with  noconstant (0)
 
declare mf8_list_id  =  i4  with  noconstant (0.0)
 
declare mvc_list_type  =  vc  with  noconstant ("")
 
select into "nl:"
from dcp_patient_list pl
	,dcp_pl_argument ar
	,dcp_pl_encntr_filter ef
plan pl
	where pl.patient_list_id = CNVTREAL($PATLST_ID)
join ar
	where ar.patient_list_id = outerjoin(pl.patient_list_id)
join ef
	where ef.patient_list_id = outerjoin(pl.patient_list_id)
order by pl.patient_list_id
		,ar.sequence
		,ef.encntr_filter_id
head pl.patient_list_id
 
	mi4_arg_cnt = 0
	mi4_encntr_filtercnt = 0
 
	ptlst_request->patient_list_id = pl.patient_list_id
 
	ptlst_request->patient_list_type_cd = pl.patient_list_type_cd
	ptlst_request->best_encntr_flag = 0
 
 
head ar.sequence
 
	if(ar.argument_id >0)
		mi4_arg_cnt = mi4_arg_cnt + 1
		stat = alterlist(ptlst_request->arguments,mi4_arg_cnt)
 
		ptlst_request->arguments[mi4_arg_cnt].argument_name = TRIM(ar.argument_name,3)
		ptlst_request->arguments[mi4_arg_cnt].argument_value = trim(ar.argument_value,3)
		ptlst_request->arguments[mi4_arg_cnt].parent_entity_id = ar.parent_entity_id
		ptlst_request->arguments[mi4_arg_cnt].parent_entity_name = trim(ar.parent_entity_name,3)
 
	endif
head ef.encntr_filter_id
 
	if(ef.encntr_filter_id > 0)
		mi4_encntr_filtercnt = mi4_encntr_filtercnt+1
		stat = alterlist(ptlst_request->encntr_type_filters,mi4_encntr_filtercnt)
 
		ptlst_request->encntr_type_filters[mi4_encntr_filtercnt].encntr_type_cd = ef.encntr_type_cd
	endif
with nocounter
 
set mvc_list_type = CNVTUPPER(uar_get_code_meaning(ptlst_request->patient_list_type_cd))
 
set mf8_list_id = ptlst_request->patient_list_id
 
call echo(build("list type :",mvc_list_type))

case (mvc_list_type)
	of "CUSTOM":
		execute 1_cust_mp_sep_plst_custom
	of "CARETEAM":
		execute 1_cust_mp_sep_plst_cteam
	of "LOCATIONGRP":
		execute 1_cust_mp_sep_plst_census
	of "LOCATION":
		execute 1_cust_mp_sep_plst_census
	of "SERVICE" :
		execute 1_cust_mp_sep_plst_census
	of "VRELTN" :
		execute 1_cust_mp_sep_plst_reltn
	of "LRELTN" :
		execute 1_cust_mp_sep_plst_reltn
	of "RELTN" :
		execute 1_cust_mp_sep_plst_reltn
	of "PROVIDERGRP" :
 		execute 1_cust_mp_sep_plst_provgrp
 	of "ASSIGNMENT":
 		execute 1_cust_mp_sep_plst_assign
 	of "QUERY":
 		execute 1_cust_mp_sep_plst_query
endcase
 
; Check if patients were retrieved and that structure is valid
call echo("Checking patient data structure...")

if (NOT(VALIDATE(PTLSTENCNTR_REPLY->patients, 0)))
    call echo("WARNING: ptlstEncntr_reply->patients structure is not valid")
    
    set ptlstencntr_reply->status_data.status = "Z"
    set ptlstencntr_reply->status_data.message = "Error: Invalid patient data structure returned from list type script."
    set ptlstencntr_reply->patientCnt = 0
elseif (SIZE(PTLSTENCNTR_REPLY->patients, 5) = 0)
    call echo("No patients retrieved from patient list type script.")
    
    set ptlstencntr_reply->status_data.status = "Z"
    set ptlstencntr_reply->status_data.message = "No patients found in the selected list."
    set ptlstencntr_reply->patientCnt = 0
else
    call echo("Patients retrieved from patient list type script.")
    
    set ptlstencntr_reply->status_data.status = "S"
    set ptlstencntr_reply->status_data.message = concat(
        "Successfully retrieved ", 
        cnvtstring(SIZE(PTLSTENCNTR_REPLY->patients, 5)), 
        " patients"
    )
    set ptlstencntr_reply->patientCnt = SIZE(PTLSTENCNTR_REPLY->patients, 5)
endif

set _memory_reply_string = cnvtrectojson(ptlstencntr_reply, 4)
call echo(_memory_reply_string)
call echojson(ptlstencntr_reply, $1)

end go