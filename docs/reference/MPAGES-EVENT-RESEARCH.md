# MPAGES_EVENT Research - PowerForm Launch

**Task:** 5.1 - Research MPAGES_EVENT syntax
**Date:** 2025-10-18
**Issue:** #28 PowerForm Quick Launch POC

---

## 🔍 Research Findings

### **MPAGES_EVENT Meta Tag**
Found in MPages HTML files:
```html
<meta name="discern"
      content="APPLINK,CCLLINK,MPAGES_EVENT,MPAGES_SVC_EVENT,XMLCCLREQUEST,CCLNEWSESSIONWINDOW"
      http-equiv="Content-Type">
```

This meta tag enables MPage-specific functionality in PowerChart environment.

### **Available MPages APIs**
- **APPLINK** - Launch URLs or PowerChart components
- **CCLLINK** - Execute CCL programs
- **MPAGES_EVENT** - Trigger MPage events (including PowerForm launch)
- **MPAGES_SVC_EVENT** - Service events
- **XMLCCLREQUEST** - AJAX CCL calls
- **CCLNEWSESSIONWINDOW** - New session windows

---

## 📚 Documentation Sources Searched

**Public Resources:**
- ❌ No specific MPAGES_EVENT examples found
- ❌ No PowerForm launch code samples available
- ⚠️ Limited public documentation for Cerner MPages APIs

**Known Resources (Access Required):**
- ✅ uCern wiki (wiki.ucern.com) - Cerner community documentation
- ✅ Cerner Code Console (code-console.cerner.com)
- ✅ Internal Cerner developer guides
- ✅ Client-specific implementation examples

---

## 💡 Theoretical Implementation (Based on Research)

### **Hypothesis: MPAGES_EVENT PowerForm Launch Pattern**

Based on APPLINK pattern and MPages architecture, the syntax might be:

```javascript
// Hypothetical pattern (UNVERIFIED)
function launchPowerForm(powerFormName, personId, encntrId) {
    // Option 1: Via window.external (like XMLCC LRequest)
    if (window.external && window.external.MPAGES_EVENT) {
        window.external.MPAGES_EVENT(
            'POWERFORM',
            powerFormName,
            `/PERSONID=${personId} /ENCNTRID=${encntrId}`
        );
    }

    // Option 2: Via global function (like APPLINK)
    else if (typeof MPAGES_EVENT === 'function') {
        MPAGES_EVENT('POWERFORM', powerFormName, personId, encntrId);
    }

    // Option 3: Via custom event trigger
    else {
        const event = new CustomEvent('MPAGES_EVENT', {
            detail: {
                type: 'POWERFORM',
                name: powerFormName,
                personId: personId,
                encntrId: encntrId
            }
        });
        document.dispatchEvent(event);
    }
}
```

**⚠️ WARNING:** This is theoretical and UNVERIFIED. Actual implementation may differ.

---

## 🎯 Alternative Approaches

### **Option A: APPLINK for PowerForms**
```javascript
// Similar to patient chart navigation
const powerFormLink = `javascript:;APPLINK(0, 'POWERFORM', '/FORMNAME=${powerFormName} /PERSONID=${personId} /ENCNTRID=${encntrId}')`;
```

### **Option B: CCL Program Launch**
```javascript
// Call CCL program that launches PowerForm
XMLCclRequest('1_launch_powerform', [powerFormName, personId, encntrId]);
```

### **Option C: URL-Based Launch**
```javascript
// If PowerForms have URL access
window.open(`cerner://powerform?name=${powerFormName}&person=${personId}&encounter=${encntrId}`);
```

---

## 📋 **POC Decision: Document for Stakeholder**

Since specific MPAGES_EVENT PowerForm syntax is not publicly documented, we have two options for the POC:

### **Option 1: Placeholder Implementation**
- Keep console.log click handlers
- Document that PowerForm launch requires Cerner-specific API knowledge
- Get actual syntax from Cerner support or internal documentation

### **Option 2: Test in Cerner Environment**
- Deploy POC to CERT
- Try hypothetical patterns
- Document what works

---

## ✅ **Recommendation for POC**

**For this POC, we should:**
1. ✅ Keep clickable circles working (already done)
2. ✅ Document that PowerForm launch requires stakeholder to provide:
   - Exact PowerForm names
   - Cerner API documentation for MPAGES_EVENT
   - Or test in CERT environment to determine correct syntax
3. ✅ Create placeholder launchPowerForm function with documentation

**This demonstrates:**
- ✅ UI works (clickable circles with conditional logic)
- ✅ Patient context captured (person_id, encntr_id)
- ✅ Ready to integrate once MPAGES_EVENT syntax confirmed

---

## 📞 **Next Steps for Production**

**To complete PowerForm integration:**
1. Contact Cerner support for MPAGES_EVENT documentation
2. Access uCern wiki for API examples
3. Get PowerForm names from clinical team
4. Test in Cerner CERT environment
5. Document working syntax for future use

---

**Research Status:** Complete (no public documentation found)
**POC Approach:** Placeholder with documentation
**Production Path:** Requires Cerner-specific resources

**Created:** 2025-10-18
**Task:** 5.1 - Research MPAGES_EVENT
**Result:** Limited public documentation, requires internal Cerner resources
