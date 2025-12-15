# Stakeholder Discussion: SEP-1 Logic Comparison

**Purpose:** Compare current dashboard logic vs. Tammy's abstractor feedback vs. CMS SEP-1 requirements

**Meeting Date:** TBD
**Attendees:** Tammy Mitchell, Casey Wolfe, Dr. Crawford, Dr. Anwar, Shannon Carpenter, Carrie Morris, Troy Shelton

---

## Quick Summary

**Tammy's feedback raises important questions about:**
1. Should we track **separate Septic Shock time zero**?
2. Is IVF timeframe **-6hr to +3hr** from shock (vs. standard 3hr from sepsis)?
3. Should we add **"Ruled Out" column**?

**Current dashboard aligns with standard CMS SEP-1**, but may need adjustment based on CAMC's abstraction practice.

---

## Comparison Table

| Element | Current Dashboard | Standard CMS SEP-1 | Tammy's Request | Decision Needed |
|---------|-------------------|-------------------|-----------------|-----------------|
| **Time Zero** | One timestamp (Severe Sepsis) | One timestamp (Severe Sepsis presentation) | Two timestamps (Severe Sepsis + Septic Shock) | ❓ One or two? |
| **Septic Shock Definition** | Lactate ≥4.0 (Phase 1 only) | Hypotension OR lactate ≥4.0 | Hypotension OR lactate >4 | ✅ Add hypotension (Phase 2) |
| **IVF Timeframe** | 3 hours from Severe Sepsis | 3 hours from Severe Sepsis | -6hr to +3hr from Septic Shock | ❓ Which is correct? |
| **IVF Trigger** | Lactate ≥4.0 (partial) | Hypotension OR lactate ≥4.0 | Hypotension OR lactate >4 | ✅ Issue #16 Phase 2 |
| **Perfusion Start** | Not implemented | Not clearly specified | IVF completion time | ❓ Need guidance |
| **Perfusion End** | 6hr from Severe Sepsis (TBD) | 6hr from Severe Sepsis | 6hr from Septic Shock | ❓ Which time zero? |
| **"Ruled Out" Column** | Not present | Not required | Requested | ❓ Value for abstraction? |

---

## Detailed Analysis

### **Issue 1: IVF Timeframe (-6hr to +3hr?)**

**Tammy's Statement:**
> "The appropriate timeframe for IVF is from 6 hours prior to through 3 hours after the documented onset of Septic SHOCK"

**Standard CMS SEP-1 (Multiple Sources):**
- "30 mL/kg within 3 hours of sepsis presentation" (PMC9448659)
- "Within 180 minutes of sepsis presentation" (Dexur SEP-1 Guide)
- "Within 3 hours of severe sepsis presentation time" (CMS Quality Reporting)

**Question:** Where does the -6hr to +3hr window come from?

**Possible explanations:**
1. **Facility-specific abstraction practice** - CAMC may use different window
2. **Clinical practice vs. measure** - Clinicians may give fluids earlier, abstractors count retroactively
3. **Misunderstanding** - May be conflating fluid timing with "look-back" period for documentation

**Research finding:**
> "If septic shock is identified within 360 minutes (6 hours) of severe sepsis presentation, then the entire 6-hour septic shock bundle must be completed" (Dexur)

This says if shock develops WITHIN 6 hours, not that fluids can be -6hr to +3hr!

---

### **Issue 2: Separate Septic Shock Time Zero**

**Current Standard:** ONE time zero (Severe Sepsis)

**Tammy's Request:** TWO time zeros:
1. Severe Sepsis time
2. Septic Shock time (when hypotension OR lactate >4 first occurs)

**CMS SEP-1:** Uses one time zero (Severe Sepsis), but elements 4-7 are conditional on Septic Shock criteria

**Question:** Does CAMC abstraction require tracking when Septic Shock criteria were met separately?

**Potential Value:**
- Could help calculate when fluids/pressors/perfusion windows start
- May simplify abstraction if Septic Shock develops later
- Aligns with clinical progression (sepsis → shock)

---

### **Issue 3: Perfusion Reassessment Timing**

**Tammy's Statement:**
> "The timeframe for the perfusion reassessment starts with the completion of the IVF date/time and ending 6 hr after Septic SHOCK date/time."

**CMS SEP-1:**
- Reassess volume status within 6 hours of Severe Sepsis presentation
- For patients with septic shock (persistent hypotension)

**Tammy's Addition:**
- START: When IVF completed (not just time zero + 0hr)
- END: 6hr after SEPTIC SHOCK (not Severe Sepsis)

**Question:** Is this facility-specific interpretation or CMS requirement?

---

### **Issue 4: ED vs. Inpatient Scope**

**Current:** One dashboard (ED-focused based on current use)

**Tammy's Context:**
> "For abstraction purposes, IVF administration and perfusion reassessment are correlated with Septic Shock, rather than Severe Sepsis."

**Questions:**
1. Are ED and Inpatient abstracted differently?
2. Is Inpatient sepsis more likely to be Septic Shock?
3. Should Phase 1 (ED) use simpler logic, Phase 2 (Inpatient) use Septic Shock time?

---

## Dashboard Implementation Options

### **Option A: Keep Current Logic (Standard CMS SEP-1)**
**Pro:**
- Aligns with published CMS measure specs
- Simpler to implement and understand
- Works for majority of cases

**Con:**
- May not match CAMC's abstraction practice
- Could show incorrect compliance if Tammy's interpretation is facility standard

### **Option B: Implement Tammy's Logic**
**Pro:**
- Aligns with abstractor's interpretation
- May improve abstraction pass rates
- Shows clinical progression (sepsis → shock)

**Con:**
- Requires major redesign (separate time zeros, wider timeframes)
- Differs from standard CMS interpretation
- Complex to implement

### **Option C: Hybrid Approach**
**Pro:**
- ED dashboard (Phase 1): Standard CMS logic
- Inpatient dashboard (Phase 2): Septic Shock-focused with Tammy's timeframes
- Best of both worlds

**Con:**
- Two different dashboards to maintain
- Requires clear documentation of differences

---

## Questions Requiring Answers

### **CRITICAL Questions:**

1. **IVF Timeframe:** Is -6hr to +3hr window:
   - [ ] CMS requirement (need citation)
   - [ ] CAMC abstraction practice (need policy)
   - [ ] Misunderstanding (need clarification)

2. **Septic Shock Time Zero:** Should we track:
   - [ ] One time zero (Severe Sepsis only) - current
   - [ ] Two time zeros (Severe Sepsis + Septic Shock) - Tammy's request
   - [ ] Depends on ED vs. Inpatient

3. **Dashboard Scope:** What's in Phase 1?
   - [ ] ED only (current assumption)
   - [ ] ED + Inpatient (combined)
   - [ ] ED first, Inpatient Phase 2

### **Secondary Questions:**

4. **"Ruled Out" Column:**
   - [ ] Yes, add to dashboard
   - [ ] No, not needed
   - [ ] Phase 2 only

5. **Abstraction Alignment:**
   - [ ] Dashboard should match abstraction practice exactly
   - [ ] Dashboard should match CMS specs, abstractors adapt
   - [ ] Create dashboard mode toggle (CMS vs. Facility)

---

## Pre-Meeting Action Items

**For Tammy:**
- [ ] Provide CMS measure specification citation for -6hr to +3hr window
- [ ] Share CAMC's official abstraction guidelines
- [ ] Clarify if this applies to ED, Inpatient, or both

**For Casey:**
- [ ] Confirm CAMC's SEP-1 abstraction practice
- [ ] Validate timeframes used for compliance reporting
- [ ] Clarify ED vs. Inpatient dashboard scope

**For Development Team (Troy):**
- [x] Research standard CMS SEP-1 requirements (completed)
- [x] Document current dashboard logic (completed)
- [x] Create comparison table (this document)
- [ ] Prepare implementation options for each scenario

---

## Current Dashboard Logic (v1.34.0-sepsis)

**Time Zero:**
- Single timestamp: Earliest of Alert, Diagnosis, or PowerForm screening
- Displayed in "Time Zero" column

**3-Hour Bundle:**
- Element 1: Lactate ✅
- Element 2: Blood cultures ✅
- Element 3: Antibiotics ✅
- Element 4: Fluids - **Conditional on lactate ≥4.0** (Issue #16 Phase 1)
  - ⚠️ Missing: Hypotension check (Phase 2 pending)
  - ⚠️ Timeframe: 3hr from Severe Sepsis (standard CMS)

**6-Hour Bundle:**
- Element 5: Repeat lactate - Conditional on lactate ≥4.0 ✅
- Element 6: Vasopressors - Conditional ✅
- Element 7: Perfusion - Conditional, logic TBD

**Timer:**
- 3-Hr Timer: Counts down from Severe Sepsis Time Zero
- Shows bundle completion status when expired (Issue #17)

---

## Proposed Changes Based on Feedback

### **If Tammy's Interpretation is Correct:**

**Major Changes Needed:**
1. Add "Septic Shock Time Zero" column
2. Track when hypotension OR lactate >4 first occurs
3. Expand IVF timeframe to -6hr to +3hr window
4. Change perfusion window to start at IVF completion
5. Add "Ruled Out" column

**Estimated Effort:** 2-3 weeks development + testing

### **If Standard CMS is Correct:**

**Minor Changes Needed:**
1. Complete Issue #16 Phase 2 (add hypotension check)
2. Optionally add "Ruled Out" column
3. Current timeframes remain (3hr/6hr from Severe Sepsis)

**Estimated Effort:** 1 week development + testing

---

## References

**CMS SEP-1 Sources:**
- CMS Hospital IQR Program - SEP-1 Measure Specifications
- PMC9448659 - "Improving Compliance with CMS SEP-1 Bundle"
- PMC9924005 - "Compliance with SEP-1 guidelines"
- Dexur - "SEP-1 Compliance and Timings Guide"
- CMS Quality Reporting Center - Official measure documentation

**Abstraction Variability:**
- PMC7977505 - "Abstractors agreed on time zero in only 36% of cases"
- CID 72(4) - IDSA recommendations on SEP-1 reliability issues

**CAMC-Specific:**
- `docs/reference/clinical/SEP-1-BUNDLE-REQUIREMENTS.md` - Current understanding
- Tammy Mitchell email - October 16, 2025

---

## Decision Matrix

| If Stakeholders Decide... | Then We... | Timeline |
|---------------------------|------------|----------|
| Use standard CMS logic | Continue current approach, complete Issue #16 Phase 2 | 1 week |
| Use Tammy's -6hr to +3hr window | Major redesign, add Septic Shock time, expand windows | 2-3 weeks |
| ED = standard, Inpatient = Tammy's | Build two dashboards with different logic | 3-4 weeks |
| Need more research | Pause development, get official CMS guidance | TBD |

---

**Created:** 2025-10-16
**For:** Stakeholder alignment meeting
**Related:** Issue #20, Issue #16, Issue #17, Issue #19
