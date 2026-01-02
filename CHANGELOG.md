# Changelog

All notable changes to the Mobility Dashboard.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
