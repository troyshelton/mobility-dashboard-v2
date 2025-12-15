# POC Merge Strategy - Combining PowerForm and PowerPlan Quick Launch

**Date:** 2025-10-18
**Purpose:** Merge two POC features for combined stakeholder demonstration
**Issues:** #28 (PowerForm) + #29 (PowerPlan)

---

## 🎯 Goal

**Combine two POC features into single demo:**
1. PowerForm Quick Launch (Screen + Perfusion) - Issue #28
2. PowerPlan Quick Launch (PowerPlan column) - Issue #29

**Result:** Stakeholders see comprehensive quick launch workflow

---

## 📋 **Three POC Branches**

**Current State:**
- `main` - Production v1.34.0-sepsis (untouched)
- `feature/poc-powerform-quick-launch` - PowerForm POC (Issue #28) ✅ Complete
- `feature/poc-powerplan-quick-launch` - PowerPlan POC (Issue #29) ⏸️ To be created

**After Merge:**
- `feature/combined-quick-launch-demo` - BOTH features together

---

## 🔀 **Merge Strategy: Option A (Recommended)**

### **Create Combined Demo Branch**

**Step 1: Create new branch from main**
```bash
git checkout main
git checkout -b feature/combined-quick-launch-demo
```

**Step 2: Merge PowerForm POC**
```bash
git merge feature/poc-powerform-quick-launch
# Should merge cleanly (first merge)
```

**Step 3: Merge PowerPlan POC**
```bash
git merge feature/poc-powerplan-quick-launch
# May have conflicts in same files (main.js, Config.js, etc.)
```

**Step 4: Resolve Conflicts**
- main.js: Combine both renderers (Screen, Perfusion, PowerPlan)
- Config.js: Keep simulator setting
- styles.css: Merge any new CSS
- index.html: Ensure both scripts loaded

**Step 5: Test Combined**
- Test all three clickable columns
- Verify no conflicts
- CERT deployment
- Stakeholder demo ready

---

## 🔀 **Merge Strategy: Option B (Alternative)**

### **Add PowerPlan to PowerForm Branch**

**Step 1: Checkout PowerForm branch**
```bash
git checkout feature/poc-powerform-quick-launch
```

**Step 2: Merge PowerPlan**
```bash
git merge feature/poc-powerplan-quick-launch
```

**Step 3: Resolve and test**

**Pros:** Single branch with both features
**Cons:** Mixes two separate POCs (less clean)

---

## 📝 **Expected Merge Conflicts**

### **Files Likely to Conflict:**

**main.js:**
- PowerForm POC: Modified screenAssessmentRenderer, conditionalRenderer
- PowerPlan POC: Will modify powerplanRenderer
- **Resolution:** Keep all modifications (both POCs work together)

**Config.js:**
- Both may change simulator setting
- **Resolution:** Keep `enabled: false` for CERT demo

**index.html:**
- PowerForm POC: Added PowerFormLauncher.js
- PowerPlan POC: Will add PowerPlanLauncher.js
- **Resolution:** Load both scripts

**XMLCclRequestSimulator.js:**
- PowerForm POC: Added alert test data
- PowerPlan POC: May add PowerPlan test data
- **Resolution:** Merge test scenarios

---

## ✅ **Merge Resolution Checklist**

**When merging, ensure:**
- [ ] All three columns clickable (Screen, Perfusion, PowerPlan)
- [ ] PowerFormLauncher.js loaded
- [ ] PowerPlanLauncher.js loaded (new)
- [ ] CSS includes .clickable-action hover
- [ ] Mock data has all test scenarios
- [ ] No JavaScript errors
- [ ] CERT deployment successful
- [ ] All three PowerForm/PowerPlan launches work

---

## 🧪 **Testing Combined Demo**

**Test Matrix:**

| Column | Condition | Display | Click Result |
|--------|-----------|---------|--------------|
| **Screen** | Alert + no screening | Empty circle | Opens Sepsis Screening PowerForm |
| **PowerPlan** | Not ordered | Empty circle | Opens PowerPlan ordering dialog |
| **Perfusion** | Lactate ≥4 + not done | Empty circle | Opens Perfusion PowerForm |

**All three should work simultaneously!**

---

## 📊 **Branch Timeline**

**Week 1 (Complete):**
- ✅ Issue #28: PowerForm Quick Launch
- ✅ Branch: `feature/poc-powerform-quick-launch`
- ✅ CERT tested and working

**Week 2 (Tomorrow):**
- ⏸️ Issue #29: PowerPlan Quick Launch
- ⏸️ Branch: `feature/poc-powerplan-quick-launch`
- ⏸️ CERT testing

**Week 2 (After PowerPlan Complete):**
- 🔄 Create: `feature/combined-quick-launch-demo`
- 🔄 Merge both POCs
- 🔄 CERT test combined
- 🎬 Stakeholder demo ready

---

## 🎬 **Stakeholder Demo Flow (Combined)**

**Demo Script:**

1. **Show current state** (main branch - no clicks)
2. **Switch to combined demo branch**
3. **Demo PowerPlan Quick Launch:**
   - "See this patient with no PowerPlan? Click the empty circle..."
   - PowerPlan ordering dialog opens
4. **Demo PowerForm Quick Launch (Screening):**
   - "This patient has an alert but no screening. Click..."
   - Sepsis Screening PowerForm opens
5. **Demo PowerForm Quick Launch (Perfusion):**
   - "This patient has critical lactate. Click..."
   - Perfusion Assessment PowerForm opens

**All three working in one dashboard!** 🎯

---

## 📁 **Branch Structure (Final)**

```
main (production)
├── feature/poc-powerform-quick-launch (Issue #28) ✅
├── feature/poc-powerplan-quick-launch (Issue #29) ⏸️
├── feature/combined-quick-launch-demo (both merged) 🔄
└── feature/ollama-poc-ai-agent (Issue #27) ✅
```

**All preserved separately, main untouched!**

---

## ✅ **Pre-Work Complete for Tomorrow**

**Ready for you:**
- ✅ GitHub Issue #29 created
- ✅ Merge strategy documented
- ✅ Branch plan clear
- ✅ Testing checklist ready

**When you say "start PowerPlan POC tomorrow":**
1. I'll create branch from main
2. Create TaskMaster tasks
3. Follow same workflow as PowerForm (worked perfectly!)
4. After complete, merge both for demo

---

**Created:** 2025-10-18
**Status:** Ready for tomorrow
**Branches:** PowerForm complete, PowerPlan ready to start, merge planned
