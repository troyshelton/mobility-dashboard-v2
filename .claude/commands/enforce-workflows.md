---
description: Enforce mandatory healthcare production workflows (Deployment Verification, Code Review, Validation Gates)
---

Remind Claude of mandatory enforcement workflows and get explicit acknowledgment.

**Use this command when:**
- Starting a fresh session
- Claude skips deployment verification
- Claude deploys without showing code
- Claude rushes through validation gates
- You want to remind Claude of the rules

---

## Steps:

1. **Display Mandatory Workflows Summary:**

Show this message:

```
🛑 MANDATORY HEALTHCARE PRODUCTION ENFORCEMENT REMINDER

This is a HEALTHCARE PRODUCTION SYSTEM. The following workflows are REQUIRED:

1. Deployment Verification (DEPLOYMENT-VERIFICATION-WORKFLOW.md)
   ⚠️ Before EVERY deployment:
   - Show full command (source, destination, account)
   - Highlight what's being deployed
   - Ask: "Is this the correct destination?"
   - WAIT for "approved"

2. Code Review (CODE-REVIEW-WORKFLOW.md)
   ⚠️ Before deploying ANY code:
   - Show code changes (git diff or sections)
   - Explain what changed, why, how
   - Explain impact and testing
   - WAIT for user review and approval

3. Validation Gates (VALIDATION-GATE-PROTOCOL.md)
   ⚠️ At EVERY 🛑 TaskMaster subtask:
   - STOP immediately (do not auto-proceed)
   - Show summary of completed work
   - Show what needs validation
   - WAIT for user approval

Violation History (this project):
- 2025-12-08 (Issue #78):
  • Deployed 8+ times without verification
  • Deployed ~500 lines without code review
  • Rushed through validation gates without pausing

These workflows are NOT OPTIONAL.
```

2. **Get Explicit Acknowledgment:**

Ask Claude to type:

```
I acknowledge these mandatory workflows:
✅ Deployment Verification - Show command, wait for approval
✅ Code Review - Show code before deploying
✅ Validation Gates - Stop at 🛑, wait for approval

I will follow them without exception.
```

3. **Verify Acknowledgment:**

Claude must type the acknowledgment before continuing with ANY work.

If Claude proceeds without acknowledging → User says "/enforce-workflows" again.

---

**This command serves as a "reset button" for enforcement in any session.**
