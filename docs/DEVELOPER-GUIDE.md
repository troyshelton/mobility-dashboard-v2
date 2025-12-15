# Sepsis Dashboard - Developer Guide

**Version:** 1.44.0-sepsis
**Date:** 2025-11-03
**For:** Developers maintaining or extending the Sepsis Dashboard
**Audience:** Co-workers with MPages development experience

---

## Quick Start for Experienced MPage Developers

**You said you've developed MPages before, so here's what's different:**

1. **Service Architecture** - Separated concerns (not one monolithic JS file)
2. **Pure Vanilla JavaScript** - No frameworks (React, Vue, etc.) - intentional choice
3. **Dual Deployment** - Works on both Azure (web server) and Citrix (file://)
4. **Modern Tooling** - Uses current libraries but keeps it simple

**If you're comfortable with:**
- XMLCclRequest for CCL communication ✅ (same pattern)
- MPAGES_EVENT for PowerForms ✅ (same pattern)
- File protocol MPage development ✅ (we use that here)

**Then you'll find this familiar, just more organized.**

---

## Architecture Overview

### Why Pure JavaScript? (No Framework)

**Intentional Decision - Here's Why:**

1. **Cerner PowerChart Compatibility**
   - PowerChart environments have strict security policies
   - Frameworks (React, Vue, Angular) add complexity and potential CSP issues
   - Vanilla JS = zero compatibility concerns

2. **Healthcare Reliability**
   - No framework version conflicts
   - No breaking changes from framework updates
   - Full control over every line of code

3. **Performance**
   - Zero framework overhead (~130KB total JS vs multi-MB frameworks)
   - Instant load time in PowerChart
   - No build process needed for deployment

4. **Maintainability for Small Team**
   - No framework expertise required
   - Any JavaScript developer can maintain
   - No build tools, transpilers, or package managers needed

**Trade-off:** More manual DOM manipulation, but worth it for stability.

---

## File Structure and Purpose

### JavaScript Files (11 total - 325KB)

```
src/web/js/
├── Config.js               (3.2KB)  - Configuration management
├── VisualIndicators.js     (7.2KB)  - UI state indicators
├── AdminCommands.js        (14KB)   - Admin utilities
├── UserInfoService.js      (5.6KB)  - User authentication
├── PatientListService.js   (14KB)   - Patient list management
├── SendCclRequest.js       (12KB)   - CCL communication (production)
├── XMLCclRequestSimulator.js (30KB) - Mock data (development)
├── PatientDataService.js   (122KB)  - Data processing & formatting
├── PowerFormLauncher.js    (3.8KB)  - PowerForm integration
├── PowerPlanLauncher.js    (14KB)   - PowerPlan integration
└── main.js                 (130KB)  - Application orchestration
```

---

## Service Architecture Pattern

### Why Separate Files? (Service Pattern)

**Traditional MPage Approach:**
```javascript
// One giant zzz_mpage.js file (300KB+)
// Everything mixed together
```

**This Dashboard Approach:**
```javascript
// Separated by responsibility
Config.js          → What can be configured
UserInfoService.js → Who is logged in
PatientListService.js → Which lists are available
PatientDataService.js → How to process patient data
main.js            → How everything works together
```

**Benefits:**
- ✅ Easier to find code (know which file to look in)
- ✅ Multiple developers can work simultaneously
- ✅ Test individual services in isolation
- ✅ Reuse services in other MPages
- ✅ Clearer separation of concerns

**Trade-off:** More files to load, but negligible performance impact.

---

## Core Services Explained

### 1. Config.js (3.2KB) - "The Control Panel"

**Purpose:** Central configuration for all toggleable features

**What it controls:**
```javascript
SIMULATOR_CONFIG - Dev mode (mock data) vs Production (real CCL)
USER_CONTEXT_CONFIG - User impersonation for support scenarios
AUTO_REFRESH_CONFIG - Automatic dashboard refresh settings
```

**Why separate file?**
- Toggle simulator mode without touching code
- One place to change all configuration
- Safe for non-developers to modify

**Key Pattern:**
```javascript
window.SIMULATOR_CONFIG = {
    enabled: false  // Toggle here for dev vs prod
};
```

**When to modify:**
- Switching between development and production
- Enabling/disabling features
- Changing default settings

---

### 2. UserInfoService.js (5.6KB) - "Who Am I?"

**Purpose:** Get current user information from Cerner

**What it does:**
- Calls CCL program: `1_cust_mp_sep_user_info.prg`
- Returns: prsnl_id, username, position, location
- Handles: Simulator mode vs real CCL

**Key Functions:**
```javascript
UserInfoService.getUserInfo(callback)
```

**When to use:**
- Need to know who's logged in
- User-specific features
- Audit trail requirements

**Pattern:**
```javascript
UserInfoService.getUserInfo(function(userInfo) {
    console.log('Logged in as:', userInfo.username);
    // Use userInfo.prsnl_id for queries
});
```

---

### 3. PatientListService.js (14KB) - "Which Lists?"

**Purpose:** Get available patient lists for current user

**What it does:**
- Calls CCL program: `1_cust_mp_sep_get_plists.prg`
- Returns: List of available patient lists
- Populates: Dropdown selector

**Key Functions:**
```javascript
PatientListService.getPatientLists(callback)
```

**Why needed:**
- Users may have access to multiple patient lists
- List A vs List B differentiation
- User-specific list permissions

**Pattern:**
```javascript
PatientListService.getPatientLists(function(lists) {
    lists.forEach(function(list) {
        // Add to dropdown
    });
});
```

---

### 4. PatientDataService.js (122KB) - "The Workhorse"

**Purpose:** Process raw CCL data into displayable format

**What it does:**
- Calls CCL program: `1_cust_mp_sep_get_pdata_20.prg` (latest version)
- Parses JSON response from CCL
- Formats data for Handsontable display
- Calculates derived values (time elapsed, bundle compliance)
- Handles complex tooltip content

**Why so large?**
- Handles 15+ columns of data
- Complex tooltip formatting (each column has different rules)
- Time calculations (hours since sepsis alert)
- Bundle compliance logic
- Error handling for missing data

**Key Functions:**
```javascript
PatientDataService.getPatientData(patientListId, callback)
PatientDataService.formatPatientForTable(patient)
```

**Pattern:**
```javascript
PatientDataService.getPatientData(listId, function(patients) {
    patients.forEach(function(patient) {
        var formatted = PatientDataService.formatPatientForTable(patient);
        // Add to Handsontable
    });
});
```

**Important:** This is where most business logic lives.

---

### 5. SendCclRequest.js (12KB) - "Talk to Cerner"

**Purpose:** Production CCL communication via XMLCclRequest

**What it does:**
- Wrapper around Cerner's XMLCclRequest
- Handles request/response lifecycle
- Error handling and timeouts
- Logging for debugging

**Key Pattern:**
```javascript
var request = new XMLCclRequest();
request.open('GET', 'CCL_PROGRAM_NAME');
request.send('^MINE^, value($PAT_Personid$), value($VIS_Encntrid$)');
```

**When used:** Production mode (SIMULATOR_CONFIG.enabled = false)

---

### 6. XMLCclRequestSimulator.js (30KB) - "Fake Cerner"

**Purpose:** Mock CCL responses for development without Cerner access

**What it does:**
- Simulates XMLCclRequest behavior
- Returns realistic test data
- Allows development on Mac/PC without Citrix

**Test Data Included:**
- 8 mock patients with various sepsis scenarios
- Completed assessments, pending items, alerts
- Realistic timestamps and clinical values

**When used:** Development mode (SIMULATOR_CONFIG.enabled = true)

**Why needed:**
- Develop on local machine without VPN
- Test edge cases easily
- Faster iteration (no CCL compile cycle)

---

### 7. main.js (130KB) - "The Orchestra Conductor"

**Purpose:** Application initialization and Handsontable configuration

**What it does:**
- Initializes Handsontable grid
- Configures all column renderers (15+ columns)
- Handles user interactions (dropdown, refresh, filters)
- Coordinates between services
- Manages auto-refresh functionality

**Why so large?**
- 15+ custom column renderers (each 50-500 lines)
- Tooltip logic for every column type
- Click handlers for PowerForm/PowerPlan launches
- Filter logic
- Auto-refresh state management

**Key Sections:**
```javascript
window.PatientListApp = {
    init: function() {
        // 1. Initialize services
        // 2. Setup UI event listeners
        // 3. Configure Handsontable
    },

    loadPatientData: function(listId) {
        // Fetch and display patient data
    }
};
```

**Pattern:**
- Services do the work
- main.js coordinates everything
- UI logic separated from business logic

---

### 8. PowerFormLauncher.js (3.8KB) - "Launch PowerForms"

**Purpose:** Integration with Cerner PowerForms (documentation screens)

**What it does:**
- Launches PowerForms via MPAGES_EVENT
- Passes patient context (person_id, encntr_id)
- Opens specific PowerForms (Screening, Perfusion)

**Key Function:**
```javascript
launchPowerForm(personId, encntrId, formId, activityId, chartMode)
```

**PowerForms Used:**
- Sepsis Screening: Form ID 5028848557
- Perfusion Assessment: Form ID 162637233

---

### 9. PowerPlanLauncher.js (14KB) - "Launch PowerPlans"

**Purpose:** Integration with Cerner PowerPlans (order sets)

**What it does:**
- Launches PowerPlan ordering via MPAGES_EVENT
- Supports multiple PowerPlan types
- Handles PowerPlan status display

**PowerPlans Supported:**
- Blood Cultures + Antibiotics (abbreviated)
- Full sepsis bundle PowerPlan

---

### 10. VisualIndicators.js (7.2KB) - "Status Bar"

**Purpose:** Visual feedback for configuration state

**What it shows:**
- Simulator mode indicator (Dev vs Prod)
- User impersonation status
- Auto-refresh state
- Environment information

**Pattern:**
```javascript
window.updateUnifiedIndicator()  // Call when config changes
```

---

### 11. AdminCommands.js (14KB) - "Developer Tools"

**Purpose:** Console commands for debugging and admin tasks

**Available Commands:**
```javascript
toggleSimulator()      // Switch between dev/prod mode
impersonateUser(id)    // Test as different user
clearStorage()         // Reset localStorage
showConfig()           // Display current configuration
```

**When to use:** Debugging, testing, support scenarios

---

## Libraries Used

### Why These Specific Libraries?

#### Handsontable v15.2.0 (Excel-like Grid)

**Why:**
- ✅ Excel-like interface (familiar to clinical users)
- ✅ Built-in filtering, sorting
- ✅ Custom cell renderers (icons, colors, tooltips)
- ✅ Large dataset performance (100+ patients)

**Alternative considered:** Custom table with HTML
**Why not:** Would need to rebuild filtering, sorting, performance optimization

**Where used:** main.js (grid configuration and column renderers)

#### Tippy.js v6.3.7 (Tooltips)

**Why:**
- ✅ Automatic viewport collision detection (tooltips don't go off-screen)
- ✅ Professional animations
- ✅ Positioning engine (auto-flip, shift)
- ✅ Reduced code: 214 lines removed vs manual tooltips

**Alternative considered:** Manual tooltip positioning
**Why not:** Tedious calculations, viewport edge issues (we had this problem!)

**Where used:** All column renderers in main.js and PatientDataService.js

#### Font Awesome 6.5.1 (Medical Icons)

**Why:**
- ✅ Healthcare-standard iconography
- ✅ Color-coded status indicators (red=critical, yellow=alert, green=stable)
- ✅ Universal recognition

**Icons used:**
- Circle icons (completed vs pending states)
- Alert icons (warnings, critical values)
- Medical symbols (thermometer for acuity)

**Where used:** Column renderers, custom cell formatting

#### Eruda DevTools (Debug Console)

**Why:**
- ✅ PowerChart blocks browser DevTools
- ✅ Cannot be blocked by Citrix policies
- ✅ Full console, network, DOM inspector
- ✅ Keyboard shortcut (Ctrl+Shift+F)

**When to use:** Debugging in production Citrix environment

**Where configured:** index.html (initialization) and AdminCommands.js (toggle)

---

## Data Flow Architecture

### The Complete Journey (User Click → Display)

```
1. User selects patient list from dropdown
   ↓
2. main.js calls PatientListService.loadPatientData(listId)
   ↓
3. PatientDataService checks SIMULATOR_CONFIG
   ↓
   If simulator enabled:
   → XMLCclRequestSimulator.mockResponse()
   → Returns test data immediately

   If simulator disabled:
   → SendCclRequest creates XMLCclRequest
   → Calls 1_cust_mp_sep_get_pdata_20.prg
   → CCL queries Cerner database
   → Returns JSON via _memory_reply_string
   ↓
4. PatientDataService.formatPatientForTable(patient)
   → Parses JSON
   → Calculates derived values
   → Formats for Handsontable
   ↓
5. main.js adds rows to Handsontable
   ↓
6. Column renderers execute for each cell
   → Apply custom formatting
   → Add tooltips via Tippy.js
   → Add click handlers for PowerForm/PowerPlan
   ↓
7. User sees formatted, interactive dashboard
```

---

## Key Design Patterns

### Pattern 1: Configuration-Driven Behavior

**Instead of:**
```javascript
// Hard-coded behavior
if (isDevelopment) {
    useMockData();
} else {
    useRealCCL();
}
```

**We use:**
```javascript
// Config.js controls behavior
if (window.SIMULATOR_CONFIG.enabled) {
    XMLCclRequestSimulator.mockResponse();
} else {
    SendCclRequest.callCCL();
}
```

**Benefit:** Change mode without code changes, just toggle config.

---

### Pattern 2: Service Responsibilities

**Each service has ONE job:**

| Service | Single Responsibility |
|---------|----------------------|
| UserInfoService | Get current user context |
| PatientListService | Get available patient lists |
| PatientDataService | Process patient data |
| SendCclRequest | Communicate with CCL |
| XMLCclRequestSimulator | Provide test data |

**Why:** Easy to find code, test independently, reuse in other MPages.

---

### Pattern 3: Callback-Based Async

**Pattern used throughout:**
```javascript
Service.doSomething(function(result) {
    // Handle result here
});
```

**Why not Promises/async-await?**
- Matches Cerner's XMLCclRequest callback pattern
- No transpilation needed (works in older IE)
- Familiar pattern to MPage developers

---

### Pattern 4: Custom Renderers for Every Column

**Handsontable allows custom cell rendering:**

```javascript
{
    data: 'ALERT_TYPE',
    renderer: function(instance, td, row, col, prop, value, cellProperties) {
        // Custom logic for this column
        if (value === 'CRITICAL') {
            td.innerHTML = '<i class="fas fa-circle" style="color: red;"></i>';
        }
        return td;
    }
}
```

**We have 15+ custom renderers:**
- Alert column (icon + color)
- Screen column (completed vs pending)
- PowerPlan column (clickable circles)
- Lactate column (critical values highlighted)
- Blood Cultures column (ordered status)
- Antibiotics column (administration tracking)
- Fluids column (volume calculations)
- And more...

**Each renderer:**
1. Checks data availability
2. Applies conditional logic
3. Formats display
4. Adds tooltip
5. Adds click handler (if applicable)

---

## CCL Integration

### How Dashboard Talks to Cerner

**Primary CCL Program:** `1_cust_mp_sep_get_pdata_20.prg` (v20, latest)

**What it queries:**
- Patient demographics
- Sepsis alerts (clinical_event)
- Screening assessments (PowerForm completions)
- Lactate values (lab results)
- Blood culture orders
- Antibiotic administrations
- IV fluid administrations
- Pressor medications
- Perfusion assessments
- PowerPlan orders

**Response Format:** JSON via `_memory_reply_string`

**Example Response Structure:**
```json
{
  "patients": [
    {
      "PERSON_ID": "12345",
      "ENCNTR_ID": "67890",
      "NAME": "DOE, JOHN",
      "ALERT_TYPE": "Severe Sepsis",
      "SCREEN_ASSESSMENT": "Severe Sepsis",
      "LACTATE_CRITICAL": "5.2",
      "BLOOD_CULTURES_ORDERED": "Y",
      ...
    }
  ]
}
```

---

### CCL Version History (Why v20?)

**Versioning Pattern:** Incremental versions as features added

- **v01-v10:** Basic patient data and sepsis alerts
- **v11-v13:** Added lactate tracking, blood cultures
- **v14-v15:** Added antibiotics, fluids, pressors
- **v16:** Added Normosol fluid detection
- **v17-v18:** PowerPlan integration
- **v19:** Screening PowerForm tracking
- **v20:** Perfusion PowerForm tracking ⬅️ **Current**

**Important: Version Numbers Are Source Control Only!**

**File names on disk:**
- `1_cust_mp_sep_get_pdata_20.prg` (v20)
- `1_cust_mp_sep_get_pdata_21.prg` (v21)

**But called in JavaScript as:**
```javascript
// Always the SAME name (no version number!)
request.open('GET', '1_CUST_MP_SEP_GET_PDATA');
```

**Why?**
- When you compile/include CCL, it creates a runtime object
- The object name doesn't include version number
- Each new version overwrites the previous in Cerner's memory
- Version numbers in filenames are for backup/rollback only

**Pattern for updates:**
```bash
# 1. Create new version (preserves old as backup)
cp 1_cust_mp_sep_get_pdata_20.prg → 1_cust_mp_sep_get_pdata_21.prg

# 2. Edit v21 with your changes

# 3. Compile and include v21
# This OVERWRITES the runtime object '1_CUST_MP_SEP_GET_PDATA'

# 4. No JavaScript changes needed!
# Code still calls '1_CUST_MP_SEP_GET_PDATA' (generic name)

# 5. Test with new version
```

**Rollback:**
```bash
# Just re-compile/include the old version
# It will overwrite the runtime object back to v20
```

---

## Development Workflow

### Local Development (Without Citrix Access)

**1. Enable Simulator Mode:**
```javascript
// In Config.js
window.SIMULATOR_CONFIG = {
    enabled: true  // Use mock data
};
```

**2. Open HTML Locally:**
```bash
open src/web/index.html
# OR
cd src/web && python3 -m http.server 8000
# Then: http://localhost:8000
```

**3. See Test Data:**
- XMLCclRequestSimulator provides 8 mock patients
- All scenarios covered (critical, alert, stable)
- No Cerner connection needed

---

### Testing in Cerner CERT Environment

**1. Disable Simulator Mode:**
```javascript
// In Config.js
window.SIMULATOR_CONFIG = {
    enabled: false  // Use real CCL
};
```

**2. Deploy to Azure CERT:**
```bash
az storage blob upload-batch \
  --account-name ihazurestoragedev \
  --destination '$web/camc-sepsis-mpage/src' \
  --source src/web \
  --overwrite --auth-mode key
```

**3. Access via URL:**
```
https://ihazurestoragedev.z13.web.core.windows.net/camc-sepsis-mpage/src/index.html
```

**4. Test with Real Data:**
- Real patient lists
- Real sepsis alerts
- Real CCL queries

---

### Production Deployment (Citrix I: Drive)

**See:** `CITRIX-DEPLOYMENT-GUIDE.md` for complete instructions

**Summary:**
- CCL driver in backend ($cust_script)
- Web assets on I: drive
- Accessed via PowerChart tab (PrefMaint)
- No web server needed

---

## Column Architecture

### How Columns Work (The Pattern)

**Every column follows this structure:**

```javascript
{
    data: 'FIELD_NAME',          // JSON field from CCL
    width: 100,                  // Column width in pixels
    readOnly: true,              // No editing
    renderer: function(instance, td, row, col, prop, value, cellProperties) {
        // 1. Get patient data for this row
        var patient = instance.getSourceDataAtRow(row);

        // 2. Apply conditional logic
        if (patient.LACTATE_CRITICAL >= 4.0) {
            // Critical lactate
        }

        // 3. Format cell content
        td.innerHTML = '<i class="fas fa-circle"></i> ' + value;

        // 4. Add tooltip (Tippy.js)
        tippy(td, {
            content: 'Detailed information here'
        });

        // 5. Add click handler (if applicable)
        td.onclick = function() {
            launchPowerForm(...);
        };

        return td;
    }
}
```

**Columns in Dashboard (15 total):**

1. **Patient Name** - Basic text display
2. **Age** - Calculated from birth date
3. **Acuity** - Icon with severity level
4. **Alert** - Sepsis alert type with tooltip
5. **Screen** - Assessment status, clickable to launch PowerForm
6. **Time Zero** - Hours since alert (countdown)
7. **PowerPlan** - Ordered status, clickable to order
8. **Lactate** - Critical values highlighted, tooltip with all values
9. **Blood Cultures** - Ordered status with tooltip
10. **Antibiotics** - Administered status with tooltip
11. **Fluids** - Volume calculation with tooltip
12. **Perfusion** - Assessment completion with tooltip
13. **Pressors** - Detected medications
14. **Bundle** - Overall compliance icon
15. **Actions** - Additional controls (if needed)

---

## Understanding the Renderer Pattern

### Example: Alert Column Renderer

**Let's break down a real column:**

```javascript
// Alert column configuration
{
    data: 'ALERT_TYPE',
    width: 110,
    renderer: function(instance, td, row, col, prop, value, cellProperties) {
        // Get full patient object for this row
        var patient = instance.getSourceDataAtRow(row);

        // Default styling
        td.style.textAlign = 'left';
        td.style.paddingLeft = '8px';
        td.className = 'htLeft htMiddle';

        // Conditional display based on alert data
        if (patient.ALERT_DETAILS && patient.ALERT_DETAILS.length > 0) {
            var alert = patient.ALERT_DETAILS[0];

            // Display icon + text
            var iconHtml = '<i class="fas fa-exclamation-triangle" style="color: #dc2626; margin-right: 4px;"></i>';
            td.innerHTML = iconHtml + alert.ALERT_TYPE;

            // Add tooltip with details
            tippy(td, {
                content: buildAlertTooltip(alert)  // Helper function
            });
        } else {
            // No alert
            td.innerHTML = '--';
            td.style.color = '#94a3b8';
        }

        return td;
    }
}
```

**Every renderer follows this pattern:**
1. Get data
2. Style the cell
3. Conditional logic
4. Format display
5. Add tooltip
6. Add interactivity (if needed)

---

## Tooltip Architecture

### Tooltip Philosophy

**Before Tippy.js (Manual):**
- 125 lines for perfusion tooltip positioning
- Manual viewport collision detection
- Inconsistent styling
- Difficult to maintain

**After Tippy.js:**
- 12 lines for same tooltip
- Automatic positioning
- Consistent styling
- Easy to maintain

**Standard Pattern:**
```javascript
tippy(element, {
    content: buildStructuredTooltip([
        { label: 'PowerForm:', value: 'Sepsis Screening' },
        { label: 'Completed:', value: '10/24/2025 14:30' },
        { label: 'By:', value: 'John Doe, RN' }
    ])
});
```

**Helper Functions (in main.js):**
```javascript
buildStructuredTooltip(items)  // Label-value pairs
buildActionTooltip(message)    // Simple action messages
createSepsisTooltip(element, content)  // Factory with auto-hide
```

---

## Why This Architecture?

### Design Decisions Explained

#### Decision 1: No Framework

**Rationale:**
- PowerChart compatibility is #1 priority
- Healthcare reliability > developer convenience
- Small team = no framework expertise needed
- No build process = simpler deployment

**Trade-off:** More manual work, but predictable behavior.

---

#### Decision 2: Service Pattern (Separate Files)

**Rationale:**
- Traditional MPage = one giant JS file (hard to navigate)
- Services = logical separation (easy to find code)
- Reusable in other MPages
- Multiple developers can work in parallel

**Trade-off:** More HTTP requests, but negligible in practice.

---

#### Decision 3: Simulator Mode

**Rationale:**
- Can't develop in PowerChart (slow compile-test cycle)
- Need realistic test data
- Want fast iteration locally

**Trade-off:** Must keep mock data in sync with CCL changes.

---

#### Decision 4: Local Libraries (No CDNs)

**Rationale:**
- File:// protocol doesn't allow external requests
- Citrix environment may block CDNs
- Guaranteed to work offline

**Trade-off:** Larger repository size, but reliability wins.

---

## Common Development Tasks

### Task 1: Add a New Column

**Steps:**

1. **Update CCL (1_cust_mp_sep_get_pdata_*.prg):**
```ccl
; Add field to record structure
record drec (
    1 patients[*]
        2 NEW_FIELD = vc
)

; Query for data
detail
    drec->patients[d1.seq].NEW_FIELD = ce.result_val
```

2. **Add Column in main.js:**
```javascript
{
    data: 'NEW_FIELD',
    width: 100,
    renderer: function(instance, td, row, col, prop, value, cellProperties) {
        td.innerHTML = value || '--';
        return td;
    }
}
```

3. **Test in simulator:**
- Add test data to XMLCclRequestSimulator.js
- Verify column displays

4. **Deploy and test in CERT**

---

### Task 2: Modify Existing Column

**Steps:**

1. **Find the column renderer in main.js**
   - Search for column header text
   - Or search for `data: 'FIELD_NAME'`

2. **Modify renderer logic**
   - Update conditional logic
   - Change formatting
   - Update tooltip content

3. **Test locally with simulator**

4. **Deploy to CERT for validation**

---

### Task 3: Add PowerForm Launch

**Pattern (from PowerFormLauncher.js):**

```javascript
// In column renderer
td.onclick = function() {
    launchPowerForm(
        patient.PERSON_ID,     // Patient person_id
        patient.ENCNTR_ID,     // Encounter id
        5028848557,            // PowerForm form_id (from DCP_FORMS_REF)
        0,                     // Activity ID (0 = new)
        0                      // Chart mode (0 = edit)
    );
};

// Add visual cue
td.className += ' clickable-action';
td.style.cursor = 'pointer';
```

**Find PowerForm IDs:**
```ccl
; In Cerner
select form_id, description
from dcp_forms_ref
where description like '%Sepsis%'
```

---

### Task 4: Update Simulator Data

**File:** XMLCclRequestSimulator.js

**Pattern:**
```javascript
patients: [
    {
        PERSON_ID: "12345",
        ENCNTR_ID: "67890",
        NAME: "TEST, PATIENT",
        ALERT_TYPE: "Severe Sepsis",
        // Add your new field here
        NEW_FIELD: "test value"
    }
]
```

**Tip:** Create scenarios for:
- Completed state
- Pending state
- Critical values
- Edge cases

---

## Debugging Guide

### Using Eruda Console in PowerChart

**Access:**
```
Ctrl+Shift+F (or Cmd+Shift+F on Mac)
```

**Or manually:**
```javascript
// In browser console or CCL output
toggleEruda()   // Toggle on/off
showEruda()     // Show
hideEruda()     // Hide
```

**Tabs Available:**
- **Console:** JavaScript logs, errors
- **Elements:** DOM inspector
- **Network:** Track CCL requests
- **Resources:** View loaded files
- **Info:** Environment details

---

### Common Debug Scenarios

#### Scenario 1: Column Not Displaying

**Check:**
1. Is field in CCL response? (Console → Network → View response)
2. Is renderer executing? (Add `console.log` in renderer)
3. Is Handsontable configured? (Check columns array)

**Debug:**
```javascript
// In renderer
console.log('Rendering FIELD_NAME:', value, 'for patient:', patient.NAME);
```

---

#### Scenario 2: Tooltip Not Appearing

**Check:**
1. Is Tippy.js loaded? (`typeof tippy !== 'undefined'`)
2. Is tooltip content defined?
3. Is element still in DOM?

**Debug:**
```javascript
// Test tooltip manually
tippy(document.querySelector('.test'), {
    content: 'Test tooltip'
});
```

---

#### Scenario 3: CCL Not Responding

**Check:**
1. Is simulator disabled? (Check Config.js)
2. Is CCL program included? (Try in Discern Explorer)
3. Is request formatted correctly?

**Debug:**
```javascript
// In SendCclRequest.js - uncomment logging
console.log('Calling CCL:', programName, 'with params:', params);
```

---

## Code Organization Philosophy

### "Convention Over Configuration"

**File Naming:**
```
UserInfoService.js      → Service that gets user info
PatientDataService.js   → Service that processes patient data
PowerFormLauncher.js    → Utility that launches PowerForms
```

**Function Naming:**
```
getUserInfo()           → Gets user info
getPatientData()        → Gets patient data
launchPowerForm()       → Launches a PowerForm
```

**If it does what the name says, you're in the right place.**

---

### "Each File Has One Purpose"

**Ask: "What is this file responsible for?"**

- Config.js → "Configuration"
- UserInfoService.js → "User information"
- main.js → "Application coordination"

**If answer is complex, file might be doing too much.**

---

### "Services Don't Know About Each Other"

**Good:**
```javascript
// UserInfoService.js
function getUserInfo(callback) {
    // Just gets user info, returns it
    callback(userData);
}
```

**Bad:**
```javascript
// UserInfoService.js
function getUserInfo(callback) {
    // Gets user info
    var data = ...;
    // Then also loads patient lists (wrong!)
    PatientListService.getPatientLists(...);
}
```

**Why:** Services should be reusable independently.

---

## Performance Considerations

### Why It's Fast

**1. Lazy Loading:**
- Only loads data when patient list selected
- Doesn't query all lists on page load

**2. Efficient Rendering:**
- Handsontable virtual scrolling (only renders visible rows)
- Tooltip creation on-demand (not pre-created)

**3. Minimal Dependencies:**
- Total JS: ~325KB (small compared to frameworks)
- All minified libraries
- Local hosting (no CDN latency)

**4. Smart Caching:**
- Patient list dropdown cached
- User info cached (doesn't re-query)

---

## Common Modifications

### How To: Change Simulator Mode

**File:** `src/web/js/Config.js`

**Change:**
```javascript
window.SIMULATOR_CONFIG = {
    enabled: true   // Dev mode
    // OR
    enabled: false  // Production mode
};
```

**When:** Switching between local dev and CERT/production testing

---

### How To: Add Test Patient to Simulator

**File:** `src/web/js/XMLCclRequestSimulator.js`

**Find:** `patients: [...]` array

**Add:**
```javascript
{
    PERSON_ID: "99999",
    ENCNTR_ID: "88888",
    NAME: "YOURTEST, PATIENT",
    AGE: "45",
    ACUITY: "2",
    ALERT_TYPE: "Severe Sepsis",
    ALERT_DETAILS: [
        {
            ALERT_TYPE: "Severe Sepsis",
            ALERT_DT_TM: "2025-11-03 10:00:00",
            CRITERIA: "Lactate ≥4.0, qSOFA ≥2"
        }
    ],
    // Add more fields as needed
}
```

---

### How To: Update to New CCL Version

**Important:** CCL programs are called WITHOUT version numbers in the code!

**File names on disk:**
- `1_cust_mp_sep_get_pdata_20.prg` (v20 - current)
- `1_cust_mp_sep_get_pdata_21.prg` (v21 - new version)

**But called in code as:**
```javascript
// Always calls the same name (no version number)
request.open('GET', '1_CUST_MP_SEP_GET_PDATA');
```

**Why?** When you compile/include the CCL program, it overwrites the previous version in Cerner's memory. The program object name doesn't include the version number.

**To deploy new version:**
1. Create new file: `1_cust_mp_sep_get_pdata_21.prg` (keeps v20 as backup)
2. Compile and include v21 (overwrites the runtime object)
3. No JavaScript changes needed (already calls generic name)
4. Test to verify new data structure works

**Version numbering is for source control only, not runtime.**

---

### How To: Modify Tooltip Content

**File:** `src/web/js/main.js`

**Find:** The column's renderer function

**Pattern:**
```javascript
// Build tooltip content
var tooltipContent = buildStructuredTooltip([
    { label: 'PowerForm:', value: 'Sepsis Screening' },
    { label: 'Completed:', value: completedDate },
    { label: 'By:', value: performedBy }
    // Add/remove/modify items here
]);

// Apply tooltip
tippy(td, { content: tooltipContent });
```

---

## Best Practices

### Do's ✅

- ✅ **Add console.log statements** for debugging
- ✅ **Test in simulator first** before CERT
- ✅ **Keep CCL versions** (don't overwrite old versions)
- ✅ **Document changes** in CHANGELOG.md
- ✅ **Use validation gates** (TaskMaster workflow)
- ✅ **Sync documentation** before committing
- ✅ **Create GitHub issue** before starting work

### Don'ts ❌

- ❌ **Don't mix concerns** (keep services separate)
- ❌ **Don't hardcode values** (use Config.js)
- ❌ **Don't skip testing** (simulator → CERT → production)
- ❌ **Don't modify original files** (create new versions)
- ❌ **Don't commit without doc sync** (recurring issue!)
- ❌ **Don't use TodoWrite** (use TaskMaster for development)

---

## Quick Reference

### File Sizes (What's Normal?)

| File | Size | What If Larger? |
|------|------|-----------------|
| Config.js | ~3KB | Adding too many configs? |
| UserInfoService.js | ~6KB | Should be simple |
| PatientListService.js | ~14KB | Should be simple |
| PatientDataService.js | ~122KB | Normal (complex formatting) |
| main.js | ~130KB | Normal (15+ renderers) |
| XMLCclRequestSimulator.js | ~30KB | Normal (test data) |

### File Load Order (Important!)

**In index.html - Order matters:**
```html
1. VisualIndicators.js   (UI indicators first)
2. Config.js             (Configuration)
3. AdminCommands.js      (Admin utilities)
4. SendCclRequest.js     (CCL communication)
5. XMLCclRequestSimulator.js (Mock data)
6. UserInfoService.js    (User context)
7. PatientListService.js (Patient lists)
8. PatientDataService.js (Data processing)
9. PowerFormLauncher.js  (PowerForm integration)
10. PowerPlanLauncher.js (PowerPlan integration)
11. Tippy.js libraries   (Tooltip system)
12. main.js              (Application init - LAST!)
```

**Why this order:**
- Services must load before main.js uses them
- Config must load before services check it
- Libraries before application code

---

## Getting Help

### Where to Look

**1. Inline Comments:**
- Every renderer has comments explaining logic
- Complex calculations documented
- CCL integration patterns explained

**2. Documentation:**
- `README.md` - Project overview
- `CHANGELOG.md` - What changed when
- `CLAUDE.md` - Development standards
- `CITRIX-DEPLOYMENT-GUIDE.md` - Deployment procedures
- This file - Architecture and patterns

**3. GitHub Issues:**
- Historical context for features
- Decision rationale
- Testing results

**4. Git History:**
```bash
# See what changed in a file
git log -p src/web/js/main.js

# See specific version
git show v1.44.0-sepsis:src/web/js/main.js
```

---

## Questions Your Co-Worker Might Ask

### Q: Why no React/Vue/Angular?

**A:** PowerChart compatibility and healthcare reliability over developer convenience. Frameworks add unnecessary risk in clinical environments.

---

### Q: Why so many files instead of one big JS file?

**A:** Service pattern allows parallel development, easier testing, and code reuse. Traditional one-file approach works but doesn't scale well with multiple developers.

---

### Q: What's the simulator for?

**A:** Allows development without Citrix/VPN access. Faster iteration, test edge cases easily. Production just toggles it off.

---

### Q: Can I use jQuery or other libraries?

**A:** We intentionally avoided jQuery (not needed with modern vanilla JS). Adding libraries requires file:// protocol compatibility verification.

---

### Q: How do I test changes?

**A:** Simulator locally → CERT with real data → Citrix production. Never skip CERT testing.

---

### Q: Where's the build process?

**A:** There isn't one (intentional). No webpack, no transpiling. Deploy files as-is. Simplicity for healthcare reliability.

---

### Q: How do column renderers work?

**A:** Handsontable calls renderer for each cell. We apply custom logic, formatting, tooltips, and click handlers. Pattern repeated for each column.

---

## Next Steps for Your Co-Worker

### Suggested Learning Path

**Day 1: Understand Architecture**
- ✅ Read this guide (you're here!)
- ✅ Read CITRIX-DEPLOYMENT-GUIDE.md
- ✅ Review Config.js (simplest file)

**Day 2: Explore Services**
- ✅ Read UserInfoService.js (simple service)
- ✅ Read PatientListService.js (simple service)
- ✅ Understand service pattern

**Day 3: Dive Into Data**
- ✅ Read PatientDataService.js
- ✅ See how CCL data → formatted display
- ✅ Understand JSON parsing

**Day 4: Master Renderers**
- ✅ Read main.js column configurations
- ✅ Pick simple column (Age, Patient Name)
- ✅ Pick complex column (Lactate, Screening)
- ✅ Understand pattern differences

**Day 5: Make a Change**
- ✅ Add console.log to a renderer
- ✅ Modify tooltip content
- ✅ Test in simulator
- ✅ Deploy to CERT

---

## Summary for In-Service Meeting

**High-Level Talking Points:**

1. **"It's a service-based architecture"**
   - Not one big file, separated by responsibility
   - UserInfo, PatientList, PatientData services

2. **"Pure JavaScript - no framework"**
   - PowerChart compatibility
   - Healthcare reliability
   - Simple deployment

3. **"Simulator mode for development"**
   - Toggle in Config.js
   - Test locally without Citrix
   - Mock data in XMLCclRequestSimulator.js

4. **"Two deployment modes"**
   - Azure for CERT testing (web server)
   - Citrix for production (file:// with CCL driver)

5. **"15+ custom column renderers"**
   - Each column has unique logic
   - Tooltips via Tippy.js
   - Click handlers for PowerForm/PowerPlan

6. **"Everything is well-documented"**
   - Inline comments
   - Deployment guides
   - GitHub issue history
   - TaskMaster workflow tracking

---

**Ready to maintain and extend!** 🚀

---

*Created: 2025-11-03*
*For: Developer onboarding and knowledge transfer*
*Version: 1.0*
