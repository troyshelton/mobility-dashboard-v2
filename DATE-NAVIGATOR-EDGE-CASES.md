# Date Navigator: Edge Cases and Considerations

**Feature:** Date Navigator for Temporal Mobility Data (Issue #1)
**Documented:** 2025-12-15
**Status:** To be implemented in Subtask 1.5 (CCL development)

---

## Critical Edge Case: Patient Admit/Discharge Dates

### The Problem

**Patient lists show current active census**, but when viewing historical dates, patients may not have been admitted yet or may have already been discharged.

### Examples

**Scenario 1: Patient Not Yet Admitted**
- Today (Dec 15): Patient A is in current census
- User navigates to Dec 10 (historical date)
- Patient A wasn't admitted until Dec 12
- **Problem:** Patient A appears in list but has NO data for Dec 10
- **Solution:** Don't show Patient A for dates before their admission

**Scenario 2: Patient Already Discharged**
- Today (Dec 15): Patient B is in current census (readmitted)
- User navigates to Dec 5
- Patient B was discharged Dec 6 (previous stay)
- **Problem:** Patient B might show data from wrong stay
- **Solution:** Only show patients who were active on selected date

**Scenario 3: Still Admitted (Current)**
- Today (Dec 15): Patient C admitted Dec 1, still inpatient
- User navigates to Dec 10
- Patient C was admitted and still there
- **Correct:** Show Patient C with Dec 10 data ✓

### Required Solution

**CCL Query Logic (for Subtask 1.5):**

```ccl
; Get patient admission and discharge dates
SELECT
    e.encntr_id,
    e.reg_dt_tm AS admit_dt_tm,
    e.disch_dt_tm AS discharge_dt_tm
FROM encounter e
WHERE e.encntr_id IN (patient list encounter IDs)

; Filter patients who were active on selected date
AND e.reg_dt_tm <= date_end             ; Admitted before or on selected date
AND (e.disch_dt_tm IS NULL              ; Still admitted (no discharge)
     OR e.disch_dt_tm >= date_start)    ; Or discharged after selected date

; Then get mobility data for that filtered list
```

**Logic Breakdown:**

**Patient is "active" on selected date if:**
1. `admit_date <= selected_date` (already admitted)
2. AND (`discharge_date IS NULL` (still there) OR `discharge_date >= selected_date` (not yet discharged))

**Date Range Variables:**
```ccl
; Selected date midnight
date_start = DATEADD(selected_date, 0, "dd")  ; Dec 10 00:00:00

; Selected date end of day
date_end = DATEADD(selected_date, 1, "dd")    ; Dec 11 00:00:00 (exclusive)
```

---

## Additional Considerations

### 1. Multiple Encounters (Readmissions)

**Problem:** Patient may have multiple encounters (admitted, discharged, readmitted)

**Solution:**
- Use encounter_id to track specific stay
- Filter encounter active dates, not just patient
- Each encounter has its own admit/discharge dates

### 2. Transfer Between Units

**Problem:** Patient transfers from ICU to 3W mid-stay

**Solution:**
- Encounter persists across transfers
- Location changes but encounter_id same
- Mobility data linked to encounter, not location

### 3. Future Dates (Today and Beyond)

**Problem:** Cannot view future dates (no data exists yet)

**Solution:**
- Next button disabled when at today (already implemented in UI)
- CCL only queries <= CURDATE
- No future date selection allowed

---

## Implementation Plan for Subtask 1.5

**When creating `1_cust_mp_mob_get_pdata_01.prg`:**

### Step 1: Add Admit/Discharge Date Fields
```ccl
record drec (
    1 patients[*]
        2 person_id = f8
        2 encntr_id = f8
        2 admit_dt_tm = dq8      ; NEW: Track admission date
        2 discharge_dt_tm = dq8  ; NEW: Track discharge date
        2 person_name = vc
        ; ... other fields ...
)
```

### Step 2: Filter Active Patients for Selected Date
```ccl
; Main encounter query
SELECT FROM encounter e
WHERE e.encntr_id IN (encounter list from patient list)

; Filter: Patient active on selected date
AND e.reg_dt_tm <= date_end             ; Admitted on or before selected date
AND (e.disch_dt_tm IS NULL              ; Still admitted
     OR e.disch_dt_tm >= date_start)    ; Not discharged before selected date

; This gives us only patients who were actually there on selected date
```

### Step 3: Get Mobility Data Only for Active Patients
```ccl
; Mobility interventions query
SELECT FROM clinical_event ce
WHERE ce.encntr_id IN (filtered encounter list)  ; Only active patients
AND ce.event_end_dt_tm >= date_start
AND ce.event_end_dt_tm < date_end
; ... mobility event codes ...
```

---

## Testing Strategy

**Test Cases to Verify:**

1. **Current patients on current date** → All show
2. **Current patient on past date before admission** → Don't show
3. **Discharged patient on date when they were active** → Shows with historical data
4. **Discharged patient on date after discharge** → Don't show
5. **Readmitted patient** → Show only relevant encounter data

**Mock Data Scenarios:**

```javascript
// Patient admitted Dec 1, still here
{ admit: '12/01/2025', discharge: null }
→ Shows for Dec 10, Dec 15 ✓

// Patient admitted Dec 12, still here
{ admit: '12/12/2025', discharge: null }
→ Don't show for Dec 10 ✓
→ Shows for Dec 15 ✓

// Patient admitted Dec 1, discharged Dec 8
{ admit: '12/01/2025', discharge: '12/08/2025' }
→ Shows for Dec 5 ✓
→ Don't show for Dec 10 ✗
→ Don't show for Dec 15 ✗
```

---

## Benefits of This Approach

**Clinical Accuracy:**
- ✅ Only show patients who were actually there
- ✅ Prevent confusion from wrong-stay data
- ✅ Accurate historical census

**Data Integrity:**
- ✅ Each encounter tracked separately
- ✅ Admit/discharge dates respected
- ✅ No mixing data from different stays

**Audit Trail:**
- ✅ Clear which patients were active when
- ✅ Accurate point-in-time snapshots
- ✅ Regulatory compliance

---

## Questions for Future Resolution

1. **Should we show discharged patients in grayed-out state?**
   - Or completely hide them?
   - User preference needed

2. **What about patients transferred to different unit?**
   - Still show them?
   - Filter by current location?

3. **ER patients who were admitted to floor?**
   - Track encounter across locations?
   - Separate ER vs inpatient encounters?

4. **Observation patients (not admitted)?**
   - Include in inpatient census?
   - Filter by patient class?

---

**These will be addressed during CCL implementation (Subtask 1.5) and testing (Subtask 1.8).**

*Document created: 2025-12-15*
*Status: Edge cases identified, solutions planned*
*Implementation: Subtask 1.5 (CCL development)*
