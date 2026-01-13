drop program 1_cust_mp_mob_get_pdata go
create program 1_cust_mp_mob_get_pdata

;===============================================================================
; Program: 1_cust_mp_mob_get_pdata_13.prg
; Version: v13
; Build Date: 2026-01-12
; Project: Mobility Dashboard v2.8.0-mobility
; Issue: #20/#21 - Clinician Feedback Enhancements + PT/OT Eval Links
;
; Features: demographics, patient-list-integration, 30-day-lookback, 11-clinical-events, activity-precautions, historical-arrays, bmat-parsing, baseline-mobility, toileting-method, pt-ot-transfers, ambulation-distance, ambulation-personnel, powerform-discrete-grid, order-detection, powerform-activity-links
;
; Description: Get patient demographics + 11 clinical events with 30-day historical data
;              Uses SIX SELECT statements: (1) Demographics, (2) Clinical Events, (3) BMAT,
;              (4) Activity Precautions, (5) PT Transfer, (6) OT Transfer
;              Returns BOTH current values (for table) AND 30-day history (for side panel)
;              Pattern: Clinical Leader Organizer (Cerner standard) + PowerForm Discrete Grid Navigation
;
; Changelog v13:
;   - ADDED: activity_id to PT/OT transfer history arrays (Issue #21)
;   - ADDED: dcp_forms_activity_id for PowerForm navigation links
;   - Purpose: Allow clicking PT/OT history entries to open original PowerForm in view mode
;   - Pattern: PowerFormLauncher.launchPowerForm(personId, encntrId, 0, activityId, 1)
;   - Based on v12 with PowerForm activity ID tracking
;
; Date Filtering:
;   - 30-day lookback from current date/time (testing: broader window for data entry)
;   - Uses: cnvtdatetime(curdate - $LOOKBACK_DAYS, 0) pattern (CCL_COMMON_PATTERNS.md)
;   - Clinical events filtered by event_end_dt_tm >= 30 days ago
;
; Clinical Events (Current + 30-Day History):
;   1. Morse Fall Risk Score (3612336.00)
;   2. Call Light & Personal Items Within Reach (29672179.00)
;   3. IV Sites Assessed (45431765.00)
;   4. SCDs Applied (10288133561.00)
;   5. Psychosocial and Safety Needs Addressed (29672693.00)
;   6. BMAT (Brief Mobility Assessment Tool) - Levels 1-4
;      - BMAT Sit and Shake (9597986177.00)
;      - BMAT Stretch and Point (9597989063.00)
;      - BMAT Stand (9597989705.00)
;      - BMAT Walk (9597990693.00)
;   7. Baseline Mobility - Levels 1-4
;      - PowerForm: "Baseline Functional Assessment"
;      - Event: "Baseline Mobility" (8339925023.00)
;      - Format: "(Level X) description"
;      - Example: "(Level 4) No limitation with walking"
;   8. Toileting Method - Text
;      - I-View Documentation: "Toileting Offered ADL"
;      - Event: "Toileting Offered" (279864735.00)
;      - Format: Comma-separated methods or single value
;      - Examples: "Bedside commode, Independent, Assisted to BR, Using Bedpan, Using Urinal"
;                  "Sleeping"
;
; BMAT Parsing Logic:
;   - Query all 4 BMAT test event codes
;   - Extract mobility level (1-4) from result_val text
;   - Examples: "Fail - Patient is Mobility Level 3" → 3
;               "Pass, move on to Mobility Level 4" → 4
;
; Record Structure Enhancement:
;   - Each metric has TWO fields:
;     * Current value (e.g., morse_score, bmat_level) - for table display
;     * Historical array (e.g., morse_history[*], bmat_history[*]) - for side panel
;   - Historical arrays contain ALL entries from past 30 days (DESC order)
;
; Changelog v10:
;   - ADDED: PT Transfer as 9th clinical event (Issue #10)
;   - ADDED: OT Transfer as 10th clinical event (Issue #11)
;   - ADDED: PowerForm discrete grid navigation pattern
;   - ADDED: SELECT 5 for PT "Transfer Bed to and From Chair Rehab" from PT Acute Evaluation
;   - ADDED: SELECT 6 for OT "Transfer Bed to and From Chair Rehab" from OT Acute Evaluation
;   - ADDED: SELECT 7 for PT transfer comments (ce_event_note + long_blob)
;   - ADDED: SELECT 8 for OT transfer comments (ce_event_note + long_blob)
;   - ADDED: pt_transfer_assist, pt_transfer_comment, pt_transfer_history[] to record structure
;   - ADDED: ot_transfer_assist, ot_transfer_comment, ot_transfer_history[] to record structure
;   - ADDED: Tables: dcp_forms_activity, dcp_forms_activity_comp, ce_event_note, long_blob
;   - ADDED: Comment handling: compression, RTF removal, ocf_blob cleanup
;   - Pattern: Same event_cd (4348328.00) distinguished by PowerForm name
;   - Based on v09 with PT/OT PowerForm enhancements
;
; Changelog v09:
;   - ADDED: Toileting Method as 8th clinical event (Issue #9)
;   - ADDED: Query for "Toileting Offered ADL" from I-View documentation
;   - ADDED: No parsing needed - store full text from result_val
;   - ADDED: toileting_method and toileting_history[] to record structure
;   - ADDED: Event code 279864735.00 to SELECT 2
;   - Based on v08 with toileting method enhancements
;
; Changelog v08:
;   - ADDED: Baseline Mobility as 7th clinical event (Issue #8)
;   - ADDED: Query for "Baseline Mobility" event from "Baseline Functional Assessment" PowerForm
;   - ADDED: Parsing logic to extract level from "(Level X) description" format
;   - ADDED: baseline_level and baseline_history[] to record structure
;   - ADDED: Event code 8339925023.00 to SELECT 2
;   - Based on v07 with baseline mobility enhancements
;
; Changelog v07:
;   - ADDED: Activity Precautions as side panel metric (Issue #7)
;   - ADDED: SELECT 4 for order detection using UAR_GET_CODE_BY
;   - Based on v06 with activity precautions
;===============================================================================

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter IDs" = 0
	, "Lookback Days" = 30

with OUTDEV, ENCOUNTER_IDS, LOOKBACK_DAYS

; Version tracking constants
DECLARE PROGRAM_VERSION = vc WITH CONSTANT("v13"), PROTECT
DECLARE BUILD_DATE = vc WITH CONSTANT("2026-01-12"), PROTECT
DECLARE PROGRAM_FEATURES = vc WITH CONSTANT("demographics,patient-list-integration,30-day-lookback,11-clinical-events,activity-precautions,historical-arrays,side-panel,bmat-parsing,baseline-mobility,toileting-method,pt-ot-transfers,ambulation-distance,ambulation-personnel,powerform-discrete-grid,order-detection,six-select,powerform-activity-links"), PROTECT

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
		2 bmat_level = vc
		2 bmat_dt_tm = vc
		; Historical Arrays - 30-Day History (for side panel)
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
		2 bmat_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 baseline_level = vc
		2 baseline_dt_tm = vc
		2 baseline_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		2 toileting_method = vc
		2 toileting_dt_tm = vc
		2 toileting_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
		; PT Transfer (Issue #10 - PowerForm Discrete Grid)
		2 pt_transfer_assist = vc
		2 pt_transfer_dt_tm = vc
		2 pt_transfer_comment = vc
		2 pt_transfer_history[*]
			3 value = vc
			3 comment = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
			3 activity_id = f8        ; v13: dcp_forms_activity_id for PowerForm link
		; OT Transfer (Issue #11 - PowerForm Discrete Grid)
		2 ot_transfer_assist = vc
		2 ot_transfer_dt_tm = vc
		2 ot_transfer_comment = vc
		2 ot_transfer_history[*]
			3 value = vc
			3 comment = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
			3 activity_id = f8        ; v13: dcp_forms_activity_id for PowerForm link
		; Ambulation Distance (Issue #16 - Numeric Clinical Event)
		; v12: Added performed_by and performed_position for personnel tracking (Issue #20)
		2 ambulation_distance = vc
		2 ambulation_dt_tm = vc
		2 ambulation_performed_by = vc
		2 ambulation_performed_position = vc
		2 ambulation_history[*]
			3 value = vc
			3 event_dt_tm = dq8
			3 datetime_display = vc
			3 performed_by = vc
			3 performed_position = vc
		; Activity Precautions (Issue #7)
		2 active_precaution_count = i4
		2 activity_precautions[*]
			3 precaution_name = vc
			3 order_detail = vc
			3 order_dt_tm = dq8
			3 datetime_display = vc
			3 order_status = vc
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
	, prsnl p

PLAN D1
	WHERE drec->patientCnt > 0

JOIN ce
	WHERE ce.encntr_id = drec->patients[d1.seq].encntr_id
	AND ce.event_cd IN (
		value(uar_get_code_by("DISPLAY", 72, "Morse Fall Score")),  /* DISPLAY = "Morse Fall Score", DESCRIPTION = "Morse Fall Risk Score" */
		value(uar_get_code_by("DISPLAY", 72, "Call Light & Personal Items Within Reach")),
		value(uar_get_code_by("DISPLAY", 72, "IV Sites Assessed")),
		value(uar_get_code_by("DISPLAY", 72, "SCDs Applied")),
		value(uar_get_code_by("DISPLAY", 72, "Psychosocial and Safety Needs Addressed")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Sit and Shake")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Stretch and Point")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Stand")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Walk")),
		value(uar_get_code_by("DISPLAY", 72, "Baseline Mobility")),
		value(uar_get_code_by("DISPLAY", 72, "Toileting Offered ADL")),
		269481201.00  /* Ambulation Distance - hardcoded (not unique) */
	)
	AND ce.event_end_dt_tm >= cnvtdatetime(curdate - $LOOKBACK_DAYS, 0)  /* Dynamic lookback period */
	AND ce.valid_until_dt_tm >= SYSDATE
	AND ce.result_status_cd = 25.00  /* Auth */

; v12: Join to prsnl table for personnel tracking (Issue #20 - Ambulation performer)
JOIN p
	WHERE p.person_id = outerjoin(ce.performed_prsnl_id)
	AND p.active_ind = outerjoin(1)

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

	elseif(ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Baseline Mobility")))
		; Baseline Mobility - PowerForm "Baseline Functional Assessment"
		; Parse "(Level X) description" format
		; Example: "(Level 4) No limitation with walking"
		;
		; EDGE CASE - PENDING CLINICAL VALIDATION:
		; Baseline is typically charted once at admission, but edge cases need verification:
		; - What if charted on wrong patient and corrected?
		; - What if modified after authentication?
		; - Should we show only most recent authenticated, or all entries?
		; Current implementation: Stores ALL entries in 30-day window, shows most recent in table
		; Action: Validate with clinical team (Courtney Friend, MOT, OTR/L)
		;
		stat = alterlist(drec->patients[d1.seq].baseline_history, hist_cnt)

		; Store full text for side panel display
		drec->patients[d1.seq].baseline_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].baseline_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].baseline_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")

		; First entry (most recent) = parse level for table display
		if(first_entry = 1)
			; Extract level number from "(Level X)" pattern
			if(findstring("(Level 1)", ce.result_val) > 0)
				drec->patients[d1.seq].baseline_level = "1"
			elseif(findstring("(Level 2)", ce.result_val) > 0)
				drec->patients[d1.seq].baseline_level = "2"
			elseif(findstring("(Level 3)", ce.result_val) > 0)
				drec->patients[d1.seq].baseline_level = "3"
			elseif(findstring("(Level 4)", ce.result_val) > 0)
				drec->patients[d1.seq].baseline_level = "4"
			endif
			drec->patients[d1.seq].baseline_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Toileting Offered ADL")))
		; Toileting Method - I-View Documentation "Toileting Offered ADL"
		; Store full text (no parsing needed)
		; Format: Comma-separated methods or single value
		; Examples: "Bedside commode, Independent, Assisted to BR, Using Bedpan, Using Urinal"
		;           "Sleeping"
		stat = alterlist(drec->patients[d1.seq].toileting_history, hist_cnt)

		; Store full text for both table and side panel
		drec->patients[d1.seq].toileting_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].toileting_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].toileting_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")

		; First entry (most recent) = current value for table
		if(first_entry = 1)
			drec->patients[d1.seq].toileting_method = ce.result_val
			drec->patients[d1.seq].toileting_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			first_entry = 0
		endif

	elseif(ce.event_cd = 269481201.00)  /* Ambulation Distance - hardcoded (not unique) */
		; Ambulation Distance - Numeric clinical event with units (feet)
		; Store full text (includes units: "100 ft")
		; v12: Added personnel tracking (Issue #20 - who documented ambulation)
		stat = alterlist(drec->patients[d1.seq].ambulation_history, hist_cnt)

		drec->patients[d1.seq].ambulation_history[hist_cnt].value = ce.result_val
		drec->patients[d1.seq].ambulation_history[hist_cnt].event_dt_tm = ce.event_end_dt_tm
		drec->patients[d1.seq].ambulation_history[hist_cnt].datetime_display = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		; v12: Store personnel who documented (PT, OT, Nursing, Cardiac Rehab)
		drec->patients[d1.seq].ambulation_history[hist_cnt].performed_by = p.name_full_formatted
		drec->patients[d1.seq].ambulation_history[hist_cnt].performed_position = uar_get_code_display(p.position_cd)

		; First entry (most recent) = current value for table
		if(first_entry = 1)
			drec->patients[d1.seq].ambulation_distance = ce.result_val
			drec->patients[d1.seq].ambulation_dt_tm = format(ce.event_end_dt_tm, "MM/DD/YYYY HH:MM;;Q")
			; v12: Current personnel for table display
			drec->patients[d1.seq].ambulation_performed_by = p.name_full_formatted
			drec->patients[d1.seq].ambulation_performed_position = uar_get_code_display(p.position_cd)
			first_entry = 0
		endif

	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

;===============================================================================
; SELECT 3: Get BMAT Assessments (Complex Parsing) - DUMMYT Pattern
;===============================================================================
; BMAT requires separate query because 4 events must be grouped by session
; to determine single mobility level per assessment
SELECT INTO "NL:"
FROM
	(DUMMYT D1 WITH SEQ = SIZE(drec->patients, 5))
	, clinical_event ce

PLAN D1
	WHERE drec->patientCnt > 0

JOIN ce
	WHERE ce.encntr_id = drec->patients[d1.seq].encntr_id
	AND ce.event_cd IN (
		value(uar_get_code_by("DISPLAY", 72, "BMAT Sit and Shake")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Stretch and Point")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Stand")),
		value(uar_get_code_by("DISPLAY", 72, "BMAT Walk"))
	)
	AND ce.event_end_dt_tm >= cnvtdatetime(curdate - $LOOKBACK_DAYS, 0)
	AND ce.valid_until_dt_tm >= SYSDATE
	AND ce.result_status_cd = 25.00  /* Auth */

ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC, ce.event_cd

HEAD ce.encntr_id
	; New patient - reset counter
	bmat_hist_cnt = 0

HEAD ce.event_end_dt_tm
	; New BMAT assessment session - will determine level at FOOT
	bmat_level_str = ""
	session_dt_tm = ce.event_end_dt_tm

DETAIL
	; Find highest mobility level mentioned across all 4 test events in this session
	if(findstring("Mobility Level 4", ce.result_val) > 0)
		bmat_level_str = "4"
	elseif(findstring("Mobility Level 3", ce.result_val) > 0 AND bmat_level_str < "3")
		bmat_level_str = "3"
	elseif(findstring("Mobility Level 2", ce.result_val) > 0 AND bmat_level_str < "2")
		bmat_level_str = "2"
	elseif(findstring("Mobility Level 1", ce.result_val) > 0 AND bmat_level_str < "1")
		bmat_level_str = "1"
	endif

FOOT ce.event_end_dt_tm
	; End of assessment session - store ONE entry for this session
	if(bmat_level_str > "")
		bmat_hist_cnt = (bmat_hist_cnt + 1)
		stat = alterlist(drec->patients[d1.seq].bmat_history, bmat_hist_cnt)
		drec->patients[d1.seq].bmat_history[bmat_hist_cnt].value = bmat_level_str
		drec->patients[d1.seq].bmat_history[bmat_hist_cnt].event_dt_tm = session_dt_tm
		drec->patients[d1.seq].bmat_history[bmat_hist_cnt].datetime_display = format(session_dt_tm, "MM/DD/YYYY HH:MM;;Q")

		; First session (most recent) = current value for table
		if(bmat_hist_cnt = 1)
			drec->patients[d1.seq].bmat_level = bmat_level_str
			drec->patients[d1.seq].bmat_dt_tm = format(session_dt_tm, "MM/DD/YYYY HH:MM;;Q")
		endif
	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

;===============================================================================
; SELECT 4: Get Activity Precautions (Order Detection) - DUMMYT Pattern
;===============================================================================
; Query active Patient Care orders for activity precautions
SELECT INTO "NL:"
FROM
	(DUMMYT D1 WITH SEQ = SIZE(drec->patients, 5))
	, orders o

PLAN D1
	WHERE drec->patientCnt > 0

JOIN o
	WHERE o.encntr_id = drec->patients[d1.seq].encntr_id
	AND o.catalog_type_cd = value(uar_get_code_by("DISPLAY", 6000, "Patient Care"))
	AND o.order_status_cd = 2550.00  /* Ordered */
	AND o.catalog_cd IN (
		value(uar_get_code_by("DISPLAY", 200, "Weight Bearing Status, Lower Extremity")),
		value(uar_get_code_by("DISPLAY", 200, "Weight Bearing Status, Upper Extremity")),
		value(uar_get_code_by("DISPLAY", 200, "Hip Precautions Anterior Approach")),
		value(uar_get_code_by("DISPLAY", 200, "Hip Precautions Posterior Approach")),
		value(uar_get_code_by("DISPLAY", 200, "Thoracolumbar Spine Restrictions")),
		value(uar_get_code_by("DISPLAY", 200, "Cervical Spine Restrictions")),
		value(uar_get_code_by("DISPLAY", 200, "Miami J Cervical Collar"))
		; TODO (Issue #7): Add when ordered in CERT - Code set 200
		; value(uar_get_code_by("DISPLAY", 200, "TLSO Brace Activity")),
		; value(uar_get_code_by("DISPLAY", 200, "LSO Brace Activity"))
	)

ORDER BY o.encntr_id, o.orig_order_dt_tm DESC

HEAD o.encntr_id
	; New patient - reset counter
	precaution_cnt = 0

DETAIL
	; Add each active precaution to array
	precaution_cnt = (precaution_cnt + 1)
	stat = alterlist(drec->patients[d1.seq].activity_precautions, precaution_cnt)
	drec->patients[d1.seq].activity_precautions[precaution_cnt].precaution_name = o.order_mnemonic
	drec->patients[d1.seq].activity_precautions[precaution_cnt].order_detail = o.clinical_display_line
	drec->patients[d1.seq].activity_precautions[precaution_cnt].order_dt_tm = o.orig_order_dt_tm
	drec->patients[d1.seq].activity_precautions[precaution_cnt].datetime_display = format(o.orig_order_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	drec->patients[d1.seq].activity_precautions[precaution_cnt].order_status = uar_get_code_display(o.order_status_cd)

FOOT o.encntr_id
	; Store count for table display
	drec->patients[d1.seq].active_precaution_count = precaution_cnt

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

;===============================================================================
; SELECT 5: PT Transfer Assist Level (PowerForm Discrete Grid)
;===============================================================================
; PowerForm: "PT Acute Evaluation" → Mobility Section → Discrete Grid
; Event: "Transfer Bed to and From Chair Rehab" (4348328.00)
; Pattern: dcp_forms_activity → dcp_forms_activity_comp → clinical_event (3 levels)
;===============================================================================
SELECT INTO "NL:"
FROM
	(DUMMYT D1 WITH SEQ = SIZE(drec->patients, 5))
	, dcp_forms_activity dfa_pt
	, dcp_forms_activity_comp dfc_pt
	, clinical_event c1_pt
	, clinical_event c2_pt
	, clinical_event c3_pt
	, clinical_event c4_pt

PLAN D1
	WHERE drec->patientCnt > 0

JOIN dfa_pt
	WHERE dfa_pt.person_id = drec->patients[d1.seq].person_id
	AND dfa_pt.encntr_id = drec->patients[d1.seq].encntr_id
	AND dfa_pt.dcp_forms_ref_id = (
		SELECT dcp_forms_ref_id
		FROM dcp_forms_ref
		WHERE description = "PT Acute Evaluation"
		AND active_ind = 1
	)
	AND dfa_pt.active_ind = 1
	AND dfa_pt.form_status_cd IN (25.00, 34.00, 35.00)  /* Auth, Modified */
	AND dfa_pt.form_dt_tm >= cnvtdatetime(curdate - $LOOKBACK_DAYS, 0)

JOIN dfc_pt
	WHERE dfc_pt.dcp_forms_activity_id = dfa_pt.dcp_forms_activity_id
	AND dfc_pt.component_cd = 10891.00  /* PRIMARY EVENT_ID */
	AND dfc_pt.parent_entity_name = "CLINICAL_EVENT"

JOIN c1_pt
	WHERE c1_pt.event_id = dfc_pt.parent_entity_id
	AND c1_pt.valid_until_dt_tm > SYSDATE
	AND c1_pt.view_level = 1

JOIN c2_pt
	WHERE c2_pt.parent_event_id = c1_pt.event_id
	AND c2_pt.valid_until_dt_tm > SYSDATE
	AND c2_pt.event_title_text = "Mobility"

JOIN c3_pt
	WHERE c3_pt.parent_event_id = c2_pt.event_id
	AND c3_pt.valid_until_dt_tm > SYSDATE
	AND c3_pt.event_title_text = "Discrete Grid"
	AND c3_pt.event_cd = 2214520.00  /* Mobility Grid */

JOIN c4_pt
	WHERE c4_pt.parent_event_id = c3_pt.event_id
	AND c4_pt.event_cd = 4348328.00  /* Transfer Bed to and From Chair Rehab */
	AND c4_pt.valid_until_dt_tm > SYSDATE
	AND c4_pt.view_level = 1
	AND c4_pt.result_status_cd IN (25, 34, 35)

ORDER BY c4_pt.encntr_id, dfa_pt.form_dt_tm DESC

HEAD c4_pt.encntr_id
	pt_hist_cnt = 0

DETAIL
	pt_hist_cnt = pt_hist_cnt + 1
	stat = alterlist(drec->patients[d1.seq].pt_transfer_history, pt_hist_cnt)

	drec->patients[d1.seq].pt_transfer_history[pt_hist_cnt].value = c4_pt.result_val
	drec->patients[d1.seq].pt_transfer_history[pt_hist_cnt].event_dt_tm = dfa_pt.form_dt_tm
	drec->patients[d1.seq].pt_transfer_history[pt_hist_cnt].datetime_display = format(dfa_pt.form_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	drec->patients[d1.seq].pt_transfer_history[pt_hist_cnt].comment = ""  /* Populated in SELECT 7 */
	drec->patients[d1.seq].pt_transfer_history[pt_hist_cnt].activity_id = dfa_pt.dcp_forms_activity_id  ; v13: PowerForm link

	; First entry (most recent) = current value for table
	if (pt_hist_cnt = 1)
		drec->patients[d1.seq].pt_transfer_assist = c4_pt.result_val
		drec->patients[d1.seq].pt_transfer_dt_tm = format(dfa_pt.form_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

;===============================================================================
; SELECT 6: OT Transfer Assist Level (PowerForm Discrete Grid)
;===============================================================================
; PowerForm: "OT Acute Evaluation" → Mobility Section → Discrete Grid
; Same event_cd as PT, distinguished by PowerForm name
;===============================================================================
SELECT INTO "NL:"
FROM
	(DUMMYT D1 WITH SEQ = SIZE(drec->patients, 5))
	, dcp_forms_activity dfa_ot
	, dcp_forms_activity_comp dfc_ot
	, clinical_event c1_ot
	, clinical_event c2_ot
	, clinical_event c3_ot
	, clinical_event c4_ot

PLAN D1
	WHERE drec->patientCnt > 0

JOIN dfa_ot
	WHERE dfa_ot.person_id = drec->patients[d1.seq].person_id
	AND dfa_ot.encntr_id = drec->patients[d1.seq].encntr_id
	AND dfa_ot.dcp_forms_ref_id = (
		SELECT dcp_forms_ref_id
		FROM dcp_forms_ref
		WHERE description = "OT Acute Evaluation"
		AND active_ind = 1
	)
	AND dfa_ot.active_ind = 1
	AND dfa_ot.form_status_cd IN (25.00, 34.00, 35.00)  /* Auth, Modified */
	AND dfa_ot.form_dt_tm >= cnvtdatetime(curdate - $LOOKBACK_DAYS, 0)

JOIN dfc_ot
	WHERE dfc_ot.dcp_forms_activity_id = dfa_ot.dcp_forms_activity_id
	AND dfc_ot.component_cd = 10891.00  /* PRIMARY EVENT_ID */
	AND dfc_ot.parent_entity_name = "CLINICAL_EVENT"

JOIN c1_ot
	WHERE c1_ot.event_id = dfc_ot.parent_entity_id
	AND c1_ot.valid_until_dt_tm > SYSDATE
	AND c1_ot.view_level = 1

JOIN c2_ot
	WHERE c2_ot.parent_event_id = c1_ot.event_id
	AND c2_ot.valid_until_dt_tm > SYSDATE
	AND c2_ot.event_title_text = "Mobility"

JOIN c3_ot
	WHERE c3_ot.parent_event_id = c2_ot.event_id
	AND c3_ot.valid_until_dt_tm > SYSDATE
	AND c3_ot.event_title_text = "Discrete Grid"
	AND c3_ot.event_cd = 2214520.00  /* Mobility Grid */

JOIN c4_ot
	WHERE c4_ot.parent_event_id = c3_ot.event_id
	AND c4_ot.event_cd = 4348328.00  /* Transfer Bed to and From Chair Rehab */
	AND c4_ot.valid_until_dt_tm > SYSDATE
	AND c4_ot.view_level = 1
	AND c4_ot.result_status_cd IN (25, 34, 35)

ORDER BY c4_ot.encntr_id, dfa_ot.form_dt_tm DESC

HEAD c4_ot.encntr_id
	ot_hist_cnt = 0

DETAIL
	ot_hist_cnt = ot_hist_cnt + 1
	stat = alterlist(drec->patients[d1.seq].ot_transfer_history, ot_hist_cnt)

	drec->patients[d1.seq].ot_transfer_history[ot_hist_cnt].value = c4_ot.result_val
	drec->patients[d1.seq].ot_transfer_history[ot_hist_cnt].event_dt_tm = dfa_ot.form_dt_tm
	drec->patients[d1.seq].ot_transfer_history[ot_hist_cnt].datetime_display = format(dfa_ot.form_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	drec->patients[d1.seq].ot_transfer_history[ot_hist_cnt].comment = ""  /* Populated in SELECT 8 */
	drec->patients[d1.seq].ot_transfer_history[ot_hist_cnt].activity_id = dfa_ot.dcp_forms_activity_id  ; v13: PowerForm link

	; First entry (most recent) = current value for table
	if (ot_hist_cnt = 1)
		drec->patients[d1.seq].ot_transfer_assist = c4_ot.result_val
		drec->patients[d1.seq].ot_transfer_dt_tm = format(dfa_ot.form_dt_tm, "MM/DD/YYYY HH:MM;;Q")
	endif

FOOT REPORT
	null

WITH NOCOUNTER, TIME = 60

;===============================================================================
; SELECT 7: PT Transfer Comments (TODO - Pending Comment Pattern Research)
;===============================================================================
; TODO: Add ce_event_note + long_blob joins after user shares comment examples
; Pattern: Join to c3_pt.event_id from SELECT 5
; Tables: ce_event_note, long_blob
; Handling: Compression, RTF removal, ocf_blob cleanup
;===============================================================================

;===============================================================================
; SELECT 8: OT Transfer Comments (TODO - Pending Comment Pattern Research)
;===============================================================================
; TODO: Add ce_event_note + long_blob joins after user shares comment examples
; Pattern: Join to c3_ot.event_id from SELECT 6
; Tables: ce_event_note, long_blob
; Handling: Compression, RTF removal, ocf_blob cleanup
;===============================================================================

; Output JSON to MPage framework
SET _memory_reply_string = cnvtrectojson(drec)

; Debug output
call echo(build("Program Version: ", PROGRAM_VERSION))
call echo(build("Lookback Period: ", cnvtstring($LOOKBACK_DAYS), " days (", format(cnvtdatetime(curdate - $LOOKBACK_DAYS, 0), "@SHORTDATETIME"), " to ", format(cnvtdatetime(curdate, curtime3), "@SHORTDATETIME"), ")"))
call echo(build("Patient Count: ", cnvtstring(drec->patientCnt)))
call echorecord(drec)

end
go
