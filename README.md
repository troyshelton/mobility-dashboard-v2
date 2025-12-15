# Inpatient Dashboard Template

**Version:** v1.0.0-inpatient
**Type:** Generic Boilerplate
**Last Updated:** 2025-12-14
**Source:** Copied from er-tracking-dashboard-template v1.0.0

---

## Overview

**Generic boilerplate for creating inpatient floor/unit dashboards** with patient list integration for Oracle Health Cerner MPages.

This template provides a proven, production-ready foundation with:
- ✅ **Patient List Functionality** - All 7 list types supported
- ✅ **Service Architecture** - Proven patterns from production
- ✅ **Demographics Display** - Clean 8-column patient info
- ✅ **Mock Data Framework** - Test without Cerner
- ✅ **12 Generic CCL Programs** - Reusable everywhere
- ⏸️ **Inpatient Encounter Queries** - Phase 2 (see DIFFERENCES-FROM-ER-TEMPLATE.md)

**Use this template to create:** Mobility, Med-Surg, Telemetry, or any inpatient floor/unit dashboard

---

## Differences from ER Template

**Key Change Needed (Phase 2):**
- **ER Unit Dropdown** → Will become **Nursing Unit/Floor Dropdown**
- **Tracking Board Queries** → Will use **encounter_domain + encounter tables**
- **New CCL Program** → `1_cust_mp_inp_get_encounters.prg` (to be created)

**See:** `DIFFERENCES-FROM-ER-TEMPLATE.md` for complete details

---

## What's Included

### 12 Generic CCL Programs (ALL REUSABLE)

**Core Utilities:**
- `1_cust_mp_gen_get_plists.prg` - Get patient lists
- `1_cust_mp_gen_get_pids.prg` - Get encounter IDs from list
- `1_cust_mp_gen_get_pdata.prg` - Get demographics (114 lines)
- `1_cust_mp_gen_user_info.prg` - Get user authentication
- `1_cust_mp_gen_get_er_encntrs.prg` - ⚠️ ER-specific (will need inpatient version)

**Patient List Types:**
- `1_cust_mp_plst_custom.prg`, `plst_provgrp.prg`, `plst_cteam.prg`, `plst_census.prg`, `plst_query.prg`, `plst_reltn.prg`, `plst_assign.prg`

### JavaScript Services (Production-Ready)

- PatientListService, UserInfoService, SendCclRequest, Config, VisualIndicators, XMLCclRequestSimulator, AdminCommands, main.js, PatientDataService

### UI Framework

- Handsontable v15.2.0, Font Awesome 6.5.1, Tippy.js v6.3.7, Eruda DevTools

### Current Display

8 Demographics Columns: Patient Name, Unit, Room/Bed, Age, Gender, Class, Admitted, Status

---

## Current State (Phase 1)

**What Works Now:**
- ✅ Patient list dropdown (all types)
- ✅ Demographics display
- ✅ Smooth Handsontable refresh
- ✅ Loading messages in table
- ✅ Simulator mode with mock data
- ✅ SIMULATOR badge in header

**What Needs Implementation (Phase 2):**
- ⏸️ Nursing unit/floor dropdown (replaces ER unit dropdown)
- ⏸️ Inpatient encounter queries (encounter_domain + encounter tables)
- ⏸️ New CCL program for inpatient encounters
- ⏸️ Mock data for nursing units

---

## Quick Start (Testing Current State)

```bash
# Open in browser
open src/web/index.html

# Test with patient lists (works now!)
# ER unit dropdown (placeholder - will be replaced with nursing units)
```

---

## Phase 2: Inpatient Implementation

**When ready to add inpatient queries:**

1. **Design nursing unit dropdown**
   - Decide options (4 East, 3 West, ICU, etc.)
   - Update HTML dropdown

2. **Create inpatient CCL program**
   - `1_cust_mp_inp_get_encounters.prg`
   - Query encounter_domain and encounter tables
   - Filter by nursing unit codes

3. **Update services**
   - Add `getInpatientUnitPatients()` method
   - Update mock data for nursing units

4. **Test and validate**
   - Verify unit-specific patient lists
   - Test with real data in CERT

---

## Comparison: ER vs Inpatient Queries

**ER Template (Tracking Board):**
```ccl
SELECT FROM tracking_board
WHERE tracking_group_cd = [ER facility code]
```

**Inpatient (Direct Encounter - Phase 2):**
```ccl
SELECT FROM encounter e, encntr_domain ed
WHERE ed.encntr_domain_cd = [inpatient domain]
AND e.loc_nurse_unit_cd IN [nursing unit codes]
```

---

## Repository

**GitHub:** https://github.com/troyshelton/inpatient-dashboard-template

**Clone:**
```bash
git clone https://github.com/troyshelton/inpatient-dashboard-template.git
```

---

*Generic Boilerplate - Ready for Inpatient Extensions*
*Phase 1 Complete - Phase 2 Pending*
*Based on ER Template v1.0.0*
