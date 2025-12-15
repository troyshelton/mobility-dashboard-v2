# Patient List MPage Template - Usage Guide

This template provides a clean, professional foundation for creating patient list MPages with Cerner integration.

## What You Get

### ✅ Ready-to-Use Template
- **Clean Professional Interface** - Blue header, clean dropdown, professional Handsontable
- **Working Service Architecture** - Proven service pattern from respiratory MPage
- **Firebug Lite Debug System** - Simple debugging with console logging
- **Two Demo Patient Lists** - Simple A/B lists for testing functionality
- **Basic Demographics Display** - Name, Unit, Room, Class, Age, Gender, Admission Date
- **Complete CCL Architecture** - Production-ready CCL programs (4 main + 7+ child programs)

### ✅ Production Ready
- **Proven Architecture** - Based on working respiratory MPage
- **All Patient List Types Supported** - Custom, Care Team, Census, Relationship, Provider Group, Assignment, Query
- **Two-Step CCL Workflow** - Get patient IDs → Get patient demographics
- **Error Handling** - Comprehensive error handling and fallback to simulator mode

## Quick Start (5 minutes)

### 1. Demo the Template
```bash
# Open in browser for immediate demo
open src/web/index.html
```

**What you'll see:**
- Clean blue header: "Patient List MPage"
- Dropdown with "Demo Patient List A" and "Demo Patient List B"
- Select either list → patients display in professional table
- Firebug Lite console for debugging (toggle appears when logging occurs)

### 2. Test Patient Lists
- **Demo Patient List A**: Shows 2 ICU patients (John Doe, Jane Smith)
- **Demo Patient List B**: Shows 2 ER patients (Michael Brown, Sarah Davis)
- **Switch between lists** to see different patient data loads

## Customization Guide

### For Clinical Use Cases (Sepsis, Cardiac, etc.)

#### 1. Extend Handsontable Columns
Edit `src/web/js/main.js` line ~50:
```javascript
// Current basic demographics
const columns = [
    { data: 'PATIENT_NAME', title: 'Patient Name', width: 180 },
    { data: 'UNIT', title: 'Unit', width: 80 },
    // ... add your clinical columns here ...
    { data: 'SEPSIS_SCORE', title: 'Sepsis Score', width: 100 },
    { data: 'ALERT_TYPE', title: 'Alert', width: 80 }
];
```

#### 2. Update CCL Programs
- Copy working CCL programs from `/src/ccl/` to your target Cerner domain
- Customize `1_cust_mp_gen_get_pdata.prg` to include clinical data
- Keep the proven patient list infrastructure unchanged

#### 3. Update Mock Data
Edit `src/web/js/XMLCclRequestSimulator.js`:
```javascript
// Add your clinical fields to patient data
const patientDataMap = {
    12345001: {
        PATIENT_NAME: "ZZZTEST, John Doe", 
        // ... existing fields ...
        SEPSIS_SCORE: "High",
        ALERT_TYPE: "Septic Shock"
    }
};
```

#### 4. Switch to Production
Edit `src/web/index.html` line ~105:
```javascript
// Change from simulator to production
userInfoService = new UserInfoService(false, true, true);      // false = Millennium mode
patientListService = new PatientListService(false, true, true); // false = Millennium mode
patientDataService = new PatientDataService(false, true);       // false = Millennium mode
```

## CCL Programs Included

### 4 Main Programs (Production Ready)
1. **`1_cust_mp_gen_get_plists.prg`** - Get available patient lists (copied from working respiratory program)
2. **`1_cust_mp_gen_get_pids.prg`** - Dispatcher for all patient list types (copied from working respiratory program)
3. **`1_cust_mp_gen_get_pdata.prg`** - Get patient demographics (simplified from respiratory program)
4. **`1_cust_mp_gen_user_info.prg`** - Get user environment info

### 7 Child Programs (Copy from Respiratory MPage)
To complete the template, copy and rename these working programs:
- `1_mhn_mp_ptlst_custom_01.prg` → `1_cust_mp_gen_plst_custom.prg`
- `1_mhn_mp_ptlst_careteam_01.prg` → `1_cust_mp_gen_plst_cteam.prg`
- `1_mhn_mp_ptlst_census_01.prg` → `1_cust_mp_gen_plst_census.prg`
- `1_mhn_mp_ptlst_reltn_01.prg` → `1_cust_mp_gen_plst_reltn.prg`
- `1_mhn_mp_ptlst_providergrp_01.prg` → `1_cust_mp_gen_plst_provgrp.prg`
- `1_mhn_mp_ptlst_asgnmt_01.prg` → `1_cust_mp_gen_plst_assign.prg`
- `1_mhn_mp_ptlst_query_01.prg` → `1_cust_mp_gen_plst_query.prg`

## Example Use Cases

### 1. Sepsis MPage
- Add sepsis-specific columns (Alert Type, Timer, Lactate, etc.)
- Extend patient data CCL program with sepsis indicators
- Update styling to red theme

### 2. Cardiac MPage  
- Add cardiac-specific columns (EKG, Troponin, etc.)
- Extend patient data CCL program with cardiac markers
- Update styling to appropriate theme

### 3. Mobility MPage
- Add mobility-specific columns (Fall Risk, BMAT Score, etc.)
- Extend patient data CCL program with mobility assessments
- Update styling to match mobility theme

## Template Benefits

### ✅ Proven Foundation
- **Production-tested architecture** from respiratory MPage
- **Handles all patient list types** (Custom, Location, Care Team, etc.)
- **Professional clean interface** like Mobility MPage
- **Comprehensive error handling** and debugging

### ✅ Development Ready
- **Simulator mode** for local development
- **Firebug Lite** for debugging
- **Mock data** for testing
- **Complete documentation** for deployment

### ✅ Easily Extensible
- **Add clinical columns** with minimal changes
- **Extend CCL programs** for specific data needs
- **Update styling** for different clinical areas
- **Maintain proven service architecture**

---
*Template Version: 1.0.0*  
*Based on: Respiratory MPage (proven production architecture)*  
*UI Design: Sepsis Demo (clean professional interface)*  
*Debug System: RCM Project (Firebug Lite)*