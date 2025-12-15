# Project: Sepsis Dashboard

**Current Version:** v1.48.0-sepsis
**Date:** 2025-12-08
**Project Type:** Healthcare Production ⚠️
**Enforcement:** Mandatory Workflows Required

---

## Project Overview

Real-time sepsis detection and monitoring dashboard for emergency department clinical staff.

**Clinical Purpose:** Early sepsis detection and intervention tracking
**Patient Impact:** Reduces sepsis mortality through faster identification and treatment
**Compliance:** HIPAA, Patient Safety Standards, Clinical Quality Measures

---

# 🛑 CLAUDE: READ AND ACKNOWLEDGE BEFORE ANY WORK 🛑

**Before doing ANYTHING on this project, you MUST acknowledge:**

- [ ] I have read the Deployment Verification Workflow (.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md)
- [ ] I will show EVERY deployment command with source, destination, account BEFORE executing
- [ ] I will WAIT for "approved" before deploying
- [ ] I have read the Code Review Workflow (.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md)
- [ ] I will show code changes (git diff or code sections) BEFORE deploying
- [ ] I will explain what, why, how for every code change
- [ ] I have read the Validation Gate Protocol (.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md)
- [ ] I will STOP at every 🛑 TaskMaster validation gate
- [ ] I will show summary and WAIT for approval before proceeding
- [ ] I understand violations are documented in workflow files with dates
- [ ] I understand repeated violations may result in session termination

**REQUIRED ACKNOWLEDGMENT:**

Type this explicitly at start of session (or when reminded):

```
I acknowledge these mandatory workflows:
✅ Deployment Verification - Show command, wait for approval
✅ Code Review - Show code before deploying
✅ Validation Gates - Stop at 🛑, wait for approval

I will follow them without exception.
```

**Violation history for this project:**
- 2025-12-08 (Issue #78): Deployed 8+ times without verification, deployed ~500 lines without code review, rushed through validation gates

**If you skip this acknowledgment:** User will remind you to read CLAUDE.md enforcement section.

---

# 🛑 MANDATORY HEALTHCARE PRODUCTION ENFORCEMENT 🛑

**⚠️ READ THIS FIRST - ENFORCED WORKFLOWS**

**This project is a HEALTHCARE PRODUCTION SYSTEM.** The following workflows are MANDATORY and ENFORCED:

## 1. Deployment Verification (NO EXCEPTIONS)

**Before EVERY `az storage` command:**

```
I'm about to deploy to Azure CERT:

Source:      /Users/troyshelton/Projects/vandalia/sepsis-dashboard/src/web
Destination: $web/camc-sepsis-mpage/src
Account:     ihazurestoragedev

⚠️ CRITICAL: Is this the correct destination?

Reply "approved" to deploy.
```

**WAIT for "approved" before executing.**

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md`

**Violation (2025-12-08):** Issue #78 - Deployed 8+ times without verification

---

## 2. Code Review (NO EXCEPTIONS)

**Before deploying code changes:**
- Show git diff or code sections
- Explain what, why, how
- Wait for user review and approval

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md`

**Violation (2025-12-08):** Issue #78 - Deployed ~500 lines without showing user

---

## 3. TaskMaster Validation Gates (NO EXCEPTIONS)

**At EVERY 🛑 subtask:**
- STOP immediately
- Show summary of work
- WAIT for approval
- Do not auto-proceed

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md`

**Violation (2025-12-08):** Issue #78 - Rushed through gates without pausing

---

**These violations damaged trust and violated healthcare compliance requirements.**

**Going forward:** Claude reads these workflows at session start and follows them WITHOUT EXCEPTION.

---

# ⚠️ MANDATORY SESSION START CHECKLIST FOR CLAUDE ⚠️

**Before doing ANY work, complete this checklist:**

- [ ] 1. **Detect Project State**: Check if this is a new or existing project
  ```bash
  # Check for project documentation:
  ls README.md CHANGELOG.md 2>/dev/null
  ```

  **If files exist** → Existing project (go to step 2)
  **If files missing** → New project (skip to step 2 with "NEW PROJECT" flag)

- [ ] 2. **For EXISTING Projects - Check Documentation Sync**:
  - Do README.md and CHANGELOG.md have matching versions and dates?
  ```bash
  head -10 README.md | grep "Version:"
  head -10 CHANGELOG.md | grep "##"
  ```
  - **If IN SYNC** → Show concise status, ask what to work on
  - **If OUT OF SYNC** → Show workflow menu + warning

- [ ] 2. **For NEW Projects - Show Initialization Menu**:
  - Skip doc sync check (no docs exist yet)
  - Present initialization workflow menu:
    - Option 1: TASKMASTER-PROJECT-INIT.md
    - Option 2: Copy from existing project template
    - Option 3: Manual setup

- [ ] 3. **If User Selects Workflow Template**:
  - Use `task-master parse-prd` on selected template
  - Follow template tasks with validation gates
  - Templates auto-handle doc creation and git workflow

- [ ] 4. **If User Chooses Custom Approach**:
  - Get explicit confirmation they want to skip templates
  - Warn about manual doc-sync and git workflow requirements
  - Remind them of validation gates they'll need to manage

- [ ] 5. **For Healthcare Production Work** (Sepsis Dashboard):
  - MUST use TASKMASTER-GIT-ENHANCEMENT.md v2.1 (WITH PULL REQUESTS + Azure Deployment Validation)
  - Full audit trail required (Issue → PR → Branch → Tag)
  - Deployment destination verification required (prevents wrong-location deployments)
  - Cannot skip validation gates
  - Required for: team development, production deployments, audit compliance

  **TaskMaster Task Creation:**
  - Claude creates tasks using TaskMaster MCP tools
  - Claude provides detailed task structure document first
  - Claude shows user tasks exist before implementation
  - Example: Issue #72 (Frontend tooltip enhancement)

  **Accountability Mechanism:**
  1. Claude creates detailed TaskMaster structure document
  2. Claude creates tasks via TaskMaster MCP (`add_task`, `add_subtask`)
  3. Claude shows `task-master list` output to user
  4. User verifies tasks exist and structure correct
  5. Claude uses TaskMaster throughout (NOT TodoWrite)

  **Why:** Tasks visible = accountability. Prevents TodoWrite usage when tasks exist.

  **Common TaskMaster CLI Fix:**
  - MCP `add_subtask` tool has `id` parameter issues
  - **Use CLI instead:** `task-master add-subtask --parent=<taskId> --title="..." --description="..."`
  - CLI auto-generates subtask IDs (don't specify --id parameter)

- [ ] 6. **Tool Usage Enforcement** (CRITICAL):
  - ❌ **NEVER use TodoWrite for development tasks**
  - ❌ **NEVER use TodoWrite during TaskMaster workflows**
  - ✅ **ONLY use TaskMaster** for tracking development work
  - ✅ TodoWrite ONLY if user explicitly approves for simple personal reminders
  - **Violation = Process failure**

**⚠️ If you skip this checklist:**
- Documentation WILL get out of sync (happened 2025-10-12)
- Git workflow WILL be incomplete (fixed with Task 5)
- TodoWrite WILL be used instead of TaskMaster (happened 2025-10-13)
- Standards will not be followed consistently

---

## ⚠️ TOOL USAGE RESTRICTIONS (ENFORCED) ⚠️

### TodoWrite Tool Policy

**TodoWrite is DISABLED for development work on this project.**

#### When TodoWrite is FORBIDDEN:
- ❌ During any TaskMaster workflow
- ❌ For development tasks (coding, CCL, frontend work)
- ❌ When GitHub issue is open
- ❌ When on a feature branch
- ❌ During TASKMASTER-GIT-ENHANCEMENT workflow

#### When TodoWrite MAY be used (with permission):
- ✅ Simple personal reminders (ONLY after asking user)
- ✅ Non-development tasks explicitly approved by user

#### Pre-Flight Check (MANDATORY before TodoWrite):

**Before using TodoWrite, Claude MUST execute this check:**

1. **Check TaskMaster status**:
   ```bash
   task-master list
   ```
   If tasks exist → Use TaskMaster, NOT TodoWrite

2. **Check for open GitHub issues**:
   ```bash
   gh issue list --state open
   ```
   If issues exist → Use TaskMaster, NOT TodoWrite

3. **Check current branch**:
   ```bash
   git branch --show-current
   ```
   If on feature branch → Use TaskMaster, NOT TodoWrite

4. **If ANY check is YES** → STOP. Use TaskMaster instead.

5. **If all checks are NO** → Ask user permission:
   ```
   I was about to use TodoWrite for [specific task].

   Pre-flight check results:
   - TaskMaster active? NO
   - GitHub issue open? NO
   - On feature branch? NO
   - Development work? [YES/NO]

   May I use TodoWrite for this, or would you prefer TaskMaster?
   ```

#### Why This Rule Exists

**Documented TodoWrite violations**:
- **2025-10-13 (v1.31.0)**: Used TodoWrite during blood culture development
  - Skipped validation gates between CCL and frontend
  - User lost visibility of progress
  - Had to re-create TaskMaster tasks retroactively
  - Process broken, trust violated

**TaskMaster advantages**:
- ✅ Validation gates (user approval required at key points)
- ✅ Permanent tracking (persists across sessions)
- ✅ User visibility (can see progress anytime)
- ✅ Audit trail (healthcare compliance requirement)
- ✅ Dependency management (prevents skipping steps)

#### Enforcement

**If Claude violates this rule**:
1. User will immediately notice lack of TaskMaster updates
2. Claude must acknowledge violation
3. Work must be re-tracked in TaskMaster with proper subtasks
4. This wastes time and damages trust

**Prevention**: Follow the pre-flight check EVERY time.

---

This file provides project-specific guidance for the Patient List MPage Template.

## Project Overview

A reusable, professional patient list MPage template for healthcare applications. Combines clean UI design with proven service architecture for Cerner PowerChart integration.

## Technology Stack

- **Frontend**: Clean HTML with Tailwind CSS utilities
- **JavaScript**: Vanilla JavaScript with service architecture pattern  
- **Data Grid**: Handsontable for Excel-like data display
- **Debug System**: Eruda DevTools for PowerChart environments
- **Backend**: Cerner CCL programs (with simulator mode for development)
- **Icons**: Font Awesome 6.5.1 for medical-standard iconography

## Specification Adherence Guidelines

### Core Principle
**NEVER deviate from user specifications without explicit approval**

### When User Requests Specific Technologies
1. **Always attempt the exact specification first**
   - Try multiple CDNs, versions, configurations
   - Document all failure points encountered
   - Exhaust all reasonable implementation approaches

2. **If specification cannot be implemented:**
   - **STOP implementation** immediately
   - **Clearly explain technical barriers** encountered
   - **Present alternative options** with detailed pros/cons
   - **Get explicit approval** before proceeding with alternatives

3. **Document the decision** 
   - Why original specification failed
   - Why alternative was chosen
   - User approval confirmation

### Technology Substitution Protocol

#### Example: Debug Console Request
```
User Request: "Install Firebug Lite"

Claude Process:
1. Attempt Firebug Lite from multiple CDNs
2. Try local versions and configurations  
3. If all fail: "I attempted Firebug Lite but encountered [specific barriers]:
   - CDN loading failures from getfirebug.com, jsdelivr, cloudflare
   - API initialization timeouts
   - Strict mode compatibility conflicts
   
   Alternative options:
   - Eruda: Modern DevTools replacement, better features, actively maintained
   - vConsole: Lightweight debugging, simpler interface
   - Custom solution: Guaranteed compatibility but maintenance burden
   
   Would you like me to proceed with Eruda or try a different approach?"

4. Wait for explicit approval before implementing alternative
```

### Communication Standards
- **Be explicit about deviations** from specifications
- **Explain technical reasoning** for why alternatives are needed
- **Present options clearly** with honest pros/cons assessment
- **Get written approval** before implementing substitutions
- **Never assume user will accept alternatives** without asking

### Documentation Requirements
- **Record specification attempts** in comments or changelog
- **Document technical barriers** encountered
- **Explain alternative selection rationale**
- **Note user approval** for substitutions

## Current Technology Decisions

### Debug Console: Firebug Lite → Eruda (Approved)
**Original Request**: Firebug Lite for PowerChart debugging
**Technical Barriers Encountered**:
- Multiple CDN failures (getfirebug.com, jsdelivr, cloudflare)
- API initialization timeouts in modern browsers
- Strict mode compatibility conflicts

**Alternative Selected**: Eruda DevTools
**Rationale**: 
- Modern, actively maintained (vs deprecated Firebug)
- Complete DevTools replacement (Console, DOM, Network, Resources)
- Better PowerChart compatibility
- Professional Material Design interface

**User Approval**: Granted after evaluation
**Status**: Successfully implemented with keyboard shortcuts

## Project Structure Standards

Following Mixed Projects (CCL + Web) structure per global CLAUDE.md:
```
patient-list-mpage-template/
├── README.md
├── CHANGELOG.md
├── CLAUDE.md          # This file - project-specific guidelines
├── docs/              # Documentation
│   ├── api/
│   ├── guides/
│   └── reference/
├── src/
│   ├── ccl/           # CCL programs
│   ├── web/           # Web application  
│   └── shared/
├── tests/
└── scripts/
```

## Development Guidelines

### CCL Development Reference
**ALWAYS consult before writing/modifying CCL queries:**
- **Data Model Reports**: `/Users/troyshelton/Projects/CCL_REFERENCE/Oracle Cerner - Millennium Data Model Reports/`
  - **Latest Version**: `2025401(2025.4.01) Models/` (2025.4.01)
  - **Use for:** Verify table schemas, field names, data types, JOIN relationships
  - **Prevents:** Compilation errors from non-existent fields
  - **Example:** Use to verify `pathway`, `orders`, `order_catalog` table structures
- **CCL Syntax Guides**: See global CLAUDE.md for complete reference list

### Debug System Usage
- **Production**: Debug hidden by default (`eruda.hide()`)
- **Development**: Use `Command+Shift+F` to toggle Eruda
- **PowerChart**: Cannot be blocked, perfect for restricted environments
- **Manual access**: `toggleEruda()`, `showEruda()`, `hideEruda()`

### Service Architecture
- **UserInfoService**: User authentication and environment
- **PatientListService**: Patient list management
- **PatientDataService**: Data processing and formatting
- **XMLCclRequestSimulator**: Mock data for development
- All services support debug mode integration

### Font Awesome Integration
- **Medical status indicators** with appropriate healthcare iconography
- **Color-coded backgrounds** for visual priority identification
- **Custom cell renderers** for Handsontable integration
- Status: Critical (red), Alert (orange), Stable (green)
- Acuity: Level 1-3 with thermometer icons

## Deployment Considerations

### Azure Storage Deployment

**⚠️ CRITICAL: Deployment Destination Verification Required**

**BEFORE deploying, Claude MUST:**
1. Show the full deployment command with source and destination paths
2. Get explicit user confirmation of the correct destination
3. Wait for "approved" before executing

**CAMC Sepsis Dashboard Deployment Paths:**

### **Deployment Architecture**

**CERT Environment (Development/Testing):**
- **Cerner CERT:** CCL programs compiled in Cerner CERT domain
- **Azure CERT:** Web assets deployed to Azure storage
  - Account: `ihazurestoragedev`
  - Destination: `$web/camc-sepsis-mpage/src`
  - Source: `/Users/troyshelton/Projects/vandalia/sepsis-dashboard/src/web`
  - URL: `https://ihazurestoragedev.z13.web.core.windows.net/camc-sepsis-mpage/src/index.html`
- **Purpose:** Quick development and Casey validation

**Production Environment:**
- **Cerner Production:** CCL programs compiled in Cerner production domain
- **Citrix I: Drive:** Web assets deployed to file share (NOT Azure)
  - See: CITRIX-DEPLOYMENT-GUIDE.md
- **Note:** Azure is NOT used in production, only CERT

**Deployment Command Template:**
```bash
az storage blob upload-batch \
  --account-name ihazurestoragedev \
  --destination '$web/camc-sepsis-mpage/src' \
  --source /Users/troyshelton/Projects/vandalia/sepsis-dashboard/src/web \
  --overwrite --auth-mode key
```

**Validation Gate Example:**
```
I'm about to deploy to Azure CERT:

Source:      /Users/troyshelton/Projects/vandalia/sepsis-dashboard/src/web
Destination: $web/camc-sepsis-mpage/src
Account:     ihazurestoragedev

⚠️ CRITICAL: Is this the correct destination?

Reply "approved" to deploy, or provide the correct destination.
```

**Why This Matters:**
- Wrong destination could overwrite production files
- Healthcare data safety requires verification
- Audit trail needs accurate deployment records
- Lesson learned: 2025-10-15 - deployed to wrong location twice before verification added

**Previous Deployment Methods:**
- **Automated deployment**: See [AZURE_DEPLOYMENT.md](AZURE_DEPLOYMENT.md) for complete guide
- **Command-line method**: Replaces manual Azure Storage Explorer drag-and-drop
- **Multi-account safety**: Built-in verification for dev/production environments

### PowerChart Environment
- **Header colors** chosen for PowerChart integration
- **Professional spacing** based on mobility MPage standards
- **Debug access** via keyboard shortcut when DevTools blocked
- **Error suppression** ensures clean end-user experience

### Production Checklist
- [ ] Deploy using Azure CLI method (see AZURE_DEPLOYMENT.md)
- [ ] Test patient list differentiation (List A vs List B)
- [ ] Verify Font Awesome icons and colors display correctly
- [ ] Confirm Eruda debugging works via Command+Shift+F
- [ ] Validate error suppression for end users
- [ ] Test in PowerChart environment if available

## Outstanding Work Tracking

**Active TODO Items**: Track using GitHub Issues
**Repository Issues**: https://github.com/troyshelton/sepsis-dashboard/issues

**Current Open Issues**:
- Issue #1: Define Priority Column Logic (stakeholder input needed)
- Issue #2: Verify Perfusion & Pressors Implementation
- Issue #3: Flatten /src/ Directory (Cerner Standard Structure)

**Archived Documentation**: `docs/archive/REQUESTOR_TODO_ARCHIVE.md` (historical reference only)

### Future Enhancements (Planned)
- [ ] **Cerner Standard Structure**: Flatten `/src/` directory to match Oracle Health patterns (Issue #3)
- [ ] **Flexible HTML Entry Points**: Add `test.html` for environment-specific testing
- [ ] **CCL Image Driver Integration**: Parameter-driven approach (directory + HTML file)
- [ ] **Priority Column Logic**: Define and implement High/Medium determination (Issue #1)

### Completed Enhancements
- [x] **Enhancement 3**: Add Normosol to fluids detection (v1.28.0-sepsis, 2025-10-06)
  - CCL v16: Added NORMOSOL and NORMASOL patterns
  - Verified with Casey's test patient: "Normosol-R PH 7.4 1,000 mL"
  - Complete SEP-1 bundle balanced crystalloid capture
- [x] **Volume Documentation**: Integrated into Fluids tooltips (v1.26.0-sepsis, 2025-09-24)
  - Shows total volume + individual administrations on hover
  - No separate column needed (consolidated UX)

## Working Base Project Protocol

### Reference Project
**Base**: Respiratory MPage (`/Users/troyshelton/Projects/claude-test/mhn-azure-resp-mpage/v2.0.0/resp-ther-mpage/`)
**Approach**: Copy working implementations and rename systematically

### Critical Process Failure Prevention
**When creating templates from working projects:**

#### 1. ALWAYS Copy Working Implementations
- **Copy exact CCL programs** - Preserve _memory_reply_string, parameter handling
- **Copy exact service implementations** - Proven patterns, API calls, error handling  
- **Copy exact communication layer** - SendCclRequest, XMLCclRequest usage
- **Preserve data structures** - JSON formats, record mappings, response parsing

#### 2. Systematic Renaming Only
```
Respiratory → Patient List Template:
1_mhn_mp_user_env_info_02.prg → 1_cust_mp_gen_user_info.prg
1_mhn_mp_get_patlist_02.prg → 1_cust_mp_gen_get_plists.prg
SendCclRequest.js → SendCclRequest.js (preserve implementation)
```

#### 3. Template Creation Failure Analysis
**What went wrong**: Created custom implementations instead of copying proven working code
**Root cause**: Misinterpreted "template" as "simplified version" vs "working copy"
**Impact**: Missing critical components (_memory_reply_string), broken functionality
**Prevention**: Copy first, rename second, modify minimally only with approval

### Lessons Learned
- **"Template" means working copy** - not simplified recreation
- **Proven patterns must be preserved** - especially in healthcare environments
- **Copy and rename workflow** - systematic approach prevents functionality loss
- **Test incrementally** - verify each copied component works

---
*Project Type: Patient List MPage Template*
*Base Project: Respiratory MPage v2.0.0*
*Integration: PowerChart Embedded*
*Debug System: Eruda DevTools*
*Tooltips: Tippy.js v6.3.7 with Auto-Positioning*
*Deployment: Dual (Azure CERT + Cerner Citrix I: Drive)*
*Version: v1.48.0-sepsis*
*Last Updated: 2025-12-08*

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
