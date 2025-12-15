# Order Status Mapping Documentation - For Requestor Review

## Overview
This document details the mapping logic used to convert Cerner order statuses to healthcare order status icons in the Sepsis Dashboard. This mapping is applied to both PowerPlan status and individual intervention orders (Lactate, Blood Cultures, Antibiotics, etc.).

## Clinical Status Mapping Logic - Sophisticated Workflow Implementation

### PowerPlan Status Mapping (Enhanced with Discontinued/Cancelled Logic)

**Clinical Context**: PowerPlans can be Initiated, Discontinued (completed), Cancelled (stopped incorrectly), or Planned.  
**Clinical Decision Point**: "Was the sepsis PowerPlan executed?" (Regardless of current status)

| Cerner Phase Status | Icon Display | Healthcare Icon | Clinical Meaning |
|-------------------|--------------|-----------------|------------------|
| **"Initiated"** | **"Y"** | 🟢 Green circle ✓ | PowerPlan currently active and running |
| **"Discontinued"** | **"Y"** | 🟢 Green circle ✓ | PowerPlan executed and completed (discontinued = finished) |
| **"Cancelled"** | **"N"** | ⚪ Gray empty circle | PowerPlan cancelled/stopped incorrectly |
| **"Planned"** | **"Pend"** | 🟡 Yellow half-filled | PowerPlan ordered but not started |
| **Not Found** | **"N"** | ⚪ Gray empty circle | No sepsis PowerPlan ordered |

**Clinical Rationale**: Discontinued PowerPlans indicate completed sepsis protocols, not failed ones.

### Blood Cultures - Collection-Focused Workflow Mapping

**Clinical Context**: Blood cultures must be physically collected BEFORE antibiotics to avoid contamination.  
**Nursing Decision Point**: "Has at least one blood culture been collected?" (Can we safely give antibiotics?)  
**Requestor Clarification**: At least one blood culture needs to be collected for antibiotic safety

| Phase Status | Order Status | Icon Display | Healthcare Icon | Nursing Workflow Meaning |
|--------------|--------------|--------------|-----------------|--------------------------|
| **Active/Discontinued** | **"Collected"** | **"Y"** | 🟢 Green circle ✓ | Blood obtained - SAFE for antibiotics |
| **Active/Discontinued** | **"In Lab"** | **"Y"** | 🟢 Green circle ✓ | Samples collected and processing - SAFE |
| **Active/Discontinued** | **"Completed"** | **"Y"** | 🟢 Green circle ✓ | Results available - SAFE |
| **Active/Discontinued** | **"Dispatched"** | **"Pend"** | 🟡 Yellow half-filled | Ordered but not collected - HOLD antibiotics |
| **Active/Discontinued** | **"Ordered"** | **"Pend"** | 🟡 Yellow half-filled | Ordered but not collected - HOLD antibiotics |
| **Cancelled** | **Any** | **"N"** | ⚪ Gray empty | Phase cancelled - not active |
| **Not Found** | **N/A** | **"N"** | ⚪ Gray empty | Blood cultures not ordered |

**Clinical Rule**: For discontinued phases, still check individual order collection status because blood may have been collected before discontinuation.

### Real Data Examples (From Encounter 114259401):
```json
// Blood Culture Phase
"pPhaseName": "Blood Culture X 2",
"orders": [
  {
    "oOrderMnemonic": "C Blood",
    "oOrderStatus": "Dispatched"  // → "Pend" → 🟡 (awaiting collection)
  },
  {
    "oOrderMnemonic": "C Blood", 
    "oOrderStatus": "Dispatched"  // → "Pend" → 🟡 (awaiting collection)
  }
]
```

### Multiple Blood Culture Logic (2 Cultures Scenario)
**Clinical Scenario**: Blood Culture X 2 (two separate cultures ordered)

#### Status Determination Logic:
```javascript
// Example: Culture #1 = "Collected", Culture #2 = "Dispatched"
const bloodCultures = [
  { oOrderMnemonic: "C Blood", oOrderStatus: "Collected" },   // Culture #1 ✅
  { oOrderMnemonic: "C Blood", oOrderStatus: "Dispatched" }   // Culture #2 ⏳
];

// "At least one collected" logic per requestor clarification
const anyCollected = bloodCultures.some(culture => 
  ["Collected", "In Lab", "Completed", "Processed"].includes(culture.oOrderStatus)
);

// Result: anyCollected = true → "Y" → 🟢 Green circle ✓ (safe for antibiotics)
```

#### Possible Scenarios:
| **Culture #1** | **Culture #2** | **Result** | **Icon** | **Nursing Decision** |
|----------------|----------------|------------|----------|---------------------|
| Dispatched | Dispatched | **Pend** | 🟡 | Neither collected - HOLD antibiotics |
| **Collected** | Dispatched | **Y** | 🟢 | At least one collected - SAFE for antibiotics |
| Dispatched | **Collected** | **Y** | 🟢 | At least one collected - SAFE for antibiotics |
| **Collected** | **Collected** | **Y** | 🟢 | Both collected - SAFE for antibiotics |

### Lactate Orders - Completion-Focused Workflow Mapping

**Clinical Context**: Lactate orders focus on completion status for clinical decision making.  
**Clinical Decision Point**: "Is the lactate order completed?" (Completion workflow focus)

| Phase Status | Order Status | Icon Display | Healthcare Icon | Clinical Meaning |
|--------------|--------------|--------------|-----------------|------------------|
| **Active/Discontinued** | **"Completed"** | **"Y"** | 🟢 Green circle ✓ | Lactate order completed - result available |
| **Active/Discontinued** | **"Dispatched"** | **"Pend"** | 🟡 Yellow half-filled | Lactate processing - result pending |
| **Active/Discontinued** | **"Ordered"** | **"Pend"** | 🟡 Yellow half-filled | Ordered but not completed |
| **Cancelled** | **Any** | **"N"** | ⚪ Gray empty | Phase cancelled - not active |
| **Not Found** | **N/A** | **"N"** | ⚪ Gray empty | Lactate not ordered |

### Antibiotics - Order-Focused Workflow Mapping

**Clinical Context**: Antibiotics focus on order initiation for sepsis intervention compliance (SEP-1 bundle).  
**Clinical Decision Point**: "Were sepsis antibiotics ordered?" (Intervention initiated)  
**Global Filtering**: Only antibiotics in sepsis-specific phases count (excludes CNS, CSF, COVID phases)

| Phase Status | Order Status | Icon Display | Healthcare Icon | Clinical Meaning |
|--------------|--------------|--------------|-----------------|------------------|
| **Active/Discontinued** | **"Ordered"** | **"Y"** | 🟢 Green circle ✓ | Sepsis antibiotic intervention initiated |
| **Active/Discontinued** | **"Dispatched"** | **"Y"** | 🟢 Green circle ✓ | Antibiotic sent to pharmacy |
| **Active/Discontinued** | **"Completed"** | **"Y"** | 🟢 Green circle ✓ | Antibiotic administered |
| **Cancelled** | **Any** | **"N"** | ⚪ Gray empty | Phase cancelled - not active |
| **Not Found** | **N/A** | **"N"** | ⚪ Gray empty | No sepsis antibiotics ordered |

**Detected Antibiotics**: piperacillin/tazobactam, vancomycin, linezolid, levofloxacin, cefepime, metronidazole  
**Clinical Rule**: Any sepsis antibiotic ordered in sepsis phases = intervention initiated (green checkmark)

### Sepsis Fluids - Resuscitation-Focused Workflow Mapping

**Clinical Context**: Sepsis fluids focus on SEP-1 bundle fluid resuscitation requirements (30 mL/kg crystalloid).  
**Clinical Decision Point**: "Were sepsis fluid resuscitation orders placed?" (SEP-1 bundle compliance)  
**Global Filtering**: Only fluids in sepsis-specific phases count (excludes CNS, CSF, COVID phases)

| Phase Status | Order Status | Icon Display | Healthcare Icon | Clinical Meaning |
|--------------|--------------|--------------|-----------------|------------------|
| **Active/Discontinued** | **"Ordered"** | **"Y"** | 🟢 Green circle ✓ | Sepsis fluid resuscitation ordered |
| **Active/Discontinued** | **"Dispatched"** | **"Y"** | 🟢 Green circle ✓ | Fluid sent to unit |
| **Active/Discontinued** | **"Completed"** | **"Y"** | 🟢 Green circle ✓ | Fluid administered |
| **Cancelled** | **Any** | **"N"** | ⚪ Gray empty | Phase cancelled - not active |
| **Not Found** | **N/A** | **"N"** | ⚪ Gray empty | No sepsis fluids ordered |

**Detected Fluids**: Sodium Chloride 0.9%, Normal Saline, Lactated Ringer, Crystalloid, Bolus fluids  
**SEP-1 Bundle Focus**: 30 mL/kg crystalloid within 3 hours for hypotension/shock  
**Clinical Rule**: Any sepsis fluid ordered in sepsis phases = resuscitation intervention initiated (green checkmark)

### Perfusion Assessment - Conditional Logic (Lactate-Dependent)

**Clinical Context**: Perfusion reassessment only indicated when lactate ≥ 4.0 mmol/L (SEP-1 6-hour bundle).  
**Conditional Display Logic**: Check lactate result FIRST, then assess intervention status.  
**Data Source Status**: **REQUESTOR INPUT NEEDED** - PowerPlan analysis shows requirement but no discrete orders.

| Lactate Result | Display | Visual | Clinical Meaning |
|----------------|---------|--------|------------------|
| **< 4.0 mmol/L** | **"N/A"** | Gray italic text | Not clinically indicated per SEP-1 guidelines |
| **≥ 4.0 mmol/L** | **TBD** | Gray italic text | Clinically indicated, awaiting data source |
| **null/undefined** | **"N/A"** | Gray italic text | Cannot determine clinical indication |

**PowerPlan Analysis Findings**:
- **Requirement found**: "CMS Core Measure: A repeat assessment of volume status and tissue perfusion is required"
- **Assessment methods**: CVP, central venous oxygen, bedside CV ultrasound, fluid challenge, passive leg raise
- **No discrete orders**: PowerPlan contains requirement note but no specific assessment orders
- **Clinical conclusion**: Likely clinical charting/documentation rather than orders

**REQUESTOR TODO**: Determine perfusion assessment data source (charting vs orders vs documentation)

### Vasopressors (Pressors) - Conditional Logic (Lactate-Dependent)

**Clinical Context**: Vasopressors only indicated when lactate ≥ 4.0 mmol/L (SEP-1 6-hour bundle shock management).  
**Conditional Display Logic**: Check lactate result FIRST, then assess intervention status.  
**Data Source Status**: **REQUESTOR INPUT NEEDED** - PowerPlan analysis shows no vasopressor orders.

| Lactate Result | Display | Visual | Clinical Meaning |
|----------------|---------|--------|------------------|
| **< 4.0 mmol/L** | **"N/A"** | Gray italic text | Not clinically indicated per SEP-1 guidelines |
| **≥ 4.0 mmol/L** | **TBD** | Gray italic text | Clinically indicated, awaiting data source |
| **null/undefined** | **"N/A"** | Gray italic text | Cannot determine clinical indication |

**PowerPlan Analysis Findings**:
- **No vasopressor orders found** in either ED Sepsis PowerPlan printout
- **ED focus**: PowerPlans contain lab, culture, antibiotic, fluid orders (not vasopressors)
- **ICU transition**: Vasopressors likely ordered when patient moves to ICU
- **Separate medication orders**: Likely outside PowerPlan structure

**REQUESTOR TODO**: Determine vasopressor order data source and medication list (norepinephrine, dopamine, etc.)

### Conditional Logic Implementation (From Sepsis Data Display Spec)

**Source**: August 20, 2025 Sepsis Data Display Specification  
**Special Display Rules**: Columns 15 (Perfusion) and 16 (Pressors)

```javascript
// Conditional logic per specification
if (LACTATE_RESULT < 4.0 || LACTATE_RESULT === null || LACTATE_RESULT === undefined) {
  Display: "N/A"
  Color: Gray (#9ca3af)
  Rationale: Not clinically indicated
} else {
  // Display standard Y/N/Pend based on actual data
  Apply standard intervention display logic
}
```

**Clinical Rationale**: Prevents inappropriate alerts for interventions that aren't clinically warranted per SEP-1 guidelines.

### Volume Documentation (Vol Doc) - Fluids-Dependent Conditional Logic

**Clinical Context**: Volume documentation only relevant when fluids are ordered/administered (cross-column dependency).  
**Conditional Display Logic**: Check Fluids column status FIRST, then assess documentation relevance.  
**Data Source Status**: **REQUESTOR INPUT NEEDED** - Volume documentation source requires clinical specification.

| Fluids Status | Vol Doc Display | Visual | Clinical Meaning |
|---------------|----------------|--------|------------------|
| **"N" (No fluids)** | **"--"** | Gray double hyphens | Not applicable - no fluids to document |
| **"Pend" (Fluids planned)** | **"--"** | Gray double hyphens | Not applicable - fluids not started |
| **"Y" (Fluids ordered)** | **"TBD"** | Gray italic text | Documentation relevant, data source pending |

**Clinical Workflow**: Fluids ordered → Fluids administered → Volume documented  
**Cross-Column Dependency**: Vol Doc status depends on Fluids column (not independent intervention)  
**SEP-1 Bundle Focus**: Volume documentation follows 30 mL/kg crystalloid resuscitation

**Clinical Questions for Requestor**:
- **Data source**: Clinical charting vs IV pump records vs automated calculation
- **Documentation workflow**: When and who documents volume administration  
- **Measurement criteria**: Total volume vs hourly rates vs cumulative balance

**REQUESTOR TODO**: Define volume documentation tracking method and data source requirements

### Time Zero - Diagnosis-Based Implementation

**Clinical Context**: Time Zero establishes sepsis identification timestamp for SEP-1 bundle timing calculations.  
**Data Source**: Severe sepsis diagnosis assertion date/time from Cerner diagnosis data.  
**Implementation Status**: **COMPLETE** ✅ - Uses enhanced CCL program with diagnosis integration.

#### Time Zero Display Logic:
| Diagnosis Status | diagAssertedDtTmDisp | Display | Clinical Meaning |
|------------------|---------------------|---------|------------------|
| **Severe sepsis diagnosis found** | **Available** | **Formatted date/time** | Time Zero established (e.g., "09/10/25 20:01") |
| **Severe sepsis diagnosis found** | **Empty/null** | **"TBD"** | Time Zero exists, date field research needed |
| **No severe sepsis diagnosis** | **N/A** | **"--"** | Time Zero not established |

#### Real Data Integration (From Enhanced CCL):
- **ZZTEST, SEPSISONE**: diagDisplay "Severe sepsis" + formatted display → Time Zero "09/10/25 20:01"
- **VEST, CAROL SUE**: diagDisplay "Severe sepsis" + empty display → Time Zero "TBD" (research needed)
- **Other patients**: No diagnosis → Time Zero "--"

#### Clinical Workflow:
- **Diagnosis assertion** → Time Zero established → Bundle timers activated
- **SEP-1 bundle timing**: 3-hour and 6-hour bundles calculated from Time Zero
- **Critical for compliance**: Objective timestamp for intervention timing

**Implementation Complete**: Time Zero functional with real Cerner diagnosis data

### Timer - Time Zero-Dependent Implementation

**Clinical Context**: Timer shows elapsed time since sepsis identification (Time Zero) for SEP-1 bundle compliance.  
**Time Zero Dependency**: Timer calculation requires established Time Zero timestamp.  
**Implementation Status**: **COMPLETE** ✅ - Real-time calculation from Time Zero.

#### Timer Display Logic (Time Zero-Dependent):
| Time Zero Status | Timer Display | Format Example | Clinical Meaning |
|------------------|---------------|----------------|------------------|
| **Formatted date/time** | **Calculated elapsed time** | "45m" or "2h 15m" | Active sepsis timer |
| **"TBD" (research needed)** | **"TBD"** | TBD | Timer pending Time Zero research |
| **"--" (no diagnosis)** | **"--"** | -- | No timer (no sepsis identified) |

#### Timer Format Rules (Enhanced for Multi-Day Patient Stays):
- **Under 1 hour**: Display as "Xm" (e.g., "45m", "23m", "58m")
- **1-23 hours**: Display as "Xh Ym" (e.g., "2h 15m", "1h 30m", "23h 45m")
- **24+ hours**: Display as "Xd Yh Zm" (e.g., "1d 2h 15m", "3d 0h 30m", "5d 12h 0m")

#### Real-Time Calculation:
- **Current Date/Time - Time Zero = Elapsed Time**
- **Updates dynamically** with each dashboard refresh
- **SEP-1 bundle timing** - Critical for 3-hour and 6-hour bundle deadlines

#### Clinical Benefits:
- **Bundle compliance tracking** - Shows elapsed time since sepsis identification
- **Real-time updates** - Dynamic calculation from established Time Zero
- **Clinical decision support** - Immediate visibility of bundle timing status

**Implementation Complete**: Timer functional with real-time calculations from Time Zero

## Global Sepsis Phase Filtering (CRITICAL)

**Clinical Context**: Sepsis PowerPlans contain multiple clinical pathways. Only sepsis-specific phases should contribute to sepsis intervention tracking.

### Phases EXCLUDED from ALL Sepsis Interventions
Even though these phases are within sepsis PowerPlans, they represent separate clinical pathways:

| Phase Type | Example Phases | Exclusion Rationale |
|------------|----------------|-------------------|
| **CSF/Meningitis** | "Cerebrospinal Fluid (CSF)" | Meningitis workup, not sepsis intervention |
| **CNS Therapy** | "ED CNS Empiric Drug Therapy" | Brain infection treatment, not sepsis treatment |
| **COVID Protocols** | "COVID-19 PUI - Admission - Active Infection Suspec" | COVID protocols, not sepsis protocols |

### Phases INCLUDED in Sepsis Interventions
Core sepsis-specific phases that should contribute to intervention tracking:

| Phase Type | Example Phases | Inclusion Rationale |
|------------|----------------|-------------------|
| **Core Sepsis Lab** | "ED Lab Panel" | Primary sepsis laboratory workup |
| **Sepsis Cultures** | "Blood Culture X 2" | Sepsis source identification |
| **Sepsis Treatment** | "ED Severe Sepsis - ADULT EKM" | Main sepsis treatment protocol |
| **Sepsis Resuscitation** | "ED Severe Sepsis Resuscitation/Antibiotics - ADULT" | Sepsis resuscitation protocol |

### Global Filtering Impact
**Applies to ALL intervention columns:**
- **PowerPlan Status**: Only sepsis phases count toward PowerPlan execution status
- **Lactate Orders**: Only lactate orders in sepsis phases count
- **Blood Cultures**: Only blood cultures in sepsis phases count  
- **Antibiotics**: Only antibiotics in sepsis phases count

**Clinical Benefit**: Ensures sepsis dashboard tracks true sepsis interventions, not coincidental orders in non-sepsis phases.

## Clinical Logic Summary for Requestor Review

**CRITICAL**: Each intervention type has intervention-specific clinical logic based on healthcare workflow requirements.

| Intervention | Primary Focus | "Y" (🟢) Criteria | "Pend" (🟡) Criteria | "N" (⚪) Criteria |
|--------------|---------------|-------------------|---------------------|-------------------|
| **PowerPlan** | **Execution Status** | Initiated OR Discontinued | Planned | Cancelled OR Not Found |
| **Blood Cultures** | **Collection Status** | At least one collected | Ordered but none collected | Cancelled phase OR Not found |
| **Lactate** | **Processing Status** | Dispatched/Completed | Ordered | Cancelled phase OR Not found |
| **Antibiotics** | **Order Status** | Ordered/Dispatched/Completed | (Rare - usually Y or N) | Cancelled phase OR Not found |
| **Fluids** | **Resuscitation Status** | Ordered/Dispatched/Completed | (Rare - usually Y or N) | Cancelled phase OR Not found |
| **Vol Doc** | **Documentation Status** | TBD (when fluids ordered) | N/A | -- (when no fluids) |

### Key Clinical Distinctions

#### Discontinued vs Cancelled (CRITICAL for Requestor Understanding)
- **"Discontinued"** = **COMPLETED** → Treat as "Y" (Protocol executed and finished)
- **"Cancelled"** = **STOPPED** → Treat as "N" (Protocol cancelled incorrectly)

#### Intervention-Specific Focus Areas
- **PowerPlan**: Did the protocol run? (Execution focus)
- **Blood Cultures**: Was blood collected? (Collection focus for antibiotic safety)  
- **Lactate**: Is the test processing? (Lab processing focus)
- **Antibiotics**: Was the medication ordered? (Order focus)

## Complex Clinical Scenarios (For Requestor Review)

### Scenario 1: Discontinued PowerPlan with Mixed Order Statuses
**Real Example**: ZZTEST, ZZSEPSISTWO
- **PowerPlan Status**: "Discontinued" → **"Y"** (Protocol was executed)
- **Blood Culture Orders**: "Dispatched" (not collected) → **"Pend"** (Need collection for antibiotics)
- **Lactate Orders**: "Dispatched" (lab processing) → **"Y"** (Lab working on it)

### Scenario 2: Active PowerPlan with Collected Blood Cultures
**Real Example**: ZZTEST, SEPSISONE  
- **PowerPlan Status**: "Initiated" → **"Y"** (Protocol currently active)
- **Blood Culture Orders**: "Dispatched" (not yet collected) → **"Pend"** (Hold antibiotics)
- **Lactate Orders**: "Dispatched" (lab processing) → **"Y"** (Lab working on it)

### Scenario 3: Cancelled PowerPlan
- **PowerPlan Status**: "Cancelled" → **"N"** (Protocol stopped incorrectly)
- **All Orders**: In cancelled phase → **"N"** (No active interventions)

## Order Status Mapping Comparison (Legacy Documentation)

### Cerner Order Status → Healthcare Icon Mapping

| Cerner Status | Icon Display | Healthcare Icon | Clinical Meaning |
|---------------|--------------|-----------------|------------------|
| **"Dispatched"** | **"Y"** | 🟢 Green filled circle with ✓ | Order sent to department, being processed |
| **"Completed"** | **"Y"** | 🟢 Green filled circle with ✓ | Order fulfilled, results available |
| **"Ordered"** | **"Pend"** | 🟡 Yellow half-filled circle | Order placed but not yet processed |
| **Not Found** | **"N"** | ⚪ Gray empty circle | Order not placed/not in PowerPlan |

## Real Data Examples (From Encounter 114259401)

### Laboratory Orders - "Dispatched" Status
```json
{
  "oOrderId": 6867049733,
  "oOrderMnemonic": "LA",           // Lactate/Lactic Acid
  "oOrderStatus": "Dispatched",     // → "Y" → 🟢 Green circle with ✓
  "oOrderCatalogCd": 272253411
}

{
  "oOrderId": 6867049751,
  "oOrderMnemonic": "C Blood",      // Blood Culture
  "oOrderStatus": "Dispatched",     // → "Y" → 🟢 Green circle with ✓
  "oOrderCatalogCd": 31713873
}
```

### Nursing Orders - "Ordered" Status
```json
{
  "oOrderId": 6867049711,
  "oOrderMnemonic": "Peripheral IV", // IV Access
  "oOrderStatus": "Ordered",         // → "Pend" → 🟡 Yellow half-filled circle
  "oOrderCatalogCd": 2780695
}

{
  "oOrderId": 6867049713,
  "oOrderMnemonic": "Vital Signs",   // Monitoring
  "oOrderStatus": "Ordered",         // → "Pend" → 🟡 Yellow half-filled circle  
  "oOrderCatalogCd": 2696752
}
```

### Audit Orders - "Completed" Status
```json
{
  "oOrderId": 6867049727,
  "oOrderMnemonic": "ED Adult Severe Sepsis Audit", // Quality Audit
  "oOrderStatus": "Completed",       // → "Y" → 🟢 Green circle with ✓
  "oOrderCatalogCd": 661838449
}
```

## Mapping Rationale

### Clinical Workflow Logic
1. **"Dispatched" = Active Processing**
   - Order has been sent to appropriate department (Lab, Pharmacy, etc.)
   - Work is in progress or being performed
   - **Clinical Status**: Active intervention
   - **Icon**: Green filled circle (positive status)

2. **"Completed" = Task Finished**
   - Order has been fulfilled completely
   - Results may be available
   - **Clinical Status**: Intervention completed
   - **Icon**: Green filled circle (positive status)

3. **"Ordered" = Waiting for Processing**
   - Order has been placed but not yet sent to department
   - Awaiting scheduling or department pickup
   - **Clinical Status**: Pending intervention
   - **Icon**: Yellow half-filled circle (in-progress status)

4. **Not Found = No Order Placed**
   - No order exists for this intervention in the PowerPlan
   - Intervention not requested or planned
   - **Clinical Status**: No intervention
   - **Icon**: Gray empty circle (neutral status)

## Sepsis-Specific Applications

### Current Implementation: Lactate Orders
- **Search Pattern**: `oOrderMnemonic === "LA"` (Lactic Acid)
- **Real Data**: LA order with "Dispatched" status → "Y" → 🟢
- **Clinical Significance**: Initial lactate is critical first step in sepsis bundle

### Future Interventions (Same Logic):
- **Blood Cultures**: `oOrderMnemonic === "C Blood"` 
- **Antibiotics**: `oOrderMnemonic` containing antibiotic names
- **IV Fluids**: `oOrderMnemonic === "Peripheral IV"` or fluid orders

## Modification Instructions (For Requestors)

### To Change Order Status Mapping:
1. **Edit PatientDataService.js** - Find `determineLactateOrderedStatus` function
2. **Modify switch statement** - Update Cerner status to icon mapping
3. **Update this documentation** - Reflect new mapping logic
4. **Test with real data** - Verify new mapping works with your Cerner environment

### To Add New Order Status:
```javascript
// Add new case to switch statement
case "NewCernerStatus":
    return "Y" | "Pend" | "N";  // Choose appropriate icon
```

### To Change Icon Display:
- **Healthcare icons**: Modify CSS classes in styles.css  
- **Alternative icons**: Uncomment backup icon versions in powerplanRenderer

## Order Status Discovery

### Found in Real Data (Encounter 114259401):
- **"Dispatched"** - 10 lab orders (LA, CBC, Hepatic, PT, APTT, etc.)
- **"Ordered"** - 5 nursing orders (Bedrest, IV, Vitals, Monitoring, etc.)
- **"Completed"** - 1 audit order (Sepsis Audit)

### Potential Additional Statuses (Not Yet Seen):
- **"Pending"** - Possible order status
- **"Cancelled"** - Cancelled orders
- **"Discontinued"** - Stopped orders
- **"Failed"** - Failed orders

## Review Questions for Requestors

1. **Is "Dispatched" = "Y" correct?** (Order sent to lab/department)
2. **Is "Ordered" = "Pend" correct?** (Order placed but not sent)  
3. **Should "Completed" = "Y"?** (Order finished/resulted)
4. **Any additional Cerner statuses** to consider?
5. **Different mapping needed** for different order types?

## Testing Environment
- **Real Patient**: ZZTEST, ZZSEPSISTWO (Encounter 114259401)
- **Real PowerPlan**: ED Severe Sepsis - ADULT
- **Real Lactate Order**: LA with "Dispatched" status
- **Expected Result**: 🟢 Green circle with checkmark in ① Lac column

---
*Order Status Mapping Documentation*  
*Sepsis Dashboard v1.4.0*  
*Created: 2025-09-09*  
*For Requestor Review and Approval*