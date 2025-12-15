# Sepsis Dashboard - Developer Cheat Sheet

**Version:** 1.44.0-sepsis | **Quick Reference for In-Service Training**

---

## 🏗️ Architecture in 30 Seconds

**Pattern:** Service-based vanilla JavaScript (no framework)
**Why:** PowerChart compatibility + healthcare reliability
**Deployment:** Dual (Azure CERT + Citrix I: drive)

---

## 📁 File Structure - What's Where?

| File | Size | Purpose | When to Modify |
|------|------|---------|----------------|
| **Config.js** | 3KB | Settings (simulator, refresh) | Toggle dev/prod mode |
| **UserInfoService.js** | 6KB | Get logged-in user | Rarely |
| **PatientListService.js** | 14KB | Get patient lists | Rarely |
| **PatientDataService.js** | 122KB | Process CCL data | Adding/changing columns |
| **main.js** | 130KB | Column renderers + UI | Modifying columns |
| **SendCclRequest.js** | 12KB | Production CCL calls | Rarely |
| **XMLCclRequestSimulator.js** | 30KB | Mock data for dev | Adding test scenarios |
| **PowerFormLauncher.js** | 4KB | Launch PowerForms | Adding PowerForm integrations |
| **PowerPlanLauncher.js** | 14KB | Launch PowerPlans | Adding PowerPlan integrations |

---

## 🔄 Data Flow (User Click → Display)

```
1. User selects list → 2. Check Config (simulator?) → 3. Call CCL or Mock
   ↓                                                           ↓
8. User sees data ← 7. Render columns ← 6. Add to grid ← 5. Format ← 4. Parse JSON
```

---

## 🎯 Common Tasks (Copy & Paste Ready)

### Toggle Simulator Mode
```javascript
// Config.js line 16
enabled: true   // Dev mode (mock data)
enabled: false  // Prod mode (real CCL)
```

### Add Test Patient
```javascript
// XMLCclRequestSimulator.js - patients array
{
    PERSON_ID: "12345",
    NAME: "TEST, PATIENT",
    ALERT_TYPE: "Severe Sepsis",
    LACTATE_CRITICAL: "5.2"
}
```

### Find Column Renderer
```javascript
// main.js - search for column header text
// Example: Search "Lactate" to find lactate column
```

### Add Console Debug
```javascript
// In any renderer
console.log('Column value:', value, 'Patient:', patient.NAME);
```

### Update to New CCL Version
```javascript
// No code change needed! CCL called without version:
request.open('GET', '1_CUST_MP_SEP_GET_PDATA');

// Just compile/include new version (e.g., v21)
// It overwrites the runtime object automatically
// Version # is for source files only, not runtime calls
```

---

## 🛠️ Development Workflow

| Environment | Simulator | How to Access | When to Use |
|-------------|-----------|---------------|-------------|
| **Local Mac** | ✅ ON | `open src/web/index.html` | Quick testing |
| **Azure CERT** | ❌ OFF | Azure URL | Real data validation |
| **Citrix Prod** | ❌ OFF | PowerChart tab | Production |

---

## 🐛 Debugging

### Access Console in PowerChart
```
Ctrl+Shift+F (or Cmd+Shift+F)
Opens Eruda DevTools
```

### Console Commands
```javascript
toggleSimulator()     // Switch dev/prod mode
showConfig()          // View current config
toggleEruda()         // Show/hide console
```

---

## 📐 Deployment Patterns

### Azure (CERT Testing)
- **Files:** `src/web/index.html` (relative paths)
- **Method:** Azure CLI upload
- **Access:** HTTPS URL
- **When:** Testing with real data

### Citrix (Production)
- **Backend:** `1_cust_mp_sepsis_dashboard.html` (in $cust_script)
- **Frontend:** `I:\custom\mpages\sepsis_dashboard\` (web assets)
- **Driver:** `1_cust_mp_sepsis_dashboard.prg` (CCL)
- **Access:** PowerChart tab
- **When:** Production use

**See:** `CITRIX-DEPLOYMENT-GUIDE.md` for complete steps

---

## 💡 Key Insights

### Why Services Pattern?
**Traditional:** One `zzz_mpage.js` file (300KB+) - hard to navigate
**This Project:** 11 files by purpose - easy to find code

### Why Vanilla JS?
**No React/Vue/Angular** = No framework compatibility issues in PowerChart

### Why Simulator?
**Can develop locally** = Faster iteration without Citrix access

### Why Tippy.js?
**Auto-positioning** = 214 lines of manual positioning code removed

### Why Handsontable?
**Excel-like interface** = Clinical users already know how to use it

---

## 🚨 Watch Out For

| Issue | Why | Fix |
|-------|-----|-----|
| **Editing wrong file** | Azure vs Citrix different | Check filename: `index.html` vs `1_cust_mp_sepsis_dashboard.html` |
| **Simulator still on** | Seeing mock data in CERT | Check Config.js line 16 |
| **Missing double backslash** | Citrix paths fail | Use `\\` not `\` in CCL/HTML |
| **Skipping doc sync** | Files out of sync | Update CHANGELOG, CLAUDE.md, README together |
| **Wrong CCL version** | Old data format | Check PatientDataService.js calls v20 |

---

## 📚 Full Documentation

| Document | Purpose |
|----------|---------|
| **DEVELOPER-GUIDE.md** | Complete architecture (read first!) |
| **CITRIX-DEPLOYMENT-GUIDE.md** | Deployment procedures |
| **README.md** | Project overview |
| **CHANGELOG.md** | Version history |
| **GitHub Issues** | Feature context and decisions |

---

## 🎓 In-Service Key Takeaways

**1. Architecture:** Service pattern with vanilla JavaScript
**2. Why:** PowerChart compatibility + reliability
**3. Services:** Config, UserInfo, PatientList, PatientData
**4. Main.js:** Column renderers (15+ custom columns)
**5. Development:** Simulator mode → CERT → Citrix
**6. Deployment:** Dual (Azure + Citrix with CCL driver)
**7. Debugging:** Eruda console (Ctrl+Shift+F)
**8. Files:** Well-documented inline + external guides

---

## 🚀 Ready to Code

**First Task Suggestion:**
1. Enable simulator in Config.js
2. Open index.html locally
3. Add console.log to one column renderer in main.js
4. See it work!

**Questions?** Read DEVELOPER-GUIDE.md or check inline comments.

---

*Print this for quick reference during development!*
