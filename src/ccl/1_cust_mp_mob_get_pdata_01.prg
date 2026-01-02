drop program 1_cust_mp_mob_get_pdata_01 go
create program 1_cust_mp_mob_get_pdata_01

;===============================================================================
; Program: 1_cust_mp_mob_get_pdata_01.prg
; Version: v01
; Build Date: 2025-12-15
; Project: Mobility Dashboard
;
; Features: demographics-only, patient-list-integration, date-filtering
;
; Description: Get patient demographics with date filtering support
;              Extends generic template with temporal query capability
;              Derived from er-tracking-dashboard-template v1.0.0
;              Uses Bob Ross uCern pattern for date parameters
;
; Date Filtering:
;   - SELECTED_DATE parameter: CURDATE (reserved word) or mmddyyyy integer
;   - date_start: Midnight of selected date (00:00:00)
;   - date_end: End of day (23:59:59)
;   - Future use: clinical_event queries filtered by event_dt_tm
;===============================================================================

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = 0
	, "Selected Date" = CURDATE

with OUTDEV, ENCOUNTER_IDS, SELECTED_DATE

; Version tracking constants
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v01"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2025-12-15"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("demographics-only,patient-list-integration,date-filtering"), PROTECT

; Parse encounter IDs from prompt parameter (MUST be declared before date logic)
DECLARE encntr_list = vc WITH NOCONSTANT("")

; Simple record structure - DEMOGRAPHICS ONLY
free record drec
record drec(
	1 patientCnt = i4
	1 program_version = vc
	1 program_build_date = vc
	1 selected_date = vc          ; Echoes back the date filter for debugging
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

; Set encounter list from prompt parameter
SET encntr_list = $ENCOUNTER_IDS

; ==============================================================================
; Date Filtering Variables (Bob Ross uCern Pattern)
; ==============================================================================
; Purpose: Enable temporal queries for clinical events (mobility assessments,
;          interventions, distances). Currently used for future feature support.
;
; JavaScript passes either:
;   - CURDATE → Use current date (CCL reserved word as integer)
;   - 12152025 → Specific date in mmddyyyy format (integer)
;
; Filter window: midnight (00:00:00) to end of day (23:59:59)
;   Example: event_dt_tm BETWEEN 12/15/2025 00:00:00 AND 12/15/2025 23:59:59
; ==============================================================================

; Parse the SELECTED_DATE parameter (integer format)
; No DECLARE needed - let CCL infer type from assignment (Bob Ross pattern)
if($SELECTED_DATE = CURDATE)
	set filter_date = CURDATE
else
	set filter_date = cnvtdate($SELECTED_DATE)  ; Convert mmddyyyy integer to date
endif

; Calculate date range (midnight to end of day)
set date_start = CNVTDATETIME(filter_date, 0)        ; Midnight 00:00:00
set date_end = CNVTDATETIME(filter_date, 235959)     ; End of day 23:59:59

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
	drec->selected_date = format(filter_date, "MM/DD/YYYY;;Q")

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
call echo(build("Selected Date: ", format(filter_date, "MM/DD/YYYY;;Q")))
call echo(build("Date Range: ", format(date_start, "@SHORTDATETIME"), " to ", format(date_end, "@SHORTDATETIME")))
call echo(build("Patient Count: ", cnvtstring(drec->patientCnt)))
call echorecord(drec)

end
go
