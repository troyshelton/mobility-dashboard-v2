# Project: Mobility Dashboard

**Current Version:** v1.0.0-mobility (v1.1.0 in development)
**Date:** 2025-12-15
**Project Type:** Healthcare Application ⚠️
**Enforcement:** Mandatory Workflows Required

---

## Project Overview

Mobility assessment dashboard for inpatient floors with patient list integration for Oracle Health Cerner MPages.

**Clinical Purpose:** Fall risk assessment, mobility device tracking, PT/OT intervention monitoring
**Patient Impact:** Reduces falls, improves mobility outcomes, supports rehabilitation goals
**Compliance:** HIPAA, Patient Safety Standards, Clinical Quality Measures

---

# 🛑 MANDATORY HEALTHCARE WORKFLOW ENFORCEMENT 🛑

**This project is a HEALTHCARE APPLICATION.** The following workflows are MANDATORY:

## 1. Deployment Verification (NO EXCEPTIONS)

**Before EVERY deployment command:**
- Show full deployment command (source, destination, account)
- Highlight what's being deployed and where
- Ask: "⚠️ CRITICAL: Is this the correct destination?"
- WAIT for "approved" before executing

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/DEPLOYMENT-VERIFICATION-WORKFLOW.md`

---

## 2. Code Review (NO EXCEPTIONS)

**Before deploying ANY code:**
- Show code changes (git diff or code sections)
- Explain what changed, why, and how it works
- Explain impact and testing
- Wait for user review and approval

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/CODE-REVIEW-WORKFLOW.md`

---

## 3. Validation Gate Protocol (NO EXCEPTIONS)

**At EVERY 🛑 VALIDATION subtask:**
- STOP immediately (do not auto-proceed)
- Show summary of completed work
- Show what needs validation
- WAIT for user approval before continuing

**See:** `/Users/troyshelton/Projects/.standards/WORKFLOWS/VALIDATION-GATE-PROTOCOL.md`

---

**These workflows are NOT optional for healthcare applications.**

---

## Current Development

**Active Feature:** Date Navigator for Temporal Mobility Data
- **Issue:** #1
- **Branch:** feature/v1.1.0-date-navigator
- **Progress:** 4/10 subtasks (40%)
- **Status:** Paused at validation gate #1 (passed)
- **Next:** Subtask 1.5 (CCL development)

---

## Technology Stack

- **Frontend:** HTML with Tailwind-style CSS
- **JavaScript:** Vanilla JavaScript with service architecture
- **Data Grid:** Handsontable v15.2.0
- **Debug System:** Eruda DevTools
- **Backend:** Cerner CCL programs (with simulator mode)
- **Icons:** Font Awesome 6.5.1

---

## Git Workflow

**For ALL features, enhancements, or bug fixes:**

1. ✅ Create GitHub Issue FIRST
2. ✅ Create feature branch (feature/vX.Y.Z-description)
3. ✅ Use TaskMaster for tracking
4. ✅ Implement with validation gates
5. ✅ Update documentation (CHANGELOG, README)
6. ⏸️ Create Pull Request (when complete)
7. ⏸️ Code review and approval
8. ⏸️ Merge to main
9. ⏸️ Tag release (vX.Y.Z)
10. ⏸️ Close issue

**See:** `/Users/troyshelton/Projects/.standards/GIT-WORKFLOW.md`

---

## Documentation Sync

**Before commits with version changes:**

All THREE files must be updated:
1. CHANGELOG.md - Add version entry
2. README.md - Update version and date
3. CLAUDE-PROJECT.md (this file) - Update version and date

**See:** `/Users/troyshelton/Projects/.standards/DOCUMENTATION-SYNC-PROTOCOL.md`

---

## Repository

**GitHub:** https://github.com/troyshelton/mobility-dashboard-v2

**Local:** `/Users/troyshelton/Projects/vandalia/mobility-dashboard/`

---

## Development Standards

**See global standards:**
- `/Users/troyshelton/Projects/CLAUDE.md` - Global development guidelines
- `/Users/troyshelton/Projects/.standards/` - All workflow standards

---

*Healthcare Application - Mandatory Workflows Enforced*
*Last Updated: 2025-12-15*
*Version: v1.0.0-mobility (v1.1.0 in development)*

---

## TaskMaster Integration

**For TaskMaster commands and usage, see:** `.taskmaster/CLAUDE.md`
