# Handsontable Async Multi-Query Enhancement

## Overview

This document provides comprehensive research and implementation strategies for enhancing the Patient List MPage Template with asynchronous multi-query capabilities. The goal is to load additional clinical data (labs, vitals, medications, etc.) while maintaining a stable table layout and professional user experience.

## Current Template Architecture

### Existing Data Flow
```
User selects list → get_pids → get_pdata (basic demographics) → Display table
```

### Enhanced Architecture Goal
```
User selects list → get_pids → get_pdata (demographics) → Display stable table
                                       ↓
                            Async enhancement calls:
                            ├── Load labs data
                            ├── Load vital signs  
                            ├── Load medications
                            └── Load allergies
```

## Handsontable Async Capabilities

### Built-in Mechanisms

#### 1. updateData() Method
```javascript
// Replace entire dataset
hot.updateData(enhancedPatientData);
```

#### 2. setDataAtCell() for Individual Updates
```javascript
// Update specific cells when additional data arrives
hot.setDataAtCell(rowIndex, 'LABS', labResults);
hot.setDataAtCell(rowIndex, 'VITALS', vitalSigns);
```

#### 3. Custom Async Cell Renderers
```javascript
function asyncLabRenderer(instance, td, row, col, prop, value, cellProperties) {
    const patientId = instance.getDataAtCell(row, 'PATIENT_ID');
    
    // Show loading state
    td.innerHTML = '<span style="color: #999; font-style: italic;">🔄 Loading labs...</span>';
    
    // Fetch lab data asynchronously
    getLabResults(patientId).then(labData => {
        if (labData.critical) {
            td.innerHTML = `<span style="color: red; font-weight: bold;">❌ ${labData.value}</span>`;
            td.style.background = '#fee';
        } else {
            td.innerHTML = `<span style="color: green;">✅ ${labData.value}</span>`;
        }
    }).catch(error => {
        td.innerHTML = '<span style="color: #999;">-- No data --</span>';
    });
    
    return td;
}
```

#### 4. Column Header Updates
```javascript
// Update column headers during loading
function updateColumnHeader(columnKey, newTitle) {
    const columnIndex = getColumnIndex(columnKey);
    const headers = hot.getColHeader();
    headers[columnIndex] = newTitle;
    hot.updateSettings({ colHeaders: headers });
}
```

#### 5. Hook System
```javascript
afterLoadData: function(firstTime) {
    if (firstTime) {
        // Trigger additional data loading after initial demographics load
        loadAdditionalClinicalData();
    }
}
```

## Implementation Strategies

### Strategy A: Single CCL Program for Multiple Lab Types (RECOMMENDED)

#### Advantages
- **Fewer CCL programs** - One `1_cust_mp_gen_get_labs` instead of multiple
- **Efficient database calls** - One query with multiple lab codes
- **Consistent response format** - All labs in same structure
- **Better performance** - Fewer CCL round trips
- **Easier maintenance** - One program to maintain

#### Implementation
```javascript
// Single CCL program with lab type parameter
async function loadLabData(encounterIds, labType) {
    // Update header to show loading for this lab type
    updateColumnHeader(labType, `🔄 ${labType} (Loading)`);
    
    try {
        const labResponse = await sendCclRequest(
            '1_cust_mp_gen_get_labs',
            ['MINE', `value(${encounterIds.join(',')})`, labType],
            { debug: true, timeout: 15000 }
        );
        
        // Update column data for all patients
        labResponse.labData.patients.forEach((labData, rowIndex) => {
            const formattedResult = formatLabResult(labData, labType);
            hot.setDataAtCell(rowIndex, labType, formattedResult);
        });
        
        // Update header to show completion
        const icon = getLabIcon(labType); // 🧪 ⚗️ 🫁
        updateColumnHeader(labType, `${icon} ${labType}`);
        
    } catch (error) {
        console.error(`Failed to load ${labType} data:`, error);
        updateColumnHeader(labType, `❌ ${labType} (Failed)`);
    }
}

// Usage
loadLabData(encounterIds, 'CBC');
loadLabData(encounterIds, 'BMP'); 
loadLabData(encounterIds, 'ABG');
```

#### CCL Program Structure
```ccl
drop program 1_cust_mp_gen_get_labs go
create program 1_cust_mp_gen_get_labs

prompt 
    "Output to File/Printer/MINE" = "MINE"
    , "Encounter IDs" = 0
    , "Lab Type" = ""

with OUTDEV, ENCOUNTER_IDS, LAB_TYPE

; Handle different lab types
declare lab_codes = vc with noconstant("")

case (cnvtupper($LAB_TYPE))
    of "CBC":
        ; CBC lab codes (WBC, RBC, HGB, HCT, PLT)
        set lab_codes = value(
            uar_get_code_by("DISPLAYKEY", 72, "WBC"),
            uar_get_code_by("DISPLAYKEY", 72, "RBC"),
            uar_get_code_by("DISPLAYKEY", 72, "HGB"),
            uar_get_code_by("DISPLAYKEY", 72, "HCT"),
            uar_get_code_by("DISPLAYKEY", 72, "PLT")
        )
    of "BMP": 
        ; BMP lab codes (Na, K, Cl, CO2, BUN, Creat, Glucose)
        set lab_codes = value(
            uar_get_code_by("DISPLAYKEY", 72, "SODIUM"),
            uar_get_code_by("DISPLAYKEY", 72, "POTASSIUM"),
            uar_get_code_by("DISPLAYKEY", 72, "CHLORIDE"),
            uar_get_code_by("DISPLAYKEY", 72, "CO2"),
            uar_get_code_by("DISPLAYKEY", 72, "BUN"),
            uar_get_code_by("DISPLAYKEY", 72, "CREATININE"),
            uar_get_code_by("DISPLAYKEY", 72, "GLUCOSE")
        )
    of "ABG":
        ; ABG lab codes (pH, pCO2, pO2, HCO3, Base Excess)
        set lab_codes = value(
            uar_get_code_by("DISPLAYKEY", 72, "PH"),
            uar_get_code_by("DISPLAYKEY", 72, "PCO2"),
            uar_get_code_by("DISPLAYKEY", 72, "PO2"),
            uar_get_code_by("DISPLAYKEY", 72, "HCO3"),
            uar_get_code_by("DISPLAYKEY", 72, "BASEEXCESS")
        )
endcase

select into "nl:"
from encounter e, clinical_event ce
plan e
    where e.encntr_id = $ENCOUNTER_IDS
join ce
    where ce.encntr_id = e.encntr_id  
    and ce.event_cd in (lab_codes)
    and ce.result_status_cd = AUTH_RESULT_CODE
```

### **Strategy B: Single Call for All Labs**

#### Implementation
```javascript
async function loadAllLabsData(encounterIds) {
    // Update all lab headers to show loading
    ['CBC', 'BMP', 'ABG'].forEach(labType => {
        updateColumnHeader(labType, `🔄 ${labType} (Loading)`);
    });
    
    try {
        // Single CCL call for all lab types
        const allLabsResponse = await sendCclRequest(
            '1_cust_mp_gen_get_all_labs',
            ['MINE', `value(${encounterIds.join(',')})`],
            { debug: true, timeout: 30000 }
        );
        
        // Populate all lab columns from single response
        allLabsResponse.labData.patients.forEach((patientLabs, rowIndex) => {
            hot.setDataAtCell(rowIndex, 'CBC', formatCBC(patientLabs.cbc));
            hot.setDataAtCell(rowIndex, 'BMP', formatBMP(patientLabs.bmp));
            hot.setDataAtCell(rowIndex, 'ABG', formatABG(patientLabs.abg));
        });
        
        // Update all headers to show completion
        updateColumnHeader('CBC', '🧪 CBC');
        updateColumnHeader('BMP', '⚗️ BMP');
        updateColumnHeader('ABG', '🫁 ABG');
        
    } catch (error) {
        console.error('Failed to load lab data:', error);
        ['CBC', 'BMP', 'ABG'].forEach(labType => {
            updateColumnHeader(labType, `❌ ${labType} (Failed)`);
        });
    }
}
```

### **Strategy C: Individual CCL Programs**

#### Implementation
```javascript
// Separate CCL programs for maximum flexibility
async function loadCBCData(encounterIds) {
    updateColumnHeader('CBC', '🔄 CBC (Loading)');
    const cbcData = await sendCclRequest('1_cust_mp_gen_get_cbc', ['MINE', encounterIds]);
    populateColumn('CBC', cbcData);
    updateColumnHeader('CBC', '🧪 CBC');
}

async function loadBMPData(encounterIds) {
    updateColumnHeader('BMP', '🔄 BMP (Loading)');
    const bmpData = await sendCclRequest('1_cust_mp_gen_get_bmp', ['MINE', encounterIds]);
    populateColumn('BMP', bmpData);
    updateColumnHeader('BMP', '⚗️ BMP');
}

async function loadABGData(encounterIds) {
    updateColumnHeader('ABG', '🔄 ABG (Loading)');
    const abgData = await sendCclRequest('1_cust_mp_gen_get_abg', ['MINE', encounterIds]);
    populateColumn('ABG', abgData);
    updateColumnHeader('ABG', '🫁 ABG');
}
```

### **Strategy D: Progressive Column Addition**

#### Implementation
```javascript
// Add columns dynamically as data becomes available
async function addLabColumnsProgressively(encounterIds) {
    // Start with basic demographics table
    initializeBasicTable();
    
    // Add CBC column and load data
    addColumn({ data: 'CBC', title: '🔄 CBC (Loading)', width: 120 });
    const cbcData = await loadCBCData(encounterIds);
    updateColumnData('CBC', cbcData);
    updateColumnHeader('CBC', '🧪 CBC');
    
    // Add BMP column and load data  
    addColumn({ data: 'BMP', title: '🔄 BMP (Loading)', width: 120 });
    const bmpData = await loadBMPData(encounterIds);
    updateColumnData('BMP', bmpData);
    updateColumnHeader('BMP', '⚗️ BMP');
}
```

## Visual Loading State Examples

### Fixed Column Headers (PREFERRED)

#### Initial State - All Headers Present:
```
┌─────────────┬──────┬─────┬────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────────┐
│ Patient     │ Unit │ Age │ Gender │ 🔄 CBC (Loading)│ 🔄 BMP (Loading)│ 🔄 ABG (Loading)│ 🔄 Vitals (Loading) │
├─────────────┼──────┼─────┼────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│ John Doe    │ ICU  │ 45  │ Male   │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
│ Jane Smith  │ ICU  │ 52  │ Female │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
│ Mike Brown  │ ER   │ 38  │ Male   │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
└─────────────┴──────┴─────┴────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

#### CBC Loaded:
```
┌─────────────┬──────┬─────┬────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────────┐
│ Patient     │ Unit │ Age │ Gender │ 🧪 CBC          │ 🔄 BMP (Loading)│ 🔄 ABG (Loading)│ 🔄 Vitals (Loading) │
├─────────────┼──────┼─────┼────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│ John Doe    │ ICU  │ 45  │ Male   │ WBC: 8.5 ✅     │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
│ Jane Smith  │ ICU  │ 52  │ Female │ WBC: 12.1 ❌    │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
│ Mike Brown  │ ER   │ 38  │ Male   │ WBC: 7.2 ✅     │ 🔄 Loading...   │ 🔄 Loading...   │ 🔄 Loading...       │
└─────────────┴──────┴─────┴────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

#### All Data Loaded:
```
┌─────────────┬──────┬─────┬────────┬─────────────────┬─────────────────┬─────────────────┬─────────────────────┐
│ Patient     │ Unit │ Age │ Gender │ 🧪 CBC          │ ⚗️ BMP           │ 🫁 ABG           │ 💓 Vital Signs      │
├─────────────┼──────┼─────┼────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│ John Doe    │ ICU  │ 45  │ Male   │ WBC: 8.5 ✅     │ K+: 3.8 ✅      │ pH: 7.35 ⚠️     │ BP: 120/80, HR: 72 │
│ Jane Smith  │ ICU  │ 52  │ Female │ WBC: 12.1 ❌    │ K+: 2.1 ❌      │ pH: 7.42 ✅     │ BP: 140/90, HR: 88 │
│ Mike Brown  │ ER   │ 38  │ Male   │ WBC: 7.2 ✅     │ K+: 4.1 ✅      │ pH: 7.40 ✅     │ BP: 118/75, HR: 65 │
└─────────────┴──────┴─────┴────────┴─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

### Loading State Indicators

#### Header Loading States
```javascript
const HEADER_STATES = {
    LOADING: '🔄 {name} (Loading)',
    SUCCESS: '{icon} {name}',
    ERROR: '❌ {name} (Failed)',
    NO_DATA: '⚪ {name} (No Data)'
};

const LAB_ICONS = {
    CBC: '🧪',
    BMP: '⚗️', 
    ABG: '🫁',
    VITALS: '💓',
    MEDS: '💊',
    ALLERGIES: '⚠️'
};
```

#### Cell Loading States
```javascript
const CELL_STATES = {
    LOADING: '🔄 Loading...',
    NORMAL: '✅ {value}',
    CRITICAL: '❌ {value}',
    WARNING: '⚠️ {value}',
    NO_DATA: '-- No data --'
};
```

## Clinical Data Categories

### Laboratory Results
- **CBC (Complete Blood Count)**: WBC, RBC, HGB, HCT, PLT
- **BMP (Basic Metabolic Panel)**: Na, K, Cl, CO2, BUN, Creatinine, Glucose
- **ABG (Arterial Blood Gas)**: pH, pCO2, pO2, HCO3, Base Excess
- **Coagulation**: PT, PTT, INR
- **Liver Function**: ALT, AST, Bilirubin, Albumin
- **Cardiac Markers**: Troponin, CK-MB, BNP

### Vital Signs
- **Basic Vitals**: Blood Pressure, Heart Rate, Temperature, Respiratory Rate
- **Advanced**: O2 Saturation, Pain Scale, Glasgow Coma Scale
- **Monitoring**: Central Venous Pressure, Pulmonary Artery Pressure

### Medications
- **Current Active**: Currently administered medications
- **Scheduled**: Upcoming scheduled doses  
- **PRN**: As-needed medications
- **Recent**: Recently administered

### Other Clinical Data
- **Allergies**: Drug allergies and reactions
- **Care Team**: Assigned physicians, nurses, specialists
- **Procedures**: Scheduled procedures and surgeries
- **Alerts**: Clinical alerts and warnings

## Technical Implementation Patterns

### Column Configuration for Async Loading

#### Fixed Column Definition
```javascript
// Define all columns upfront for stable layout
const COLUMN_DEFINITIONS = [
    // Basic demographics (loaded immediately)
    { data: 'PATIENT_NAME', title: 'Patient Name', width: 150, async: false },
    { data: 'UNIT', title: 'Unit', width: 80, async: false },
    { data: 'AGE', title: 'Age', width: 60, async: false },
    { data: 'GENDER', title: 'Gender', width: 80, async: false },
    
    // Clinical data (loaded asynchronously)
    { data: 'CBC', title: '🔄 CBC (Loading)', width: 120, async: true, loader: 'loadLabData', params: ['CBC'] },
    { data: 'BMP', title: '🔄 BMP (Loading)', width: 120, async: true, loader: 'loadLabData', params: ['BMP'] },
    { data: 'ABG', title: '🔄 ABG (Loading)', width: 120, async: true, loader: 'loadLabData', params: ['ABG'] },
    { data: 'VITALS', title: '🔄 Vitals (Loading)', width: 160, async: true, loader: 'loadVitalData', params: [] },
    { data: 'MEDS', title: '🔄 Meds (Loading)', width: 200, async: true, loader: 'loadMedicationData', params: [] }
];
```

#### Async Loading Manager
```javascript
async function loadAsyncColumns(encounterIds) {
    // Get all async columns
    const asyncColumns = COLUMN_DEFINITIONS.filter(col => col.async);
    
    // Load each async column
    for (const column of asyncColumns) {
        try {
            console.log(`Loading ${column.data}...`);
            
            // Call the appropriate loader function
            const loader = window[column.loader];
            const data = await loader(encounterIds, ...column.params);
            
            // Update column data
            populateColumn(column.data, data);
            
            // Update header to show success
            const icon = LAB_ICONS[column.data] || '✅';
            updateColumnHeader(column.data, `${icon} ${column.data}`);
            
        } catch (error) {
            console.error(`Failed to load ${column.data}:`, error);
            updateColumnHeader(column.data, `❌ ${column.data} (Failed)`);
        }
    }
}
```

### Error Handling Patterns

#### Column-Specific Error States
```javascript
function handleColumnError(columnKey, error) {
    console.error(`Error loading ${columnKey}:`, error);
    
    // Update header to show error
    updateColumnHeader(columnKey, `❌ ${columnKey} (Failed)`);
    
    // Show error in all cells for this column
    const rowCount = hot.countRows();
    for (let row = 0; row < rowCount; row++) {
        hot.setDataAtCell(row, columnKey, '❌ Error loading data');
    }
}
```

#### Retry Mechanisms
```javascript
async function retryColumnLoad(columnKey, encounterIds, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            updateColumnHeader(columnKey, `🔄 ${columnKey} (Retry ${attempt})`);
            const data = await loadColumnData(columnKey, encounterIds);
            return data;
        } catch (error) {
            if (attempt === maxRetries) {
                throw error; // Final attempt failed
            }
            console.warn(`Attempt ${attempt} failed for ${columnKey}, retrying...`);
            await new Promise(resolve => setTimeout(resolve, 1000 * attempt)); // Exponential backoff
        }
    }
}
```

## Performance Considerations

### CCL Program Efficiency
- **Single query with multiple event codes** is more efficient than multiple queries
- **Batch processing** for all encounter IDs reduces database load
- **Proper indexing** on encounter_id and event_cd tables
- **Result caching** where appropriate

### JavaScript Performance  
- **Debounced updates** to prevent excessive DOM manipulation
- **Batch cell updates** using `hot.batch()` for multiple changes
- **Virtual scrolling** for large patient lists
- **Progressive disclosure** for non-critical data

### User Experience
- **Immediate feedback** with loading indicators
- **Stable layout** prevents UI jumping
- **Clear error states** for failed data loads
- **Graceful degradation** when optional data unavailable

## Future Implementation Roadmap

### Phase 1: Core Enhancement
1. **Single lab CCL program** with type parameter
2. **Fixed column headers** for stable layout
3. **Basic async loading** for 2-3 lab types
4. **Error handling** and retry logic

### Phase 2: Clinical Expansion  
1. **Additional lab types** (Coag, LFTs, Cardiac markers)
2. **Vital signs integration** 
3. **Medication data**
4. **Care team information**

### Phase 3: Advanced Features
1. **Configurable columns** per MPage type
2. **Real-time updates** for changing data
3. **Export functionality** with all data
4. **Print layouts** optimized for clinical workflows

## MPage-Specific Customization

### Sepsis MPage Enhancement
```javascript
const SEPSIS_COLUMNS = [
    ...BASIC_DEMOGRAPHICS,
    { data: 'LACTATE', title: '🔄 Lactate (Loading)', loader: 'loadLabData', params: ['LACTATE'] },
    { data: 'WBC', title: '🔄 WBC (Loading)', loader: 'loadLabData', params: ['WBC'] },
    { data: 'TEMP', title: '🔄 Temperature (Loading)', loader: 'loadVitalData', params: ['TEMP'] },
    { data: 'ANTIBIOTICS', title: '🔄 Antibiotics (Loading)', loader: 'loadMedicationData', params: ['ANTIBIOTICS'] }
];
```

### Cardiac MPage Enhancement  
```javascript
const CARDIAC_COLUMNS = [
    ...BASIC_DEMOGRAPHICS,
    { data: 'TROPONIN', title: '🔄 Troponin (Loading)', loader: 'loadLabData', params: ['TROPONIN'] },
    { data: 'BNP', title: '🔄 BNP (Loading)', loader: 'loadLabData', params: ['BNP'] },
    { data: 'EKG', title: '🔄 EKG (Loading)', loader: 'loadCardiacData', params: ['EKG'] },
    { data: 'CARDIAC_MEDS', title: '🔄 Cardiac Meds (Loading)', loader: 'loadMedicationData', params: ['CARDIAC'] }
];
```

### Mobility MPage Enhancement
```javascript
const MOBILITY_COLUMNS = [
    ...BASIC_DEMOGRAPHICS,
    { data: 'FALL_RISK', title: '🔄 Fall Risk (Loading)', loader: 'loadAssessmentData', params: ['FALL_RISK'] },
    { data: 'MOBILITY_SCORE', title: '🔄 Mobility Score (Loading)', loader: 'loadAssessmentData', params: ['MOBILITY'] },
    { data: 'PT_OT', title: '🔄 PT/OT (Loading)', loader: 'loadTherapyData', params: ['PT_OT'] }
];
```

---
*Future Enhancement Documentation*  
*Patient List MPage Template*  
*Ready for implementation post v1.0.1*