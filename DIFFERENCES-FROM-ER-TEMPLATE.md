# Differences from ER Tracking Dashboard Template

**Source:** er-tracking-dashboard-template v1.0.0
**Target:** inpatient-dashboard-template
**Date:** 2025-12-14

---

## Key Differences to Implement

### 1. ER Unit Dropdown (CHANGE REQUIRED)

**ER Template:**
- Dropdown: "Select ER Unit..." (6 facilities)
- Queries: ER tracking board tables
- CCL Program: `1_cust_mp_gen_get_er_encntrs.prg`
- Table: encounter_domain, tracking board tables

**Inpatient Template:**
- Dropdown: TBD (Floor/Unit selection? Nursing units?)
- Queries: encounter_domain and encounter tables DIRECTLY
- CCL Program: NEW - `1_cust_mp_inp_get_encounters.prg` (to create)
- Table: encounter_domain, encounter (different query pattern)

**Action Needed:**
1. Decide dropdown options (floors? units? care areas?)
2. Create new CCL program for inpatient encounter queries
3. Update dropdown HTML and event handler
4. Update mock data for inpatient units

---

### 2. Query Pattern Difference

**ER Tracking:**
```ccl
/* Queries tracking board for ER census */
SELECT FROM tracking_board_tables
WHERE tracking_group_cd = [ER facility code]
```

**Inpatient (Future):**
```ccl
/* Queries encounter domain directly */
SELECT FROM encounter e, encntr_domain ed
WHERE ed.encntr_domain_cd = [inpatient domain code]
AND e.loc_nurse_unit_cd IN [nursing unit codes]
```

**Key Difference:** Direct encounter queries vs. tracking board queries

---

### 3. Mock Data Structure

**ER Template:**
- ER units by facility (General, Memorial, Teays Valley, etc.)
- Mixed units: ICU, ER, 2N, 3W

**Inpatient Template:**
- Nursing units/floors (4 East, 3 West, ICU, etc.)
- Inpatient-only (no ER patients)
- Focus on floor-based organization

---

## Files That Need Updates

**When implementing inpatient queries:**

1. `src/web/index.html`:
   - Line ~155: Change ER unit dropdown to floor/unit dropdown
   - Update options to nursing units

2. `src/ccl/` (NEW):
   - Create: `1_cust_mp_inp_get_encounters.prg`
   - Query encounter_domain and encounter tables
   - Return encounter IDs for selected nursing unit(s)

3. `src/web/js/PatientListService.js`:
   - Update `getERUnitPatients()` method name (or create new method)
   - Call new inpatient CCL program
   - Update mock data for nursing units

4. `src/web/js/main.js`:
   - Update event handler for unit dropdown
   - Update state variable names (currentERUnit → currentNursingUnit?)

5. Documentation:
   - Update README.md for inpatient context
   - Update CHANGELOG.md
   - Update CLAUDE.md

---

## What Stays the Same

**Generic components (NO CHANGES):**
- ✅ All 12 generic CCL programs (gen_*, plst_*)
- ✅ Patient list functionality (unchanged)
- ✅ Service architecture (PatientListService, UserInfoService, etc.)
- ✅ Demographics display (8 columns)
- ✅ Messaging system (loading, error, no data)
- ✅ Simulator badge
- ✅ Handsontable smooth refresh
- ✅ UI framework (Handsontable, Font Awesome, Tippy, Eruda)

---

## Implementation Timeline

**Phase 1 (Current):**
- Copy template ✅
- Document differences ✅
- Placeholder for inpatient functionality

**Phase 2 (Future):**
- Design nursing unit dropdown options
- Create inpatient encounter CCL program
- Update mock data
- Test and validate
- Update documentation

---

## Notes

- ER template uses tracking boards (ER-specific pattern)
- Inpatient template will use encounter_domain (general inpatient pattern)
- Both templates share the same core infrastructure
- Only the encounter retrieval mechanism differs

---

*Document created: 2025-12-14*
*For questions, see: er-tracking-dashboard-template README.md*
