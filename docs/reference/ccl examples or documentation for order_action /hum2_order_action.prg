drop   program hum2_order_action:dba go
create program hum2_order_action:dba
 
set prog_file = cnvtlower(trim(curprog))
call echo(build("begin_date:",bdate_dt_tm_dsp))
call echo(build("end_date:",edate_dt_tm_dsp))
call echo(concat("running script: ", cnvtlower(trim(curprog))))
 
Execute hum2_localize "SCRIPT_TOP", curprog
 
select into concat(print_dir,print_file)
	action_dt_tm = format(oa.action_dt_tm,"yyyyMMddhhmmss;;d"),
	action_initiated_dt_tm = format(oa.action_initiated_dt_tm,"yyyyMMddhhmmss;;d"),
	action_personnel_id = cnvtstring(oa.action_personnel_id),
	action_qualifier_cd = cnvtstring(oa.action_qualifier_cd),
	action_rejected_ind = cnvtstring(oa.action_rejected_ind),
	action_sequence = cnvtstring(oa.action_sequence),
	action_type_cd = cnvtstring(oa.action_type_cd),
	action_tz = cnvtstring(oa.action_tz),
	billing_provider_flag = cnvtstring(oa.billing_provider_flag),
	clinical_display_line = trim(oa.clinical_display_line,3),
	communication_type_cd = cnvtstring(oa.communication_type_cd),
	constant_ind = cnvtstring(oa.constant_ind),
	contributor_system_cd = cnvtstring(oa.contributor_system_cd),
	core_ind = cnvtstring(oa.core_ind),
	current_start_dt_tm = format(oa.current_start_dt_tm,"yyyyMMddhhmmss;;d"),
	current_start_tz = cnvtstring(oa.current_start_tz),
	dept_status_cd = cnvtstring(oa.dept_status_cd),
	digital_signature_ident = trim(oa.digital_signature_ident,3),
	effective_dt_tm = format(oa.effective_dt_tm,"yyyyMMddhhmmss;;d"),
	effective_tz = cnvtstring(oa.effective_tz),
	eso_action_cd = cnvtstring(oa.eso_action_cd),
	formulary_status_cd = cnvtstring(oa.formulary_status_cd),
	frequency_id = cnvtstring(oa.frequency_id),
	inactive_flag = cnvtstring(oa.inactive_flag),
	incomplete_order_ind = cnvtstring(oa.incomplete_order_ind),
	medstudent_action_ind = cnvtstring(oa.medstudent_action_ind),
	needs_verify_ind = cnvtstring(oa.needs_verify_ind),
	need_clin_review_flag = cnvtstring(oa.need_clin_review_flag),
	next_dose_dt_tm = format(oa.next_dose_dt_tm,"yyyyMMddhhmmss;;d"),
	order_action_id = cnvtstring(oa.order_action_id),
	order_app_nbr = cnvtstring(oa.order_app_nbr),
	order_conversation_id = cnvtstring(oa.order_conversation_id),
	order_convs_seq = cnvtstring(oa.order_convs_seq),
	order_detail_display_line = trim(oa.order_detail_display_line,3),
	order_dt_tm = format(oa.order_dt_tm,"yyyyMMddhhmmss;;d"),
	order_id = cnvtstring(oa.order_id),
	order_locn_cd = cnvtstring(oa.order_locn_cd),
	order_provider_id = cnvtstring(oa.order_provider_id),
	order_schedule_precision_bit = cnvtstring(oa.order_schedule_precision_bit),
	order_status_cd = cnvtstring(oa.order_status_cd),
	order_tz = cnvtstring(oa.order_tz),
	prn_ind = cnvtstring(oa.prn_ind),
	projected_stop_dt_tm = format(oa.projected_stop_dt_tm,"yyyyMMddhhmmss;;d"),
	projected_stop_tz = cnvtstring(oa.projected_stop_tz),
	sch_state_cd = cnvtstring(oa.sch_state_cd),
	simplified_display_line = trim(oa.simplified_display_line,3),
	source_dot_action_seq = cnvtstring(oa.source_dot_action_seq),
	source_dot_order_id = cnvtstring(oa.source_dot_order_id),
	source_protocol_action_seq = cnvtstring(oa.source_protocol_action_seq),
	stop_type_cd = cnvtstring(oa.stop_type_cd),
	supervising_provider_id = cnvtstring(oa.supervising_provider_id),
	template_order_flag = cnvtstring(oa.template_order_flag),
	undo_action_type_cd = cnvtstring(oa.undo_action_type_cd),
	updt_applctx = cnvtstring(oa.updt_applctx),
	updt_cnt = cnvtstring(oa.updt_cnt),
	updt_dt_tm = format(oa.updt_dt_tm,"yyyyMMddhhmmss;;d"),
	updt_id = cnvtstring(oa.updt_id),
	updt_task = cnvtstring(oa.updt_task),
	valid_dose_dt_tm = format(oa.valid_dose_dt_tm,"yyyyMMddhhmmss;;d")
 
from order_action oa
plan oa where oa.updt_dt_tm between cnvtdatetime(bdate) and cnvtdatetime(edate)
head report
	head_line = build(
	"action_dt_tm",
	"||action_initiated_dt_tm",
	"||action_personnel_id",
	"||action_qualifier_cd",
	"||action_rejected_ind",
	"||action_sequence",
	"||action_type_cd",
	"||action_tz",
	"||billing_provider_flag",
	"||clinical_display_line",
	"||communication_type_cd",
	"||constant_ind",
	"||contributor_system_cd",
	"||core_ind",
	"||current_start_dt_tm",
	"||current_start_tz",
	"||dept_status_cd",
	"||digital_signature_ident",
	"||effective_dt_tm",
	"||effective_tz",
	"||eso_action_cd",
	"||formulary_status_cd",
	"||frequency_id",
	"||inactive_flag",
	"||incomplete_order_ind",
	"||medstudent_action_ind",
	"||needs_verify_ind",
	"||need_clin_review_flag",
	"||next_dose_dt_tm",
	"||order_action_id",
	"||order_app_nbr",
	"||order_conversation_id",
	"||order_convs_seq",
	"||order_detail_display_line",
	"||order_dt_tm",
	"||order_id",
	"||order_locn_cd",
	"||order_provider_id",
	"||order_schedule_precision_bit",
	"||order_status_cd",
	"||order_tz",
	"||prn_ind",
	"||projected_stop_dt_tm",
	"||projected_stop_tz",
	"||sch_state_cd",
	"||simplified_display_line",
	"||source_dot_action_seq",
	"||source_dot_order_id",
	"||source_protocol_action_seq",
	"||stop_type_cd",
	"||supervising_provider_id",
	"||template_order_flag",
	"||undo_action_type_cd",
	"||updt_applctx",
	"||updt_cnt",
	"||updt_dt_tm",
	"||updt_id",
	"||updt_task",
	"||valid_dose_dt_tm")
 
  col 0 head_line
  row + 1
 
detail
	detail_line = build(
	action_dt_tm
	,"||",action_initiated_dt_tm
	,"||",action_personnel_id
	,"||",action_qualifier_cd
	,"||",action_rejected_ind
	,"||",action_sequence
	,"||",action_type_cd
	,"||",action_tz
	,"||",billing_provider_flag
	,"||",clinical_display_line
	,"||",communication_type_cd
	,"||",constant_ind
	,"||",contributor_system_cd
	,"||",core_ind
	,"||",current_start_dt_tm
	,"||",current_start_tz
	,"||",dept_status_cd
	,"||",digital_signature_ident
	,"||",effective_dt_tm
	,"||",effective_tz
	,"||",eso_action_cd
	,"||",formulary_status_cd
	,"||",frequency_id
	,"||",inactive_flag
	,"||",incomplete_order_ind
	,"||",medstudent_action_ind
	,"||",needs_verify_ind
	,"||",need_clin_review_flag
	,"||",next_dose_dt_tm
	,"||",order_action_id
	,"||",order_app_nbr
	,"||",order_conversation_id
	,"||",order_convs_seq
	,"||",order_detail_display_line
	,"||",order_dt_tm
	,"||",order_id
	,"||",order_locn_cd
	,"||",order_provider_id
	,"||",order_schedule_precision_bit
	,"||",order_status_cd
	,"||",order_tz
	,"||",prn_ind
	,"||",projected_stop_dt_tm
	,"||",projected_stop_tz
	,"||",sch_state_cd
	,"||",simplified_display_line
	,"||",source_dot_action_seq
	,"||",source_dot_order_id
	,"||",source_protocol_action_seq
	,"||",stop_type_cd
	,"||",supervising_provider_id
	,"||",template_order_flag
	,"||",undo_action_type_cd
	,"||",updt_applctx
	,"||",updt_cnt
	,"||",updt_dt_tm
	,"||",updt_id
	,"||",updt_task
	,"||",valid_dose_dt_tm)
 
col 0	detail_line
row +1
 
with maxrow = 1,
     nocounter,
     maxcol = 32000,
     format = variable,
     orahintcbo("INDEX_DESC(oa xie7order_action)")
 
SET row_count = curqual
SET ERRORCODE = ERROR(ERRORMSG,0)
Execute hum2_localize "SCRIPT_BOTTOM", curprog
 
end
go
 
