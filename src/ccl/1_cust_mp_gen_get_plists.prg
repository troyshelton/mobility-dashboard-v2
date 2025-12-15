drop program 1_cust_mp_gen_get_plists go
create program 1_cust_mp_gen_get_plists

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Personnel ID" = 4178952 

with OUTDEV, PRSNL_ID

RECORD rpatlists
(
	1 application_id = f8
	1 prsnl_id = f8
	1 qual[*]
    2 view_seq = i4 
		2 patient_list_id  =  f8
		2 name  =  vc
)

select into "nl:"
dp.view_seq, pl.name, pl.patient_list_id
from detail_prefs dp
    ,name_value_prefs nvp
    ,dcp_patient_list pl

plan dp
  where dp.prsnl_id = CNVTREAL($2)
    and dp.view_name = "PATLISTVIEW"
    ;and dp.application_number ;= reply->application_id ; 600005
join nvp
  where nvp.parent_entity_id = dp.detail_prefs_id
    and nvp.parent_entity_name = "DETAIL_PREFS"
    and cnvtupper(nvp.pvc_name) = "PATIENTLISTID"
join pl
  where pl.patient_list_id = CNVTREAL(nvp.pvc_value)
order by dp.view_seq;, pl.name
head report
  cnt = 0
detail
  cnt = cnt + 1
  stat = alterlist(rpatlists->qual, cnt)
  rpatlists->qual[cnt].view_seq = dp.view_seq
  rpatlists->qual[cnt].name = pl.name
  rpatlists->qual[cnt].patient_list_id = pl.patient_list_id
foot report
  null
with time = 60, format, uar_code(c,d,e,m,0), format(date, "MM/DD/YYYY hh:mm;;Q")

/*******************************************************************
;RETURN JSON TO JavaScript
*******************************************************************/
set rpatlists->application_id = 0.0
set rpatlists->prsnl_id = CNVTREAL($PRSNL_ID)

; CRITICAL: Set _memory_reply_string for MPage framework (from respiratory MPage pattern)
set _memory_reply_string = cnvtrectojson(rpatlists, 4)
call echo(_memory_reply_string)

call echorecord(rpatlists)

; Example execution: execute 1_cust_mp_sep_get_plists "MINE", 4178952.0

end
go
