# Executive Summary: CAMC Sepsis Dashboard Alignment with Novant Health Model

**To:** Dr. Anthony R. Uy, Chief Quality Officer
**From:** Troy Shelton, IT Development
**Date:** October 16, 2025
**Re:** Novant Health Article - Dashboard Validation

---

## Thank You

Thank you for sharing the Novant Health article. It provides **exceptional validation** that our sepsis dashboard approach aligns with proven strategies for dramatically improving patient outcomes.

---

## Key Finding: Perfect Alignment

### **Novant's Critical Success Factor:**

**Quote from Dr. Daniel Feinstein (Novant System Physician Executive):**
> "Another big piece was creating a **live data dashboard**. This lets us monitor whether patients are getting the sepsis bundle elements (blood cultures, lactate levels, antibiotics, fluids) within the three- and six-hour windows. **That level of accountability improved compliance and outcomes.**"

### **CAMC Dashboard:**

**Implements this exact model:**
- ✅ Live monitoring of all bundle elements
- ✅ 3-hour and 6-hour window tracking
- ✅ Real-time visibility for accountability
- ✅ Visual compliance indicators

**Our dashboard provides the same "level of accountability" Novant credits for their success.**

---

## Novant's Results (What's Possible)

### **Mortality Reduction:**
- **>50% reduction** in sepsis mortality since 2021
- **25-26 patients per month** who were predicted to die are now surviving
- Across **20+ hospitals** system-wide

### **Process Improvements:**
- **30% bundle compliance improvement** within 3 months (tele-ICU implementation)
- **25% reduction in ICU admissions** through early intervention
- Over **5,300 patients/year** touched by monitoring team

### **The Driver:**
Dashboard monitoring → Accountability → Compliance → Outcomes

---

## How CAMC Dashboard Matches Novant's Model

### **1. Live Bundle Monitoring (THE KEY)**

**Novant:** "monitor whether patients are getting bundle elements"
**CAMC:** ✅ Lactate, Cultures, Antibiotics, Fluids columns

### **2. Time Windows (3-hour and 6-hour)**

**Novant:** "within the three- and six-hour windows"
**CAMC:** ✅ 3-Hr Timer + conditional 6-hour bundle columns

### **3. Accountability Through Visibility**

**Novant:** "That level of accountability improved compliance"
**CAMC:** ✅ Real-time dashboard visible to all staff

### **4. Visual Compliance Feedback**

**Novant:** (Implied - dashboard shows compliance)
**CAMC:** ✅ **Enhanced** - Green ✓/Red ✗ icons when timer expires

---

## CAMC Dashboard Enhancements

**Beyond what Novant article mentions, we have:**

### **Recent Releases:**

**v1.33.1-sepsis:** Fluids conditional logic
- Shows "N/A" when fluids not required (lactate <4.0)
- Improves compliance accuracy

**v1.34.0-sepsis:** Bundle completion status icons
- Green ✓ when all 4 elements met
- Red ✗ when elements missing
- Instant visual feedback at deadline

### **Unique Features:**

1. **Countdown timer** - Creates urgency as deadline approaches
2. **Detailed tooltips** - Drill-down on each element
3. **Blood culture timeline** - Ordered→Collected→In-Lab→Completed progression
4. **Conditional display** - Smart N/A for non-applicable elements
5. **Visual urgency indicators** - Orange badges (<1 hour), pink badges (critical lactate)

**These enhancements build on Novant's proven model.**

---

## Clinical Impact Potential

### **If CAMC Achieves Novant-Level Results:**

**Novant Scale:**
- 20+ hospitals
- 25-26 lives/month saved
- 50% mortality reduction

**CAMC Opportunity:**
- Apply same model
- Measure baseline mortality
- Track improvement over time
- Document lives saved

### **Early Indicators of Success:**

**Novant:** 30% compliance improvement in 3 months (tele-ICU)
**CAMC:** Could track:
- Bundle completion rates
- Time to antibiotics
- Fluids administration compliance
- 3-hour bundle pass rates

**Timeline:** Begin measuring Q4 2025, review Q1 2026

---

## Technology Validation

### **Novant's Approach:**

**Technology Stack:**
1. Epic BPAs (alert system)
2. Epic Sepsis Screening Tool (predictive)
3. **Live dashboard** (accountability)
4. Tele-ICU (remote monitoring)

### **CAMC's Approach:**

**Current:**
1. Cerner alerts (similar to Epic BPAs)
2. PowerForm screening (sepsis documentation)
3. **Live dashboard** ✅ (same as Novant)
4. Real-time bundle tracking

**The core component (dashboard) is implemented!**

---

## Alignment with Novant's Philosophy

### **Early Detection:**

**Novant:** Uses Sepsis-2 (wider net, earlier identification)
**CAMC:** Dashboard supports early detection (Alert, Screen, Time Zero columns)

### **Fast Treatment:**

**Novant:** "It all starts with identification — and with the proper definition"
**CAMC:** Dashboard makes identification visible, tracks intervention speed

### **Standardized Protocols:**

**Novant:** Consistent processes across 20+ hospitals
**CAMC:** Dashboard provides consistent bundle tracking

### **Accountability:**

**Novant:** "Level of accountability improved compliance"
**CAMC:** Dashboard creates same accountability through visibility

**Philosophy alignment: ✅ MATCH**

---

## Stakeholder Feedback Integration

### **Recent Input Received:**

1. **Tammy Mitchell (Abstractor):** Feedback on Septic Shock time zero and IVF timeframes
   - Documented in Issue #20
   - Stakeholder meeting needed for alignment

2. **Casey Wolfe (Sepsis Coordinator):** Pending validation on:
   - Blood cultures "Collected" = complete (Issue #19)
   - Issue #16 Phase 2 priorities

3. **Dr. Anthony Uy (CQO):** Shared Novant article
   - Validates dashboard approach
   - Highlights potential impact

### **Alignment Process:**
Stakeholder meeting to ensure dashboard matches:
- ✅ Clinical workflow (Novant model)
- ✅ Abstraction requirements (Tammy's input)
- ✅ SEP-1 compliance (CMS standards)

---

## Recommendations

### **Immediate (This Week):**

1. ✅ **Complete Issue #17** (bundle completion icons)
   - Final feature matching Novant's live monitoring
   - CERT validated and working

2. 📋 **Share Novant article** with full stakeholder group
   - Validates current approach
   - Builds support for dashboard

3. 📋 **Schedule stakeholder meeting**
   - Align on abstraction requirements
   - Discuss ED vs. Inpatient scope
   - Review Tammy's feedback

### **Short Term (Q4 2025):**

1. 📋 **Deploy to ED** (primary users)
2. 📋 **Staff training** (how to use dashboard)
3. 📋 **Establish baseline metrics** (current compliance rates)
4. 📋 **Begin impact measurement**

### **Long Term (2026):**

1. 📋 **Analytics layer** (compliance tracking like Novant)
2. 📋 **Integration with alerts** (if Epic BPAs or Cerner equivalent)
3. 📋 **Inpatient dashboard** (if different requirements)
4. 📋 **Continuous improvement** based on outcomes

---

## Value Proposition

### **Investment:**
- Dashboard development (largely complete)
- Staff training (minimal)
- Process integration (ongoing)

### **Potential Return (Based on Novant Model):**
- Significant mortality reduction
- Improved SEP-1 compliance (affects reimbursement)
- Reduced ICU admissions (cost savings)
- Fewer complications (shorter stays)
- **Lives saved** (25-26/month at Novant's scale)

### **Novant's Endorsement:**
> "To take 20-plus hospitals and a bunch of clinicians and make changes as dramatic as we have is really remarkable. We've seen a greater than 50% reduction in mortality for sepsis patients."

**CAMC has the same opportunity.**

---

## Conclusion

### **Key Message:**

**Our sepsis dashboard implements the proven model that enabled Novant Health to cut mortality in half.**

**Novant's Success = Early Detection + Live Dashboard + Accountability**
**CAMC Dashboard = Same Model, Enhanced Features**

### **Critical Quote:**
> "Creating a live data dashboard... That level of accountability improved compliance and outcomes."

**We have built exactly what Novant credits for their success.**

### **Next Steps:**
1. Complete current work (Issue #17)
2. Stakeholder alignment (Tammy's feedback, scope discussion)
3. Deploy and measure
4. Track impact and iterate

### **Opportunity:**
**Achieve Novant-level outcomes:**
- 50% mortality reduction
- Improved bundle compliance
- Lives saved

**The foundation is in place. Let's execute.**

---

**Respectfully submitted,**
Troy Shelton
IT Development

**References:**
- Novant Health article (Becker's Hospital Review, October 16, 2025)
- GitHub Issue #22 (Novant model alignment)
- Presentation deck: `docs/reference/NOVANT-SUCCESS-MODEL-PRESENTATION.md`
- Comparison document: `docs/reference/clinical/STAKEHOLDER-COMPARISON-TAMMY-FEEDBACK.md`

---

**CC:** Dr. Adam Crawford, Casey Wolfe, Stakeholder Team
