# Sepsis Dashboard Stakeholder Meeting - Agenda

**Date:** Week of October 21, 2025 (TBD)
**Time:** TBD
**Location:** TBD

**Attendees:**
- Dr. Anthony Uy (Chief Quality Officer)
- Dr. Adam Crawford (Physician)
- Casey Wolfe (Sepsis Coordinator)
- Tammy Mitchell (Abstractor)
- Dr. Javaria Anwar
- Shannon Carpenter
- Carrie Morris (SICU)
- Troy Shelton (IT Development)

**Purpose:** Align on sepsis dashboard requirements, abstraction needs, and implementation roadmap

---

## Pre-Meeting Materials

**Please review before meeting:**
1. ✅ Novant Health article (shared by Dr. Uy) - Mortality reduction case study
2. ✅ Executive Summary (`docs/reference/EXECUTIVE-SUMMARY-DR-UY-NOVANT-ALIGNMENT.md`)
3. ✅ Tammy's abstraction feedback + screenshot (Issue #20)
4. ✅ Current dashboard demo (CERT environment)

---

## Agenda Items

### **1. Dashboard Validation (15 min)**

**Purpose:** Validate that dashboard implements proven model

#### **Novant Health Success Story**
- **Result:** >50% mortality reduction since 2021
- **Key Factor:** Live data dashboard monitoring bundle compliance
- **Quote:** "That level of accountability improved compliance and outcomes"

#### **CAMC Dashboard Alignment**
- ✅ Live bundle monitoring (exact match)
- ✅ 3-hour and 6-hour windows (exact match)
- ✅ All bundle elements tracked (exact match)
- ✅ Enhanced features (completion icons, conditional logic)

**Discussion:**
- Dashboard implements Novant's proven model
- Opportunity for similar outcomes

**Decision:** Approve continued development? ✅ or ❌

---

### **2. Abstraction Requirements - TWO Time Zeros (30 min)**

**Purpose:** Align dashboard with official CMS abstraction form

#### **Critical Discovery (Tammy's Screenshot)**

**CMS SEP-1 Abstraction Form has TWO SEPARATE sections:**
1. **Severe Sepsis Presentation** (Date + Time)
2. **Septic Shock Presentation** (Date + Time) - SEPARATE timestamp

**Questions 31-42 (IVF, vasopressors, reassessment) measured from SEPTIC SHOCK time, not Severe Sepsis time**

#### **Current Dashboard Issue:**
- ✅ Tracks Severe Sepsis time (one Time Zero)
- ❌ Does NOT track Septic Shock time
- ❌ Measures fluids/pressors/perfusion from wrong time zero

#### **Tammy's Requests Explained:**

**1. Septic Shock Time Zero Column**
- When patient first meets: (Severe Sepsis) + (hypotension OR lactate >4)
- May be DIFFERENT from Severe Sepsis time
- Required for accurate abstraction

**2. IVF Timeframe: -6hr to +3hr from Septic Shock**
- Abstractors look for fluids from 6 hours before shock through 3 hours after
- Currently: We check 3 hours from Severe Sepsis (incorrect for abstraction)

**3. Perfusion Timing: From IVF completion to +6hr after Septic Shock**
- Window starts when fluids completed
- Ends 6 hours after Septic Shock time
- Currently: Not clearly defined

**Discussion Questions:**
1. Does CAMC abstraction use this 2-time-zero model? (Tammy confirm)
2. Is IVF -6hr to +3hr window official practice? (Tammy provide reference)
3. Should dashboard match abstraction form exactly?
4. Timeline for implementation?

**Decision:** Implement two time zeros? ✅ Priority? 🔥 High / Medium / Low

**Reference:** Issue #20, Tammy's screenshot

---

### **3. Provider Screen-Driven Bundle Logic (20 min)**

**Purpose:** Determine if provider assessment should override lab values

#### **Clinical Scenarios:**

**A. Provider Screens "Septic Shock" but Lactate <4.0**
- Current: 6-hr bundle shows "N/A" (lactate-based)
- Proposed: 6-hr bundle shows icons (provider assessment primary)
- Rationale: Provider identifies shock via hypotension/clinical judgment

**B. Provider Screens "Ruled Out"**
- Current: Shows bundle icons if elements present
- Proposed: ALL bundles show "N/A" (not sepsis-related)
- Rationale: Blood cultures/antibiotics were for other reasons

**C. Provider Screens "Cannot Determine"**
- Current: Uncertain behavior
- Proposed: ??? Show icons (conservative) or N/A?

**Discussion Questions:**
1. Should provider assessment always override lab values?
2. How to handle "Ruled Out" (show N/A for all bundles)?
3. What about "Cannot Determine"?
4. Clinical workflow implications?

**Decision:** Provider screen primary? ✅ or ❌

**Reference:** Issue #24

---

### **4. Timeline Changes (Ruled Out → Develops Sepsis) (15 min)**

**Purpose:** Handle sepsis developing during hospitalization

#### **Scenario:**
- Day 1 ED: "Ruled Out" → Dashboard shows N/A
- Day 3 Inpatient: "Severe Sepsis" develops → Dashboard should reset

**Current:** May use Day 1 "Ruled Out" as Time Zero (incorrect)
**Proposed:** Detect screening changes, reset to Day 3 as new Time Zero

**Discussion Questions:**
1. How common is this scenario at CAMC?
2. Priority for ED (rare) vs. Inpatient (more common)?
3. Should dashboard show screening history or just latest?

**Decision:** Implement timeline reset logic? ✅ Phase? 📅

**Reference:** Issue #25

---

### **5. Blood Cultures "Collected" = Complete (10 min)**

**Purpose:** Confirm SEP-1 interpretation for bundle completion

#### **Current Dashboard:**
- Blood cultures show green ✓ when "Collected" (nursing workflow)
- Bundle check counts "Collected" as complete (SEP-1 Element 2)

**SEP-1 Requirement:**
- "Obtain blood cultures before antibiotics"
- "Obtained" = Collected (doesn't require final lab results)

**Discussion Questions:**
1. Does Casey agree "Collected" = complete for SEP-1?
2. Matches CAMC's abstraction practice? (Tammy confirm)
3. Any concerns with current logic?

**Decision:** Keep current logic? ✅ or ❌

**Reference:** Issue #19

---

### **6. 6-Hour Timer Request (10 min)**

**Purpose:** Determine if conditional 6-hour timer needed

#### **Physician Request:**
- Add second timer for 6-hour bundle compliance
- Would only show when 6-hr bundle applies (shock/high lactate)

**Current:** 3-hour timer only

**Discussion Questions:**
1. Clinical value of 6-hour timer?
2. Would it reduce confusion or add complexity?
3. Space constraints in UI?

**Decision:** Add 6-hour timer? ✅ or ❌ Priority? 🔥

**Reference:** Issue #15

---

### **7. Dashboard Scope - ED vs. Inpatient (15 min)**

**Purpose:** Clarify Phase 1 scope and future phases

#### **Questions:**

**Phase 1 Scope:**
- Is current dashboard ED-focused?
- Should it also work for Inpatient?
- Different requirements for ED vs. Inpatient?

**Abstraction Differences:**
- Does ED sepsis abstract differently than Inpatient?
- Are two time zeros more relevant for Inpatient?
- Timeline changes more common in Inpatient?

**Rollout Plan:**
- ED first, then Inpatient?
- Combined dashboard?
- Two separate dashboards?

**Discussion Questions:**
1. What's in Phase 1 (current work)?
2. Timeline for Inpatient dashboard?
3. Resource allocation?

**Decision:** Phase 1 scope? 📋 Timeline? 📅

---

### **8. Issue Prioritization (15 min)**

**Purpose:** Prioritize enhancements based on clinical impact

#### **Open Issues:**

| Issue | Title | Impact | Effort | Priority? |
|-------|-------|--------|--------|-----------|
| #15 | 6-Hour Timer | Medium | Low | ? |
| #16 Phase 2 | Add Hypotension/MAP Data | High | Medium | ? |
| #19 | Blood Cultures "Collected" = Complete | Low | None | ✅ Validated |
| #20 | Two Time Zeros (Septic Shock Time) | **CRITICAL** | **High** | ? |
| #22 | Novant Model Enhancements | Medium | Varies | ? |
| #24 | Provider Screen-Driven Logic | High | Medium | ? |
| #25 | Timeline Changes (Ruled Out → Sepsis) | Medium | Medium | ? |

**Discussion:**
- Which issues are most critical?
- What's the implementation order?
- Resource constraints?

**Decision:** Priority ranking? 🔢 Timeline? 📅

---

### **9. Implementation Roadmap (10 min)**

**Purpose:** Agree on timeline and phases

#### **Proposed Roadmap:**

**Phase 1 (Current - Q4 2025):**
- ✅ Issue #13: Text alignment (COMPLETE)
- ✅ Issue #16 Phase 1: Fluids conditional (COMPLETE)
- ✅ Issue #17: Bundle completion icons (COMPLETE)
- 📋 Deploy to ED
- 📋 Measure baseline compliance

**Phase 2 (Q1 2026):**
- 📋 Issue #20: Two time zeros (Septic Shock time)
- 📋 Issue #16 Phase 2: Add hypotension/MAP data
- 📋 Issue #24: Provider screen-driven logic
- 📋 3-month impact review

**Phase 3 (Q2 2026):**
- 📋 Issue #25: Timeline changes handling
- 📋 Inpatient dashboard (if different requirements)
- 📋 Analytics layer (compliance tracking)

**Discussion:**
- Does this timeline work?
- Resource availability?
- Training plan?

**Decision:** Approve roadmap? ✅ Adjust? 📝

---

### **10. Success Metrics (10 min)**

**Purpose:** Define how we'll measure dashboard impact

#### **Proposed Metrics:**

**Process Measures:**
- Bundle compliance rates (3-hour and 6-hour)
- Time to antibiotics
- Blood culture collection rates
- Fluids administration compliance

**Outcome Measures:**
- Sepsis mortality rates
- ICU admission rates
- Length of stay
- Readmission rates

**Baseline:**
- Establish current metrics (before dashboard)
- Track monthly changes
- Target: Novant-level improvement (50% mortality reduction)

**Discussion:**
- What metrics matter most?
- How to collect baseline?
- Reporting frequency?

**Decision:** Approve metrics? ✅ Reporting plan? 📊

---

### **11. Training and Communication (10 min)**

**Purpose:** Plan dashboard rollout

#### **Training Needs:**

**Clinical Staff:**
- How to interpret icons
- What actions to take (red ✗ = missing elements)
- How to use for bedside decisions

**Providers:**
- PowerForm screening importance
- Dashboard visibility of their assessments

**Abstractors:**
- How dashboard aligns with abstraction form
- Data availability for SEP-1 reporting

**Discussion:**
- Training format? (Video, in-person, quick reference card)
- Timeline?
- Communication plan?

**Decision:** Training approach? 📚 Timeline? 📅

---

### **12. Next Steps and Action Items (10 min)**

**Purpose:** Assign responsibilities and deadlines

#### **Action Items from Meeting:**

**For IT (Troy):**
- [ ] Implement agreed-upon enhancements
- [ ] Timeline: [TBD]

**For Clinical Team (Casey, Dr. Crawford):**
- [ ] Provide feedback on current dashboard
- [ ] Test in clinical workflow

**For Abstraction (Tammy):**
- [ ] Validate abstraction form alignment
- [ ] Provide official references

**For Leadership (Dr. Uy):**
- [ ] Approve resource allocation
- [ ] Support policy alignment

**Decision:** Who does what by when? 📅

---

## Meeting Goals

### **Must Achieve:**
1. ✅ Align on abstraction requirements (two time zeros)
2. ✅ Prioritize open issues
3. ✅ Approve Phase 1 deployment
4. ✅ Set timeline for Phase 2

### **Nice to Have:**
1. Resolve screen-driven logic questions
2. Agree on success metrics
3. Plan training rollout

---

## Materials Prepared

**Documents:**
1. Novant Health article (PDF)
2. Executive summary for Dr. Uy
3. Presentation deck (16 slides)
4. Stakeholder comparison (Current vs. Tammy vs. CMS)
5. SEP-1 requirements reference
6. GitHub issues (#15-25)

**Demo:**
- Live CERT dashboard
- Show bundle completion icons
- Show fluids conditional logic
- Walk through each column

---

## Expected Outcomes

**Minimum:**
- Alignment on abstraction requirements
- Priority ranking of issues
- Approval to deploy Phase 1

**Ideal:**
- Complete roadmap agreement
- Resource allocation approved
- Training plan defined
- Success metrics established

---

**Prepared by:** Troy Shelton
**Date:** October 16, 2025
**Next Update:** After stakeholder meeting
