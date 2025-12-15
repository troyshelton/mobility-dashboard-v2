# Future Topics for SEPSIS Dashboard

## Azure Blob Storage Direct Write (Option 3 Pattern)

**Context:** Emergency Med Calculator discussion (2025-12-09)

**Interest:** Direct browser → Azure Blob Storage API for persistent medication database updates

**Security Considerations for AI Agent + PHI:**

### Critical Questions to Answer:

1. **PHI Access & Transmission**
   - How does AI agent access patient data?
   - Where is PHI processed (client, server, AI service)?
   - How is PHI transmitted (encryption, anonymization)?
   - Data residency requirements (HIPAA, state laws)?

2. **Authentication & Authorization**
   - How to secure Azure API credentials in browser?
   - PowerChart user role-based access control?
   - Audit trail for AI agent actions?
   - Session management in Citrix environment?

3. **Data Protection**
   - PHI encryption at rest and in transit?
   - De-identification before AI analysis?
   - AI service BAA (Business Associate Agreement)?
   - Data retention and deletion policies?

4. **Regulatory Compliance**
   - HIPAA compliance for AI processing?
   - 21 CFR Part 11 (electronic records)?
   - State privacy laws (CCPA, etc.)?
   - Audit requirements for AI decisions?

5. **Azure Blob Storage Security**
   - SAS tokens vs API keys?
   - Token expiration and rotation?
   - IP restrictions for Citrix environment?
   - Blob-level access control?

### Potential Architecture Patterns:

**Pattern A: Proxy API (Most Secure)**
- Browser → Your API → Azure Blob Storage
- API validates user, logs actions, enforces security
- No credentials in browser
- Full audit trail

**Pattern B: SAS Tokens (Moderate Security)**
- Browser → Azure Blob (with short-lived SAS token)
- Token generated server-side per user/session
- Limited scope (write-only to specific blob)
- Expires quickly (15 min)

**Pattern C: Function App Middleware**
- Browser → Azure Function → Blob Storage
- Function validates request, sanitizes data
- Logs all writes for audit
- PowerChart user context passed via headers

### Next Steps:
- Consult with Cerner/Oracle Health security team
- Review HIPAA requirements for AI + PHI
- Evaluate AI service providers (Azure OpenAI BAA?)
- Design audit trail for regulatory compliance

**Reference Project:** Emergency Med Calculator (localStorage vs Azure deployment discussion)

**Created:** 2025-12-09
**Status:** Planning/Research Phase
