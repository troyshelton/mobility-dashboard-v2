drop program 1_cust_mp_mob_get_pdata_03 go
create program 1_cust_mp_mob_get_pdata_03

;===============================================================================
; Program: 1_cust_mp_mob_get_pdata_03.prg
; Version: v03
; Build Date: 2025-12-15
; Project: Mobility Dashboard
;
; Features: demographics, patient-list-integration, date-filtering, 5-clinical-events
;
; Description: Get patient demographics + 5 clinical events with date filtering
;              Uses TWO SELECT statements: (1) Demographics, (2) Clinical Events
;              Derived from er-tracking-dashboard-template v1.0.0
;              Uses Bob Ross uCern pattern for date parameters
;
; Date Filtering:
;   - SELECTED_DATE parameter: CURDATE (reserved word) or mmddyyyy integer
;   - date_start: Midnight of selected date (00:00:00)
;   - date_end: End of day (23:59:59)
;   - Clinical events filtered by event_end_dt_tm within date range
;
; Clinical Events (Most Recent Per Event Type):
;   1. Morse Fall Risk Score (3612336.00)
;   2. Call Light & Personal Items Within Reach (29672179.00)
;   3. IV Sites Assessed (45431765.00)
;   4. SCDs Applied (10288133561.00)
;   5. Psychosocial and Safety Needs Addressed (29672693.00)
;===============================================================================

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = ""
	, "Selected Date" = CURDATE

with OUTDEV, ENCOUNTER_IDS, SELECTED_DATE

; Version tracking constants
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v03"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2025-12-15"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("demographics,patient-list-integration,date-filtering,5-clinical-events,two-query"), PROTECT

; Parse encounter IDs from prompt parameter
DECLARE encntr_list = vc WITH NOCONSTANT("")

; Record structure - DEMOGRAPHICS + 5 CLINICAL EVENTS (date-filtered)
free record drec
record drec(
	1 patientCnt = i4
	1 program_version = vc
	1 program_build_date = vc
	1 selected_date = vc
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
		; Clinical Events (date-filtered, most recent per event type)
		2 morse_score = vc
		2 morse_event_dt_tm = vc
		2 call_light_in_reach = vc
		2 call_light_dt_tm = vc
		2 iv_sites_assessed = vc
		2 iv_sites_dt_tm = vc
		2 scds_applied = vc
		2 scds_dt_tm = vc
		2 safety_needs_addressed = vc
		2 safety_needs_dt_tm = vc
)

; Set encounter list from prompt parameter
SET encntr_list = $ENCOUNTER_IDS

; ==============================================================================
; Date Filtering Variables (Bob Ross uCern Pattern)
; ==============================================================================
; Parse the SELECTED_DATE parameter (integer format)
if($SELECTED_DATE = CURDATE)
	set filter_date = CURDATE
else
	set filter_date = cnvtdate($SELECTED_DATE)
endif

; Note: Date range calculated inline in WHERE clauses
; Oracle cannot accept dq8 variables in WHERE (ORA-00932 error)

;===============================================================================
; SELECT 1: Get Demographics (FIN, MRN)
;===============================================================================
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

	; Populate demographics
	drec->patients[cnt].person_id = p.person_id
	drec->patients[cnt].encntr_id = e.encntr_id
	drec->patients[cnt].person_name = p.name_full_formatted
	drec->patients[cnt].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	drec->patients[cnt].roomBed = build(uar_get_code_display(e.loc_room_cd), "-", uar_get_code_display(e.loc_bed_cd))
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

;===============================================================================
; SELECT 2: Get Clinical Events (Date-Filtered) - DUMMYT Pattern
;===============================================================================
SELECT INTO "NL:"
FROM
	(DUMMYT D1 WITH SEQ = SIZE(drec->patients, 5))
	, clinical_event ce

PLAN D1
	WHERE drec->patientCnt > 0

JOIN ce
	WHERE ce.encntr_id = drec->patients[d1.seq].encntr_id
	AND ce.event_cd IN (
		3612336.00,      /* Morse Fall Risk Score */
		29672179.00,     /* Call Light & Personal Items Within Reach */
		45431765.00,     /* IV Sites Assessed */
		10288133561.00,  /* SCDs Applied */
		29672693.00      /* Psychosocial and Safety Needs Addressed */
	)
	AND ce.event_end_dt_tm >= CNVTDATETIME(filter_date, 0)        /* Midnight */
	AND ce.event_end_dt_tm <= CNVTDATETIME(filter_date, 235959)   /* End of day */
	AND ce.valid_until_dt_tm >= SYSDATE
	AND ce.result_status_cd = 25.00  /* Auth */

ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm ASC

HEAD ce.encntr_id
	; New encounter - reset tracking
	null

HEAD ce.event_cd
	; New event type - reset tracking
	event_captured = 0

DETAIL
	; Update clinical event fields - last value per event_cd wins (most recent)
	if(ce.event_cd = 3612336.00)
		; Morse Fall Risk Score
		drec->patients[d1.seq].morse_score = ce.result_val
		drec->patients[d1.seq].morse_event_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	elseif(ce.event_cd = 29672179.00)
		; Call Light & Personal Items Within Reach
		drec->patients[d1.seq].call_light_in_reach = ce.result_val
		drec->patients[d1.seq].call_light_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	elseif(ce.event_cd = 45431765.00)
		; IV Sites Assessed
		drec->patients[d1.seq].iv_sites_assessed = ce.result_val
		drec->patients[d1.seq].iv_sites_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	elseif(ce.event_cd = 10288133561.00)
		; SCDs Applied
		drec->patients[d1.seq].scds_applied = ce.result_val
		drec->patients[d1.seq].scds_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	elseif(ce.event_cd = 29672693.00)
		; Psychosocial and Safety Needs Addressed
		drec->patients[d1.seq].safety_needs_addressed = ce.result_val
		drec->patients[d1.seq].safety_needs_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

; Output JSON to MPage framework
SET _memory_reply_string = cnvtrectojson(drec)

; Debug output
call echo(build("Program Version: ", PROGRAM_VERSION))
call echo(build("Selected Date: ", format(filter_date, "MM/DD/YYYY;;Q")))
call echo(build("Date Range: ", format(CNVTDATETIME(filter_date, 0), "@SHORTDATETIME"), " to ", format(CNVTDATETIME(filter_date, 235959), "@SHORTDATETIME")))
call echo(build("Patient Count: ", cnvtstring(drec->patientCnt)))
call echorecord(drec)

end
go
