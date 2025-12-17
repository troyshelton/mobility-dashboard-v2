# Changelog

All notable changes to the Mobility Dashboard.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased] - v2.0.0-mobility

### Direction Change (2025-12-16)
- **Stakeholder Feedback:** Clinical team prefers metric-specific historical view over global date navigation
- **Decision:** Replace date navigator (Issue #1) with side panel pattern (Issue #3)
- **Pattern:** Clinical Leader Organizer - click cell to see 3-day history for that metric

### Added (Planning)
- **Side Panel Historical Metric View** (Issue #3) - Planning complete, ready for implementation
  - **Pattern:** Click clinical event cell → Side panel opens → Shows 3-day history
  - **Metrics:** 5 clinical events (Phase 1: Morse, Call Light, IV Sites, SCDs, Safety)
  - **UI:** Slide from right, 350-400px, backdrop overlay, 3 close methods
  - **Data:** Pre-fetch 3 days of historical data (instant panel open)
  - **Template System:** Handle single-value and multi-field metrics
  - **Branch:** feature/v2.0.0-side-panel
  - **Status:** Requirements documented, ready to implement

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

### Completed (Low Priority)
- **Patient Presence Indicator** (Issue #2 Phase 1) - Complete but low priority with 3-day lookback
  - ✅ Grayed-out rows for patients not admitted on selected date
  - ✅ Warning icon (⚠️) before patient name
  - ✅ Works with zebra striping
  - ✅ Direct DOM manipulation
  - **Status:** Available if needed, less critical with short lookback periods

### Changed
- PatientDataService.formatForTable() - Added clinical event fields
- PatientListService - Integrated date parameter for CCL calls
- Main.js - Added reloadCurrentData() for date navigation
- Handsontable - Nested headers with Demographics + Clinical Events groups

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
