# Mobility Dashboard - Stakeholder Demo Presentation Notes

**Version:** v2.7.0-mobility
**Demo Date:** Tuesday, January 7, 2026
**Presenter:** Troy Shelton
**Stakeholders:** Clinical Leadership, Nursing Staff, Therapy Team
**Duration:** 30 minutes

---

## Executive Summary

**Mobility Dashboard** is a comprehensive patient safety and mobility monitoring system for inpatient floors, providing real-time visibility into patient mobility status, fall prevention measures, and therapy assessments.

**Key Value:**
- ✅ Improves patient safety through real-time mobility monitoring
- ✅ Supports fall prevention with comprehensive intervention tracking
- ✅ Integrates PT/OT assessments for coordinated care
- ✅ Provides 30-day historical trending for all metrics

---

## Dashboard Overview

### Patient Demographics (8 Columns)
Standard patient identification and status information.

### Clinical Data (11 Metrics - 4 Logical Groups)

**1. Assessments** (What We Measure)
- **Baseline Mobility** - Admission functional assessment level (PowerForm)
- **BMAT** - Brief Mobility Assessment Tool (current mobility level 1-4)
- **Morse** - Fall Risk Score (risk stratification)

**2. Fall Prevention Interventions** (What We Do)
- **Call Light** - Personal items within reach
- **IV Sites** - IV site assessment
- **SCDs** - Sequential compression devices applied
- **Safety** - Psychosocial and safety needs addressed
- **Precautions** - Active activity precautions (count)
- **Toileting** - Toileting method/assistance

**3. Ambulation** (How Mobile They Are)
- **Amb Dist** - Ambulation distance in feet (numeric with trend)

**4. PT / OT** (What Therapy Says)
- **PT Transfer** - Physical Therapy bed-to-chair transfer assist level
- **OT Transfer** - Occupational Therapy bed-to-chair transfer assist level

---

## Key Features

### 1. Real-Time Data Integration

**Multiple Data Sources:**
- ✅ PowerForms (Baseline, PT/OT Evaluations)
- ✅ Clinical Events (BMAT, Morse, nursing documentation)
- ✅ I-View Documentation (Toileting)
- ✅ Order Management (Activity Precautions)

**All data refreshes with patient list selection.**

### 2. Historical Trending (30-Day Lookback)

**Click any clinical metric to see:**
- 30-day historical data
- Side panel with detailed history
- Sparklines for numeric data (Morse, Ambulation)
- Trend identification (improving vs declining)

**Example:** Click BMAT to see mobility level progression over time.

### 3. Side Panel Detail View

**Pattern: Clinical Leader Organizer (Cerner Standard)**
- Click any metric → Side panel opens
- Shows full 30-day history
- Includes timestamps
- Automatic sparklines for numeric data
- Close with X, backdrop click, or ESC key

### 4. Professional Organization

**Logical Grouping:**
- Assessments together (baseline, current, risk)
- Interventions together (fall prevention actions)
- Ambulation separate (distinct mobility category)
- Therapy together (PT/OT professional assessments)

**Benefits:** Easier scanning, matches clinical workflow

---

## Demo Walkthrough

### Opening (2 minutes)

**Context:**
"Good morning! Today I'll demonstrate the Mobility Dashboard - a comprehensive patient safety and mobility monitoring system we've developed for our inpatient units."

**Value Proposition:**
"This dashboard provides real-time visibility into patient mobility status, fall prevention measures, and therapy assessments, all in one integrated view with 30-day historical trending."

### Patient List Selection (2 minutes)

**Demonstrate:**
1. Open dashboard: https://ihazurestoragedev.z13.web.core.windows.net/camc-mobility-mpage/src/index.html
2. Select patient list dropdown
3. Choose test patient list
4. Show table populating with patient data

**Highlight:**
"Notice the professional group headers organizing our clinical data logically."

### Assessments Group (5 minutes)

**1. Baseline Mobility**
- "Shows admission functional assessment level from PT/OT intake"
- Click to show: "(Level 4) No limitation with walking"
- "This is our reference point - where did they start?"

**2. BMAT (Brief Mobility Assessment)**
- "Current mobility assessment - updated throughout stay"
- Click to show: 6 entries showing progression (Level 1 → 4)
- **Highlight sparkline:** "Notice the visual trend - patient improving!"
- "Levels: 1 (bedbound) → 4 (walking)"

**3. Morse Fall Risk Score**
- "Fall risk stratification"
- Click to show: Historical scores
- **Highlight sparkline:** "Visual risk trending"
- "Helps us adjust fall prevention interventions"

### Fall Prevention Interventions (7 minutes)

**Context:**
"Based on fall risk, here's what nursing is doing to keep patients safe:"

**1. Call Light & Personal Items**
- "Within reach? Critical for preventing falls when trying to get up"
- Click to show: Yes/No history over 30 days

**2. IV Sites Assessed**
- "IV management - prevents trips/tangles"

**3. SCDs Applied**
- "Sequential compression devices"

**4. Safety Needs Addressed**
- "Psychosocial and safety check"

**5. Activity Precautions** ⭐
- "This one is special - shows COUNT of active precautions"
- Click to show: 8 active precautions with details
- **Detailed view:** Weight bearing, hip precautions, spine restrictions
- "Each shows order details, date/time, status"
- **Clinical value:** "Quick count alerts staff to extra safety needs"

**6. Toileting**
- "How patient uses restroom - bedside commode, bed pan, etc."
- Click to show: Multiple entries throughout day
- "Tracks progression toward independence"

### Ambulation (3 minutes)

**Ambulation Distance**
- "How far they're walking - measured in feet"
- Click to show: 100 ft → 75 ft → 50 ft
- **Highlight sparkline:** "Visual trend of ambulation capacity"
- **Clinical Insight:** "This patient may be declining - clinical team can intervene"

### PT / OT Assessments (8 minutes) ⭐

**Technical Achievement Alert:**
"These next two columns represent a significant technical breakthrough - we solved a complex PowerForm discrete grid query pattern."

**1. PT Transfer**
- "Physical Therapy assessment of bed-to-chair transfer ability"
- Shows: "Mod A" (Moderate Assist)
- Click to show: Historical PT assessments
- **Assist Levels:** Complete I, Mod I, Supervision, Min A, Mod A, Max A, Total A
- "Tracks patient progress toward independence"

**2. OT Transfer**
- "Occupational Therapy assessment - same transfer, different lens"
- Shows: "Max A" (Maximal Assist)
- Click to show: Historical OT assessments
- **Note difference:** "PT says Mod A, OT says Max A - both documented same day"
- **Clinical Value:** "Shows interdisciplinary perspective"

**Why Both?**
"PT focuses on strength/endurance, OT focuses on functional ADLs. Having both gives complete picture of patient's transfer ability."

### Technical Capabilities (3 minutes)

**For Technical Stakeholders:**

**Data Integration:**
- 4 different data sources (PowerForms, Clinical Events, I-View, Orders)
- PowerForm discrete grid navigation (4-level hierarchy)
- 30-day lookback with dynamic date filtering

**Performance:**
- Efficient queries (inner joins, no unnecessary outer joins)
- Proven Cerner patterns (Clinical Leader Organizer)
- Optimized for dashboard refresh performance

**Extensibility:**
- Modular architecture
- Easy to add new metrics
- Pattern documented for future enhancements

---

## Clinical Benefits

### 1. Comprehensive Patient View
"Everything mobility-related in one place - no clicking through multiple screens"

### 2. Early Intervention
"Declining trends visible immediately - ambulation dropping, fall risk increasing"

### 3. Interdisciplinary Coordination
"PT, OT, and nursing all see same data - coordinated care planning"

### 4. Fall Prevention Focus
"All fall prevention interventions grouped - easy to verify compliance"

### 5. Historical Context
"30-day trends show true progress, not just point-in-time snapshot"

---

## Use Case Examples

### Case 1: Fall Risk Management
**Scenario:** Patient with high Morse score

**Dashboard Shows:**
- Morse Score: 60 (High Risk)
- Fall Prevention: Call light ✓, IV sites ✓, SCDs ✓, Safety ✓
- Precautions: 3 active (hip precautions, weight bearing restrictions)
- BMAT: Level 2 (limited mobility)

**Action:** Care team has complete fall risk picture at a glance

### Case 2: Mobility Progression Tracking
**Scenario:** Post-surgical patient recovering

**Dashboard Shows:**
- Baseline: Level 2 (admission)
- BMAT History: Level 1 → 2 → 3 (improving! sparkline shows upward trend)
- Ambulation: 25 ft → 50 ft → 75 ft (progressing! sparkline shows improvement)
- PT Transfer: Max A → Mod A (improving!)

**Action:** Team celebrates progress, adjusts therapy goals

### Case 3: Decline Detection
**Scenario:** Patient condition changing

**Dashboard Shows:**
- BMAT: Was Level 4, now Level 2 (declining)
- Ambulation: Was 100 ft, now 50 ft (sparkline shows downward trend)
- Morse: Score increased from 35 to 60 (higher risk)

**Action:** Early warning triggers care team huddle, intervention

---

## Future Enhancements (If Asked)

### Planned for v2.8.0+

**1. PT/OT Comments**
- Add comment text from discrete grid entries
- Show clinical notes with assessments

**2. Additional Therapy Metrics**
- More PT/OT assessment fields
- Therapy goals tracking

**3. TLSO/LSO Braces**
- Complete activity precautions coverage
- 2 remaining precaution types

### Under Consideration

**1. Alerts/Notifications**
- Declining trend alerts
- Missing documentation reminders

**2. Reporting**
- Unit-level metrics
- Compliance reporting

**3. Integration**
- Epic integration (if applicable)
- Mobile access

---

## Q&A Preparation

### Expected Questions

**Q: "Can we add more metrics?"**
A: "Yes! We've established proven patterns. Adding new metrics takes 1-2 days depending on complexity."

**Q: "How often does data refresh?"**
A: "Data refreshes when you select a patient list. We can add auto-refresh if needed."

**Q: "Can we filter or sort?"**
A: "Yes - click column headers to sort. Handsontable has built-in filtering in dropdown menus."

**Q: "What if patient doesn't have PT/OT assessment?"**
A: "Column shows empty - we only display data that exists. No fake data."

**Q: "Can we export to Excel?"**
A: "Not currently, but Handsontable supports CSV export - we can add that feature."

**Q: "How do we know data is accurate?"**
A: "All data comes directly from Cerner - PowerForms, clinical events, orders. No manual entry in dashboard."

**Q: "What about PHI security?"**
A: "Dashboard runs within Cerner MPages environment - same security as PowerChart. No data stored externally."

**Q: "Can other units use this?"**
A: "Absolutely! This is a template. We can customize for any unit (Med-Surg, Telemetry, ICU, etc.)"

---

## Stakeholder-Specific Talking Points

### For Nursing Leadership

**Focus:**
- Fall prevention compliance visibility
- Intervention documentation tracking
- Early warning for declining patients
- Staff efficiency (one screen vs many)

**Key Metric:** Activity Precautions count
"Immediate visual of patients with special safety needs"

### For Therapy Leadership (Courtney Friend, MOT, OTR/L)

**Focus:**
- PT/OT assessment integration
- Transfer ability tracking
- Ambulation distance trending
- Baseline functional assessment visibility

**Key Metrics:** PT Transfer, OT Transfer, Baseline, Ambulation
"Your team's assessments now visible to entire care team"

### For IT/Technical Stakeholders

**Focus:**
- PowerForm discrete grid integration (technical achievement)
- Cerner-native (no external systems)
- Performance optimized
- Proven patterns from production systems
- Extensible architecture

**Technical Win:** "Solved complex 4-level PowerForm hierarchy navigation"

### For Clinical Quality/Safety

**Focus:**
- Fall prevention compliance
- Documentation completeness
- Trend identification for quality metrics
- Patient safety outcomes

**Quality Metrics:** All fall prevention interventions visible and tracked

---

## Demo Script (30 Minutes)

**0:00-0:02** - Welcome & Context
**0:02-0:05** - Dashboard Overview (patient list, group headers)
**0:05-0:10** - Assessments Deep Dive (Baseline, BMAT sparkline, Morse)
**0:10-0:17** - Fall Prevention (all 6 interventions, highlight Precautions detail)
**0:17-0:20** - Ambulation (sparkline, trending)
**0:20-0:28** - PT/OT (technical achievement, clinical value, interdisciplinary coordination)
**0:28-0:30** - Q&A

---

## Key Messages

### Primary Message
"The Mobility Dashboard provides comprehensive, real-time patient mobility and safety monitoring with 30-day historical trending, enabling proactive clinical intervention and coordinated interdisciplinary care."

### Supporting Messages

**1. Patient Safety Focus**
"Every metric supports fall prevention and safe mobility"

**2. Clinical Workflow Alignment**
"Organized the way clinicians think: Assess → Intervene → Monitor → Coordinate"

**3. Proven Technology**
"Built on Cerner-native platform using proven Clinical Leader Organizer pattern"

**4. Interdisciplinary Coordination**
"PT, OT, and nursing see same data - coordinated care planning"

**5. Evidence-Based**
"30-day trends show true progress, enabling data-driven decisions"

---

## Success Metrics to Highlight

### From Development

**Timeline:**
- Started: December 14, 2025
- Current: v2.7.0 (January 3, 2026)
- Releases: 7 versions in 3 weeks

**Features Delivered:**
- 11 clinical event metrics
- 4 data source integrations
- PowerForm discrete grid navigation
- Professional group headers

**Quality:**
- All features CERT validated with real patient data
- Full healthcare production workflow compliance
- Complete audit trail and documentation

### Expected Clinical Outcomes (Post-Implementation)

**Efficiency:**
- Reduced time scanning multiple screens
- Faster identification of high-risk patients
- Quicker response to declining trends

**Safety:**
- Improved fall prevention compliance visibility
- Earlier intervention for declining patients
- Better coordination between disciplines

**Quality:**
- Complete documentation visibility
- Trend-based decision making
- Interdisciplinary care coordination

---

## Handling Objections

### "We already have PowerChart"
**Response:** "Yes, and this pulls data FROM PowerChart. But instead of clicking through forms and multiple patients, you see everything at once for your entire unit."

### "This looks complicated"
**Response:** "Actually, it's simpler! Everything clinicians need is in one view. Click any metric for 30-day history. No navigation through multiple screens."

### "What if clinicians don't use it?"
**Response:** "We've organized it to match clinical workflow - Assess, Intervene, Monitor, Coordinate. It's intuitive. Plus, we can provide training and gather feedback for improvements."

### "How much does this cost to maintain?"
**Response:** "Minimal. It's built on existing Cerner platform. Once deployed, it's self-maintaining. Updates are quick because we've documented all patterns."

### "Can we customize for our unit?"
**Response:** "Absolutely! This is a template. We can add unit-specific metrics, adjust columns, add new features. That's the power of modular architecture."

---

## Closing

### Call to Action

**For Approval:**
"We're ready to deploy to production. Today I need:
1. Approval to deploy to production units
2. Identification of pilot unit (which unit goes first?)
3. Training plan and timeline
4. Feedback mechanism for continuous improvement"

**For Feedback:**
"We're also gathering input for v3.0. What additional metrics would enhance clinical decision-making for your teams?"

### Next Steps

**This Week:**
1. Incorporate stakeholder feedback
2. Finalize production deployment plan
3. Create training materials

**Next Week:**
1. Pilot unit deployment
2. Staff training sessions
3. Collect initial feedback

**Ongoing:**
- Monitor usage and outcomes
- Iterate based on clinical feedback
- Add requested features

---

## Demo Tips

### Do's
✅ **Click through features live** - show real CERT data
✅ **Highlight sparklines** - visual trends are powerful
✅ **Show side panels** - the 30-day history is the key differentiator
✅ **Emphasize PT/OT integration** - this is unique and valuable
✅ **Use clinical scenarios** - "Here's a declining patient..."
✅ **Invite questions throughout** - engagement is good

### Don'ts
❌ **Don't dive too deep into technical details** (unless IT stakeholders present)
❌ **Don't apologize for "missing" features** - focus on what's there
❌ **Don't promise features without checking effort** - "Let me evaluate and get back to you"
❌ **Don't skip the "why"** - always tie features to clinical value

---

## Backup Slides/Info (If Needed)

### Technical Architecture
- Cerner MPages framework
- CCL backend (6 SELECT statements)
- JavaScript frontend (Handsontable)
- Azure static web hosting (CERT)
- No external systems or PHI exposure

### Development Methodology
- Agile/iterative releases
- Clinical feedback-driven
- Healthcare production workflows (validation gates, deployment verification)
- Full audit trail (Git, issues, PRs, tags)

### Team
- Developer: Troy Shelton
- Clinical SME: Courtney Friend, MOT, OTR/L (Acute Care Therapy Lead)
- Stakeholders: Nursing leadership, therapy team, clinical quality

---

## Post-Demo Actions

### Immediately After
- [ ] Capture all stakeholder feedback
- [ ] Note requested features
- [ ] Document concerns or objections
- [ ] Get commitment on next steps

### Follow-Up (Within 24 hours)
- [ ] Send thank-you email with summary
- [ ] Share demo recording if available
- [ ] Provide timeline for requested changes
- [ ] Schedule follow-up meeting if needed

### Within Week
- [ ] Create issues for requested features
- [ ] Update roadmap based on feedback
- [ ] Begin production deployment planning
- [ ] Develop training materials

---

## Contact Info for Follow-Up

**Dashboard Questions:**
Troy Shelton
Email: [your email]
Extension: [your extension]

**Clinical Workflow Questions:**
Courtney Friend, MOT, OTR/L
Acute Care Therapy Lead

**Project Updates:**
GitHub: https://github.com/troyshelton/mobility-dashboard-v2
CERT Demo: https://ihazurestoragedev.z13.web.core.windows.net/camc-mobility-mpage/src/index.html

---

## Appendix: Version History

**v2.7.0-mobility** - Column Reorganization (Demo Ready)
**v2.6.0-mobility** - Ambulation Distance
**v2.5.0-mobility** - PT/OT Transfer Assessments
**v2.4.0-mobility** - Toileting Method
**v2.3.0-mobility** - Baseline Mobility
**v2.2.0-mobility** - Activity Precautions
**v2.1.0-mobility** - BMAT
**v2.0.0-mobility** - Side Panel Historical View

**Total Development Time:** 3 weeks
**Releases:** 8 versions
**Issues Closed:** 9
**Features Delivered:** 11 clinical events + side panels + group headers

---

*Last Updated: 2026-01-03*
*Status: READY FOR STAKEHOLDER DEMONSTRATION*
*Confidence Level: HIGH - All features CERT validated*
