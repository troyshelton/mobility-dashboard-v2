# PowerPlan API Documentation - MOEW (Modal Order Entry Window)

**Source:** Cerner Documentation
**Date:** 2025-10-18
**Purpose:** Issue #29 - PowerPlan Quick Launch POC

---

## 📚 **PowerOrders MOEW API**

### **Overview**
MOEW = Modal Order Entry Window
Allows programmatic creation and management of PowerPlans from MPages.

### **Key Object**
```javascript
var PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS")
```

---

## 🔧 **API Methods**

### **1. CreateMOEW - Create Modal Order Entry Window**
```javascript
m_hMOEW = PowerOrdersMPageUtils.CreateMOEW(personId, encounterId, 24, 2, 127)
```

**Parameters:**
- `personId` - Patient person_id
- `encounterId` - Patient encntr_id
- `24`, `2`, `127` - Window configuration (TBD meanings)

**Returns:** Handle to modal window

---

### **2. AddPowerPlanMOEW - Add PowerPlan to Order Window**
```javascript
PowerOrdersMPageUtils.AddPowerPlanMOEW(hMOEW, pathwayCatalogId, personalizedPlanId)
```

**Parameters:**
- `hMOEW` - Handle from CreateMOEW
- `pathwayCatalogId` - PowerPlan catalog ID (from pathway_catalog table)
- `personalizedPlanId` - Customized/favorite plan ID (0 for standard catalog plan)

**Returns:** BOOL (true if successful)

**Example:**
```javascript
// Standard catalog plan
PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, 3037437837.0, 0.0)

// Plan favorite (customized)
PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, 3037437837.0, 3037723701.0)
```

---

### **3. CustomizeTabMOEW - Customize Order Window Tabs**
```javascript
PowerOrdersMPageUtils.CustomizeTabMOEW(hMOEW, 2, 127)
PowerOrdersMPageUtils.CustomizeTabMOEW(hMOEW, 3, 127)
```

**Purpose:** Configure which tabs are visible in order window
**Parameters:** TBD (window handle, tab number, settings)

---

### **4. SignOrders - Sign and Submit Orders**
```javascript
var retVal = PowerOrdersMPageUtils.SignOrders(hMOEW)
```

**Purpose:** Sign and submit all orders in the window
**Returns:** Result value (success/failure)

---

### **5. DestroyMOEW - Close Modal Window**
```javascript
PowerOrdersMPageUtils.DestroyMOEW(hMOEW)
```

**Purpose:** Clean up and close the modal order entry window

---

## 🎯 **Complete Workflow Example**

```javascript
// 1. Initialize
var m_hMOEW = 0
var PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS")
var m_dPersonId = 3616324.00
var m_dEncounterId = 8364339.00

// 2. Create modal window
m_hMOEW = PowerOrdersMPageUtils.CreateMOEW(m_dPersonId, m_dEncounterId, 24, 2, 127)

// 3. Customize tabs
PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 2, 127)
PowerOrdersMPageUtils.CustomizeTabMOEW(m_hMOEW, 3, 127)

// 4. Add PowerPlan(s)
PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, 3037437837.0, 0.0) // Standard
PowerOrdersMPageUtils.AddPowerPlanMOEW(m_hMOEW, 3037437837.0, 3037723701.0) // Favorite

// 5. Sign orders
var retVal = PowerOrdersMPageUtils.SignOrders(m_hMOEW)

// 6. Clean up
PowerOrdersMPageUtils.DestroyMOEW(m_hMOEW)
```

---

## 💡 **Implementation for POC**

### **Simplified Launch (No Auto-Sign)**

For POC, we likely want to **open the PowerPlan for provider review** (not auto-sign):

```javascript
function launchPowerPlanOrdering(personId, encounterId, powerPlanCatalogId) {
    try {
        // Get PowerOrders utility
        var PowerOrdersMPageUtils = window.external.DiscernObjectFactory("POWERORDERS");

        // Create modal order entry window
        var hMOEW = PowerOrdersMPageUtils.CreateMOEW(personId, encounterId, 24, 2, 127);

        if (hMOEW) {
            // Add PowerPlan to window
            var success = PowerOrdersMPageUtils.AddPowerPlanMOEW(hMOEW, powerPlanCatalogId, 0.0);

            if (success) {
                console.log('PowerPlan added to order window - provider can review and sign');
                // Window stays open for provider to review/modify/sign
                // Do NOT call SignOrders or DestroyMOEW - let provider control
            } else {
                console.error('Failed to add PowerPlan to order window');
                PowerOrdersMPageUtils.DestroyMOEW(hMOEW); // Clean up on failure
            }
        } else {
            console.error('Failed to create modal order entry window');
        }
    } catch (error) {
        console.error('PowerPlan launch error:', error);
    }
}
```

**Key Decision:** Let provider sign manually (safer for POC)

---

## 🔍 **Information Needed**

### **From Stakeholder:**
1. **PowerPlan Catalog ID** - Which ED Sepsis PowerPlan?
   - ED Severe Sepsis - ADULT
   - ED Severe Sepsis - ADULT EKM
   - ED Severe Sepsis Resuscitation/Antibiotics - ADULT
   - ED Severe Sepsis Resuscitation/Antibiotics - ADULT EKM

2. **Query to get ID:**
```sql
SELECT pathway_catalog_id, description
FROM pathway_catalog
WHERE description LIKE '%Severe Sepsis%'
AND active_ind = 1
```

3. **CreateMOEW parameters:** What do 24, 2, 127 mean?
   - Window type?
   - Display options?
   - Security settings?

---

## 🎨 **Combined Demo Features**

**After merge, dashboard will have:**

**Screen Column:**
- Alert + no screening → Click → Sepsis Screening PowerForm

**PowerPlan Column:**
- No PowerPlan ordered → Click → PowerPlan ordering dialog

**Perfusion Column:**
- Lactate ≥4 + not done → Click → Perfusion Assessment PowerForm

**All three working together!** 🚀

---

## 📋 **Tomorrow's Workflow**

**Step 1: Create PowerPlan POC Branch**
```bash
git checkout main
git checkout -b feature/poc-powerplan-quick-launch
```

**Step 2: Implement (similar to PowerForm)**
- Task #1: PowerPlan column clickable logic
- Task #2: PowerPlanLauncher.js with MOEW API
- Task #3: CERT testing
- Task #4: Documentation

**Step 3: Merge for Demo**
```bash
git checkout -b feature/combined-quick-launch-demo
git merge feature/poc-powerform-quick-launch
git merge feature/poc-powerplan-quick-launch
# Test combined, deploy to CERT
```

**Step 4: Stakeholder Demo**
- Show all three quick launch features
- Get approval
- Decision on production deployment

---

**Strategy documented and ready for tomorrow!** ✅

**Last Updated:** 2025-10-18
**Status:** PowerForm POC complete, PowerPlan POC queued, merge strategy planned

---

## ⚠️ **IMPORTANT: Conditional Logic for PowerPlan Column**

**Added:** 2025-10-18 (late evening clarification)

### **PowerPlan Column Should Only Be Clickable When:**

```
IF Alert exists (Severe Sepsis alert fired):
  IF PowerPlan NOT ordered (currently shows N):
    Show CLICKABLE empty circle
    - Click launches PowerPlan ordering dialog
  ELSE IF PowerPlan ordered/initiated:
    Show current behavior (Y or Pend - not clickable)
ELSE (No severe sepsis alert):
  Show empty circle (NOT clickable - PowerPlan not indicated)
  OR show "--" (PowerPlan not needed)
```

### **Key Point:**
**PowerPlan ordering should only be offered when there's a severe sepsis alert!**

This is the SAME conditional pattern as Screen column:
- Screen: Alert + no screening → Clickable (launch screening PowerForm)
- PowerPlan: Alert + no PowerPlan → Clickable (launch PowerPlan ordering)

### **Implementation for Tomorrow:**

**Check alert status:**
```javascript
const alertData = sourceData?.ALERT_TYPE || sourceData?.ALERT_DETAILS?.hasAlert;
const hasAlert = alertData && alertData !== '--' && alertData !== '' && alertData !== false;
const powerPlanNotOrdered = value === 'N';

if (hasAlert && powerPlanNotOrdered) {
    // Show CLICKABLE empty circle
    // Launch PowerPlan ordering on click
} else if (!hasAlert && powerPlanNotOrdered) {
    // Show empty circle but NOT clickable (no alert = not indicated)
} else {
    // Show Y or Pend (PowerPlan already ordered)
}
```

**This ensures PowerPlan ordering only offered when clinically appropriate!**

---

**Updated:** 2025-10-18 23:00
**Conditional Logic:** Alert-based (same as Screen column)
