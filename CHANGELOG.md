# Changelog

All notable changes to the Mobility Dashboard.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.6.0-mobility] - 2026-01-03

### Added (Issue #16 - Ambulation Distance)
- **Ambulation Distance Column** - Shows how far patient ambulated in feet
  - Event: "Ambulation Distance" (event_cd 269481201.00 - hardcoded)
  - Type: Numeric with units (feet)
  - Values: 100, 75, 50 (numeric progression)
  - Display: Numeric value (80px width, center aligned)
  - Side Panel: Historical distances with sparkline visualization
  - **CCL v11:** Added to SELECT 2 with hardcoded event_cd (no unique CKI)
  - **Frontend:** Column 13 (after OT Transfer)
  - **Sparkline:** Automatic for numeric data

### Changed
- **CCL:** Fixed Morse Score event name ("Morse Fall Risk Score" → "Morse Fall Score")
- **PatientDataService.js** - Added ambulation MetricTemplate, updated column indexes (14-19)
- **main.js** - Added Ambulation Distance column, updated click handler range (8-19)
- **XMLCclRequestSimulator.js** - Added ambulation mock data (100, 75, 50) with sparkline
- **Config.js** - Disabled simulator mode for CERT testing

### Technical Notes
- **Hardcoded Event Code:** Used 269481201.00 instead of uar_get_code_by() due to non-unique display name
- **Lesson:** When uar_get_code_by() returns -1.00 (ambiguous), use hardcoded event_cd

---

## [2.5.0-mobility] - 2026-01-02

### Added (Issues #10 & #11 - PT/OT Transfer Assessments)
- **PT Transfer Column** - Shows Physical Therapy transfer assist level from PT Acute Evaluation
  - Data Source: PT Acute Evaluation PowerForm → Mobility Section → Discrete Grid
  - Field: "Transfer Bed to and From Chair Rehab" (event_cd 4348328.00)
  - Assist Levels: Complete I, Mod I, Supervision, Min A, Mod A, Max A, Total A
  - Display: Assist level with ellipsis truncation (100px width)
  - Side Panel: Historical PT assessments with full text
  - **CCL v10:** SELECT 5 with 4-level PowerForm discrete grid navigation
  - **Pattern:** dcp_forms_activity → dcp_forms_activity_comp → 4 clinical_event levels
  - **Tables:** dcp_forms_ref, dcp_forms_activity, dcp_forms_activity_comp, clinical_event (4 levels)

- **OT Transfer Column** - Shows Occupational Therapy transfer assist level from OT Acute Evaluation
  - Data Source: OT Acute Evaluation PowerForm → Mobility Section → Discrete Grid
  - Same field and event_cd as PT, distinguished by PowerForm name
  - **CCL v10:** SELECT 6 with same 4-level pattern
  - **Fix:** Changed field name from assist_level to value for side panel compatibility

### Technical Achievements
- **PowerForm Discrete Grid Navigation:** Solved 4-level hierarchy pattern
  - Level 1: PowerForm root (view_level = 1)
  - Level 2: Section (event_title_text = "Mobility")
  - Level 3: Discrete Grid container (event_cd = 2214520.00)
  - Level 4: Actual event (event_cd = 4348328.00)
- **No Outer Joins:** Inner joins only for efficiency
- **Documented Pattern:** Created CCL_POWERFORM_DISCRETE_GRID_PATTERN.md reference

### Changed
- **PatientDataService.js** - Added pt_transfer and ot_transfer MetricTemplates, updated column indexes (11-18)
- **main.js** - Added PT and OT columns, updated click handler range (8-18)
- **XMLCclRequestSimulator.js** - Added PT/OT mock data with history
- **Config.js** - Disabled simulator mode for CERT testing

### Deferred
- **Comments (SELECT 7 & 8):** Deferred to v2.6.0 - requires ce_event_note + long_blob with compression handling

---

## [2.4.0-mobility] - 2026-01-02

### Added (Issue #9 - Toileting Method)
- **Toileting Method Column** - Shows how patient uses restroom from I-View documentation
  - Data Source: I-View "Toileting Offered ADL" nursing documentation
  - Event: "Toileting Offered ADL" (event_cd 279864735.00)
  - Display Format: Full text with ellipsis truncation in table (100px width)
  - Side Panel: Complete text for all 30-day history entries
  - Examples: "Bedside commode, Independent, Assisted to BR, Using Bedpan, Using Urinal", "Sleeping"
  - **CCL v09:** Added to SELECT 2 (no parsing - stores full text)
  - **Frontend:** Column 10 (after Baseline), htLeft alignment
  - **Frequent Updates:** Multiple entries per day showing toileting method changes
  - **Fix:** Corrected event name from "Toileting Offered" to "Toileting Offered ADL"

### Changed
- **PatientDataService.js** - Added toileting MetricTemplate, updated column indexes (10-16)
- **main.js** - Added Toileting column, updated click handler range (8-16)
- **XMLCclRequestSimulator.js** - Added 3 toileting history entries for mock testing
- **Config.js** - Disabled simulator mode for CERT testing

---

## [2.3.0-mobility] - 2026-01-02

### Added (Issue #8 - Baseline Mobility)
- **Baseline Mobility Column** - Shows patient's baseline functional assessment level (1-4)
  - Data Source: PowerForm "Baseline Functional Assessment"
  - Event: "Baseline Mobility" (event_cd 8339925023.00)
  - Display Format: Numeric level (1, 2, 3, or 4) in table
  - Side Panel: Full text "(Level X) description"
  - Example: "(Level 4) No limitation with walking"
  - **CCL v08:** Added to SELECT 2 for efficient querying
  - **Parsing Logic:** Extract level from "(Level X)" pattern
  - **Frontend:** Column 9 (after BMAT), MetricTemplate configuration
  - **Edge Case:** Multiple entries supported (documented for clinical validation)

### Changed
- **PatientDataService.js** - Added baseline MetricTemplate, updated column indexes
- **main.js** - Added Baseline column, updated click handler range (8-15)
- **XMLCclRequestSimulator.js** - Added baseline mock data
- **Config.js** - Disabled simulator mode for CERT testing

---

## [2.2.0-mobility] - 2026-01-02

### Added (Issue #7 - Activity Precautions)
- **Activity Precautions Column** - Shows count of active patient restrictions
  - 7 precaution types: Weight Bearing, Hip Precautions, Spine Restrictions, Cervical Collar
  - Click to view detailed precaution list in side panel
  - Multi-line display: Name, Order Details, Date/Time, Status
  - **CCL v07:** SELECT 4 for order detection using UAR_GET_CODE_BY
  - **Enhanced Template System:** Supports simple (value) and complex (multi-field) data types
  - **Pending:** TLSO and LSO Brace Activity (need CERT order placement)

---

## [2.1.0-mobility] - 2026-01-02

### Added (Issue #5 - BMAT)
- **BMAT Column** - Brief Mobility Assessment Tool
  - Displays mobility level (1-4)
  - Progressive assessment: Sit & Shake → Stretch & Point → Stand → Walk
  - Parses level from 4 test event results
  - Click to view 30-day mobility level history with sparkline
  - **CCL v06:** SELECT 3 for BMAT parsing with findstring logic
  - **Frontend:** Column 8 (before Morse Score), automatic sparkline

---

## [2.0.0-mobility] - 2026-01-02

### Direction Change (2025-12-16)
- **Stakeholder Feedback:** Clinical team prefers metric-specific historical view over global date navigation
- **Decision:** Replace date navigator (Issue #1) with side panel pattern (Issue #3)
- **Pattern:** Clinical Leader Organizer - click cell to see historical data for that metric

### Added (Issue #3 - Implemented)
- **Side Panel Historical Metric View** - COMPLETE and deployed to CERT
  - **Pattern:** Click clinical event cell → Side panel opens → Shows 30-day history
  - **Metrics:** 5 clinical events (Phase 1: Morse, Call Light, IV Sites, SCDs, Safety)
  - **UI:** Slide from right, 400px, backdrop overlay, 3 close methods (X, backdrop, ESC)
  - **Data:** 30-day lookback (configurable via CCL prompt parameter)
  - **Features:**
    - Automatic sparklines for numeric data (Morse scores)
    - Condensed spacing for clinical efficiency (~40% more entries visible)
    - Dynamic lookback period (7, 14, 30 days configurable)
    - Pre-built SidePanelService component
  - **CCL:** v05 with historical arrays (VALUE, EVENT_DT_TM, DATETIME_DISPLAY)
  - **Status:** Deployed to CERT, validated with real patient data

### Archived as POC
- **Date Navigator Feature** (Issue #1) - Not deployed based on stakeholder feedback
  - ✅ Fully functional (tested locally + Azure CERT)
  - ✅ Preserved in 3 locations for future reuse:
    - POC Branch: `poc/date-navigator-demo`
    - POC Tag: `v1.1.0-date-navigator-poc`
    - Standalone: `/Users/troyshelton/Projects/Templates/MPage-Date-Navigator-POC/`
  - ✅ Cataloged: `/Users/troyshelton/Projects/POC-CATALOG.md`
  - **Reusable:** Other dashboards needing global date navigation
  - **Features:** Outlook-style controls, CCL date filtering, patient presence indicator

### Changed
- **PatientDataService.js** - Added MetricTemplates configuration, historical array parsing
- **PatientListService.js** - Removed date parameter, added dynamic lookback parameter
- **main.js** - Added click handlers, parseHistoricalDateTime helper
- **index.html** - Integrated SidePanelService, removed date navigator and ER dropdown
- **styles.css** - Added clickable cell styling (cursor pointer, hover effects)
- **Config.js** - Simulator mode control for local testing
- **XMLCclRequestSimulator.js** - Dynamic lookback, 30-day mock historical data

### Removed
- **Date Navigator** (Issue #1 archived as POC) - All UI controls, state, event handlers, CSS
- **ER Unit Dropdown** - Placeholder from ER template, not needed for mobility dashboard
- **Patient Presence Indicator** - Date-specific feature no longer relevant
- Total: ~595 lines of code removed for cleaner v2.0.0 codebase

---

## [1.0.0-mobility] - 2025-12-14

### Initial Release
- Built from inpatient-dashboard-template v1.0.0-inpatient

### Added
- **Generic boilerplate for ER/ED clinical dashboards**
- **12 reusable CCL programs** (gen_*, plst_*)
  - Core: gen_get_plists, gen_get_pids, gen_get_pdata, gen_user_info, gen_get_er_encntrs
  - Patient list types: plst_custom, plst_provgrp, plst_cteam, plst_census, plst_query, plst_reltn, plst_assign
- **Demographics-only display** (8 columns)
- **Service architecture** from production sepsis-dashboard
- **Mock data framework** for testing without Cerner
- **Production-ready UI** (Handsontable, Font Awesome, Tippy, Eruda)

### Changed
- Derived from sepsis-dashboard v1.48.0-sepsis
- Removed all sepsis-specific logic (40 files deleted)
- Renamed all CCL programs to generic (sep → gen, plst generic)
- Simplified to demographics foundation only
- Updated all service references to generic programs

### Removed
- All sepsis-specific code (alerts, screening, bundle tracking)
- All clinical event queries (13 sepsis columns)
- Sepsis documentation (SEP-1 guidelines)
- 31 sepsis CCL program versions
- Test and troubleshooting files

---

## Usage

**This is a TEMPLATE.** To create a dashboard:

1. Copy this directory → your-dashboard-name
2. Extend `gen_get_pdata.prg` with domain queries
3. Add domain columns to `main.js`
4. Update documentation
5. Deploy

---

*v1.0.0-template - Initial Generic Boilerplate Release*
