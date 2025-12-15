# Cerner Citrix I: Drive Deployment Guide

**Version:** 1.0
**Date:** 2025-11-03
**For:** Sepsis Dashboard v1.44.0-sepsis and later
**Issue:** #53

---

## Overview

This guide documents the complete deployment process for the Sepsis Dashboard to Cerner Citrix environments using the two-location deployment pattern.

### Architecture

**Two-Location Deployment Pattern:**
- **Backend ($cust_script):** HTML file only
- **Frontend (I: drive):** All web assets (JS, CSS, libraries)

**Why this pattern?**
- PowerChart environments don't allow web servers
- File:// protocol requires absolute paths
- CCL driver script bridges the two locations
- Proven pattern from Oracle Health MPages training

---

## Prerequisites

### Access Required

- ✅ Cerner Discern Visual Developer access
- ✅ Write permissions to `cust_script:` directory
- ✅ Write permissions to `I:\custom\mpages\` directory
- ✅ Ability to compile and include CCL programs
- ✅ PrefMaint access (for PowerChart tab creation)

### Files Needed

From this repository:
- `src/ccl/1_cust_mp_sepsis_dashboard.prg` (CCL driver script)
- `src/web/1_cust_mp_sepsis_dashboard.html` (Modified HTML with placeholders)
- `src/web/js/` folder (all JavaScript files)
- `src/web/lib/` folder (all libraries)
- `src/web/styles.css` (stylesheet)

---

## Deployment Steps

### Phase 1: Compile CCL Driver Script

**File:** `1_cust_mp_sepsis_dashboard.prg`

**Steps:**

1. Copy `1_cust_mp_sepsis_dashboard.prg` to your Cerner backend
2. Open file in Discern Visual Developer
3. **Build → Compile** (or press F7)
4. Verify compilation successful (no errors)
5. **Build → Include** to make program available

**Expected Output:** "Compilation successful" message

**Troubleshooting:**
- **Error: "Syntax error"** → Check double backslash paths are correct
- **Error: "Include failed"** → Verify you have include permissions

---

### Phase 2: Create I: Drive Directory Structure

**Target Path:** `I:\custom\mpages\sepsis_dashboard\`

**Steps:**

1. Open Windows Explorer in Citrix environment
2. Navigate to `I:\custom\mpages\`
3. Create new folder: `sepsis_dashboard`
4. Verify folder created successfully

**Expected Result:** Empty folder at `I:\custom\mpages\sepsis_dashboard\`

**Troubleshooting:**
- **Error: Access denied** → Request I: drive write permissions from IT
- **Folder exists** → Verify it's empty or use different name

---

### Phase 3: Copy Web Assets to I: Drive

**Source:** Local repository `src/web/` directory

**Destination:** `I:\custom\mpages\sepsis_dashboard\`

**Files to Copy:**

| Source | Destination |
|--------|-------------|
| `src/web/js/` | `I:\custom\mpages\sepsis_dashboard\js\` |
| `src/web/lib/` | `I:\custom\mpages\sepsis_dashboard\lib\` |
| `src/web/styles.css` | `I:\custom\mpages\sepsis_dashboard\styles.css` |

**Method:** Windows Explorer drag-and-drop or copy/paste

**Verification Checklist:**
- [ ] js\\ folder contains 12 JavaScript files
- [ ] lib\\ folder contains 4 subdirectories (handsontable, fontawesome, tippy, eruda)
- [ ] styles.css file present at root level
- [ ] File sizes match source files
- [ ] Directory structure preserved

**Expected File Count:** ~50+ files total

---

### Phase 4: Deploy HTML to Backend

**Source:** `src/web/1_cust_mp_sepsis_dashboard.html`

**Destination:** `cust_script:\1_cust_mp_sepsis_dashboard.html`

**Steps:**

1. Open Discern Visual Developer
2. Open the HTML file from local repository
3. **File → Export** to `cust_script:` directory
4. Save as `1_cust_mp_sepsis_dashboard.html`
5. Verify file saved successfully (~8532 bytes)

**Note:** This is the ONLY file that goes to backend. All other assets stay on I: drive.

---

### Phase 5: Test MPage Execution

**Execute CCL Driver:**

1. In Discern Visual Developer: **Build → Run Prompt Program** (Ctrl+R)
2. **Program to run:** `1_cust_mp_sepsis_dashboard`
3. **Click "Run"**
4. **Enter parameters:**
   - Output to File/Printer/MINE: `MINE`
   - Static Content Directory: `I:\\custom\\mpages\\sepsis_dashboard`
   - HTML File Location/Name: `1_cust_mp_sepsis_dashboard.html`
5. **Click "Execute"**

**Expected Result:** Sepsis Dashboard displays in browser window

---

### Phase 6: Functional Testing

**Complete Testing Checklist:**

#### Visual Display
- [ ] Header displays: "Severe Sepsis Dashboard"
- [ ] Blue header border (color: #1e3a8a)
- [ ] Patient list dropdown visible
- [ ] Refresh button visible
- [ ] Auto-refresh toggle visible
- [ ] Table container displays

#### JavaScript Functionality
- [ ] Console accessible (Ctrl+Shift+F or Cmd+Shift+F)
- [ ] No JavaScript errors in console
- [ ] No 404 errors for assets
- [ ] Patient list dropdown populates (if simulator enabled)

#### Libraries Loaded
- [ ] Handsontable grid displays correctly
- [ ] Font Awesome icons visible
- [ ] Tippy.js tooltips work (hover over items)
- [ ] Eruda debug console accessible

#### Dashboard Features
- [ ] Select patient list works
- [ ] Data loads and displays in grid
- [ ] All columns visible (Alert, Screen, PowerPlan, Lactate, Blood Cultures, etc.)
- [ ] Tooltips display on hover
- [ ] PowerForm launch buttons work (if applicable)
- [ ] PowerPlan launch buttons work (if applicable)
- [ ] Auto-refresh toggle functions

---

## Path Format Reference

### Critical: Double Backslash in CCL

**Why double backslash?**
- CCL uses `\` as escape character (like most programming languages)
- `\\` = literal backslash in the path
- Single `\` would be interpreted as escape sequence

**Examples:**

```ccl
/* CORRECT - Double backslash */
"Static Content Directory" = "I:\\custom\\mpages\\sepsis_dashboard"

/* WRONG - Single backslash (will fail) */
"Static Content Directory" = "I:\custom\mpages\sepsis_dashboard"
```

### HTML Placeholder Pattern

**Template format:**
```html
<script src="$SOURCE_DIR$\\js\\Config.js"></script>
<link href="$SOURCE_DIR$\\styles.css" rel="stylesheet" />
```

**After CCL replacement becomes:**
```html
<script src="I:\custom\mpages\sepsis_dashboard\js\Config.js"></script>
<link href="I:\custom\mpages\sepsis_dashboard\styles.css" rel="stylesheet" />
```

---

## Directory Structure

### Complete I: Drive Structure

```
I:\custom\mpages\sepsis_dashboard\
├── js\
│   ├── AdminCommands.js
│   ├── Config.js
│   ├── main.js
│   ├── PatientDataService.js
│   ├── PatientListService.js
│   ├── PowerFormLauncher.js
│   ├── PowerPlanLauncher.js
│   ├── SendCclRequest.js
│   ├── UserInfoService.js
│   ├── VisualIndicators.js
│   └── XMLCclRequestSimulator.js
├── lib\
│   ├── eruda\
│   │   └── eruda.js
│   ├── fontawesome\
│   │   ├── all.min.css
│   │   └── webfonts\
│   ├── handsontable\
│   │   ├── handsontable.full.min.css
│   │   ├── handsontable.full.min.js
│   │   └── ht-theme-main.min.css
│   └── tippy\
│       ├── popper.min.js
│       ├── tippy.css
│       └── tippy.umd.min.js
└── styles.css
```

### Backend Structure

```
cust_script:\
└── 1_cust_mp_sepsis_dashboard.html
```

---

## Troubleshooting

### Common Issues

#### 1. MPage Loads But No Styling

**Symptom:** Page displays but looks unstyled (no colors, no formatting)

**Cause:** CSS file not loading from I: drive

**Fix:**
- Verify `styles.css` exists at `I:\custom\mpages\sepsis_dashboard\styles.css`
- Check path format in HTML has double backslash
- Check CCL driver successfully replaced `$SOURCE_DIR$`

#### 2. JavaScript Errors: "Cannot find module"

**Symptom:** Console shows "Failed to load resource" or 404 errors

**Cause:** JavaScript files not found on I: drive

**Fix:**
- Verify all JS files in `I:\custom\mpages\sepsis_dashboard\js\`
- Check file names match exactly (case-sensitive)
- Verify double backslash in paths

#### 3. Handsontable Grid Not Displaying

**Symptom:** Table container shows but no grid appears

**Cause:** Handsontable library not loading

**Fix:**
- Verify `I:\custom\mpages\sepsis_dashboard\lib\handsontable\` exists
- Check all three Handsontable files present:
  - handsontable.full.min.js
  - handsontable.full.min.css
  - ht-theme-main.min.css

#### 4. Font Awesome Icons Missing

**Symptom:** Empty squares or boxes instead of icons

**Cause:** Font Awesome CSS or webfonts not loading

**Fix:**
- Verify `I:\custom\mpages\sepsis_dashboard\lib\fontawesome\all.min.css` exists
- Verify `I:\custom\mpages\sepsis_dashboard\lib\fontawesome\webfonts\` folder exists
- Check font file permissions

#### 5. Tooltips Not Appearing

**Symptom:** No tooltips on hover

**Cause:** Tippy.js library not loading

**Fix:**
- Verify all Tippy files present:
  - `lib\tippy\tippy.css`
  - `lib\tippy\tippy.umd.min.js`
  - `lib\tippy\popper.min.js`

#### 6. CCL Compilation Errors

**Symptom:** "Syntax error" or "Invalid character" during compile

**Cause:** Path format incorrect in CCL

**Fix:**
- Verify double backslash `\\` in all I: drive paths
- Check no extra spaces in prompt defaults
- Verify program name under 30 characters

---

## PowerChart Integration

### Create PowerChart Tab (Optional)

**When ready for PowerChart access:**

1. Open PrefMaint (requires elevated permissions)
2. Create new MPage tab:
   - **Tab Name:** "Sepsis Dashboard"
   - **Program:** `1_cust_mp_sepsis_dashboard`
   - **Parameters:** Default (uses prompt defaults)
3. Assign tab to appropriate role/user
4. Test tab opens in PowerChart

**Note:** This step requires PrefMaint access and should be coordinated with Cerner administrators.

---

## Rollback Procedure

### If Deployment Fails

**Backend Rollback:**
1. Delete or rename `cust_script:\1_cust_mp_sepsis_dashboard.html`
2. Drop CCL program: `drop program 1_cust_mp_sepsis_dashboard:dba go`

**Frontend Rollback:**
1. Delete `I:\custom\mpages\sepsis_dashboard\` folder
2. No impact on existing systems

**Note:** Azure deployment continues to work independently - no rollback needed there.

---

## Dual Deployment Strategy

### Azure vs Citrix

**Azure Deployment (CERT Testing):**
- URL: `https://ihazurestoragedev.z13.web.core.windows.net/camc-sepsis-mpage/src/index.html`
- Protocol: HTTPS with web server
- File: `index.html` (relative paths)
- Use case: External testing, browser access

**Citrix Deployment (Production):**
- Access: Via CCL driver in PowerChart
- Protocol: file:// (no web server)
- Files: `1_cust_mp_sepsis_dashboard.*` (placeholder paths)
- Use case: Production PowerChart environment

**Both deployments work from same codebase!**

---

## Version History

### v1.44.0-sepsis (2025-11-03)

**Added:**
- Cerner Citrix I: drive deployment support
- CCL driver script: `1_cust_mp_sepsis_dashboard.prg`
- Modified HTML with placeholders: `1_cust_mp_sepsis_dashboard.html`
- Two-location deployment architecture

**Changed:**
- None (additive feature - no breaking changes)

**Deployment Locations:**
- Backend: `cust_script:\1_cust_mp_sepsis_dashboard.html`
- Frontend: `I:\custom\mpages\sepsis_dashboard\`

---

## Reusable Pattern for Future MPages

### Template for New MPages

This deployment pattern can be reused for any custom MPage:

**1. Create CCL Driver (Template):**
```ccl
drop program 1_cust_mp_[your_mpage]:dba go
create program 1_cust_mp_[your_mpage]:dba

prompt
    "Output to File/Printer/MINE" = "MINE"
    , "Static Content Directory" = "I:\\custom\\mpages\\[your_mpage]"
    , "HTML File Location/Name" = "1_cust_mp_[your_mpage].html"

with OUTDEV, CONTENTDIR, HTMLFILE

record getREQUEST (
  1 Module_Dir = vc
  1 Module_Name = vc
  1 bAsBlob = i2
)

record getREPLY (
  1 INFO_LINE[*]
    2 new_line = vc
  1 data_blob = gvc
  1 data_blob_size = i4
%i cclsource:status_block.inc
)

record putREQUEST (
  1 source_dir = vc
  1 source_filename = vc
  1 nbrlines = i4
  1 line [*]
    2 lineData = vc
  1 OverFlowPage [*]
    2 ofr_qual [*]
      3 ofr_line = vc
  1 IsBlob = c1
  1 document_size = i4
  1 document = gvc
)

record putREPLY (
  1 INFO_LINE [*]
    2 new_line = vc
%i cclsource:status_block.inc
)

set getREQUEST->Module_Dir = build2("cust_script:", $HTMLFILE)
set getREQUEST->Module_Name = ""
set getREQUEST->bAsBlob = 1

execute eks_get_source with replace(REQUEST, getREQUEST), replace(REPLY, getREPLY)

set getREPLY->data_blob = replace(getREPLY->data_blob, "$SOURCE_DIR$", $CONTENTDIR, 0)

set putREQUEST->source_dir = $OUTDEV
set putREQUEST->IsBlob = "1"
set putREQUEST->document = getREPLY->data_blob
set putREQUEST->document_size = size(putREQUEST->document)

execute eks_put_source with replace(REQUEST, putREQUEST), replace(REPLY, putREPLY)

end
go
```

**2. Modify HTML (Template):**
Replace all relative paths with `$SOURCE_DIR$\\path`

**Before:**
```html
<script src="./js/main.js"></script>
<link href="styles.css" rel="stylesheet" />
```

**After:**
```html
<script src="$SOURCE_DIR$\\js\\main.js"></script>
<link href="$SOURCE_DIR$\\styles.css" rel="stylesheet" />
```

**3. Deploy to I: Drive:**
- Create `I:\custom\mpages\[your_mpage]\` folder
- Copy web assets (js, lib, css)

**4. Deploy HTML to Backend:**
- Copy HTML to `cust_script:\`

**5. Test with CCL_READFILE**

---

## File Protocol Compatibility Requirements

### Must Be Local (No CDNs)

**Required for file:// protocol:**
- ✅ All JavaScript libraries must be local files
- ✅ All CSS files must be local files
- ✅ All fonts/icons must be local files
- ✅ No external HTTP/HTTPS dependencies
- ✅ All paths must be relative or use placeholders

**Current Libraries (All Local):**
- Handsontable v15.2.0
- Font Awesome 6.5.1
- Tippy.js v6.3.7
- Eruda DevTools

---

## Path Format Examples

### CCL Prompt Defaults

```ccl
prompt
    "Static Content Directory" = "I:\\custom\\mpages\\sepsis_dashboard"
    , "HTML File Location/Name" = "1_cust_mp_sepsis_dashboard.html"
```

### HTML Placeholders

```html
<!-- CSS Files -->
<link href="$SOURCE_DIR$\\styles.css" rel="stylesheet" />
<link rel="stylesheet" href="$SOURCE_DIR$\\lib\\fontawesome\\all.min.css" />

<!-- JavaScript Files -->
<script src="$SOURCE_DIR$\\js\\Config.js"></script>
<script src="$SOURCE_DIR$\\lib\\handsontable\\handsontable.full.min.js"></script>

<!-- Note: Always use double backslash \\ -->
```

### After CCL Processing

The CCL driver replaces `$SOURCE_DIR$` with the I: drive path:

```html
<!-- Becomes: -->
<link href="I:\custom\mpages\sepsis_dashboard\styles.css" rel="stylesheet" />
<script src="I:\custom\mpages\sepsis_dashboard\js\Config.js"></script>
```

---

## Testing Checklist

### Pre-Deployment Testing

- [ ] CCL driver compiles without errors
- [ ] CCL driver included successfully
- [ ] I: drive directory created with correct permissions
- [ ] All web assets copied to I: drive
- [ ] HTML file copied to backend
- [ ] File counts verified

### Post-Deployment Testing

- [ ] CCL_READFILE executes without errors
- [ ] MPage displays in browser
- [ ] No console errors (check Eruda: Ctrl+Shift+F)
- [ ] All columns visible
- [ ] JavaScript functionality works
- [ ] Tooltips display correctly
- [ ] PowerForm launches work (if tested)
- [ ] PowerPlan launches work (if tested)
- [ ] Auto-refresh functions
- [ ] Simulator mode toggle works (for testing)

### PowerChart Integration Testing (If Applicable)

- [ ] PowerChart tab created in PrefMaint
- [ ] Tab launches MPage successfully
- [ ] Patient context passed correctly
- [ ] MPAGES_EVENT calls work
- [ ] APPLINK functionality works
- [ ] No performance issues

---

## Maintenance and Updates

### Updating the MPage

**For code changes:**

1. Update files in local repository
2. Test locally with Azure deployment (if available)
3. Copy updated files to I: drive:
   - If JS changed: Copy to `I:\custom\mpages\sepsis_dashboard\js\`
   - If CSS changed: Copy `styles.css`
   - If libraries updated: Copy to `I:\custom\mpages\sepsis_dashboard\lib\`

4. If HTML structure changed:
   - Update `1_cust_mp_sepsis_dashboard.html` with placeholders
   - Copy to `cust_script:\`

5. Test with CCL_READFILE
6. Update version number in files

**Note:** CCL driver rarely needs changes unless I: drive path changes.

### Version Control

- Keep all files in Git repository
- Tag releases: `git tag v1.44.0-sepsis`
- Document changes in CHANGELOG.md
- Update CLAUDE.md and README.md

---

## Security and Compliance

### Healthcare Considerations

**Data Security:**
- No PHI stored in files (data comes from CCL queries)
- File permissions controlled by Cerner security
- Audit trail via Git and GitHub issues

**Access Control:**
- I: drive permissions managed by IT
- $cust_script access restricted to authorized developers
- PowerChart tab access controlled via PrefMaint roles

**Change Management:**
- All changes tracked in GitHub (Issue → PR → Tag)
- Full audit trail for regulatory compliance
- Documentation synchronized with code changes

---

## Support and Resources

### Internal Resources

**Repository:** https://github.com/troyshelton/sepsis-dashboard

**Documentation:**
- README.md - Project overview and current status
- CHANGELOG.md - Version history and changes
- CLAUDE.md - Development guidelines and architecture
- This guide - Deployment procedures

**GitHub Issues:**
- Issue #53: Citrix Deployment Integration
- Related issues: #26, #51, #52

### External References

**Oracle Health (Cerner) Documentation:**
- MPages HTML/JavaScript Training Exercises
- CCL Programming Guide
- MPAGES_EVENT, APPLINK, CCLLINK documentation

**Code Patterns:**
- Training example: `1_mp_asp_dashboard_03.prg`
- CCL driver pattern: Exercise #14
- Placeholder replacement: `$SOURCE_DIR$` technique

---

## Contact and Support

**Primary Developer:** Troy Shelton

**For deployment assistance:**
1. Check this guide first
2. Review GitHub Issue #53
3. Check repository documentation
4. Contact development team

---

## Appendix: Quick Reference

### File Naming Convention

- **CCL Programs:** `1_cust_mp_[name].prg` (max 30 chars, starts with number)
- **HTML Files:** `1_cust_mp_[name].html` (matches CCL program name)
- **Pattern:** Matches existing sepsis dashboard CCL programs

### Common Commands

**Compile CCL:**
```
Build → Compile (F7)
Build → Include
```

**Execute CCL:**
```
Build → Run Prompt Program (Ctrl+R)
Program: 1_cust_mp_sepsis_dashboard
Execute
```

**Check Console:**
```
Ctrl+Shift+F (or Cmd+Shift+F)
Opens Eruda DevTools
```

### Directory Paths

| Location | Path |
|----------|------|
| I: Drive Root | `I:\custom\mpages\sepsis_dashboard\` |
| Backend | `cust_script:\` |
| JavaScript | `I:\custom\mpages\sepsis_dashboard\js\` |
| Libraries | `I:\custom\mpages\sepsis_dashboard\lib\` |
| Styles | `I:\custom\mpages\sepsis_dashboard\styles.css` |

---

**Document Version:** 1.0
**Last Updated:** 2025-11-03
**Validated With:** Sepsis Dashboard v1.44.0-sepsis
**Pattern Status:** Production-ready and reusable

---

*This deployment pattern is proven, tested, and ready for use with other custom MPages at Vandalia Health.*
