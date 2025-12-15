# Cerner Production Deployment - Complete File List

**Version:** v1.44.1-sepsis
**Date:** 2025-11-05
**Deployment Type:** Citrix I: Drive (Two-Location Pattern)

---

## 📋 **Deployment Overview**

**Two Locations:**
1. **Backend ($cust_script):** 1 HTML file only
2. **Frontend (I: drive):** 28 web asset files
3. **CCL Programs:** 13 required programs + 1 new driver

**Total Files:** 42 files

---

## 🏗️ **BACKEND DEPLOYMENT - $cust_script**

### HTML File (1 file)

| File | Source | Destination | Size |
|------|--------|-------------|------|
| 1_cust_mp_sepsis_dashboard.html | `src/web/1_cust_mp_sepsis_dashboard.html` | `$cust_script:\1_cust_mp_sepsis_dashboard.html` | 8.5KB |

**Note:** Contains `$SOURCE_DIR$` placeholders processed by CCL driver at runtime.

---

## 💻 **FRONTEND DEPLOYMENT - I: Drive**

**Base Path:** `I:\custom\mpages\sepsis_dashboard\`

### JavaScript Files (11 files) → `js\` subfolder

| # | File | Source | Size | Purpose |
|---|------|--------|------|---------|
| 1 | AdminCommands.js | `src/web/js/AdminCommands.js` | 14KB | Admin utilities & debug commands |
| 2 | Config.js | `src/web/js/Config.js` | 3.2KB | **CRITICAL: Set simulator=false for prod!** |
| 3 | main.js | `src/web/js/main.js` | 130KB | Application init & column renderers |
| 4 | PatientDataService.js | `src/web/js/PatientDataService.js` | 122KB | Data processing & formatting |
| 5 | PatientListService.js | `src/web/js/PatientListService.js` | 14KB | Patient list management |
| 6 | PowerFormLauncher.js | `src/web/js/PowerFormLauncher.js` | 3.8KB | PowerForm integration |
| 7 | PowerPlanLauncher.js | `src/web/js/PowerPlanLauncher.js` | 14KB | PowerPlan integration |
| 8 | SendCclRequest.js | `src/web/js/SendCclRequest.js` | 12KB | Production CCL communication |
| 9 | UserInfoService.js | `src/web/js/UserInfoService.js` | 5.6KB | User authentication |
| 10 | VisualIndicators.js | `src/web/js/VisualIndicators.js` | 7.2KB | Status indicators |
| 11 | XMLCclRequestSimulator.js | `src/web/js/XMLCclRequestSimulator.js` | 30KB | Mock data (dev mode) |

**Destination:** `I:\custom\mpages\sepsis_dashboard\js\`

---

### CSS File (1 file) → Root level

| File | Source | Size | Purpose |
|------|--------|------|---------|
| styles.css | `src/web/styles.css` | 20KB | All dashboard styling |

**Destination:** `I:\custom\mpages\sepsis_dashboard\styles.css`

---

### Library Files (16 files total) → `lib\` subfolder

#### Handsontable (3 files) → `lib\handsontable\`

| File | Source | Size |
|------|--------|------|
| handsontable.full.min.css | `src/web/lib/handsontable/handsontable.full.min.css` | 330KB |
| handsontable.full.min.js | `src/web/lib/handsontable/handsontable.full.min.js` | 1.6MB |
| ht-theme-main.min.css | `src/web/lib/handsontable/ht-theme-main.min.css` | 25KB |

**Destination:** `I:\custom\mpages\sepsis_dashboard\lib\handsontable\`

---

#### Font Awesome (1 CSS + 3 fonts) → `lib\fontawesome\`

**CSS File:**

| File | Source | Size |
|------|--------|------|
| all.min.css | `src/web/lib/fontawesome/all.min.css` | 60KB |

**Destination:** `I:\custom\mpages\sepsis_dashboard\lib\fontawesome\all.min.css`

**Font Files → `lib\webfonts\` subfolder:**

| File | Source | Size |
|------|--------|------|
| fa-brands-400.woff2 | `src/web/lib/webfonts/fa-brands-400.woff2` | 130KB |
| fa-regular-400.woff2 | `src/web/lib/webfonts/fa-regular-400.woff2` | 30KB |
| fa-solid-900.woff2 | `src/web/lib/webfonts/fa-solid-900.woff2` | 80KB |

**Destination:** `I:\custom\mpages\sepsis_dashboard\lib\webfonts\`

---

#### Tippy.js Tooltips (3 files) → `lib\tippy\`

| File | Source | Size |
|------|--------|------|
| popper.min.js | `src/web/lib/tippy/popper.min.js` | 15KB |
| tippy.css | `src/web/lib/tippy/tippy.css` | 5KB |
| tippy.umd.min.js | `src/web/lib/tippy/tippy.umd.min.js` | 25KB |

**Destination:** `I:\custom\mpages\sepsis_dashboard\lib\tippy\`

---

#### Eruda DevTools (1 file) → `lib\eruda\`

| File | Source | Size |
|------|--------|------|
| eruda.js | `src/web/lib/eruda/eruda.js` | 360KB |

**Destination:** `I:\custom\mpages\sepsis_dashboard\lib\eruda\`

---

**Frontend Total:** 28 files, ~3.3MB

---

## 🔧 **CCL PROGRAMS - Compile and Include**

### Required Programs (13 programs)

**These must ALL be compiled and included in production:**

#### Core Programs (4 required)

| Program | Source | Purpose | Called By |
|---------|--------|---------|-----------|
| **1_cust_mp_sepsis_dashboard** | `src/ccl/1_cust_mp_sepsis_dashboard.prg` | **NEW! CCL driver script** | PowerChart tab |
| **1_cust_mp_sep_get_pdata** | `src/ccl/1_cust_mp_sep_get_pdata_20.prg` | Patient sepsis data (v20 current) | JavaScript |
| **1_cust_mp_sep_get_plists** | `src/ccl/1_cust_mp_sep_get_plists.prg` | Available patient lists | JavaScript |
| **1_cust_mp_sep_user_info** | `src/ccl/1_cust_mp_sep_user_info.prg` | User authentication | JavaScript |

**Note:** JavaScript calls programs WITHOUT version numbers (e.g., `1_CUST_MP_SEP_GET_PDATA`)

---

#### Dispatcher Program (1 required)

| Program | Source | Purpose |
|---------|--------|---------|
| **1_cust_mp_sep_get_pids** | `src/ccl/1_cust_mp_sep_get_pids.prg` | Determines list type, calls child programs |

---

#### Patient List Type Handlers (7 required - called by dispatcher)

| Program | Source | List Type | When Called |
|---------|--------|-----------|-------------|
| **1_cust_mp_sep_plst_custom** | `src/ccl/1_cust_mp_sep_plst_custom.prg` | CUSTOM | User-created lists |
| **1_cust_mp_sep_plst_cteam** | `src/ccl/1_cust_mp_sep_plst_cteam.prg` | CARETEAM | Care team lists |
| **1_cust_mp_sep_plst_census** | `src/ccl/1_cust_mp_sep_plst_census.prg` | LOCATION/LOCATIONGRP/SERVICE | Census/location lists |
| **1_cust_mp_sep_plst_reltn** | `src/ccl/1_cust_mp_sep_plst_reltn.prg` | RELTN/VRELTN/LRELTN | Relationship lists |
| **1_cust_mp_sep_plst_provgrp** | `src/ccl/1_cust_mp_sep_plst_provgrp.prg` | PROVIDERGRP | Provider group lists |
| **1_cust_mp_sep_plst_assign** | `src/ccl/1_cust_mp_sep_plst_assign.prg` | ASSIGNMENT | Assignment lists |
| **1_cust_mp_sep_plst_query** | `src/ccl/1_cust_mp_sep_plst_query.prg` | QUERY | Query lists |

---

#### Include File (1 optional)

| File | Source | Purpose |
|------|--------|---------|
| 0_cust_ce_blob_func.inc | `src/ccl/0_cust_ce_blob_func.inc` | Blob extraction utilities (if used) |

---

## 📐 **CCL Program Call Hierarchy**

```
PowerChart Tab
    ↓
1_cust_mp_sepsis_dashboard (CCL driver - NEW!)
    ↓
1_cust_mp_sepsis_dashboard.html (processed with paths)
    ↓
JavaScript loads and calls:
    ↓
    ├─ 1_cust_mp_sep_user_info → Get user context
    ├─ 1_cust_mp_sep_get_plists → Get available patient lists
    │
    User selects list
    ↓
    ├─ 1_cust_mp_sep_get_pids → Dispatcher determines list type
    │   ↓
    │   ├─ 1_cust_mp_sep_plst_custom (if CUSTOM list)
    │   ├─ 1_cust_mp_sep_plst_cteam (if CARETEAM list)
    │   ├─ 1_cust_mp_sep_plst_census (if LOCATION list)
    │   ├─ 1_cust_mp_sep_plst_reltn (if RELTN list)
    │   ├─ 1_cust_mp_sep_plst_provgrp (if PROVIDERGRP list)
    │   ├─ 1_cust_mp_sep_plst_assign (if ASSIGNMENT list)
    │   └─ 1_cust_mp_sep_plst_query (if QUERY list)
    │       ↓
    │       Returns encounter IDs
    │
    └─ 1_cust_mp_sep_get_pdata → Get patient sepsis data
        ↓
        Returns JSON with all dashboard data
```

---

## ✅ **Production Deployment Checklist**

### **Step 1: CCL Programs (Compile & Include)**

**Compile in this order:**

- [ ] 1. `1_cust_mp_sepsis_dashboard.prg` ⬅️ **NEW! Driver script**
- [ ] 2. `1_cust_mp_sep_user_info.prg`
- [ ] 3. `1_cust_mp_sep_get_plists.prg`
- [ ] 4. `1_cust_mp_sep_get_pids.prg` (dispatcher)
- [ ] 5. `1_cust_mp_sep_plst_custom.prg`
- [ ] 6. `1_cust_mp_sep_plst_cteam.prg`
- [ ] 7. `1_cust_mp_sep_plst_census.prg`
- [ ] 8. `1_cust_mp_sep_plst_reltn.prg`
- [ ] 9. `1_cust_mp_sep_plst_provgrp.prg`
- [ ] 10. `1_cust_mp_sep_plst_assign.prg`
- [ ] 11. `1_cust_mp_sep_plst_query.prg`
- [ ] 12. `1_cust_mp_sep_get_pdata_20.prg` (v20 - latest, overwrites generic name)
- [ ] 13. `0_cust_ce_blob_func.inc` (if used)

**Note:** The latest version (v20) is the one currently in production use.

---

### **Step 2: I: Drive Frontend**

**Create directory structure:**
```
I:\custom\mpages\sepsis_dashboard\
├── js\
├── lib\
│   ├── handsontable\
│   ├── fontawesome\
│   ├── webfonts\
│   ├── tippy\
│   └── eruda\
└── (styles.css at root)
```

**Copy files:**
- [ ] Copy `js\` folder (11 JavaScript files)
- [ ] Copy `lib\handsontable\` (3 files)
- [ ] Copy `lib\fontawesome\` (1 CSS file)
- [ ] Copy `lib\webfonts\` (3 font files)
- [ ] Copy `lib\tippy\` (3 files)
- [ ] Copy `lib\eruda\` (1 file)
- [ ] Copy `styles.css` (root level)

**Verify:** 28 files total on I: drive

---

### **Step 3: Backend HTML**

- [ ] Copy `1_cust_mp_sepsis_dashboard.html` to `$cust_script:\`
- [ ] Verify file size matches (~8.5KB)

---

### **Step 4: Verification**

**Test CCL Driver:**
- [ ] Build → Run Prompt Program (Ctrl+R)
- [ ] Program: `1_cust_mp_sepsis_dashboard`
- [ ] Parameters:
  - Output: `MINE`
  - Static Content Directory: `I:\\custom\\mpages\\sepsis_dashboard`
  - HTML File: `1_cust_mp_sepsis_dashboard.html`
- [ ] Execute and verify MPage loads

**Functional Testing:**
- [ ] All columns display
- [ ] Patient lists populate correctly
- [ ] Sepsis data displays
- [ ] PowerForm launches work (Screening, Perfusion)
- [ ] PowerPlan launches work (PowerPlan, **Fluids, Antibiotics** ⬅️ NEW!)
- [ ] Tooltips display correctly
- [ ] No console errors

---

## ⚠️ **CRITICAL: Production Configuration**

### **Before Deployment - Verify Config.js**

**File:** `I:\custom\mpages\sepsis_dashboard\js\Config.js`

**Line 16 MUST be:**
```javascript
window.SIMULATOR_CONFIG = {
    enabled: false  // MUST be false for production!
};
```

**If `enabled: true`** → Will use mock data instead of real patients!

---

## 📊 **Complete File Inventory**

**Summary:**

| Category | Files | Total Size |
|----------|-------|------------|
| **Backend HTML** | 1 | 8.5KB |
| **Frontend JS** | 11 | 356KB |
| **Frontend CSS** | 1 | 20KB |
| **Frontend Libraries** | 16 | 2.9MB |
| **CCL Programs** | 13 | ~1MB source |
| **TOTAL** | **42 files** | **~3.3MB** |

---

## 🔄 **CCL Program Dependencies (Execution Order)**

### **When MPage Opens:**

**1. Driver Executes:**
- `1_cust_mp_sepsis_dashboard` (reads HTML, processes placeholders)

**2. JavaScript Calls (on page load):**
- `1_cust_mp_sep_user_info` (gets user context)
- `1_cust_mp_sep_get_plists` (populates dropdown)

**3. User Selects List:**
- `1_cust_mp_sep_get_pids` (dispatcher determines list type)
- Calls ONE of the plst_* programs based on type:
  - `1_cust_mp_sep_plst_custom` (for CUSTOM lists)
  - `1_cust_mp_sep_plst_cteam` (for CARETEAM lists)
  - `1_cust_mp_sep_plst_census` (for LOCATION/SERVICE lists)
  - `1_cust_mp_sep_plst_reltn` (for RELTN lists)
  - `1_cust_mp_sep_plst_provgrp` (for PROVIDERGRP lists)
  - `1_cust_mp_sep_plst_assign` (for ASSIGNMENT lists)
  - `1_cust_mp_sep_plst_query` (for QUERY lists)

**4. Get Patient Data:**
- `1_cust_mp_sep_get_pdata` (v20 overwrites this name when compiled)

**All 7 patient list handlers must be included or appropriate list types will fail!**

---

## 📝 **Deployment Notes**

### **What's New in This Version (v1.44.1-sepsis)**

**Latest Changes:**
1. ✅ Antibiotics column PowerPlan quick launch (Issue #55)
2. ✅ Citrix I: drive deployment support (Issue #53)
3. ✅ Perfusion PowerForm green checkmark (Issue #47)
4. ✅ Tippy.js tooltip standardization (Issue #48)

**Production Ready Features:**
- Complete sepsis bundle tracking
- PowerForm quick launches (Screening, Perfusion)
- PowerPlan quick launches (PowerPlan, Fluids, Antibiotics)
- Auto-refresh with filter preservation
- Handsontable v15.2.0 with modern theme
- Debug console accessible (Eruda)

---

## 🆘 **Support Reference**

**If deployment issues occur:**

1. **Check:** `docs/CITRIX-DEPLOYMENT-GUIDE.md` (troubleshooting section)
2. **Verify:** All 13 CCL programs compiled and included
3. **Verify:** Config.js has `enabled: false`
4. **Check:** I: drive paths use double backslash in CCL
5. **Contact:** Development team with specific error messages

---

## 🎯 **Success Criteria**

**Deployment successful when:**
- ✅ MPage loads via CCL driver
- ✅ All patient list types work
- ✅ Sepsis data displays correctly
- ✅ All PowerForm/PowerPlan launches work
- ✅ No console errors in Eruda
- ✅ Clinical users can access and use dashboard

---

**Version:** v1.44.1-sepsis
**Production Ready:** YES ✅
**CERT Validated:** YES ✅
**All Features Tested:** YES ✅
**Documentation Complete:** YES ✅

---

*Ready for Cerner Production deployment!*
