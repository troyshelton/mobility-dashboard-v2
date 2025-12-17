# Project: Mobility Dashboard

**Current Version:** v2.0.0-mobility (in progress)
**Date:** 2025-12-16
**Project Type:** Healthcare Production ⚠️
**Enforcement:** Mandatory Workflows Required
**Repository:** https://github.com/troyshelton/mobility-dashboard-v2
**POC Catalog:** [/Users/troyshelton/Projects/POC-CATALOG.md](file:///Users/troyshelton/Projects/POC-CATALOG.md)

---

## Project Overview

Patient mobility and safety dashboard for inpatient floors with temporal clinical event tracking and date-based data visualization.

**Clinical Purpose:** Monitor patient mobility status, safety interventions, and clinical events across nursing units
**Patient Impact:** Improves patient safety through real-time mobility monitoring and fall prevention
**Compliance:** HIPAA, Patient Safety Standards, Clinical Quality Measures

**Base Template:** er-tracking-dashboard-template v1.0.0 (modified for inpatient use)

---

# 🛑 CLAUDE: READ AND ACKNOWLEDGE BEFORE ANY WORK 🛑

**Before doing ANYTHING on this project, you MUST acknowledge:**

- [ ] I have read the Deployment Verification Workflow (.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md)
- [ ] I will show EVERY deployment command with source, destination, account BEFORE executing
- [ ] I will WAIT for "approved" before deploying
- [ ] I have read the Code Review Workflow (.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md)
- [ ] I will show code changes (git diff or code sections) BEFORE deploying
- [ ] I will explain what, why, how for every code change
- [ ] I have read the Validation Gate Protocol (.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md)
- [ ] I will STOP at every 🛑 TaskMaster validation gate
- [ ] I will show summary and WAIT for approval before proceeding
- [ ] I understand violations are documented in workflow files with dates
- [ ] I understand repeated violations may result in session termination

**REQUIRED ACKNOWLEDGMENT:**

Type this explicitly at start of session (or when reminded):

```
I acknowledge these mandatory workflows:
✅ Deployment Verification - Show command, wait for approval
✅ Code Review - Show code before deploying
✅ Validation Gates - Stop at 🛑, wait for approval

I will follow them without exception.
```

**Violation history for this project:**
- None yet - project inherits sepsis-dashboard enforcement standards

**If you skip this acknowledgment:** User will remind you to read CLAUDE.md enforcement section.

---

# 🛑 MANDATORY HEALTHCARE PRODUCTION ENFORCEMENT 🛑

**⚠️ READ THIS FIRST - ENFORCED WORKFLOWS**

**This project is a HEALTHCARE PRODUCTION SYSTEM.** The following workflows are MANDATORY and ENFORCED:

## 1. Deployment Verification (NO EXCEPTIONS)

**Before EVERY `az storage` command:**

```
I'm about to deploy to Azure CERT:

Source:      /Users/troyshelton/Projects/vandalia/mobility-dashboard/src/web
Destination: $web/mobility-dashboard/src
Account:     ihazurestoragedev

⚠️ CRITICAL: Is this the correct destination?

Reply "approved" to deploy.
```

**WAIT for "approved" before executing.**

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md`

---

## 2. Code Review (NO EXCEPTIONS)

**Before deploying code changes:**
- Show git diff or code sections
- Explain what, why, how
- Wait for user review and approval

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md`

---

## 3. TaskMaster Validation Gates (NO EXCEPTIONS)

**At EVERY 🛑 subtask:**
- STOP immediately
- Show summary of work
- WAIT for approval
- Do not auto-proceed

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md`

---

# ⚠️ MANDATORY SESSION START CHECKLIST FOR CLAUDE ⚠️

**Before doing ANY work, complete this checklist:**

- [ ] 1. **Detect Project State**: Check if this is a new or existing project
  ```bash
  # Check for project documentation:
  ls README.md CHANGELOG.md 2>/dev/null
  ```

  **If files exist** → Existing project (go to step 2)
  **If files missing** → New project (skip to step 2 with "NEW PROJECT" flag)

- [ ] 2. **For EXISTING Projects - Check Documentation Sync**:
  - Do README.md, CHANGELOG.md, and CLAUDE.md have matching versions and dates?
  ```bash
  head -10 README.md | grep "Version:"
  head -10 CHANGELOG.md | grep "##"
  head -5 CLAUDE.md | grep "Version:"
  ```
  - **If IN SYNC** → Show concise status, ask what to work on
  - **If OUT OF SYNC** → Show workflow menu + warning

- [ ] 3. **For Healthcare Production Work** (Mobility Dashboard):
  - MUST use TASKMASTER-GIT-ENHANCEMENT.md v2.1 (WITH PULL REQUESTS + Azure Deployment Validation)
  - Full audit trail required (Issue → PR → Branch → Tag)
  - Deployment destination verification required (prevents wrong-location deployments)
  - Cannot skip validation gates
  - Required for: team development, production deployments, audit compliance

  **TaskMaster Task Creation:**
  - Claude creates tasks using TaskMaster MCP tools
  - Claude provides detailed task structure document first
  - Claude shows user tasks exist before implementation

  **Common TaskMaster CLI Fix:**
  - MCP `add_subtask` tool has `id` parameter issues
  - **Use CLI instead:** `task-master add-subtask --parent=<taskId> --title="..." --description="..."`
  - CLI auto-generates subtask IDs (don't specify --id parameter)

- [ ] 4. **Tool Usage Enforcement** (CRITICAL):
  - ❌ **NEVER use TodoWrite for development tasks**
  - ❌ **NEVER use TodoWrite during TaskMaster workflows**
  - ✅ **ONLY use TaskMaster** for tracking development work
  - ✅ TodoWrite ONLY if user explicitly approves for simple personal reminders
  - **Violation = Process failure**

**⚠️ If you skip this checklist:**
- Documentation WILL get out of sync
- Git workflow WILL be incomplete
- TodoWrite WILL be used instead of TaskMaster
- Standards will not be followed consistently

---

## ⚠️ TOOL USAGE RESTRICTIONS (ENFORCED) ⚠️

### TodoWrite Tool Policy

**TodoWrite is DISABLED for development work on this project.**

#### When TodoWrite is FORBIDDEN:
- ❌ During any TaskMaster workflow
- ❌ For development tasks (coding, CCL, frontend work)
- ❌ When GitHub issue is open
- ❌ When on a feature branch
- ❌ During TASKMASTER-GIT-ENHANCEMENT workflow

#### When TodoWrite MAY be used (with permission):
- ✅ Simple personal reminders (ONLY after asking user)
- ✅ Non-development tasks explicitly approved by user

#### Pre-Flight Check (MANDATORY before TodoWrite):

**Before using TodoWrite, Claude MUST execute this check:**

1. **Check TaskMaster status**:
   ```bash
   task-master list
   ```
   If tasks exist → Use TaskMaster, NOT TodoWrite

2. **Check for open GitHub issues**:
   ```bash
   gh issue list --state open
   ```
   If issues exist → Use TaskMaster, NOT TodoWrite

3. **Check current branch**:
   ```bash
   git branch --show-current
   ```
   If on feature branch → Use TaskMaster, NOT TodoWrite

4. **If ANY check is YES** → STOP. Use TaskMaster instead.

5. **If all checks are NO** → Ask user permission:
   ```
   I was about to use TodoWrite for [specific task].

   Pre-flight check results:
   - TaskMaster active? NO
   - GitHub issue open? NO
   - On feature branch? NO
   - Development work? [YES/NO]

   May I use TodoWrite for this, or would you prefer TaskMaster?
   ```

---

## Current Development Status

### v2.0.0-mobility: Side Panel Historical View (Planning Complete)

**Branch:** feature/v2.0.0-side-panel
**Issue:** [#3](https://github.com/troyshelton/mobility-dashboard-v2/issues/3)
**Status:** Requirements documented, ready for implementation
**Stakeholder Meeting:** 2025-12-16

**Direction Change:**
- ❌ Date Navigator (Issue #1) - Not wanted by clinicians
- ✅ Side Panel Pattern - Preferred (like Clinical Leader Organizer)
- **Pattern:** Click metric cell → See 3-day history for that patient

**✅ Planning Complete:**
- Stakeholder requirements gathered
- Technical approach defined (pre-fetch 3 days, template system)
- UI specifications documented (slide from right, backdrop, 3 close methods)
- Phase 1 scope: 5 clinical events
- Phase 2 scope: Activity orders + precautions
- Effort estimated: 10-14 hours (Phase 1)

**🔨 Next Steps:**
- Implement CCL v05 with historical arrays
- Build side panel UI component
- Create template system
- Add click handlers
- CERT validation

### v1.1.0-mobility: Date Navigator (Archived as POC)

**Issue:** [#1](https://github.com/troyshelton/mobility-dashboard-v2/issues/1) - Closed (Stakeholder Feedback)
**Status:** Fully functional, preserved for reuse

**POC Locations:**
- Standalone: `/Users/troyshelton/Projects/Templates/MPage-Date-Navigator-POC/`
- Git Branch: `poc/date-navigator-demo`
- Git Tag: `v1.1.0-date-navigator-poc`
- Catalog: [POC-CATALOG.md](file:///Users/troyshelton/Projects/POC-CATALOG.md)

**Why Archived:**
- Stakeholders prefer metric-specific drill-down over global date navigation
- Replaced by Issue #3 (side panel pattern)
- Preserved for other projects that need date navigation

**Features Built:**
- Outlook-style date controls, CCL date filtering, patient presence indicator
- Tested locally + Azure CERT + CCL v04 compiled in Cerner CERT

### Issue #2: Patient Presence Indicator (Low Priority)

**Issue:** [#2](https://github.com/troyshelton/mobility-dashboard-v2/issues/2)
**Status:** Phase 1 complete, marked low priority

**Completed:**
- Grayed-out rows for patients not admitted on selected date
- Warning icon (⚠️), works with zebra striping
- Direct DOM manipulation

**Rationale for Low Priority:**
- 3-day lookback (Issue #3) makes admission date edge cases rare
- Still available if needed for future enhancements

### v1.0.0-mobility: Demographics Foundation (Complete)

**Release Date:** 2025-12-14
**Features:**
- 12 reusable CCL programs (gen_*, plst_*)
- Patient list dropdown (all 7 types supported)
- Demographics display (8 columns: Name, Unit, Room/Bed, Age, Gender, Class, Admitted, Status)
- Service architecture from sepsis-dashboard
- Mock data framework for testing without Cerner

---

## Architecture Overview

### Service Architecture Pattern

```
┌─────────────┐
│   User      │
│   Input     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  main.js (Application State)            │
│  - Date state management                │
│  - Event handlers                       │
│  - Handsontable initialization          │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Services Layer                         │
│  ┌─────────────────┐ ┌────────────────┐│
│  │PatientList      │ │PatientData     ││
│  │Service          │ │Service         ││
│  │- List mgmt      │ │- Formatting    ││
│  │- Date params    │ │- Clinical evt  ││
│  └────────┬────────┘ └────────┬───────┘│
│           │                    │        │
│           ▼                    ▼        │
│  ┌──────────────────────────────────┐  │
│  │    SendCclRequest                │  │
│  │    - CCL communication           │  │
│  │    - Simulator fallback          │  │
│  └──────────┬───────────────────────┘  │
└───────────────┼──────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────┐
│  CCL Programs (Oracle Health Cerner)     │
│  - 1_cust_mp_mob_get_pdata_03.prg        │
│    (demographics + clinical events)      │
│  - 12 generic programs (gen_*, plst_*)   │
└──────────┬────────────────────────────────┘
           │
           ▼
┌───────────────────────────────────────────┐
│  Handsontable Display                    │
│  - Nested headers (Demographics/Events)  │
│  - Smooth refresh on date change         │
└───────────────────────────────────────────┘
```

### Data Flow (Date Navigator Feature)

1. **User clicks date navigation button** (Today/Previous/Next)
2. **main.js** updates `currentDate` state
3. **PatientListService.getCurrentListData()** called with date parameter
4. **CCL receives date** as mmddyyyy integer (e.g., 12162025)
5. **CCL Query 1:** Demographics (base patient data)
6. **CCL Query 2:** Clinical events with date filtering (DUMMYT pattern)
   - Loops through 5 event types
   - Filters events by date
   - Updates patient record with latest values
7. **PatientDataService** formats data into table structure
8. **Handsontable** renders with nested headers

### Two-Query Approach (CCL Pattern)

**Query 1: Demographics**
```ccl
SELECT INTO "NL:"
  patient_name = p.name_full_formatted,
  unit_name = uar_get_code_display(e.loc_nurse_unit_cd),
  room_bed = e.loc_room_cd + "/" + e.loc_bed_cd,
  age = DATETIMEDIFF(CNVTDATETIME(CURDATE, CURTIME3), p.birth_dt_tm, 1),
  gender = uar_get_code_display(p.sex_cd),
  class = uar_get_code_display(e.encntr_class_cd),
  admitted = FORMAT(e.reg_dt_tm, "MM/DD/YYYY HH:MM"),
  status = uar_get_code_display(e.encntr_status_cd)
FROM encounter e, person p
WHERE e.encntr_id IN (pids from parameter)
AND p.person_id = e.person_id
```

**Query 2: Clinical Events (with Date Filtering)**
```ccl
SELECT INTO "NL:" FROM dummyt
DETAIL
  idx = locateval(i, 1, size(drec->patients, 5), pid, drec->patients[i].encntr_id)

  ; Loop through clinical event types
  FOR (event_idx = 1 TO 5)
    ; Query clinical_event for specific event_cd and date
    ; Update drec->patients[idx].morse_score, .call_light, etc.
  ENDFOR
```

**Key Pattern:** DUMMYT allows record updates without data loss

---

## Key Files & Their Purposes

### HTML/CSS
- **`src/web/index.html`** (main UI)
  - Date navigator controls (lines ~200-220)
  - Patient list dropdown
  - Unit dropdown (placeholder for Phase 2)
  - Handsontable container

- **`src/web/styles.css`** (styling)
  - Date navigator button styles
  - Handsontable overrides
  - Loading message styles

### JavaScript Services
- **`src/web/js/main.js`** (application state)
  - Date state management (`currentDate`, `dateNavigation` object)
  - Event handlers for date buttons (lines ~150-180)
  - `reloadCurrentData()` method for date changes
  - Handsontable initialization with nested headers

- **`src/web/js/PatientListService.js`** (list management)
  - `getCurrentListData()` with date parameter integration
  - `getPatientList()` for dropdown
  - `getPatientIds()` for selected list
  - CCL program calls with date passing

- **`src/web/js/PatientDataService.js`** (data formatting)
  - `formatForTable()` with clinical event fields (lines ~50-100)
  - Column definitions for 13 columns (8 demographics + 5 clinical events)
  - Nested headers configuration

- **`src/web/js/UserInfoService.js`** (authentication)
  - User environment detection
  - Authentication state

- **`src/web/js/SendCclRequest.js`** (CCL communication)
  - CCL request wrapper
  - Error handling
  - Timeout management

- **`src/web/js/XMLCclRequestSimulator.js`** (mock data)
  - Date-aware mock responses
  - Dynamic today/yesterday data generation
  - 5 clinical events simulated

- **`src/web/js/Config.js`** (configuration)
  - Environment settings
  - CCL program names

- **`src/web/js/AdminCommands.js`** (debugging)
  - Console commands for testing
  - Data inspection

- **`src/web/js/VisualIndicators.js`** (UI feedback)
  - Loading messages
  - Error messages
  - SIMULATOR badge

### CCL Programs (Active)
- **`src/ccl/1_cust_mp_mob_get_pdata_03.prg`** (CURRENT VERSION)
  - Demographics + clinical events with date filtering
  - Two-query approach (demographics first, then events)
  - Date parameter: mmddyyyy integer format
  - 5 clinical events: Morse Score, Call Light, IV Sites, SCDs, Safety
  - DUMMYT pattern for record updates
  - Status: Deployed to CERT (2025-12-15)

- **`src/ccl/1_cust_mp_mob_get_pdata_02.prg`** (previous version - reference only)

### CCL Programs (Generic - Reusable)
- **`src/ccl/1_cust_mp_gen_get_plists.prg`** - Get patient lists
- **`src/ccl/1_cust_mp_gen_get_pids.prg`** - Get encounter IDs from list
- **`src/ccl/1_cust_mp_gen_get_pdata.prg`** - Get demographics (114 lines, demographics only)
- **`src/ccl/1_cust_mp_gen_user_info.prg`** - Get user authentication
- **`src/ccl/1_cust_mp_gen_get_er_encntrs.prg`** - ER-specific (Phase 2: replace with inpatient version)

### CCL Programs (Patient List Types - All Generic)
- **`src/ccl/1_cust_mp_plst_custom.prg`** - Custom patient lists
- **`src/ccl/1_cust_mp_plst_provgrp.prg`** - Provider group lists
- **`src/ccl/1_cust_mp_plst_cteam.prg`** - Care team lists
- **`src/ccl/1_cust_mp_plst_census.prg`** - Census lists
- **`src/ccl/1_cust_mp_plst_query.prg`** - Query-based lists
- **`src/ccl/1_cust_mp_plst_reltn.prg`** - Relationship lists
- **`src/ccl/1_cust_mp_plst_assign.prg`** - Assignment lists

### Configuration
- **`.taskmaster/`** - TaskMaster project management
  - `tasks/tasks.json` - Task tracking
  - `config.json` - AI model configuration
- **`.claude/TM_COMMANDS_GUIDE.md`** - TaskMaster command reference (see this for TaskMaster help)
- **`.mcp.json`** - MCP server configuration
- **`DIFFERENCES-FROM-ER-TEMPLATE.md`** - Phase 2 implementation notes

---

## Technology Stack

### Frontend Libraries
- **Handsontable v15.2.0** - Excel-like data grid with nested headers
- **Font Awesome 6.5.1** - Medical-standard iconography
- **Tippy.js v6.3.7** - Tooltips and popovers
- **Eruda DevTools** - Mobile debugging console

### Backend
- **Oracle Health Cerner MPages** - PowerChart integration
- **CCL (Cerner Command Language)** - Healthcare data queries
- **Azure Static Web Apps** - CERT and Production hosting

### Development Tools
- **TaskMaster MCP** - Task management with validation gates
- **XMLCclRequestSimulator** - Mock data for local testing
- **Git Worktrees** - Parallel development support

---

## CCL Reference & Patterns

### Date Filtering Pattern (Bob Ross uCern)

**Date Format:** mmddyyyy integer (e.g., 12162025 for Dec 16, 2025)

**JavaScript to CCL:**
```javascript
// main.js
const dateParam = parseInt(
  currentDate.getMonth() + 1 +
  currentDate.getDate().toString().padStart(2, '0') +
  currentDate.getFullYear()
);
```

**CCL Date Filtering:**
```ccl
; Convert parameter to datetime
DECLARE target_date = DQ8 WITH NOCONSTANT(0)
SET target_date = CNVTDATETIME(CNVTINT(p_date_param))

; Filter clinical events
WHERE ce.event_end_dt_tm BETWEEN
  CNVTDATETIME(target_date) AND
  CNVTDATETIME(DATEADD(target_date, 1, 3))  ; +1 day
```

### DUMMYT Pattern (Record Updates)

**Purpose:** Update record structure without losing data

```ccl
SELECT INTO "NL:" FROM dummyt
DETAIL
  ; Find patient index in record structure
  idx = locateval(i, 1, size(drec->patients, 5), pid, drec->patients[i].encntr_id)

  ; Update record field
  drec->patients[idx].morse_score = latest_value
```

**Why DUMMYT:** Allows looping and record updates without data loss

### Two-Query Approach

**Pattern:**
1. Query demographics (base patient data)
2. Query clinical events (loop through event types with DUMMYT)

**Benefits:**
- Cleaner code (separate concerns)
- Better performance (demographics query runs once)
- Easier maintenance (event queries isolated)

### 5 Clinical Events

1. **Morse Score** - Fall risk assessment (event_cd: TBD)
2. **Call Light** - Patient call light usage (event_cd: TBD)
3. **IV Sites** - IV site assessment (event_cd: TBD)
4. **SCDs** - Sequential compression device usage (event_cd: TBD)
5. **Safety** - General safety assessment (event_cd: TBD)

**Note:** event_cd values to be confirmed during CERT validation

### CCL Syntax Reminders

**ALWAYS consult before writing/modifying CCL:**
- **Syntax Guide:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_SYNTAX_GUIDE.md`
- **Common Patterns:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_COMMON_PATTERNS.md`
- **Data Model Reports:** `/Users/troyshelton/Projects/CCL_REFERENCE/Oracle Cerner - Millennium Data Model Reports/2025401(2025.4.01) Models/`

**Critical Rules:**
1. JOIN syntax: Use `outerjoin()`, NOT SQL-style LEFT JOIN
2. FROM clause: NO parentheses
3. NULL handling: Numeric fields use 0, date fields use IS NULL
4. expand() pattern: `(count = 0 OR expand(...))`
5. DECLARE/SET: ONLY outside SELECT statements (use simple assignment inside)
6. Record paths in ORDER BY: Use aliases, not full paths
7. Column aliases: Use CCL syntax `alias = field`, NOT SQL `AS`

---

## Phase 2: Inpatient Implementation (Pending)

**Current State:** Using ER tracking board pattern (placeholder)
**Future State:** Direct inpatient encounter queries

### Changes Needed

1. **Nursing Unit Dropdown** (replaces ER unit dropdown)
   - Decide options: 4 East, 3 West, ICU, Telemetry, Med-Surg, etc.
   - Update `src/web/index.html` dropdown (line ~155)
   - Update event handler in `src/web/js/main.js`

2. **New CCL Program** (inpatient encounters)
   - Create: `src/ccl/1_cust_mp_inp_get_encounters.prg`
   - Query: encounter_domain + encounter tables (NOT tracking board)
   - Filter: `e.loc_nurse_unit_cd IN [nursing unit codes]`

3. **Update Service** (inpatient unit patients)
   - Update `PatientListService.js` method
   - Add `getInpatientUnitPatients()` or rename existing
   - Update mock data for nursing units

4. **Testing & Validation**
   - Test unit-specific patient lists
   - Validate with real data in CERT
   - Update documentation

**See:** `DIFFERENCES-FROM-ER-TEMPLATE.md` for complete details

### Query Pattern Comparison

**Current (ER - Placeholder):**
```ccl
SELECT FROM tracking_board
WHERE tracking_group_cd = [ER facility code]
```

**Future (Inpatient - Phase 2):**
```ccl
SELECT FROM encounter e, encntr_domain ed
WHERE ed.encntr_domain_cd = [inpatient domain code]
AND e.loc_nurse_unit_cd IN [nursing unit codes]
```

---

## Git Workflow

### Issue → Branch → CERT → PR → Tag Pattern

**Current Example (Issue #1):**

1. **Create GitHub Issue** - Describes feature (#1: Date Navigator)
2. **Create Feature Branch** - `feature/v1.1.0-date-navigator`
3. **Develop & Test Locally** - Mock data validation
4. **Deploy to CERT** - Azure CERT validation (2025-12-15)
5. **CERT Validation** - Test with real clinical data
6. **Create Pull Request** - Code review before production
7. **Tag Release** - v1.1.0-mobility (with "Closes #1")
8. **Merge to Main** - Production deployment

### Branching Strategy

- **main** - Production-ready code
- **feature/vX.Y.Z-description** - Feature development
- **hotfix/vX.Y.Z-description** - Emergency fixes

### Commit Messages

```bash
# Feature commits
git commit -m "feat: add date navigator UI (issue #1)"

# Bug fixes
git commit -m "fix: correct date parameter format (issue #1)"

# Documentation
git commit -m "docs: update CLAUDE.md with project-specific content"
```

---

## Azure Deployment

### CERT Environment (Testing)

**⚠️ DEPLOYMENT VERIFICATION REQUIRED** (see workflow above)

```bash
# Deploy to CERT
az storage blob upload-batch \
  --source /Users/troyshelton/Projects/vandalia/mobility-dashboard/src/web \
  --destination '$web/mobility-dashboard/src' \
  --account-name ihazurestoragedev \
  --overwrite
```

**CERT URL:** [TBD - get from Azure portal]

### Production Environment

**⚠️ DEPLOYMENT VERIFICATION REQUIRED** (see workflow above)
**⚠️ CODE REVIEW REQUIRED** (see workflow above)

```bash
# Deploy to Production (AFTER PR approval and CERT validation)
az storage blob upload-batch \
  --source /Users/troyshelton/Projects/vandalia/mobility-dashboard/src/web \
  --destination '$web/mobility-dashboard/src' \
  --account-name ihazurestorageprod \
  --overwrite
```

**Production URL:** [TBD - get from Azure portal]

**See:** `AZURE_DEPLOYMENT.md` for detailed deployment procedures

---

## Development Guidelines

### NEVER Modify Working CCL Patterns

**Critical Rule:** If a CCL program is working, PRESERVE its patterns when extending

**Example (Date Navigator Feature):**
- ✅ Copied working two-query pattern from `v02`
- ✅ Added date filtering WITHOUT changing query structure
- ✅ Preserved DUMMYT pattern for record updates
- ✅ Backed up previous version (`v02`) before creating `v03`

**Pattern:**
1. Backup current working version
2. Copy entire structure (HEAD/DETAIL/FOOT)
3. Make incremental changes
4. Test immediately
5. Never mix pattern changes with feature additions

### Service Architecture Preservation

**From sepsis-dashboard (proven production patterns):**
- PatientListService pattern (list management)
- SendCclRequest wrapper (CCL communication)
- XMLCclRequestSimulator (mock data)
- VisualIndicators (loading/error messages)
- Config centralization

**Rule:** Don't recreate these from scratch - copy and modify

### Testing Strategy

**Local → CERT → Production**

1. **Local Testing** (XMLCclRequestSimulator)
   - Mock data matches real data structure
   - All UI interactions work
   - Date navigation logic validated
   - No console errors

2. **CERT Validation** (Real clinical data)
   - Verify event_cd values correct
   - Test date filtering accuracy
   - Validate clinical event values
   - User acceptance testing

3. **Production Deployment** (After PR approval)
   - Deploy during maintenance window
   - Monitor for errors
   - User training/documentation

### Mock Data Requirements

**Must match real data structure exactly:**
- Same column count
- Same data types
- Same null handling
- Date-aware (today/yesterday dynamic)

**Example (XMLCclRequestSimulator.js):**
```javascript
const today = new Date();
const yesterday = new Date(today);
yesterday.setDate(today.getDate() - 1);

// Generate date-aware mock data
patients.forEach(patient => {
  patient.morse_score = Math.random() > 0.5 ?
    formatDate(today) : formatDate(yesterday);
});
```

---

## Differences from ER Template

### What Changed (v1.0.0-mobility)

**Renamed Programs:**
- sepsis → mobility context
- All 12 generic programs (gen_*, plst_*) preserved

**Removed:**
- All sepsis-specific code (40 files deleted)
- Sepsis clinical event queries (13 columns)
- SEP-1 bundle logic
- Sepsis documentation

**Simplified:**
- Demographics-only foundation (8 columns)
- Generic patient list functionality
- Reusable CCL programs

### What Was Added (v1.1.0-mobility)

**Date Navigator Feature:**
- Outlook-style date controls (Today/Previous/Next)
- Date state management
- CCL date filtering (mmddyyyy format)
- 5 clinical events (temporal data)
- Nested Handsontable headers

**New Patterns:**
- Date parameter passing (JavaScript → CCL)
- DUMMYT pattern for clinical event updates
- Two-query approach (demographics + events)

### What's Pending (Phase 2)

**Inpatient Implementation:**
- Nursing unit dropdown (replaces ER unit dropdown)
- Inpatient encounter queries (replaces tracking board)
- New CCL program: `1_cust_mp_inp_get_encounters.prg`

---

## TaskMaster Integration

**This project IS configured for TaskMaster.**

**For complete TaskMaster documentation, see:**
`.claude/TM_COMMANDS_GUIDE.md`

**Quick Reference:**
```bash
# Daily workflow
task-master list                              # Show all tasks
task-master next                              # Get next task
task-master show <id>                        # View task details
task-master set-status --id=<id> --status=done  # Complete task

# Task management
task-master add-subtask --parent=<id> --title="..." --description="..."
task-master update-subtask --id=<id> --prompt="notes"
```

**When to Use TaskMaster:**
- ✅ Healthcare production workflows (ALWAYS)
- ✅ Feature development (Issue #1, Issue #2, etc.)
- ✅ Multi-step complex tasks
- ✅ When validation gates needed

**When NOT to Use TodoWrite:**
- ❌ During TaskMaster workflows
- ❌ For development tasks
- ❌ When GitHub issue is open
- ❌ When on feature branch

---

## Reference Materials

### CCL Development
- **CCL Syntax Guide:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_SYNTAX_GUIDE.md`
- **CCL Common Patterns:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_COMMON_PATTERNS.md`
- **CCL Order Detection:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_ORDER_DETECTION_PATTERNS.md`
- **CCL Beginner:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_BEGINNER.md`
- **CCL Intermediate:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_INTERMEDIATE.md`
- **CCL Advanced:** `/Users/troyshelton/Projects/CCL_REFERENCE/CCL_ADVANCED.md`

### Data Model
- **Oracle Cerner Data Model Reports:**
  `/Users/troyshelton/Projects/CCL_REFERENCE/Oracle Cerner - Millennium Data Model Reports/2025401(2025.4.01) Models/`
- **Use for:** Verifying table schemas, field names, data types before writing queries

### Standards & Workflows
- **Development Standards:** `/Users/troyshelton/Projects/.standards/`
- **Git Workflow:** `/Users/troyshelton/Projects/.standards/GIT-WORKFLOW.md`
- **Versioning:** `/Users/troyshelton/Projects/.standards/VERSIONING.md`
- **Pre-Commit Checklist:** `/Users/troyshelton/Projects/.standards/PRE-COMMIT-CHECKLIST.md`
- **Documentation Sync:** `/Users/troyshelton/Projects/.standards/DOCUMENTATION-SYNC-PROTOCOL.md`

### Workflow Templates
- **TaskMaster Git Enhancement:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/TASKMASTER-GIT-ENHANCEMENT.md`
- **Documentation Sync Workflow:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/TASKMASTER-DOC-SYNC.md`
- **Deployment Verification:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md`
- **Code Review:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md`
- **Validation Gate Protocol:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md`

### Base Templates
- **ER Tracking Dashboard:** `/Users/troyshelton/Projects/vandalia/er-tracking-dashboard-template/`
- **Sepsis Dashboard:** `/Users/troyshelton/Projects/vandalia/sepsis-dashboard/`

---

## Version History Summary

### v1.1.0-mobility (In Progress - 70% Complete)
- **Feature:** Date Navigator with temporal clinical event tracking
- **Status:** Deployed to CERT (2025-12-15), CERT validation pending
- **Branch:** feature/v1.1.0-date-navigator
- **Issue:** #1

### v1.0.0-mobility (Released 2025-12-14)
- **Feature:** Demographics foundation with 12 reusable CCL programs
- **Base:** er-tracking-dashboard-template v1.0.0
- **Status:** Production-ready template

---

*Last Updated: 2025-12-16*
*CLAUDE.md synchronized with README.md and CHANGELOG.md*
*TaskMaster guide preserved in `.claude/TM_COMMANDS_GUIDE.md`*
