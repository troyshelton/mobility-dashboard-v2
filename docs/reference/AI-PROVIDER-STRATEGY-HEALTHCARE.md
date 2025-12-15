# AI Provider Strategy for Healthcare Development

**Created:** 2025-10-17
**Purpose:** Strategic analysis of AI providers for healthcare application development
**Scope:** Proof of Concept planning for AI agents with sepsis dashboard integration

---

## Executive Summary

This document outlines AI provider options for healthcare development, focusing on:
1. **Oracle Cloud Infrastructure (OCI)** - Vandalia Health migration target
2. **Azure OpenAI** - Mountain Health Network current infrastructure
3. **Ollama** - Free, private proof of concept platform
4. **Anthropic Claude** - Current development tool (via Claude Code)

**Key Finding:** All major providers offer HIPAA BAA compliance, with varying implementation paths.

---

## Table of Contents

1. [Oracle Cloud Infrastructure (OCI)](#oracle-cloud-infrastructure-oci)
2. [Azure OpenAI](#azure-openai)
3. [Ollama (Local/Private)](#ollama-localprivate)
4. [Anthropic Claude](#anthropic-claude)
5. [Healthcare Compliance Summary](#healthcare-compliance-summary)
6. [Proof of Concept Plan](#proof-of-concept-plan)
7. [Strategic Recommendations](#strategic-recommendations)

---

## Oracle Cloud Infrastructure (OCI)

### AI Services Overview (2025)

**OCI Generative AI Service** - Fully managed service for enterprise AI

**Foundation Models Available:**
- **Cohere** (primary partner) - Enterprise-focused LLM
- **Meta Llama** - Open source, high performance
- **Google Gemini** - Latest Google AI partnership (2025)
- **Mistral AI** - European open source models
- **Hugging Face** - Custom model integration

### Healthcare Compliance

✅ **HIPAA-Assessed**: OCI Generative AI on official HIPAA services list
✅ **BAA Available**: Standard Business Associate Agreements for customers
✅ **Military-Grade Security**: Oracle Health Clinical AI Agent built on OCI
✅ **Compliance Certifications**: HIPAA + GDPR + SOC 2 + ISO certified
✅ **Data Residency**: Regional deployment options for compliance

### Key Features

**Enterprise Benefits:**
- Fully managed service with API access
- Custom model fine-tuning with private datasets
- NVIDIA GPU infrastructure for training
- Integration with Oracle Health EHR systems
- **Agent Hub** (beta November 2025) - AI agent creation platform

**Cost Model:**
- Pay-per-use (token-based pricing)
- Enterprise billing through OCI account
- Centralized cost tracking
- Volume discounts available

### Best For

✅ **Vandalia Health** - Aligns with OCI migration strategy
✅ Organizations planning Oracle Health EHR adoption
✅ Enterprise deployments requiring HIPAA compliance
✅ Long-term healthcare IT infrastructure alignment

### Implementation Timeline

**Prerequisites:**
- Active OCI account
- OCI CLI installed and configured
- BAA signed with Oracle

**Estimated Setup:** 2-3 weeks after OCI migration

---

## Azure OpenAI

### Service Overview

**Azure OpenAI Service** - Microsoft's enterprise AI platform offering OpenAI models (GPT-4, GPT-3.5, etc.) with Azure security and compliance.

### Healthcare Compliance

✅ **HIPAA Compliant**: Full HIPAA compliance built-in
✅ **BAA Included**: Business Associate Agreement included with Azure subscription
✅ **PHI Protection**: Data stays within your Azure tenant
✅ **Enterprise Security**: SOC 2, ISO, FedRAMP certified
✅ **Private Endpoints**: Network isolation for sensitive data

### Key Features

**Enterprise Advantages:**
- **Data Privacy**: Your data never leaves Azure environment
- **Audit Trails**: Complete compliance logging
- **Regional Deployment**: Data residency requirements met
- **Access Control**: Azure Active Directory integration
- **Cost Management**: Centralized billing through Azure

**AI Models Available:**
- GPT-4 Turbo (latest, most capable)
- GPT-4 (standard)
- GPT-3.5 Turbo (cost-effective)
- Embeddings models
- DALL-E (image generation)

### Cost Model

**Pay-per-use pricing:**
- GPT-4: ~$0.03-0.06 per 1K tokens
- GPT-3.5: ~$0.001-0.002 per 1K tokens
- Centralized Azure billing
- Usage quotas and limits configurable

### Best For

✅ **Mountain Health Network** - Current Azure infrastructure
✅ Organizations with existing Azure subscriptions
✅ Teams requiring immediate HIPAA compliance
✅ Microsoft-centric IT environments

### Implementation Status

**Mountain Health Network:**
- ✅ Azure account active (your credentials exist)
- ✅ BAA already in place (Azure subscription includes it)
- ✅ Ready for immediate AI integration
- ⏱️ Estimated setup: 1-2 weeks

**Key Advantage:** **FASTEST PATH TO HIPAA-COMPLIANT AI** - No additional BAA negotiation needed!

---

## Ollama (Local/Private)

### Overview

**Ollama** - Run AI models locally on your Mac, completely free and private. Perfect for development, testing, and proof of concepts.

### Healthcare Compliance

✅ **NO HIPAA CONCERNS** - Data never leaves your Mac
✅ **100% Private** - No internet transmission required
✅ **No BAA Needed** - Local processing means no third-party involvement
✅ **Audit-Safe** - No external API calls to log
✅ **Development-Friendly** - Test with real-like data without risk

### Key Features

**Technical Advantages:**
- **Completely Free** - No API costs, ever
- **Offline Capable** - Works without internet connection
- **Unlimited Usage** - No token limits or rate limiting
- **Multiple Models** - Switch between models instantly
- **Fast Iteration** - No API latency for testing

**Available Models:**
- Llama 3.2 (Meta - latest, 3B-70B parameters)
- Code Llama (Meta - code-focused)
- Mistral (Mistral AI - European)
- Gemma (Google - lightweight)
- Custom models (import from Hugging Face)

### Installation (5 minutes)

```bash
# Install Ollama via Homebrew
brew install ollama

# Start Ollama server (runs in background)
ollama serve

# Download models (one-time, ~4GB each)
ollama pull llama3.2:latest        # General purpose, fast
ollama pull codellama:latest       # Code generation/analysis
ollama pull mistral:latest         # Alternative model

# Test installation
ollama run llama3.2 "Explain the SEP-1 sepsis bundle"
```

### Integration with TaskMaster

```bash
# Configure TaskMaster to use Ollama
task-master models --ollama

# Or manually edit .taskmaster/config.json:
{
  "models": {
    "main": {
      "provider": "ollama",
      "modelId": "llama3.2"
    }
  }
}
```

### Performance Characteristics

**Response Time:**
- M1/M2/M3 Mac: 30-60 seconds per response
- Intel Mac: 60-120 seconds per response

**Quality:**
- 70-80% of Claude/GPT-4 quality
- Very good for development and testing
- Adequate for most POC scenarios

**Limitations:**
- ❌ Slower than cloud APIs (30-60s vs 2-5s)
- ❌ Lower quality than GPT-4/Claude
- ❌ Requires decent Mac hardware (8GB+ RAM recommended)
- ✅ BUT: Perfect for development, POC, testing

### Best For

✅ **Proof of Concepts** - Test AI agents safely
✅ **Development/Testing** - Rapid iteration without costs
✅ **Learning/Experimentation** - Try different models freely
✅ **Privacy-Critical Work** - Local processing only
✅ **Budget-Conscious Projects** - Zero cost solution

### Recommended Use Cases

**Perfect for:**
1. AI agent development (sepsis dashboard queries)
2. JSON response parsing and analysis
3. Algorithm validation
4. Load testing without API costs
5. Training and learning AI integration

**Not recommended for:**
- Production deployments
- Real-time user-facing applications
- High-volume request processing
- Mission-critical accuracy requirements

---

## Anthropic Claude

### Service Overview

**Anthropic Claude** - Advanced AI assistant (what powers Claude Code). Available via direct API or cloud provider integrations.

### Healthcare Compliance

⚠️ **HIPAA BAA Available with Restrictions**

**Direct API (anthropic.com):**
- ✅ BAA offered for API-only usage
- ✅ Zero data retention agreements required
- ❌ NOT covered: Claude.ai web interface, Workbench, Console
- ❌ Limited features: No web search, batch processing, or file uploads with BAA

**Via Cloud Providers (Recommended for Healthcare):**
- ✅ **AWS Bedrock** - Claude with instant BAA
- ✅ **Google Vertex AI** - Claude with instant BAA
- ✅ **Azure OpenAI** - May include Claude in future

### How to Get BAA (Direct API)

**Process:**
1. Contact Anthropic sales team
2. Submit HIPAA use case for review
3. Sign zero data retention agreement
4. Configure API with HIPAA-compliant settings
5. Use first-party API only (no web interfaces)

**Timeline:** 2-4 weeks for review and approval

### Key Features

**Technical Advantages:**
- Best-in-class reasoning and analysis
- Long context window (200K tokens)
- Excellent for complex medical logic
- Strong code generation capabilities
- Multi-turn conversation handling

**Current Usage:**
- Powers Claude Code (your development environment)
- Used for this AI provider analysis
- Proven for technical documentation

### Cost Model

**Direct API pricing:**
- Claude 3.7 Sonnet: ~$3-15 per 1M tokens
- Pay-per-use (no minimums)
- Volume discounts available

**Via AWS Bedrock:**
- Similar pricing + AWS infrastructure costs
- BAA included with AWS account

### Best For

✅ Development with Claude Code (current usage)
✅ Complex reasoning tasks
✅ Technical documentation generation
⚠️ Healthcare production (requires BAA setup)

### Recommendation

**For healthcare production:**
- Consider **AWS Bedrock** (Claude + instant BAA) instead of direct API
- Faster compliance path
- Integrated with AWS infrastructure

**For development:**
- Continue using Claude Code (current usage)
- No PHI in development prompts
- Switch to HIPAA-compliant path for production

---

## Healthcare Compliance Summary

### BAA (Business Associate Agreement) Requirements

**When BAA is REQUIRED:**
- ✅ Processing Protected Health Information (PHI)
- ✅ Production healthcare applications
- ✅ Consulting work with client PHI
- ✅ Any AI analysis of real patient data

**When BAA is NOT required:**
- ❌ Development with mock data only
- ❌ Local processing (Ollama)
- ❌ Public/de-identified datasets
- ❌ Internal tools with no PHI

### Provider Comparison

| Provider | BAA Available | Setup Time | Best For |
|----------|---------------|------------|----------|
| **Oracle OCI** | ✅ Yes, included | 2-3 weeks | Vandalia Health (OCI migration) |
| **Azure OpenAI** | ✅ Yes, included | 1-2 weeks | Mountain Health Network (Azure) |
| **Ollama** | N/A (local) | 5 minutes | POC, development, testing |
| **Anthropic Direct** | ⚠️ Yes, restricted | 2-4 weeks | Advanced reasoning tasks |
| **AWS Bedrock** | ✅ Yes, included | 1-2 weeks | Multi-provider flexibility |

### Account-Specific Recommendations

#### **Mountain Health Network Account**
**Current Infrastructure:** Azure
**Best Path:** Azure OpenAI
**Rationale:**
- ✅ BAA already in place (Azure subscription)
- ✅ Fastest implementation (1-2 weeks)
- ✅ Existing Azure expertise
- ✅ No additional infrastructure changes

**Action Items:**
1. Confirm Azure subscription includes AI services
2. Enable Azure OpenAI in existing resource group
3. Configure HIPAA-compliant endpoints
4. Deploy AI agent POC

#### **Vandalia Health (Consulting)**
**Migration Target:** Oracle Cloud Infrastructure
**Best Path:** Oracle OCI Generative AI
**Rationale:**
- ✅ Aligns with infrastructure migration
- ✅ Long-term strategy alignment
- ✅ Oracle Health EHR integration potential
- ✅ Centralized platform (infrastructure + AI)

**Action Items:**
1. Complete OCI migration planning
2. Include AI services in OCI architecture
3. Sign BAA with Oracle
4. Plan parallel deployment (Azure → OCI)

#### **Personal Consulting Entity**
**Requirements:** Handle client PHI compliantly
**Best Path:** Dual strategy
**Rationale:**
- Development: Ollama (free, private, safe)
- Production: Match client infrastructure
  - Azure clients → Azure OpenAI
  - OCI clients → OCI Generative AI

**Action Items:**
1. Install Ollama for development/POC
2. Maintain separate development/production environments
3. Obtain BAAs for production deployments
4. Document compliance procedures

---

## Proof of Concept Plan

### Overview

**Goal:** Validate AI agent capability to answer questions about sepsis dashboard data (JSON responses from CCL programs).

**Success Criteria:**
- ✅ AI agent understands SEP-1 bundle logic
- ✅ Accurate interpretation of patient status
- ✅ Bundle completion determination
- ✅ Response time acceptable (<60 seconds for POC)
- ✅ Cost feasibility for production scale

### Phase 1: Ollama (Local/Private) - Week 1

**Objective:** Prove AI agent concept with zero cost and zero risk

**Setup Tasks:**
1. Install Ollama on Mac (5 minutes)
2. Download Llama 3.2 model (~4GB, 10 minutes)
3. Test basic functionality
4. Configure development environment

**POC Implementation:**

```bash
# 1. Install Ollama
brew install ollama

# 2. Start Ollama server
ollama serve

# 3. Download model
ollama pull llama3.2:latest

# 4. Test with sepsis dashboard data
ollama run llama3.2 "Given this patient data from our sepsis dashboard:
{
  'PATIENT_NAME': 'TEST, PATIENT A',
  'LACTATE_ORDERED': 'Y',
  'BLOOD_CULTURES_ORDERED': 'Y',
  'ANTIBIOTICS_ORDERED': 'Y',
  'FLUIDS_ORDERED': 'Y',
  'TIME_ZERO': '2025-10-17 08:00',
  'CURRENT_TIME': '2025-10-17 10:30'
}

Question: Has this patient completed the SEP-1 3-hour bundle requirements?"
```

**Test Scenarios:**
1. **Bundle completion status** - All elements complete vs incomplete
2. **Missing elements identification** - Which elements are pending
3. **Timing analysis** - Time remaining until 3-hour deadline
4. **Conditional logic** - Fluids N/A when lactate <4.0
5. **Blood culture status** - Collected vs Completed distinction

**Deliverables:**
- [ ] Working Ollama installation
- [ ] Documented response times (avg, min, max)
- [ ] Quality assessment (accuracy vs expected answers)
- [ ] Integration code sample (Node.js/Python)
- [ ] Cost analysis: $0 (confirmed)

**Expected Results:**
- Response time: 30-60 seconds
- Accuracy: 70-80% vs Claude baseline
- Cost: $0
- Privacy: 100% (no data transmission)

### Phase 2: Oracle OCI Research - Week 2

**Objective:** Understand OCI Generative AI architecture and implementation path

**Research Tasks:**

**1. OCI Documentation Review**
- [ ] Read OCI Generative AI service documentation
- [ ] Review available foundation models (Cohere, Llama, Gemini, Mistral)
- [ ] Understand pricing model and cost estimations
- [ ] Study HIPAA compliance configuration
- [ ] Review API authentication methods

**2. Architecture Planning**
- [ ] Design OCI AI integration with sepsis dashboard
- [ ] Plan CCL → OCI AI data flow
- [ ] Identify security requirements (VPN, private endpoints)
- [ ] Determine deployment architecture (region, compartments)
- [ ] Plan monitoring and logging strategy

**3. Cost Analysis**
- [ ] Model pricing comparison (Cohere vs Llama vs Gemini)
- [ ] Estimate token usage for typical queries
- [ ] Calculate monthly costs at various volumes:
  - Low: 1,000 queries/month
  - Medium: 10,000 queries/month
  - High: 100,000 queries/month
- [ ] Compare to Azure OpenAI pricing

**4. Compliance Verification**
- [ ] Confirm OCI Generative AI on HIPAA services list
- [ ] Review BAA terms and conditions
- [ ] Identify required security configurations
- [ ] Document audit logging requirements
- [ ] Verify data residency options

**5. POC Setup Planning (if OCI account available)**
- [ ] OCI CLI installation and configuration
- [ ] Test API authentication
- [ ] Deploy simple "Hello World" AI query
- [ ] Validate response time and quality
- [ ] Test with mock sepsis dashboard JSON

**Deliverables:**
- [ ] OCI Generative AI architecture document
- [ ] Cost comparison spreadsheet (OCI vs Azure vs Anthropic)
- [ ] Implementation timeline estimate
- [ ] Security and compliance checklist
- [ ] Integration code samples (if POC deployed)

**Optional (if OCI account active):**
```bash
# OCI CLI setup
brew install oci-cli
oci setup config

# Test OCI Generative AI
oci generative-ai model list --compartment-id <id>

# Deploy test query
oci generative-ai inference create \
  --compartment-id <id> \
  --model-id <cohere-model-id> \
  --prompt "Explain SEP-1 bundle requirements"
```

### Phase 3: Azure OpenAI (Mountain Health Network) - Week 3

**Objective:** Validate Azure OpenAI as production-ready path for Mountain Health Network

**Prerequisites:**
- Mountain Health Network Azure account access (you have credentials)
- Confirm Azure subscription includes AI services
- Verify BAA is in place (should be automatic)

**Setup Tasks:**

**1. Azure Environment Validation**
```bash
# Install Azure CLI (if not already installed)
brew install azure-cli

# Login with Mountain Health Network credentials
az login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "<Mountain-Health-Subscription-ID>"

# Check if Azure OpenAI available
az cognitiveservices account list-kinds --output table | grep OpenAI
```

**2. Azure OpenAI Resource Creation**
```bash
# Create resource group (if needed)
az group create --name rg-ai-sepsis-poc --location eastus

# Create Azure OpenAI resource
az cognitiveservices account create \
  --name openai-sepsis-poc \
  --resource-group rg-ai-sepsis-poc \
  --kind OpenAI \
  --sku S0 \
  --location eastus \
  --custom-domain openai-sepsis-poc

# Deploy GPT-4 model
az cognitiveservices account deployment create \
  --name openai-sepsis-poc \
  --resource-group rg-ai-sepsis-poc \
  --deployment-name gpt4-deployment \
  --model-name gpt-4 \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name "Standard"
```

**3. POC Implementation**

**Test Script (Node.js example):**
```javascript
// azure-openai-test.js
const { OpenAIClient, AzureKeyCredential } = require("@azure/openai");

const endpoint = "https://openai-sepsis-poc.openai.azure.com/";
const apiKey = process.env.AZURE_OPENAI_KEY;
const deploymentId = "gpt4-deployment";

const client = new OpenAIClient(endpoint, new AzureKeyCredential(apiKey));

async function testSepsisBundleQuery() {
  const patientData = {
    PATIENT_NAME: 'TEST, PATIENT A',
    LACTATE_ORDERED: 'Y',
    BLOOD_CULTURES_ORDERED: 'Y',
    ANTIBIOTICS_ORDERED: 'Y',
    FLUIDS_ORDERED: 'Y',
    TIME_ZERO: '2025-10-17 08:00',
    CURRENT_TIME: '2025-10-17 10:30'
  };

  const messages = [
    { role: "system", content: "You are a clinical AI assistant specializing in sepsis care." },
    { role: "user", content: `Given this patient data: ${JSON.stringify(patientData)}

    Question: Has this patient completed the SEP-1 3-hour bundle requirements?
    Provide a clear yes/no answer with explanation.` }
  ];

  const result = await client.getChatCompletions(deploymentId, messages);
  console.log(result.choices[0].message.content);
}

testSepsisBundleQuery();
```

**4. Test Scenarios (Same as Phase 1)**
- [ ] Bundle completion status
- [ ] Missing elements identification
- [ ] Timing analysis
- [ ] Conditional logic (Fluids N/A)
- [ ] Blood culture status interpretation

**5. Performance Measurement**
- [ ] Response time (target: <5 seconds)
- [ ] Token usage per query
- [ ] Cost per query
- [ ] Accuracy vs expected results
- [ ] Compare to Ollama (Phase 1) results

**Deliverables:**
- [ ] Azure OpenAI resource deployed
- [ ] Working integration code
- [ ] Performance metrics documented
- [ ] Cost analysis (actual API costs)
- [ ] Comparison report (Azure vs Ollama)
- [ ] Recommendation for Mountain Health Network production deployment

**Expected Results:**
- Response time: 2-5 seconds (10x faster than Ollama)
- Accuracy: 90-95% (GPT-4 quality)
- Cost: ~$0.01-0.05 per query (depending on token usage)
- BAA: ✅ Already in place with Azure subscription

### Phase 4: Production Deployment Planning - Week 4

**Objective:** Design production-ready AI agent architecture for both organizations

**Architecture Decisions:**

**For Mountain Health Network (Azure):**
```
Sepsis Dashboard (PowerChart)
    ↓
CCL Program (1_cust_mp_sep_get_pdata_*.prg)
    ↓
JSON Response (_memory_reply_string)
    ↓
Azure OpenAI API (via secure endpoint)
    ↓
AI Agent Response (bundle status, recommendations)
    ↓
Display in Dashboard (tooltip, alert, or dedicated panel)
```

**For Vandalia Health (OCI - Future):**
```
Sepsis Dashboard (PowerChart)
    ↓
CCL Program
    ↓
JSON Response
    ↓
OCI Generative AI Service (Cohere/Llama/Gemini)
    ↓
AI Agent Response
    ↓
Display in Dashboard
```

**Security Considerations:**
- [ ] Private endpoints only (no public internet)
- [ ] VPN/ExpressRoute for Azure (VPN/FastConnect for OCI)
- [ ] Audit logging enabled
- [ ] PHI encryption in transit (TLS 1.2+)
- [ ] PHI encryption at rest
- [ ] Access controls (RBAC)
- [ ] Rate limiting and quotas

**Implementation Components:**

**1. Backend Service (Node.js/Python)**
```javascript
// sepsis-ai-agent-service.js
class SepsisAIAgent {
  constructor(provider, credentials) {
    // Initialize Azure OpenAI or OCI Generative AI client
  }

  async analyzeBundleStatus(patientData) {
    // Parse CCL JSON response
    // Construct AI prompt
    // Call AI provider API
    // Parse and validate response
    // Return structured result
  }

  async identifyMissingElements(patientData) {
    // Determine which bundle elements are incomplete
  }

  async calculateTimeRemaining(patientData) {
    // Calculate time until 3-hour deadline
  }

  async provideRecommendations(patientData) {
    // Suggest next actions for clinical staff
  }
}
```

**2. API Endpoints**
- `POST /api/sepsis/bundle-status` - Check bundle completion
- `POST /api/sepsis/missing-elements` - Identify gaps
- `POST /api/sepsis/time-analysis` - Time remaining calculation
- `POST /api/sepsis/recommendations` - Clinical action suggestions

**3. Frontend Integration**
```javascript
// In sepsis dashboard main.js
async function getAIBundleAnalysis(patientData) {
  const response = await fetch('/api/sepsis/bundle-status', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(patientData)
  });
  const analysis = await response.json();
  displayAIInsights(analysis);
}
```

**Deliverables:**
- [ ] Production architecture document
- [ ] Security implementation plan
- [ ] Cost estimates for production scale
- [ ] Deployment timeline
- [ ] Rollout strategy (pilot → full deployment)
- [ ] Monitoring and alerting plan

---

## Strategic Recommendations

### Short Term (Next 2 weeks) - Immediate Actions

#### **1. Install Ollama TODAY**
**Why:** Free, private, zero-risk POC platform
**Action:**
```bash
brew install ollama
ollama serve
ollama pull llama3.2:latest
```
**Expected time:** 15 minutes
**Benefit:** Start testing AI agent immediately

#### **2. Test with Mock Sepsis Data**
**Why:** Validate AI understands SEP-1 bundle logic
**Action:** Create test JSON responses from CCL simulator
**Expected time:** 2-3 hours
**Benefit:** Proof of concept without any infrastructure changes

#### **3. Document POC Results**
**Why:** Evidence for stakeholder discussions
**Action:** Create comparison table (Ollama vs expected results)
**Expected time:** 1 hour
**Benefit:** Data-driven decision making

### Medium Term (1-3 months) - Infrastructure Planning

#### **For Mountain Health Network**

**Recommendation: Azure OpenAI (FASTEST PATH)**

**Rationale:**
- ✅ Already have Azure credentials
- ✅ BAA included with Azure subscription
- ✅ Fastest compliance path (1-2 weeks vs 2-3 months)
- ✅ Proven Microsoft healthcare integrations
- ✅ No infrastructure migration needed

**Action Plan:**
1. **Week 1:** Validate Azure subscription includes AI services
2. **Week 2:** Deploy Azure OpenAI resource in test environment
3. **Week 3:** Implement POC integration with sepsis dashboard
4. **Week 4:** Security review and compliance validation
5. **Week 5-6:** Pilot deployment with select users
6. **Week 7-8:** Production rollout

**Cost Estimate:**
- Development: ~$50-100 (testing with mock data)
- Pilot: ~$200-500/month (limited users)
- Production: ~$1,000-3,000/month (depending on query volume)

#### **For Vandalia Health**

**Recommendation: Oracle OCI Generative AI (STRATEGIC ALIGNMENT)**

**Rationale:**
- ✅ Aligns with OCI migration strategy
- ✅ Long-term platform consistency
- ✅ Oracle Health EHR integration potential
- ✅ Consolidated vendor relationship

**Action Plan:**
1. **Month 1:** Complete OCI migration (infrastructure)
2. **Month 2:** Deploy OCI Generative AI service
3. **Month 3:** Sign BAA and configure HIPAA compliance
4. **Month 4:** Implement AI agent integration
5. **Month 5:** Pilot deployment
6. **Month 6:** Production rollout

**Cost Estimate:**
- Development: $0 (use Ollama for POC)
- Pilot: ~$300-700/month (OCI pricing typically 30-50% lower than Azure)
- Production: ~$1,500-4,000/month (depending on model and volume)

#### **For Personal Consulting Entity**

**Recommendation: Dual Strategy**

**Development Environment:**
- **Use Ollama** - Free, private, safe for all development
- No BAA needed (local processing)
- Test with realistic mock data
- Zero cost for experimentation

**Production Environment:**
- **Match client infrastructure:**
  - Azure clients → Azure OpenAI
  - OCI clients → OCI Generative AI
- Obtain BAAs for each production deployment
- Separate billing per client
- Document compliance procedures

### Long Term (6-12 months) - Production Scale

#### **Phase 1: Pilot Deployment (Month 1-3)**
- Deploy AI agent for 1-2 clinical units
- Monitor usage patterns and costs
- Collect clinician feedback
- Measure impact on bundle compliance
- Refine AI prompts and logic

**Success Metrics:**
- Response time <5 seconds (95th percentile)
- Accuracy >90% vs expert review
- User satisfaction >4.0/5.0
- Bundle compliance improvement >10%
- Cost per query <$0.10

#### **Phase 2: Expanded Rollout (Month 4-6)**
- Deploy to all sepsis-monitoring units
- Integrate with EHR alerts and workflows
- Add advanced features:
  - Predictive risk scoring
  - Proactive recommendations
  - Trend analysis and reporting
- Scale infrastructure as needed

**Success Metrics:**
- System uptime >99.9%
- Query volume 1,000+ per day
- Bundle compliance improvement >20%
- Mortality reduction (track over time)
- Cost efficiency maintained

#### **Phase 3: Advanced Features (Month 7-12)**
- Natural language querying (clinicians ask free-form questions)
- Multi-patient prioritization (which patients need attention first)
- Integration with rapid response team workflows
- Outcomes tracking and analytics dashboard
- Continuous learning from outcomes data

### Critical Success Factors

#### **1. Start Small, Prove Value**
- Begin with Ollama POC (free, fast, low-risk)
- Validate AI understands clinical logic
- Get stakeholder buy-in with working demo

#### **2. Follow Infrastructure**
- Mountain Health Network → Azure (they're already there)
- Vandalia Health → OCI (aligns with migration)
- Don't force infrastructure changes for AI

#### **3. Prioritize Compliance**
- Never use production PHI without BAA
- Always use mock data for development/testing
- Document all compliance procedures
- Regular security audits

#### **4. Measure and Optimize**
- Track response times, costs, accuracy
- Collect clinician feedback continuously
- Iterate on AI prompts and logic
- Demonstrate ROI to stakeholders

---

## Next Steps - Immediate Actions

### This Week (Week of October 17, 2025)

**Day 1-2: Ollama Setup and Testing**
- [ ] Install Ollama on Mac
- [ ] Download Llama 3.2 model
- [ ] Create test script with mock sepsis data
- [ ] Document response times and quality
- [ ] Share results with stakeholders

**Day 3-4: OCI Research**
- [ ] Review OCI Generative AI documentation
- [ ] Create architecture diagram (OCI integration)
- [ ] Compare pricing (OCI vs Azure vs Anthropic)
- [ ] Document findings in separate report

**Day 5: Azure Validation (if time permits)**
- [ ] Login to Mountain Health Network Azure account
- [ ] Verify Azure OpenAI service availability
- [ ] Confirm BAA is in place
- [ ] Document current Azure configuration

### Next Week (Week of October 24, 2025)

**Mountain Health Network - Azure POC**
- [ ] Deploy Azure OpenAI resource (test environment)
- [ ] Implement integration code
- [ ] Test with mock sepsis dashboard data
- [ ] Compare results to Ollama POC
- [ ] Create recommendation document for production

**Vandalia Health - OCI Planning**
- [ ] Schedule OCI migration timeline discussion
- [ ] Identify OCI account contacts
- [ ] Plan AI services inclusion in migration
- [ ] Create phased deployment timeline

### Month 2 (November 2025)

**Production Planning**
- [ ] Architecture finalization
- [ ] Security review
- [ ] Cost approval
- [ ] Pilot unit selection
- [ ] Training materials creation

---

## Cost Summary

### Development/POC Costs

| Phase | Tool | Cost | Timeline |
|-------|------|------|----------|
| Phase 1 | Ollama (local) | **$0** | Week 1 |
| Phase 2 | OCI Research | **$0** | Week 2 |
| Phase 3 | Azure OpenAI (testing) | ~$50-100 | Week 3 |
| **Total POC** | | **$50-100** | **3 weeks** |

### Production Costs (Monthly Estimates)

**Low Volume** (1,000 queries/month):
- Azure OpenAI: ~$10-30/month
- OCI Generative AI: ~$7-20/month
- Ollama: $0 (but not production-ready)

**Medium Volume** (10,000 queries/month):
- Azure OpenAI: ~$100-300/month
- OCI Generative AI: ~$70-200/month

**High Volume** (100,000 queries/month):
- Azure OpenAI: ~$1,000-3,000/month
- OCI Generative AI: ~$700-2,000/month

**Note:** Actual costs depend on:
- Model choice (GPT-4 vs GPT-3.5, Cohere vs Llama)
- Token usage per query (prompt + response length)
- Fine-tuning requirements
- Infrastructure costs (networking, storage, compute)

---

## Conclusion

**Key Takeaways:**

1. **Multiple HIPAA-Compliant Paths Available**
   - Oracle OCI, Azure OpenAI, AWS Bedrock all offer BAAs
   - Choose based on existing infrastructure

2. **Ollama = Perfect POC Platform**
   - Free, private, zero-risk
   - Test AI agent concept immediately
   - No infrastructure changes needed

3. **Strategic Alignment Matters**
   - Mountain Health Network → Azure (already there)
   - Vandalia Health → OCI (migration target)
   - Match AI platform to infrastructure strategy

4. **Start Small, Scale Fast**
   - Week 1: Ollama POC ($0)
   - Week 2-3: OCI research + Azure validation
   - Month 2-3: Production pilot
   - Month 6+: Full deployment

**Recommendation Priority:**

1. ⭐ **START THIS WEEK:** Install Ollama, test with mock sepsis data
2. ⭐ **WEEK 2:** Research OCI Generative AI architecture and costs
3. ⭐ **WEEK 3:** Validate Azure OpenAI for Mountain Health Network
4. **MONTH 2:** Deploy production pilot on appropriate platform

**Final Thought:** The fastest path to value is starting with Ollama POC today, while researching long-term production platforms (OCI for Vandalia, Azure for Mountain Health). This de-risks the concept and builds stakeholder confidence before any production infrastructure commitment.

---

## Appendix

### Glossary

- **BAA** - Business Associate Agreement (HIPAA requirement for third-party PHI processors)
- **CCL** - Cerner Command Language (backend database query language)
- **LLM** - Large Language Model (AI foundation models like GPT, Claude, Llama)
- **OCI** - Oracle Cloud Infrastructure
- **PHI** - Protected Health Information (regulated under HIPAA)
- **POC** - Proof of Concept
- **SEP-1** - Sepsis bundle quality measure (CMS requirement)

### Resources

**Oracle OCI Generative AI:**
- Documentation: https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm
- Pricing: https://www.oracle.com/cloud/price-list.html
- HIPAA Services: https://www.oracle.com/cloud/public-cloud-regions/data-regions/hipaa/

**Azure OpenAI:**
- Service Overview: https://azure.microsoft.com/en-us/products/ai-services/openai-service
- Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/
- HIPAA Compliance: https://learn.microsoft.com/en-us/azure/compliance/offerings/offering-hipaa-us

**Ollama:**
- Homepage: https://ollama.ai/
- GitHub: https://github.com/ollama/ollama
- Model Library: https://ollama.ai/library

**Anthropic Claude:**
- API Documentation: https://docs.anthropic.com/
- BAA Information: https://privacy.anthropic.com/en/articles/8114513
- AWS Bedrock (Claude): https://aws.amazon.com/bedrock/claude/

### Related GitHub Issues

- Issue #4: Oracle JET Research (future UI framework considerations)
- Issue #22: Novant Health Model (live dashboard with AI analytics)
- **NEW:** Issue #XX: AI Agent POC - Sepsis Bundle Analysis (to be created)

---

**Document Status:** Initial Draft
**Next Review:** After Phase 1 POC completion (Week 1)
**Maintained By:** Troy Shelton (Consulting)
**Last Updated:** 2025-10-17
