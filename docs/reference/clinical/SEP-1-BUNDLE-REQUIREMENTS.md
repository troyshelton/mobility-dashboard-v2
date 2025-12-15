# SEP-1 Bundle Requirements - CMS Clinical Reference

**Document Purpose:** Clinical reference for SEP-1 bundle compliance requirements per CMS core measure

**Last Updated:** 2025-10-16
**Sources:** CMS Hospital IQR Program, Surviving Sepsis Campaign 2021, PMC research articles

---

## Overview

**SEP-1 (Early Management Bundle, Severe Sepsis/Septic Shock)** is a CMS core measure that tracks compliance with evidence-based sepsis interventions.

**Key Characteristics:**
- **"All or Nothing" measure** - Must complete ALL applicable elements for credit
- **Time-based** - Strict 3-hour and 6-hour deadlines from "Time Zero"
- **Publicly reported** - Hospital compliance rates visible on CMS Hospital Compare
- **Pay-for-performance** - Added to Hospital Value-Based Purchasing (VBP) Program in FY 2026

---

## Time Zero Definition

**Time Zero** is the earliest point when a patient meets criteria for severe sepsis or septic shock.

Can be triggered by:
- Clinical diagnosis of severe sepsis/septic shock
- Sepsis alert firing (meeting SIRS + infection criteria)
- PowerForm sepsis screening documentation
- Elevated lactate with infection source

**Critical:** Time Zero starts the countdown for ALL bundle interventions.

---

## 3-Hour Bundle (UNIVERSAL - All Severe Sepsis/Septic Shock Patients)

**Applies to:** ALL patients with severe sepsis or septic shock
**Deadline:** Within 3 hours of Time Zero
**Compliance:** MUST complete all 4 elements

### Elements:

#### 1. Measure Lactate Level
- **Timing:** Critical - delay >20 minutes associated with increased mortality
- **Purpose:** Identify tissue hypoperfusion
- **Threshold:** Lactate ≥4.0 mmol/L triggers additional 6-hour bundle requirements

#### 2. Obtain Blood Cultures (Before Antibiotics)
- **Timing:** Delay >50 minutes associated with increased mortality
- **Requirement:** At least 2 sets (aerobic + anaerobic)
- **Critical:** MUST be drawn BEFORE antibiotic administration
- **Nursing workflow:** Ordered → Collected → In Lab

#### 3. Administer Broad-Spectrum Antibiotics
- **Timing:** Delay >125 minutes associated with increased mortality
- **Requirement:** Appropriate for suspected infection source
- **Critical:** After blood cultures but within 3-hour window

#### 4. Administer 30 mL/kg Crystalloid Fluids (IF Indicated)
- **Triggers:**
  - Hypotension (MAP <65 mmHg), OR
  - Lactate ≥4.0 mmol/L
- **Timing:** Delay >100 minutes associated with increased mortality
- **Volume:** 30 mL/kg ideal body weight
- **Fluid types:** Normal saline, Lactated Ringer's, Normosol (balanced crystalloids)

**Note:** Element #4 is CONDITIONAL - only required if hypotension OR elevated lactate present.

---

## 6-Hour Bundle (CONDITIONAL - Septic Shock or Lactate ≥4.0 Only)

**Applies to:** ONLY patients with:
- Septic shock (persistent hypotension despite fluids), OR
- Initial lactate ≥4.0 mmol/L

**Deadline:** Within 6 hours of Time Zero
**Compliance:** MUST complete all applicable elements

### Elements:

#### 5. Repeat Lactate Measurement
- **Trigger:** Initial lactate was elevated (≥2.0 or ≥4.0, varies by protocol)
- **Purpose:** Assess response to resuscitation (lactate clearance)
- **Timing:** Within 6 hours of Time Zero
- **Goal:** Trending down indicates effective resuscitation

#### 6. Apply Vasopressors (IF Indicated)
- **Trigger:** Hypotension persists AFTER adequate fluid resuscitation
- **Goal:** Maintain MAP ≥65 mmHg
- **Common agents:** Norepinephrine (first-line), vasopressin, epinephrine
- **Timing:** Within 6 hours of Time Zero

#### 7. Document Reassessment of Volume Status and Tissue Perfusion
- **Trigger:** Septic shock (persistent hypotension)
- **Methods:**
  - Repeat physical exam
  - Passive leg raise test
  - Stroke volume variation
  - Echocardiography assessment
- **Purpose:** Guide ongoing fluid management, prevent fluid overload

---

## Clinical Decision Logic

### For ALL Severe Sepsis Patients:
```
Time Zero identified
  ↓
3-Hour Bundle (Elements 1-4)
  - Lactate measured
  - Blood cultures drawn
  - Antibiotics given
  - Fluids (IF hypotension OR lactate ≥4.0)
```

### For Septic Shock OR High Lactate Patients:
```
Initial lactate ≥4.0 OR persistent hypotension
  ↓
6-Hour Bundle (Elements 5-7) APPLIES
  - Repeat lactate
  - Vasopressors (IF hypotension persists)
  - Reassess volume status
```

### For Stable Patients (Lactate <4.0, No Shock):
```
Initial lactate <4.0 AND BP responds to fluids
  ↓
6-Hour Bundle DOES NOT APPLY
  - Repeat lactate: N/A
  - Vasopressors: N/A
  - Perfusion reassessment: N/A
```

---

## Dashboard Implementation Mapping

### Current Dashboard Columns:

**3-Hour Bundle Elements:**
- ✅ **PowerPlan** - Sepsis PowerPlan initiation (bundle container)
- ✅ **Lac 1** - Initial lactate order/result (Element 1)
- ✅ **Cultures** - Blood culture collection (Element 2)
- ✅ **Abx** - Antibiotic administration (Element 3)
- ✅ **Fluids** - Crystalloid resuscitation (Element 4, conditional)

**6-Hour Bundle Elements:**
- ✅ **Lac 2** - Repeat lactate (Element 5, conditional - shows "N/A" if lactate <4.0)
- ✅ **Perfusion** - Volume/perfusion reassessment (Element 7, conditional)
- ✅ **Pressors** - Vasopressor administration (Element 6, conditional)

**Timer:**
- ✅ **3-Hr Timer** - Tracks time remaining for 3-hour bundle compliance
- ❓ **6-Hr Timer** - Potential enhancement (conditional, only for lactate ≥4.0 patients)

---

## Key Clinical Insights

### Why 3-Hour Bundle is Universal:
- Early intervention dramatically reduces mortality
- Lactate measurement: 20-minute delay increases death risk
- Blood cultures: 50-minute delay increases death risk
- Antibiotics: 125-minute delay increases death risk
- Time-sensitive interventions require strict tracking

### Why 6-Hour Bundle is Conditional:
- Only applies to sickest patients (shock or high lactate)
- Not all sepsis patients progress to shock
- Conditional logic prevents unnecessary interventions
- Lactate <4.0 with stable BP = 6-hour bundle NOT needed

### Clinical Decision Example:

**Patient A:**
- Lactate: 2.3 mmol/L (normal)
- BP: 120/80, responds to 1L NS
- **Result:** 3-hour bundle only, 6-hour bundle N/A

**Patient B:**
- Lactate: 5.2 mmol/L (critical)
- BP: 85/50, persistent after 2L NS
- **Result:** 3-hour bundle + 6-hour bundle required

---

## Recent Updates (2018-2024)

### 2018: Hour-1 Bundle (Surviving Sepsis Campaign)
- SSC combined 3-hour and 6-hour into single "Hour-1 Bundle"
- All interventions to START within 1 hour
- More aggressive than CMS SEP-1 (which still uses 3-hour/6-hour)

### 2024: VBP Inclusion
- SEP-1 moved from pay-for-reporting to pay-for-performance
- Hospital reimbursement now tied to SEP-1 compliance
- Increased focus on documentation and timing accuracy

### Current CMS Requirement (2024-2025):
- Still uses 3-hour and 6-hour bundle framework
- Has NOT adopted SSC Hour-1 Bundle (yet)
- Hospitals measured on 3-hr/6-hr compliance

---

## Mortality Impact

**Research Findings:**
- **3-hour bundle compliance:** 40% reduction in hospital mortality
- **6-hour bundle compliance:** 36% reduction in hospital mortality
- **Combined compliance:** 25% relative risk reduction
- **Time delays significantly increase mortality** (especially lactate, blood cultures)

---

## References

1. CMS Hospital Inpatient Quality Reporting (IQR) Program - SEP-1 Measure
2. Surviving Sepsis Campaign Guidelines 2021 (SCCM/ESICM)
3. PMC5396984 - Compliance with Updated Sepsis Bundles
4. PMC9448659 - Improving Compliance with CMS SEP-1 Bundle
5. HealthLeaders Media - CMS SEP-1 VBP Inclusion (2024)
6. PMC5851815 - Delay within 3-Hour SSC Guideline on Mortality

---

## Dashboard Design Considerations

### Why Current Design is Clinically Sound:

1. **3-Hour Timer is Universal** - All patients need 3-hour bundle tracking
2. **Conditional 6-Hour Columns** - Shows N/A when not applicable (prevents alert fatigue)
3. **Lactate-Driven Logic** - Automatically determines 6-hour bundle applicability
4. **Visual Indicators** - Color coding (badges) highlights urgency

### Potential Enhancement: Conditional 6-Hour Timer

**Concept:** Display a second timer ONLY when 6-hour bundle applies

**Trigger Logic:**
```
IF (initial lactate ≥4.0 OR septic shock diagnosis)
  THEN display "6-Hr Timer" showing time remaining
ELSE
  display "N/A" (6-hour bundle not applicable)
```

**Clinical Benefit:**
- Tracks repeat lactate compliance window
- Helps nursing staff prioritize high-acuity patients
- Maintains clean interface (N/A for stable patients)

**Implementation Considerations:**
- Would need column space (or replace 3-Hr Timer for shock patients)
- Requires conditional logic similar to Lac 2/Perfusion/Pressors
- May add complexity vs. clinical benefit

---

**Created:** 2025-10-16
**Author:** Clinical reference compiled from CMS/SSC guidelines
**For:** Sepsis Dashboard development team
