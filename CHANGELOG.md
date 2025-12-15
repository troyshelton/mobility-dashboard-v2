# Changelog

All notable changes to the ER Tracking Dashboard Template.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0-template] - 2025-12-13

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
