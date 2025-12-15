drop program 1_cust_mp_gen_get_pdata go
create program 1_cust_mp_gen_get_pdata

;===============================================================================
; Program: 1_cust_mp_gen_get_pdata.prg
; Version: v01
; Build Date: 2025-12-13
; Project: ER Tracking Dashboard Template (Generic Boilerplate)
;
; Features: demographics-only, patient-list-integration
;
; Description: Get patient demographics ONLY (no clinical data)
;              Generic template for extending with domain-specific features
;              Derived from sepsis-dashboard v1.48.0-sepsis
;              Use as boilerplate for: mobility, respiratory, cardiac, etc.
;===============================================================================

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = 0

with OUTDEV, ENCOUNTER_IDS

; Version tracking constants
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v01"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2025-12-13"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("demographics-only,patient-list-integration"), PROTECT

; Simple record structure - DEMOGRAPHICS ONLY
free record drec
record drec(
	1 patientCnt = i4
	1 program_version = vc
	1 program_build_date = vc
	1 patients[*]
		2 person_id = f8
		2 encntr_id = f8
		2 person_name = vc
		2 unit = vc
		2 roomBed = vc
		2 age = vc
		2 gender = vc
		2 patient_class = vc
		2 admission_date = vc
		2 status = vc
		2 fin = vc
		2 mrn = vc
)

; Parse encounter IDs from prompt parameter
DECLARE encntr_list = vc WITH NOCONSTANT("")
SET encntr_list = $ENCOUNTER_IDS

; Demographics query - ONE query, NO clinical events, NO orders
SELECT INTO "NL:"
FROM
	encounter e,
	person p,
	encntr_alias ea_fin,
	encntr_alias ea_mrn
PLAN e
	WHERE e.encntr_id = CNVTREAL(encntr_list)
	AND e.active_ind = 1
JOIN p
	WHERE p.person_id = e.person_id
	AND p.active_ind = 1
JOIN ea_fin
	WHERE ea_fin.encntr_id = outerjoin(e.encntr_id)
	AND ea_fin.encntr_alias_type_cd = outerjoin(1077.00)  /* FIN */
	AND ea_fin.active_ind = outerjoin(1)
	AND ea_fin.end_effective_dt_tm > outerjoin(SYSDATE)
JOIN ea_mrn
	WHERE ea_mrn.encntr_id = outerjoin(e.encntr_id)
	AND ea_mrn.encntr_alias_type_cd = outerjoin(1079.00)  /* MRN */
	AND ea_mrn.active_ind = outerjoin(1)
	AND ea_mrn.end_effective_dt_tm > outerjoin(SYSDATE)

HEAD REPORT
	cnt = 0
	drec->program_version = PROGRAM_VERSION
	drec->program_build_date = BUILD_DATE

DETAIL
	cnt = cnt + 1
	stat = alterlist(drec->patients, cnt)

	; Basic demographics - NO clinical data
	drec->patients[cnt].person_id = p.person_id
	drec->patients[cnt].encntr_id = e.encntr_id
	drec->patients[cnt].person_name = p.name_full_formatted
	drec->patients[cnt].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	drec->patients[cnt].roomBed = trim(concat(trim(e.loc_room_cd, 3), "-", trim(e.loc_bed_cd, 3), 3), 3)
	drec->patients[cnt].age = cnvtstring(cnvtage(p.birth_dt_tm))
	drec->patients[cnt].gender = uar_get_code_display(p.sex_cd)
	drec->patients[cnt].patient_class = uar_get_code_display(e.encntr_class_cd)
	drec->patients[cnt].admission_date = format(e.reg_dt_tm, "MM/DD/YYYY;;Q")
	drec->patients[cnt].status = uar_get_code_display(e.active_status_cd)
	drec->patients[cnt].fin = ea_fin.alias
	drec->patients[cnt].mrn = ea_mrn.alias

FOOT REPORT
	drec->patientCnt = cnt

WITH NOCOUNTER, TIME = 60

; Output JSON to MPage framework
SET _memory_reply_string = cnvtrectojson(drec)

; Debug output
call echo(build("Program Version: ", PROGRAM_VERSION))
call echo(build("Patient Count: ", cnvtstring(cnt)))
call echorecord(drec)

end
go
