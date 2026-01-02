drop program 1_cust_mp_mob_get_pdata go
create program 1_cust_mp_mob_get_pdata

;===============================================================================
; Program: 1_cust_mp_mob_get_pdata_05.prg
; Version: v05
; Build Date: 2026-01-02
; Project: Mobility Dashboard v2.0.0-mobility
; Issue: #3 - Side Panel Historical Metric View
;
; Features: demographics, patient-list-integration, 7-day-lookback, 5-clinical-events, historical-arrays
;
; Description: Get patient demographics + 5 clinical events with 7-day historical data
;              Uses TWO SELECT statements: (1) Demographics, (2) Clinical Events
;              Returns BOTH current values (for table) AND 7-day history (for side panel)
;              Pattern: Clinical Leader Organizer (Cerner standard)
;
; Date Filtering:
;   - 30-day lookback from current date/time (testing: broader window for data entry)
;   - Uses: cnvtdatetime(curdate - 30, 0) pattern (CCL_COMMON_PATTERNS.md)
;   - Clinical events filtered by event_end_dt_tm >= 30 days ago
;
; Clinical Events (Current + 7-Day History):
;   1. Morse Fall Risk Score (3612336.00)
;   2. Call Light & Personal Items Within Reach (29672179.00)
;   3. IV Sites Assessed (45431765.00)
;   4. SCDs Applied (10288133561.00)
;   5. Psychosocial and Safety Needs Addressed (29672693.00)
;
; Record Structure Enhancement:
;   - Each metric has TWO fields:
;     * Current value (e.g., morse_score) - for table display
;     * Historical array (e.g., morse_history[*]) - for side panel
;   - Historical arrays contain ALL entries from past 30 days (DESC order)
;
; Changelog v05:
;   - ADDED: Historical array structures for all 5 clinical events
;   - CHANGED: Date filter to 30-day lookback (testing: broader data window)
;   - CHANGED: ORDER BY to DESC (most recent first in arrays)
;   - CHANGED: DETAIL section populates historical arrays (not just latest)
;   - Based on v04 with side panel enhancements
;   - NOTE: 30-day period for testing flexibility (clinicians can chart test data anytime in past month)
;===============================================================================

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = 0
	, "Lookback Days" = 30

with OUTDEV, ENCOUNTER_IDS, LOOKBACK_DAYS

; Version tracking constants
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v05"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2026-01-02"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("demographics,patient-list-integration,7-day-lookback,5-clinical-events,historical-arrays,side-panel,two-query,multi-encounter"), PROTECT

; Record structure - DEMOGRAPHICS + 5 CLINICAL EVENTS (date-filtered)
free record drec
record drec(
	1 patientCnt = i4
	1 program_version = vc
	1 program_build_date = vc
	1 selected_date = vc
	1 lookback_days = i4
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
		; Clinical Events - Current Values (for table display)
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
		; Historical Arrays - 7-Day History (for side panel)
		2 morse_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 call_light_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 iv_sites_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 scds_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 safety_needs_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
)

; ==============================================================================
; 30-Day Lookback - Fixed Time Range (No Date Parameter)
; ==============================================================================
; Always shows last 30 days from current time (no user-selected date)
; Historical data always relative to NOW for side panel display
; Testing: Broader window allows clinicians to chart test data flexibly

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
	WHERE e.encntr_id = $ENCOUNTER_IDS
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
	drec->selected_date = format(curdate, "MM/DD/YYYY;;Q")
	drec->lookback_days = $LOOKBACK_DAYS

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
	AND ce.event_end_dt_tm >= cnvtdatetime(curdate - $LOOKBACK_DAYS, 0)  /* Dynamic lookback period */
	AND ce.valid_until_dt_tm >= SYSDATE
	AND ce.result_status_cd = 25.00  /* Auth */

ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC  /* Most recent first for historical arrays */

HEAD ce.encntr_id
	; New encounter - reset tracking
	null

HEAD ce.event_cd
	; New event type - reset counter (resets for each event_cd)
	hist_cnt = 0
	first_entry = 1

DETAIL
	; Increment counter for each entry
	hist_cnt = (hist_cnt + 1)

	; Populate historical arrays - ALL entries from past 7 days
	if(ce.event_cd = 3612336.00)
		; Morse Fall Risk Score
		stat = alterlist(drec->patients[d1.seq].morse_history, hist_cnt)
		drec->patients[d1.seq].morse_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].morse_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].morse_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		; First entry (most recent) = current value for table
		if(first_entry = 1)
			drec->patients[d1.seq].morse_score = ce.result_val
			drec->patients[d1.seq].morse_event_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = 29672179.00)
		; Call Light & Personal Items Within Reach
		stat = alterlist(drec->patients[d1.seq].call_light_history, hist_cnt)
		drec->patients[d1.seq].call_light_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].call_light_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].call_light_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		if(first_entry = 1)
			drec->patients[d1.seq].call_light_in_reach = ce.result_val
			drec->patients[d1.seq].call_light_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = 45431765.00)
		; IV Sites Assessed
		stat = alterlist(drec->patients[d1.seq].iv_sites_history, hist_cnt)
		drec->patients[d1.seq].iv_sites_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].iv_sites_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].iv_sites_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		if(first_entry = 1)
			drec->patients[d1.seq].iv_sites_assessed = ce.result_val
			drec->patients[d1.seq].iv_sites_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = 10288133561.00)
		; SCDs Applied
		stat = alterlist(drec->patients[d1.seq].scds_history, hist_cnt)
		drec->patients[d1.seq].scds_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].scds_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].scds_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		if(first_entry = 1)
			drec->patients[d1.seq].scds_applied = ce.result_val
			drec->patients[d1.seq].scds_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = 29672693.00)
		; Psychosocial and Safety Needs Addressed
		stat = alterlist(drec->patients[d1.seq].safety_needs_history, hist_cnt)
		drec->patients[d1.seq].safety_needs_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].safety_needs_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].safety_needs_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		if(first_entry = 1)
			drec->patients[d1.seq].safety_needs_addressed = ce.result_val
			drec->patients[d1.seq].safety_needs_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif
	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

; Output JSON to MPage framework
SET _memory_reply_string = cnvtrectojson(drec)

; Debug output
call echo(build("Program Version: ", PROGRAM_VERSION))
call echo(build("Lookback Period: ", cnvtstring($LOOKBACK_DAYS), " days (", format(cnvtdatetime(curdate - $LOOKBACK_DAYS, 0), "@SHORTDATETIME"), " to ", format(cnvtdatetime(curdate, curtime3), "@SHORTDATETIME"), ")"))
call echo(build("Patient Count: ", cnvtstring(drec->patientCnt)))
call echorecord(drec)

end
go
