# Patient List MPage Template - Technical Architecture

## Overview
This document provides comprehensive technical documentation for architects and developers implementing the Patient List MPage Template in Cerner PowerChart environments.

## System Architecture

### High-Level Design
The template follows a **service-oriented architecture** with clear separation between:
- **Presentation Layer**: HTML/CSS interface with Handsontable data grid
- **Service Layer**: JavaScript services for data processing and communication  
- **Data Layer**: CCL programs for Cerner Millennium integration
- **Debug Layer**: Eruda DevTools for production troubleshooting

### Technology Stack
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **CSS Framework**: Tailwind CSS utilities (locally customized)
- **Data Grid**: Handsontable 14.6 (Excel-like patient data display)
- **Icons**: Font Awesome 6.5.1 (medical-standard status indicators)
- **Debug Tools**: Eruda 3.4.1 (DevTools for restricted environments)
- **Backend**: Cerner CCL (10 programs total)

## Technical Workflow

### Application Initialization Sequence

1. **Page Load** (`index.html`)
   ```
   DOM Ready → Body onload → window.PatientListApp.init()
   ```

2. **Service Initialization** (`main.js:initializeApp()`)
   ```javascript
   initializeServices() → loadPatientLists() → setupEventHandlers()
   ```

3. **Service Creation**
   ```javascript
   UserInfoService(simulatorMode, debugMode)
   PatientListService(simulatorMode, debugMode) 
   PatientDataService(simulatorMode, debugMode)
   ```

4. **Patient List Loading** (`PatientListService.getPatientLists()`)
   - **Simulator Mode**: Returns mock patient lists from XMLCclRequestSimulator
   - **Production Mode**: Calls CCL program `1_cust_mp_gen_get_plists`

5. **Dropdown Population** (`main.js:loadPatientLists()`)
   ```javascript
   patientLists.forEach(list => {
     option.value = list.patientListId;
     option.textContent = list.name;
     dropdown.appendChild(option);
   });
   ```

### Patient Data Retrieval Workflow

#### User Interaction Flow
```
User selects dropdown → handlePatientListChange() → Service calls → Data processing → Table display
```

#### Detailed Technical Flow

1. **Event Trigger** (`main.js:handlePatientListChange()`)
   ```javascript
   const selectedListId = event.target.value;
   ```

2. **Patient ID Retrieval** (`PatientListService.getPatientListPatients()`)
   
   **Simulator Mode:**
   ```javascript
   XMLCclRequestSimulator.simulateRequest('1_cust_mp_gen_get_pids', ['MINE', listId])
   ```
   
   **Production Mode:**
   ```javascript
   sendCclRequest('1_cust_mp_gen_get_pids', ['MINE', listId])
   ```

3. **Patient Data Retrieval** 
   
   **Simulator Mode:**
   ```javascript
   XMLCclRequestSimulator.simulateRequest('1_cust_mp_gen_get_pdata', encounterIds)
   ```
   
   **Production Mode:**
   ```javascript
   sendCclRequest('1_cust_mp_gen_get_pdata', encounterIds)
   ```

4. **Data Processing** (`PatientDataService.formatForTable()`)
   ```javascript
   rawPatientData → processedData (with STATUS/ACUITY fields)
   ```

5. **Table Rendering** (`main.js:initializePatientTable()`)
   ```javascript
   Handsontable.init(data, columns) → Custom renderers → Font Awesome icons
   ```

## File Architecture

### Directory Structure
```
src/web/
├── index.html                    # Main MPage entry point
├── styles.css                   # Unified stylesheet (Tailwind + custom)
├── lib/                          # Local dependencies (universal compatibility)
│   ├── fontawesome/
│   │   └── all.min.css          # Font Awesome CSS  
│   ├── webfonts/                # Font files for icon display
│   │   ├── fa-solid-900.woff2   # Solid icons (status indicators)
│   │   ├── fa-regular-400.woff2 # Regular icons
│   │   └── fa-brands-400.woff2  # Brand icons
│   ├── handsontable/
│   │   ├── handsontable.full.min.js   # Data grid functionality
│   │   └── handsontable.full.min.css  # Grid styling
│   └── eruda/
│       └── eruda.js             # Debug tools for PowerChart
└── js/                          # JavaScript services
    ├── DebugUtils.js            # Shared debug utility
    ├── main.js                  # Main application logic
    ├── PatientListService.js    # Patient list management
    ├── PatientDataService.js    # Data processing
    ├── UserInfoService.js       # User authentication  
    ├── SendCclRequest.js        # CCL communication
    └── XMLCclRequestSimulator.js # Mock data provider
```

### CCL Program Architecture
```
src/ccl/
├── 1_cust_mp_gen_get_plists.prg    # Main: Get available patient lists
├── 1_cust_mp_gen_get_pids.prg      # Main: Dispatcher for patient list types
├── 1_cust_mp_gen_get_pdata.prg     # Main: Get patient demographics
├── 1_cust_mp_gen_plst_custom.prg   # Child: Custom patient lists
├── 1_cust_mp_gen_plst_cteam.prg    # Child: Care team lists
├── 1_cust_mp_gen_plst_census.prg   # Child: Census/location lists
├── 1_cust_mp_gen_plst_reltn.prg    # Child: Relationship lists
├── 1_cust_mp_gen_plst_provgrp.prg  # Child: Provider group lists
├── 1_cust_mp_gen_plst_assign.prg   # Child: Assignment lists
└── 1_cust_mp_gen_plst_query.prg    # Child: Query lists
```

## JavaScript Function Reference

### Main Application Functions (`main.js`)

#### Core Functions
- **`initializeApp()`** - Main entry point, initializes entire application
- **`initializeServices()`** - Creates all service instances with proper modes
- **`loadPatientLists()`** - Populates dropdown with available patient lists
- **`setupEventHandlers()`** - Attaches dropdown change event listener
- **`handlePatientListChange(event)`** - Processes user patient list selection

#### Data Display Functions  
- **`initializePatientTable(data)`** - Creates Handsontable with patient data
- **`statusRenderer(instance, td, row, col, prop, value)`** - Custom cell renderer for status icons
- **`acuityRenderer(instance, td, row, col, prop, value)`** - Custom cell renderer for acuity icons
- **`showMessage(message)`** - Displays messages to user
- **`clearPatientTable()`** - Clears table and resets to initial state

#### Debug Functions
- **`debugLog(message, level, ...args)`** - Application-level debug logging
- **`enableDebug()`** - Enable debug mode globally
- **`disableDebug()`** - Disable debug mode

### Service Classes

#### PatientListService (`PatientListService.js`)
**Purpose**: Manages patient list retrieval and patient data fetching

**Key Methods**:
- **`getPatientLists()`** - Retrieve available patient lists for user
- **`getPatientListPatients(listId)`** - Get patients from specific list
- **`generateMockPatientData(listId)`** - Provide mock data for testing

**CCL Integration**:
- Calls `1_cust_mp_gen_get_plists` → `1_cust_mp_gen_get_pids` → `1_cust_mp_gen_get_pdata`

#### PatientDataService (`PatientDataService.js`) 
**Purpose**: Data processing and formatting for table display

**Key Methods**:
- **`formatForTable(rawData)`** - Convert raw data to table-ready format
- **`processPatientData(rawData)`** - Process and validate patient records
- **`createCaseInsensitiveObject(obj)`** - Handle field name variations
- **`formatAge(age)`**, **`formatDate(date)`** - Data formatting utilities

#### UserInfoService (`UserInfoService.js`)
**Purpose**: User authentication and environment information

**Key Methods**:
- **`getUserInfo()`** - Get current user environment details
- **`loadMockUserInfo()`** - Provide mock user info for testing

### XML/CCL Simulation (`XMLCclRequestSimulator.js`)

**Mock Data Providers**:
- **`getMockPatientLists(parameters)`** - Simulates patient list retrieval
- **`getMockPatientIds(parameters)`** - Simulates patient ID fetching  
- **`getMockPatientData(parameters)`** - Simulates patient demographics
- **`getMockUserInfo(parameters)`** - Simulates user info

## CCL Program Integration

### CCL Program Flow Architecture

#### 1. Patient List Retrieval
**Program**: `1_cust_mp_gen_get_plists.prg`
**Input**: `['MINE', personId]`
**Output**: JSON array of available patient lists
```json
{
  "rpatlists": {
    "applicationId": 0.0,
    "prsnlId": 8333417,
    "qual": [
      {"viewSeq": 1, "patientListId": 1001.0, "name": "ICU Patients"},
      {"viewSeq": 2, "patientListId": 1002.0, "name": "Emergency Department"}
    ]
  }
}
```

#### 2. Patient ID Retrieval (Dispatcher)
**Program**: `1_cust_mp_gen_get_pids.prg`  
**Input**: `['MINE', patientListId]`
**Logic**: Determines patient list type and calls appropriate child program
**Output**: JSON with encounter IDs and basic patient info

**Dispatcher Logic**:
```ccl
case (mvc_list_type)
    of "CUSTOM": execute 1_cust_mp_gen_plst_custom
    of "CARETEAM": execute 1_cust_mp_gen_plst_cteam
    of "LOCATIONGRP": execute 1_cust_mp_gen_plst_census
    of "LOCATION": execute 1_cust_mp_gen_plst_census
    of "SERVICE": execute 1_cust_mp_gen_plst_census
    of "VRELTN": execute 1_cust_mp_gen_plst_reltn
    of "LRELTN": execute 1_cust_mp_gen_plst_reltn
    of "RELTN": execute 1_cust_mp_gen_plst_reltn
    of "PROVIDERGRP": execute 1_cust_mp_gen_plst_provgrp
    of "ASSIGNMENT": execute 1_cust_mp_gen_plst_assign
    of "QUERY": execute 1_cust_mp_gen_plst_query
endcase
```

#### 3. Patient Demographics Retrieval
**Program**: `1_cust_mp_gen_get_pdata.prg`
**Input**: Array of encounter IDs from step 2
**Output**: Complete patient demographics for table display
```json
{
  "REC": {
    "CCL_SCRIPT": "1_CUST_MP_GEN_GET_PDATA",
    "patientCnt": 5,
    "patients": [
      {
        "PATIENT_NAME": "Patient, Name",
        "UNIT": "ICU", 
        "ROOM_BED": "201-A",
        "PATIENT_CLASS": "Inpatient",
        "STATUS": "Critical",
        "ACUITY": "Level 1",
        "AGE": 65,
        "GENDER": "Male",
        "ADMISSION_DATE": "09/01/2025"
      }
    ]
  }
}
```

### Child Program Specifications

Each child program follows the same interface:
- **Input**: `ptlst_request` structure with patient list details
- **Output**: `ptlstencntr_reply` structure with encounter IDs
- **Error Handling**: Proper status codes and descriptive messages

## Data Flow Technical Details

### Complete End-to-End Sequence

1. **Page Load**
   - HTML loads with all local dependencies
   - Eruda initializes (invisible to end users)  
   - JavaScript services load in order

2. **Application Initialization**
   ```javascript
   window.PatientListApp.init() → initializeServices() → loadPatientLists()
   ```

3. **Service Configuration**
   ```javascript
   // Development/Testing (Outside Cerner)
   new PatientListService(true, debugEnabled)  // simulatorMode=true
   
   // Production (Inside Cerner)  
   new PatientListService(false, debugEnabled) // simulatorMode=false
   ```

4. **Patient List Loading**
   ```
   PatientListService.getPatientLists() → 
   XMLCclRequestSimulator OR sendCclRequest('1_cust_mp_gen_get_plists') →
   Dropdown population
   ```

5. **User Selection**
   ```
   User clicks dropdown → handlePatientListChange(event) → 
   selectedListId extracted
   ```

6. **Two-Step Data Retrieval**
   ```
   Step 1: Get Patient IDs
   PatientListService.getPatientListPatients(listId) →
   XMLCclRequestSimulator OR sendCclRequest('1_cust_mp_gen_get_pids') →
   encounterIds returned
   
   Step 2: Get Patient Demographics  
   XMLCclRequestSimulator OR sendCclRequest('1_cust_mp_gen_get_pdata') →
   Complete patient data returned
   ```

7. **Data Processing**
   ```
   PatientDataService.formatForTable(rawData) →
   Field mapping and validation →
   Table-ready data structure
   ```

8. **Table Rendering**
   ```
   initializePatientTable(processedData) →
   Handsontable creation →
   Custom renderers (statusRenderer, acuityRenderer) →
   Font Awesome icon injection →
   Color-coded cell backgrounds
   ```

## Mermaid Data Flow Diagram

```mermaid
graph TD
    A[User Opens MPage] --> B[HTML Loads with Local Dependencies]
    B --> C[PatientListApp.init()]
    C --> D[Initialize Services]
    D --> E[Load Patient Lists]
    
    E --> F{Simulator Mode?}
    F -->|Yes| G[XMLCclRequestSimulator]
    F -->|No| H[CCL: 1_cust_mp_gen_get_plists]
    
    G --> I[Mock Patient Lists]
    H --> I[Real Patient Lists]
    I --> J[Populate Dropdown]
    J --> K[User Selects Patient List]
    
    K --> L[handlePatientListChange]
    L --> M{Simulator Mode?}
    
    M -->|Yes| N[XMLCclRequestSimulator Flow]
    M -->|No| O[CCL Program Flow]
    
    N --> N1[Simulate: get_pids]
    N1 --> N2[Simulate: get_pdata]
    N2 --> P[Patient Data Retrieved]
    
    O --> O1[CCL: 1_cust_mp_gen_get_pids]
    O1 --> O2{Patient List Type}
    O2 -->|CUSTOM| O3[1_cust_mp_gen_plst_custom]
    O2 -->|CARETEAM| O4[1_cust_mp_gen_plst_cteam]
    O2 -->|LOCATION| O5[1_cust_mp_gen_plst_census]
    O2 -->|RELTN| O6[1_cust_mp_gen_plst_reltn]
    O2 -->|PROVIDERGRP| O7[1_cust_mp_gen_plst_provgrp]
    O2 -->|ASSIGNMENT| O8[1_cust_mp_gen_plst_assign]
    O2 -->|QUERY| O9[1_cust_mp_gen_plst_query]
    
    O3 --> O10[Encounter IDs]
    O4 --> O10
    O5 --> O10
    O6 --> O10
    O7 --> O10
    O8 --> O10
    O9 --> O10
    
    O10 --> O11[CCL: 1_cust_mp_gen_get_pdata]
    O11 --> P
    
    P --> Q[PatientDataService.formatForTable]
    Q --> R[Field Mapping & Validation]
    R --> S[Create Handsontable]
    S --> T[Apply Custom Renderers]
    T --> U[Display Font Awesome Icons]
    U --> V[Color-Coded Status Display]
    
    style A fill:#e1f5fe
    style V fill:#c8e6c9
    style N fill:#fff3e0
    style O fill:#f3e5f5
```

## JavaScript Function Call Chain

### Initialization Chain
```javascript
// 1. Page Load
window.PatientListApp.init()
├── initializeServices()
│   ├── new UserInfoService(simulatorMode, debugMode)
│   ├── new PatientListService(simulatorMode, debugMode)  
│   └── new PatientDataService(simulatorMode, debugMode)
├── loadPatientLists()
│   └── PatientListService.getPatientLists()
└── setupEventHandlers()
    └── dropdown.addEventListener('change', handlePatientListChange)
```

### Patient Selection Chain
```javascript
// 2. User Selection
handlePatientListChange(event)
├── selectedListId = event.target.value
├── PatientListService.getPatientListPatients(selectedListId)
│   ├── XMLCclRequestSimulator.simulateRequest('1_cust_mp_gen_get_pids')
│   └── XMLCclRequestSimulator.simulateRequest('1_cust_mp_gen_get_pdata')
├── PatientDataService.formatForTable(rawData)
└── initializePatientTable(processedData)
    ├── new Handsontable(tableDiv, config)
    ├── statusRenderer() // For each STATUS cell
    └── acuityRenderer() // For each ACUITY cell
```

## CCL Callback Architecture

### Production Mode CCL Calls

#### 1. Get Patient Lists
```javascript
sendCclRequest(
    '1_cust_mp_gen_get_plists',  // Program name
    ['MINE', personId],           // Parameters
    false,                        // Not simulation
    { debug: debugMode, timeout: 15000 }
)
```

#### 2. Get Patient IDs (Dispatcher)
```javascript  
sendCclRequest(
    '1_cust_mp_gen_get_pids',    // Dispatcher program
    ['MINE', patientListId],      // Parameters
    false,
    { debug: debugMode, timeout: 15000 }
)
```

#### 3. Get Patient Demographics
```javascript
sendCclRequest(
    '1_cust_mp_gen_get_pdata',   // Data retrieval program
    encounterIds,                 // Array of encounter IDs
    false,
    { debug: debugMode, timeout: 15000 }
)
```

### CCL Program Execution Flow

```
1_cust_mp_gen_get_pids (Dispatcher)
├── Determines patient list type from list metadata
├── Executes appropriate child program based on type:
│   ├── CUSTOM → 1_cust_mp_gen_plst_custom
│   ├── CARETEAM → 1_cust_mp_gen_plst_cteam  
│   ├── LOCATION → 1_cust_mp_gen_plst_census
│   ├── RELTN → 1_cust_mp_gen_plst_reltn
│   ├── PROVIDERGRP → 1_cust_mp_gen_plst_provgrp
│   ├── ASSIGNMENT → 1_cust_mp_gen_plst_assign
│   └── QUERY → 1_cust_mp_gen_plst_query
└── Returns encounter IDs + patient metadata
```

## Debug and Monitoring

### Debug System Architecture
- **Application Debug**: `debugLog()` function with level-based filtering
- **Service Debug**: Shared `DebugUtils.logDebug()` for all services
- **Eruda DevTools**: Complete browser DevTools replacement
- **Debug History**: `window.DEBUG_HISTORY` for troubleshooting

### Debug Access Methods
```javascript
// Enable debugging
enableDebug()                    // Global application debug
Command+Shift+F                  // Toggle Eruda DevTools
toggleEruda()                   // Manual Eruda toggle

// Debug information access
window.PROJECT_VERSION          // Version and build info
window.DEBUG_HISTORY           // Debug message history
window.PatientListApp.state    // Application state inspection
```

### Production Debugging in PowerChart
- **Invisible by default** - No debug UI visible to end users
- **Keyboard activation** - Command+Shift+F opens full DevTools
- **Complete inspection** - Console, DOM, Network, Resources, Performance
- **Cannot be blocked** - Local Eruda implementation

## Performance Characteristics

### Load Performance
- **Local dependencies** - No CDN latency
- **Font optimization** - Only required webfonts loaded
- **Compressed libraries** - Minified JavaScript and CSS
- **Efficient rendering** - Handsontable optimized for large datasets

### Memory Usage
- **Debug history limit** - Maximum 100 messages retained
- **Service cleanup** - Proper instance destruction on table refresh
- **Font loading** - On-demand webfont loading

### Network Usage
- **Simulator mode** - Zero network calls
- **Production mode** - Only CCL program calls to Millennium
- **No external dependencies** - No CDN or third-party requests

## Error Handling Strategy

### Service Layer Error Handling
```javascript
try {
    // Service operation
} catch (error) {
    debugLog('Error: ' + error.message, 'error');
    throw error; // Proper error propagation for troubleshooting
}
```

### User Interface Error Handling
- **Graceful degradation** - Show meaningful messages to users
- **Technical details** - Available in debug logs for IT support
- **No fallback data** - Authentic errors prevent data confusion

### CCL Error Handling
- **Timeout protection** - 15-second timeout on CCL calls
- **Proper error propagation** - CCL errors visible for troubleshooting
- **Debug information** - Full request/response logging when debug enabled

## PowerChart File Server Deployment Architecture

### Citrix Code Warehouse Setup

**Critical Architecture Note**: PowerChart file server deployments require split architecture:

#### Web Assets Deployment
**Location**: Citrix Code Warehouse file server directory
```
\\citrix-server\code-warehouse\patient-list-mpage\
├── styles.css                  # Main stylesheet
├── lib/                        # Local dependencies
│   ├── fontawesome/           # Font Awesome CSS + webfonts  
│   ├── handsontable/          # Handsontable library files
│   ├── eruda/                 # Debug tools
│   └── webfonts/              # Font files
└── js/                        # JavaScript services
    ├── DebugUtils.js          # Shared debug utility
    ├── main.js                # Application logic
    ├── PatientListService.js  # Patient list management
    ├── PatientDataService.js  # Data processing  
    ├── UserInfoService.js     # User authentication
    ├── SendCclRequest.js      # CCL communication
    └── XMLCclRequestSimulator.js # Mock data (testing only)
```

#### CCL Integration
**Location**: `$cust_script` directory (PowerChart backend)
```
$cust_script/patient_list_mpage.html    # Main HTML file
$cust_script/1_cust_mp_driver.prg       # CCL driver program (TODO)
```

#### CCL Driver Program Requirements
**Program**: `1_cust_mp_driver.prg` (To be created)
**Purpose**: 
- Link HTML file to CCL programs
- Handle PowerChart context (person_id, encounter_id)
- Manage file server path resolution
- Coordinate between web assets and CCL backend

#### Path Resolution Strategy
**HTML file must reference Code Warehouse paths**:
```html
<link href="\\citrix-server\code-warehouse\patient-list-mpage\styles.css" />
<script src="\\citrix-server\code-warehouse\patient-list-mpage\js\main.js"></script>
```

### FUTURE WORK: File Server Implementation
**Note**: File server deployment is documented for future implementation when needed.

**Reference Project**: `/Users/troyshelton/Projects/cabell/rcm_denied_days_worklist/src/` (v1.3.0)
- Contains working `mp_common_driver.prg` pattern in `/src/ccl/original/`
- Demonstrates `$SOURCE_DIR$` and `$CRITERION$` placeholder replacement system
- Shows split deployment: Code Warehouse assets + $cust_script HTML integration
- Current production version with latest CCL driver implementation

**Key Decision**: Use Cerner's existing driver vs create custom driver
- **Cerner's driver**: May change and affect our project
- **Custom driver**: More control but additional maintenance

**Implementation Tasks** (when needed):
1. Review RCM project CCL driver pattern thoroughly
2. Analyze `mp_common_driver.prg` placeholder replacement system  
3. Decide on using Cerner's driver vs creating custom version
4. Create file server deployment variant with appropriate placeholders
5. Update HTML structure for Code Warehouse path references
6. Test split deployment architecture

---
*Technical Architecture Document*  
*Patient List MPage Template v0.4.0*  
*Last Updated: 2025-09-05*