# Generic Patient List MPage - CCL Programs

This directory contains all CCL programs needed for the generic patient list MPage template.

## Architecture Overview

The CCL architecture follows the proven respiratory MPage pattern with **4 main programs** and **7 child programs** for different patient list types.

### Main Programs (Required - 4 programs)

#### 1. `1_cust_mp_gen_get_plists.prg` (27 chars)
- **Function**: Get available patient lists for the logged-in user
- **Input**: `['MINE', personId]` 
- **Output**: JSON with patient lists accessible to this user
- **Source**: Copy from `1_mhn_mp_get_patlist_02.prg` (respiratory MPage)

#### 2. `1_cust_mp_gen_get_pids.prg` (25 chars) 
- **Function**: Dispatcher - Get patient/encounter IDs from selected list
- **Input**: `['MINE', patientListId]`
- **Logic**: Determines list type and calls appropriate child program
- **Output**: JSON with encounter IDs and basic patient info
- **Source**: Copy from `1_mhn_mp_rt_patlist_02.prg` (respiratory MPage)

#### 3. `1_cust_mp_gen_get_pdata.prg` (26 chars)
- **Function**: Get detailed patient demographics using encounter IDs
- **Input**: Array of encounter IDs from step 2
- **Output**: Complete patient demographics for table display
- **Source**: Simplified from `1_mhn_mp_rt_patproc_03.prg` (respiratory MPage)

#### 4. `1_cust_mp_gen_user_info.prg` (26 chars)
- **Function**: Get user authentication and environment info
- **Input**: No parameters
- **Output**: User details, position, permissions
- **Source**: Copy from `1_mhn_mp_user_env_info.prg` (respiratory MPage)

### Child Programs (Patient List Types - 7+ programs)

These programs are called by the dispatcher (`1_cust_mp_gen_get_pids.prg`) based on patient list type:

#### Patient List Type Handlers:
```
1_cust_mp_gen_plst_custom.prg      (28 chars) - Custom patient lists
1_cust_mp_gen_plst_cteam.prg       (27 chars) - Care team lists  
1_cust_mp_gen_plst_census.prg      (28 chars) - Census/location lists
1_cust_mp_gen_plst_reltn.prg       (27 chars) - Relationship lists
1_cust_mp_gen_plst_provgrp.prg     (29 chars) - Provider group lists
1_cust_mp_gen_plst_assign.prg      (28 chars) - Assignment lists
1_cust_mp_gen_plst_query.prg       (27 chars) - Query lists
```

#### Source Mapping:
- `custom.prg` ← Copy from `1_mhn_mp_ptlst_custom_01.prg`
- `cteam.prg` ← Copy from `1_mhn_mp_ptlst_careteam_01.prg`  
- `census.prg` ← Copy from `1_mhn_mp_ptlst_census_01.prg`
- `reltn.prg` ← Copy from `1_mhn_mp_ptlst_reltn_01.prg`
- `provgrp.prg` ← Copy from `1_mhn_mp_ptlst_providergrp_01.prg`
- `assign.prg` ← Copy from `1_mhn_mp_ptlst_asgnmt_01.prg`
- `query.prg` ← Copy from `1_mhn_mp_ptlst_query_01.prg`

## Implementation Status

### ✅ Complete Implementation (10 programs)
1. **`1_cust_mp_gen_get_plists.prg`** - Get available patient lists
2. **`1_cust_mp_gen_get_pids.prg`** - Dispatcher with all patient list types
3. **`1_cust_mp_gen_get_pdata.prg`** - Patient demographics retrieval
4. **`1_cust_mp_gen_plst_custom.prg`** - Custom patient list handler
5. **`1_cust_mp_gen_plst_cteam.prg`** - Care team patient list handler
6. **`1_cust_mp_gen_plst_census.prg`** - Census/location patient list handler
7. **`1_cust_mp_gen_plst_reltn.prg`** - Relationship patient list handler
8. **`1_cust_mp_gen_plst_provgrp.prg`** - Provider group patient list handler
9. **`1_cust_mp_gen_plst_assign.prg`** - Assignment patient list handler
10. **`1_cust_mp_gen_plst_query.prg`** - Query patient list handler

## Data Flow Architecture

```
1. User selects patient list
   ↓
2. 1_cust_mp_gen_get_pids.prg (dispatcher)
   ↓
3. Determines list type (CUSTOM, CARETEAM, etc.)
   ↓
4. Calls appropriate child program (plst_custom.prg, etc.)
   ↓
5. Child program returns encounter IDs
   ↓
6. 1_cust_mp_gen_get_pdata.prg gets patient demographics
   ↓
7. Data displayed in Handsontable
```

## Patient List Type Support

### Supported Types (from respiratory MPage):
- **CUSTOM** - User-created patient lists
- **CARETEAM** - Care team-based lists
- **LOCATIONGRP** - Location group lists
- **LOCATION** - Specific location lists  
- **SERVICE** - Service-based lists
- **VRELTN** - Virtual relationship lists
- **LRELTN** - Location relationship lists
- **RELTN** - General relationship lists
- **PROVIDERGRP** - Provider group lists
- **ASSIGNMENT** - Assignment-based lists
- **QUERY** - Query-based lists

### Dispatcher Logic (in get_pids.prg):
```ccl
case (mvc_list_type)
	of "CUSTOM":
		execute 1_cust_mp_gen_plst_custom
	of "CARETEAM":
		execute 1_cust_mp_gen_plst_cteam
	of "LOCATIONGRP":
		execute 1_cust_mp_gen_plst_census
	of "LOCATION":
		execute 1_cust_mp_gen_plst_census
	of "SERVICE" :
		execute 1_cust_mp_gen_plst_census
	of "VRELTN" :
		execute 1_cust_mp_gen_plst_reltn
	of "LRELTN" :
		execute 1_cust_mp_gen_plst_reltn
	of "RELTN" :
		execute 1_cust_mp_gen_plst_reltn
	of "PROVIDERGRP" :
 		execute 1_cust_mp_gen_plst_provgrp
 	of "ASSIGNMENT":
 		execute 1_cust_mp_gen_plst_assign
 	of "QUERY":
 		execute 1_cust_mp_gen_plst_query
endcase
```

## Expected Output Formats

### Patient Lists (get_plists.prg):
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

### Patient IDs (get_pids.prg):
```json
{
  "patientCnt": 5,
  "patients": [
    {"person_id": 123, "encntr_id": 456, "person_name": "Patient, Name"}
  ],
  "status_data": {"status": "S", "message": "Successfully retrieved 5 patients"}
}
```

### Patient Data (get_pdata.prg):
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
        "AGE": 65,
        "GENDER": "Male", 
        "ADMISSION_DATE": "09/01/2025"
      }
    ]
  }
}
```

## Deployment Instructions

### 1. Copy Working Programs
Copy all respiratory MPage CCL programs and rename them with `1_cust_mp_gen` prefix.

### 2. Generic Modifications
- Remove respiratory-specific task/medication logic from `get_pdata.prg`
- Keep basic demographics: name, unit, room, class, age, gender, admission date
- Maintain the same record structures for compatibility

### 3. Compile and Test
- Compile all programs in target Cerner domain
- Test with actual patient lists
- Verify JSON output format matches JavaScript expectations

---
*Complete working CCL architecture based on proven respiratory MPage pattern*