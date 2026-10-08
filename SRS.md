# Software Requirements Specification (SRS)

## HR Connect Pro / Career Connect

| Attribute | Details |
| :--- | :--- |
| **Document Version** | 1.0 (Draft for Architecture Review) |
| **Date** | 6 October 2026 |
| **Status** | Approved Baseline for Phase 0 & Phase 1 Execution |
| **Primary Framework** | Flutter (Multi-Platform: Android, iOS, Web) |
| **Related Documents** | [BRD.md](file:///d:/freelance/New%20folder/BRD.md), [PRD.md](file:///d:/freelance/New%20folder/PRD.md) |

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification (SRS) establishes the technical, architectural, and operational requirements for building **HR Connect Pro / Career Connect**. It translates business objectives ([BRD.md](file:///d:/freelance/New%20folder/BRD.md)) and product capabilities ([PRD.md](file:///d:/freelance/New%20folder/PRD.md)) into actionable engineering specifications for frontend (Flutter), backend APIs, database architecture, AI integration, and third-party services.

### 1.2 Scope of the System
The system comprises:
1. **Candidate & Expert Mobile Application (Flutter - Android & iOS)**:
   - Profile management, zero-hallucination AI resume ingestion, explainable job matching.
   - Self-service interview booking, rescheduling, and status tracking.
   - Expert discovery, audio/video consultation via WebRTC/SDK, integrated payment gateway.
   - In-app AI career assistant & stage-specific interview preparation.
2. **Company HR & Interviewer Portal (Flutter Web / Responsive Client)**:
   - Company verification, JD parsing, slot & interviewer calendar management.
   - Multi-round candidate pipeline management (L1/L2/L3/HR), structured scorecard evaluations, offer management.
3. **Super Admin Dashboard (Flutter Web)**:
   - Company/expert credential verification, audit trail review, duplicate account resolution queue, platform telemetry, and financial commission ledger.
4. **Backend Services & API Gateway**:
   - Microservices/Modular Monolith powering REST/GraphQL APIs, real-time WebSocket notifications, AI orchestration, and transactional ledger.

---

## 2. Overall Architectural Strategy

### 2.1 Technology Stack Selection

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│   Flutter Mobile (Android/iOS)      │    Flutter Web (HR & Admin)     │
│   - State: Riverpod / Bloc          │    - Responsive layout builder   │
│   - Routing: go_router              │    - Role-based route guards     │
│   - Network: Dio + Retrofit         │    - Real-time updates           │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTPS (TLS 1.3) / WSS
┌───────────────────────────────────▼────────────────────────────────────┐
│                    API GATEWAY & SECURITY LAYER                        │
│   - Reverse Proxy & Rate Limiter (Kong / NGINX / Cloudflare)           │
│   - JWT Auth & Token Rotation (AccessToken: 15m, RefreshToken: 30d)    │
│   - DPDP Compliance & Consent Interceptor                              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                         CORE APPLICATION LAYER                         │
│  ┌────────────────────┐ ┌────────────────────┐ ┌─────────────────────┐ │
│  │ Auth & Identity    │ │ Matching & Jobs    │ │ Booking & Calendar  │ │
│  └────────────────────┘ └────────────────────┘ └─────────────────────┘ │
│  ┌────────────────────┐ ┌────────────────────┐ ┌─────────────────────┐ │
│  │ Expert Marketplace │ │ Interview Pipeline │ │ Notification Engine │ │
│  └────────────────────┘ └────────────────────┘ └─────────────────────┘ │
└──────────┬────────────────────────┬───────────────────────┬────────────┘
           │                        │                       │
┌──────────▼──────────┐  ┌──────────▼──────────┐ ┌──────────▼────────────┐
│   DATA & CACHE      │  │ THIRD-PARTY ADAPTERS│ │     AI ENGINE         │
│  PostgreSQL 16      │  │ Video: 100ms / Agora│ │ Gemini 1.5/2.0 API    │
│  Redis 7 (Locks)    │  │ Pay: Razorpay Route │ │ - Resume JSON Parser  │
│  S3 (Encrypted Doc) │  │ SMS/OTP: Twilio/SNS │ │ - Explainable Matcher │
│                     │  │ Push: Firebase FCM  │ │ - Mock Prep Generator │
└─────────────────────┘  └─────────────────────┘ └───────────────────────┘
```

### 2.2 Client-Side Architecture (Flutter)
The Flutter application follows **Clean Architecture with Feature-First Modularization**:

```
lib/
├── app/
│   ├── config/             # Environment configs, flavors (dev, staging, prod)
│   ├── routes/             # go_router declarative routing + Auth/Role guards
│   └── theme/              # Custom design tokens, typography, dark/light themes
├── core/
│   ├── constants/          # App constants, API endpoints, error codes
│   ├── errors/             # Failure models, exceptions, error handlers
│   ├── network/            # Dio HTTP client, AuthInterceptor, RetryPolicy
│   ├── services/           # Device info, secure storage, permission handler
│   └── utils/              # Date formats, currency formatters, validators
└── features/
    ├── authentication/     # OTP auth, OAuth, biometric login
    ├── candidate_profile/  # Resume upload, profile completion wizard
    ├── jobs_matching/      # Job search, explainable match breakdown
    ├── interview_pipeline/ # Calendar booking, video call room, scorecards
    ├── expert_marketplace/ # Expert listing, slot booking, Razorpay checkout
    ├── ai_assistants/      # Career coach bot, mock interview generator
    └── admin_portal/       # Verification queues, audit log inspector
```

Each feature module is structured into three layers:
- **`data/`**: Data sources (Remote/Local), DTOs (Data Transfer Objects), and Repository implementations.
- **`domain/`**: Pure Dart entity models, value objects, and business use-case classes.
- **`presentation/`**: Flutter UI widgets, screens, and Riverpod/Bloc state controllers.

---

## 3. Detailed Functional Requirements

### 3.1 Authentication & Identity (ACC)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-ACC-01** | Mobile OTP & Email Sign-In | Firebase Phone Auth / Twilio Verify fallback. Rate limit: 3 OTP requests per 10 minutes per IP/Device ID. |
| **REQ-ACC-02** | OAuth Providers | Google Sign-In (`google_sign_in`), Apple Sign-In (`sign_in_with_apple`) for iOS guidelines compliance. |
| **REQ-ACC-03** | Role-Based Access (RBAC) | Strict JWT claim evaluation (`Candidate`, `Expert`, `CompanyAdmin`, `HRAdmin`, `Recruiter`, `Interviewer`, `SuperAdmin`). |
| **REQ-ACC-04** | Token Lifetime & Rotation | Access token (short-lived, 15m), Refresh token (stored in `flutter_secure_storage`, 30-day sliding expiry). |
| **REQ-ACC-05** | Account Deduplication | Phone hash and verified email matching on registration. If match exists, trigger `AccountRecoveryFlow`. |
| **REQ-ACC-06** | Soft Duplication Review | Ambiguous matches (fuzzy name + identical employer + graduation year) flag for Admin resolution queue; never hard-lock automatically. |

### 3.2 Candidate Profile & Resume Ingestion (CAN)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-CAN-01** | File Ingestion | Accepts `.pdf`, `.doc`, `.docx` up to 10MB. Client-side mime-type verification, pre-signed S3 upload with SSE-KMS encryption. |
| **REQ-CAN-02** | Zero-Hallucination Extraction | Gemini Structured Output (`response_mime_type: "application/json"`) with deterministic Pydantic schema validation. |
| **REQ-CAN-03** | Confidence & Human Confirmation | Fields with extraction confidence $< 0.85$ are flagged in Flutter UI as `NeedsConfirmation` state. |
| **REQ-CAN-04** | Profile Completion Meter | Dynamic computation of completeness (Target $\ge 80\%$ required before self-booking interviews). |
| **REQ-CAN-05** | Career Graph | Graph-based persistence linking Candidate Node $\rightarrow$ Skills $\rightarrow$ Experiences $\rightarrow$ Completed Interviews $\rightarrow$ Recommendations. |
| **REQ-CAN-06** | Privacy & Erasure Rights | Self-serve "Download My Data" (JSON/ZIP export) and "Delete Account" (initiates 30-day soft-delete grace period per DPDP Act). |

### 3.3 Job Catalog & Explainable Matching (JOB)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-JOB-01** | Filtered Job Catalog | Pagination via Infinite Scroll (`PagingController`), filters for experience, salary range, work mode (Remote/Hybrid/Onsite), notice period. |
| **REQ-JOB-02** | Two-Tier Matching Pipeline | **Tier 1 (Hard Rules):** SQL-indexed filter (Location, Experience bounds, Notice Period ceiling).<br>**Tier 2 (Semantic):** Vector similarity between Candidate Embeddings and Job Role Embeddings. |
| **REQ-JOB-03** | Explainability Payload | API returns exact match metadata: `matched_skills: []`, `missing_critical_skills: []`, `experience_delta_months: int`, `match_percentage: float`. |
| **REQ-JOB-04** | Company JD Creator | Company HR uploads raw JD $\rightarrow$ Gemini extracts role requirements, required skills, and rounds $\rightarrow$ HR edits in Flutter Web before publishing. |

### 3.4 Interview Scheduling & Concurrency Control (SCH)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-SCH-01** | Slot Definition | Company Admin / Interviewer sets available blocks (e.g., 45-min slots with 15-min buffer), timezone-stored in UTC. |
| **REQ-SCH-02** | Concurrency & Double-Booking Guard | Slot locking implemented via **Redis Distributed Lock (Redlock)** with 120-second lease time during candidate checkout/confirmation. |
| **REQ-SCH-03** | Self-Booking Eligibility Gate | Evaluation against company rules: candidate match score $\ge$ Job threshold AND candidate profile completeness $\ge 80\%$. |
| **REQ-SCH-04** | Reschedule Protocol | State machine transition: `Confirmed` $\rightarrow$ `Reschedule_Requested` (records reason code + proposed slot) $\rightarrow$ HR accepts or counters $\rightarrow$ Updated calendar invite sent. |
| **REQ-SCH-05** | Calendar Synchronization | Generates `.ics` payload, integrates with Google Calendar / Outlook Calendar API webhooks. |

### 3.5 Real-Time Interview Room & Feedback (INT)

```
Candidate / Interviewer App                   Backend Server                 WebRTC Provider (100ms/Agora)
         │                                          │                                      │
         ├──── 1. Fetch Room Token ─────────────────►│                                      │
         │     (Validate permissions & time window) │                                      │
         │◄─── 2. Return Short-Lived JWT ───────────┤                                      │
         │                                          │                                      │
         ├──── 3. Join Call via Flutter SDK ────────┼─────────────────────────────────────►│
         │                                          │                                      │
         │◄─── 4. Audio/Video/Chat Media Stream ────┼─────────────────────────────────────►│
         │                                          │                                      │
         ├──── 5. Submit Scorecard (Interviewer) ──►│ (Store encrypted evaluation)         │
         │                                          │                                      │
```

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-INT-01** | In-App Video Calling | Native WebRTC via 100ms or Agora Flutter SDK with adaptive bitrate, network reconnection, and active speaker highlighting. |
| **REQ-INT-02** | Multi-Stage Tracking | Pipeline stages: `L1_Screening` $\rightarrow$ `L2_Technical` $\rightarrow$ `L3_SystemDesign` $\rightarrow$ `Managerial` $\rightarrow$ `HR_Final` $\rightarrow$ `Offered`. |
| **REQ-INT-03** | Structured Scorecards | Form validated against criteria: Domain Competency (1-5), Problem Solving (1-5), Communication (1-5), Cultural Fit (1-5), Recommendation (`Strong Hire`, `Hire`, `No Hire`). |
| **REQ-INT-04** | Private Notes Protection | Internal interviewer feedback is shielded via database-level field permissions; only sanitized public feedback is visible to candidates. |
| **REQ-INT-05** | Consented Call Recording | Dual-party explicit consent modal in Flutter UI; call recording streams directly to private, compliance-locked S3 storage. |

### 3.6 Expert Advisory Marketplace & Payouts (EXP)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-EXP-01** | Expert Verification | Mandatory identity and credential verification (LinkedIn profile, past employer domain verification, photo ID check). |
| **REQ-EXP-02** | Booking & Payment Escrow (RBI PA Compliant) | Candidate pays via Razorpay Route / Cashfree Split Flutter SDK. In compliance with RBI Payment Aggregator guidelines, funds are routed through an escrow/nodal account; the platform never holds third-party funds directly. Under Apple App Store Guideline 3.1.3(d), 1-on-1 real-time personal advisory services are exempted from Apple In-App Purchase (IAP). |
| **REQ-EXP-03** | Platform Commission Ledger & Payout | Platform retains baseline 20% commission; 80% is allocated to expert linked account. Automated payouts execute via nodal settlement upon confirmed session completion. |
| **REQ-EXP-04** | Cancellation & Refund Policy Engine | Automated refund state machine: 100% refund for cancellations >24 hours before session; 50% refund between 4–24 hours; non-refundable <4 hours. 100% refund if expert no-shows or cancels. |
| **REQ-EXP-05** | Conflict of Interest Guard | Prevents expert booking if Expert’s verified current employer matches Candidate's active job application company. |
| **REQ-EXP-06** | Mutual Ratings & Reviews | Post-session double-blind 5-star rating and written review with profanity filter before publication. |

### 3.7 AI Career Coach & Mock Interview Engine (AI)

| Ref ID | Description | Technical Implementation |
| :--- | :--- | :--- |
| **REQ-AI-01** | Privacy-Sandboxed Career Bot | Answers candidate queries using only candidate's approved data and public job metadata; zero cross-tenant knowledge leakage. |
| **REQ-AI-02** | Contextual Mock Interviewer | Generates 5 tailored technical & behavioral questions based on target Job Description and Candidate seniority. |
| **REQ-AI-03** | Zero Automated Rejections | AI is strictly disallowed from executing programmatic rejections; all candidate status transitions require authenticated human recruiter action. |

---

## 4. Data Models & Database Schema (PostgreSQL)

```
┌──────────────────────┐          ┌───────────────────────┐          ┌────────────────────────┐
│     users            │1       * │   candidate_profiles  │1       * │   resumes              │
├──────────────────────┼──────────┼───────────────────────┼──────────┼────────────────────────┤
│ id (UUID, PK)        │          │ id (UUID, PK)         │          │ id (UUID, PK)          │
│ phone_number (VARCHAR│          │ user_id (UUID, FK)    │          │ profile_id (UUID, FK)  │
│ email (VARCHAR, UNQ) │          │ current_title (TEXT)  │          │ s3_url (TEXT)          │
│ role (ENUM)          │          │ total_exp_months (INT)│          │ parsed_json (JSONB)    │
│ is_verified (BOOL)   │          │ notice_period_days    │          │ parse_status (ENUM)    │
└──────────┬───────────┘          └───────────┬───────────┘          └────────────────────────┘
           │1                                 │1
           │*                                 │*
┌──────────▼───────────┐          ┌───────────▼───────────┐          ┌────────────────────────┐
│   expert_profiles    │          │   interviews          │*        1│   job_postings         │
├──────────────────────┤          ├───────────────────────┼──────────┼────────────────────────┤
│ id (UUID, PK)        │          │ id (UUID, PK)         │          │ id (UUID, PK)          │
│ user_id (UUID, FK)   │          │ job_id (UUID, FK)     │          │ company_id (UUID, FK)  │
│ hourly_rate_inr (DEC)│          │ candidate_id (UUID,FK)│          │ title (TEXT)           │
│ domain_tags (TEXT[]) │          │ slot_id (UUID, FK)    │          │ min_exp_years (INT)    │
│ commission_rate (DEC)│          │ round_type (ENUM)     │          │ salary_range (INT4R)   │
└──────────┬───────────┘          │ scheduled_start (UTC) │          │ required_skills (TEXT[])
           │1                     │ status (ENUM)         │          └───────────┬────────────┘
           │                      └───────────┬───────────┘                      │1
     ┌─────┴───────────┐                      │1                                 │*
    1│                 │1                     │1                     ┌───────────▼────────────┐
┌────▼─────────────┐ ┌─▼─────────────────┐ ┌──▼──────────────────┐   │   interview_slots      │
│expert_payout_acc │ │  expert_sessions  │ │   scorecards        │   ├────────────────────────┤
├──────────────────┤ ├───────────────────┤ ├─────────────────────┤   │ id (UUID, PK)          │
│id (UUID, PK)     │ │ id (UUID, PK)     │ │ id (UUID, PK)       │   │ job_id (UUID, FK)      │
│expert_id(UUID,FK)│ │ expert_id(UUID,FK)│ │ interview_id (FK)   │   │ interviewer_id (UUID)  │
│razorpay_acc_id   │ │ candidate_id (FK) │ │ interviewer_id (FK) │   │ start_time (UTC)       │
│kyc_status (ENUM) │ │ payment_order_id  │ │ rating_overall (INT)│   │ end_time (UTC)         │
│bank_vpa (TEXT)   │ │ escrow_status     │ │ feedback_private    │   │ status (ENUM)          │
└──────────────────┘ │ payout_amount     │ │ feedback_public     │   │ lock_lease_expires_at  │
                     └───────────────────┘ └─────────────────────┘   └────────────────────────┘
```

### 4.1 Key Table Definitions

#### `users`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `phone_number`: `VARCHAR(15) UNIQUE NOT NULL`
* `email`: `VARCHAR(255) UNIQUE NOT NULL`
* `password_hash`: `VARCHAR(255) NULL` (Null for OTP-only/OAuth users)
* `role`: `VARCHAR(32) NOT NULL` (`candidate`, `expert`, `company_hr`, `interviewer`, `admin`)
* `is_verified`: `BOOLEAN DEFAULT FALSE`
* `created_at`: `TIMESTAMPTZ DEFAULT NOW()`

#### `candidate_profiles`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `user_id`: `UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE`
* `full_name`: `VARCHAR(128) NOT NULL`
* `headline`: `VARCHAR(255)`
* `current_location`: `VARCHAR(128)`
* `preferred_locations`: `TEXT[]`
* `experience_months`: `INTEGER DEFAULT 0`
* `expected_ctc_lpa`: `NUMERIC(10,2)`
* `notice_period_days`: `INTEGER DEFAULT 30`
* `skills`: `JSONB NOT NULL DEFAULT '[]'`
* `profile_completion_pct`: `INTEGER DEFAULT 0`

#### `interview_slots`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `job_id`: `UUID NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE`
* `interviewer_id`: `UUID NOT NULL REFERENCES users(id)`
* `start_time`: `TIMESTAMPTZ NOT NULL`
* `end_time`: `TIMESTAMPTZ NOT NULL`
* `timezone`: `VARCHAR(64) NOT NULL DEFAULT 'UTC'`
* `status`: `VARCHAR(32) NOT NULL DEFAULT 'available'` (`available`, `reserved_held`, `booked`, `cancelled`)
* `lock_lease_expires_at`: `TIMESTAMPTZ NULL` (Used alongside Redis distributed lock for 120s checkout lease)
* `created_at`: `TIMESTAMPTZ DEFAULT NOW()`

#### `interviews`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `job_id`: `UUID NOT NULL REFERENCES job_postings(id)`
* `candidate_id`: `UUID NOT NULL REFERENCES candidate_profiles(id)`
* `interviewer_id`: `UUID NOT NULL REFERENCES users(id)`
* `slot_id`: `UUID UNIQUE NOT NULL REFERENCES interview_slots(id)`
* `stage`: `VARCHAR(32) NOT NULL` (`screening`, `technical_l1`, `technical_l2`, `managerial`, `hr`)
* `scheduled_start_time`: `TIMESTAMPTZ NOT NULL`
* `scheduled_end_time`: `TIMESTAMPTZ NOT NULL`
* `meeting_room_id`: `VARCHAR(128) NOT NULL`
* `reschedule_count`: `INTEGER NOT NULL DEFAULT 0`
* `status`: `VARCHAR(32) NOT NULL` (`scheduled`, `reschedule_requested`, `in_progress`, `completed`, `cancelled`)
* `created_at`: `TIMESTAMPTZ DEFAULT NOW()`

#### `expert_payout_accounts`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `expert_id`: `UUID UNIQUE NOT NULL REFERENCES expert_profiles(id) ON DELETE CASCADE`
* `gateway_account_id`: `VARCHAR(64) NOT NULL` (e.g., Razorpay Route linked account ID / Cashfree beneficiary ID)
* `account_holder_name`: `VARCHAR(128) NOT NULL`
* `bank_account_number_masked`: `VARCHAR(32) NOT NULL`
* `ifsc_code`: `VARCHAR(16) NOT NULL`
* `vpa_address`: `VARCHAR(128) NULL`
* `kyc_status`: `VARCHAR(32) NOT NULL DEFAULT 'pending'` (`pending`, `verified`, `rejected`)
* `created_at`: `TIMESTAMPTZ DEFAULT NOW()`

#### `expert_sessions`
* `id`: `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
* `expert_id`: `UUID NOT NULL REFERENCES expert_profiles(id)`
* `candidate_id`: `UUID NOT NULL REFERENCES candidate_profiles(id)`
* `slot_start_time`: `TIMESTAMPTZ NOT NULL`
* `slot_end_time`: `TIMESTAMPTZ NOT NULL`
* `booking_amount`: `NUMERIC(10,2) NOT NULL`
* `platform_fee`: `NUMERIC(10,2) NOT NULL`
* `payout_amount`: `NUMERIC(10,2) NOT NULL`
* `payment_order_id`: `VARCHAR(64) NOT NULL`
* `payment_status`: `VARCHAR(32) NOT NULL` (`initiated`, `held_in_escrow`, `paid_out`, `refunded`)

---

## 5. API Contracts (RESTful OpenAPI 3.1)

### 5.1 Candidate Resume Upload & Parse
* **Endpoint**: `POST /api/v1/candidates/resume/upload`
* **Headers**: `Authorization: Bearer <JWT>`, `Content-Type: multipart/form-data`
* **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "resume_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "completion_score": 85,
    "parsed_data": {
      "full_name": "Aditya Sharma",
      "email": "aditya.sharma@example.com",
      "phone": "+919876543210",
      "experience_years": 4.5,
      "primary_skills": ["Flutter", "Dart", "Clean Architecture", "REST APIs"],
      "secondary_skills": ["Firebase", "PostgreSQL", "Docker"],
      "uncertain_fields": [
        {
          "field": "notice_period_days",
          "extracted_value": null,
          "prompt": "Please confirm your current notice period"
        }
      ]
    }
  }
}
```

### 5.2 Job Match with Explainability
* **Endpoint**: `GET /api/v1/jobs/{jobId}/match-explanation`
* **Headers**: `Authorization: Bearer <JWT>`
* **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "job_id": "b3e0c7a1-2d93-4a18-910a-313d5e2195f0",
    "overall_match_percentage": 92,
    "eligible_for_instant_booking": true,
    "matching_breakdown": {
      "matched_skills": ["Flutter", "Dart", "REST APIs"],
      "missing_skills": ["GraphQL"],
      "experience_match": "Qualified (Candidate: 4.5y, Required: 3.0y)",
      "location_match": "Matched (Bangalore / Remote Hybrid)"
    },
    "available_slots_count": 8
  }
}
```

### 5.3 Lock & Book Interview Slot
* **Endpoint**: `POST /api/v1/interviews/slots/book`
* **Request Body**:
```json
{
  "job_id": "b3e0c7a1-2d93-4a18-910a-313d5e2195f0",
  "slot_id": "90e2f57a-c189-4b68-b765-8bceb03e04e2",
  "timezone": "Asia/Kolkata"
}
```
* **Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "interview_id": "421f5280-99ef-4cbe-b4da-c47bbfaeb2c8",
    "stage": "technical_l1",
    "scheduled_time": "2026-10-12T10:00:00Z",
    "meeting_link_preauth": "https://meet.careerconnect.pro/room/421f5280",
    "reschedule_deadline": "2026-10-11T10:00:00Z"
  }
}
```
* **Error Response (409 Conflict)**:
```json
{
  "success": false,
  "error": {
    "code": "SLOT_ALREADY_RESERVED",
    "message": "This slot was reserved by another candidate. Please select another slot."
  }
}
```

---

## 6. Non-Functional Requirements & Engineering Standards

### 6.1 Performance & Latency Budgets
1. **Screen Load Time**: Flutter First Contentful Paint $< 1.2\text{s}$ on 4G connection; time to full interactive display $< 2.5\text{s}$.
2. **Slot Reservation**: Slot acquisition and lock response time $< 800\text{ms}$ at p95.
3. **Optimized Networking**: Image asset caching via `cached_network_image`, API payload caching with HTTP ETag headers and SQLite/Drift offline sync.
4. **App Binary Footprint**: Target Android release APK $< 25\text{MB}$; iOS IPA $< 40\text{MB}$.

### 6.2 Security & Compliance (DPDP Act 2023)
1. **Cryptography**: TLS 1.3 for all endpoints; AES-256 for document storage; BCrypt (work factor 12) or Argon2id for password hashes.
2. **Strict Consent Records**: Explicit timestamped consent recorded for resume parsing, video participation, and notification delivery.
3. **Document Security**: No public URLs for candidate resumes; all document access requires short-lived pre-signed URLs (TTL: 15 minutes).
4. **Data Isolation**: Multi-tenant database design with strict Row Level Security (RLS) separating company hiring data and candidate private records.

### 6.3 System Reliability & Fault Tolerance
1. **High Availability**: 99.5% uptime target for MVP phases; active-passive database replication with automated failover.
2. **Rate Limiting**:
   - Authentication routes: 5 requests / minute / IP.
   - Slot booking routes: 20 requests / minute / User.
   - AI assistant queries: 15 requests / hour / User.
3. **Resilience**: Circuit breakers on external dependencies (SMS gateway, Payment provider, AI endpoints) with exponential backoff retries.

---

## 7. Flutter Implementation Roadmap

```
Phase 0: Architecture Setup
├── Setup Flutter workspace with flavors (dev, staging, prod)
├── Implement core network client (Dio, interceptors, error mapping)
├── Setup state management baseline (Riverpod / Bloc)
└── Setup CI/CD build pipelines (GitHub Actions, Fastlane)

Phase 1: Candidate App & Expert Marketplace
├── Module 1: Auth & Biometrics (Phone OTP, Google/Apple Sign-In)
├── Module 2: Resume Upload & AI Parser UI Review Flow
├── Module 3: Job Discovery Feed with Explainability Badges
├── Module 4: Expert Listing, Calendar Slot Selector, Razorpay Route Checkout
├── Module 5: 100ms / Agora Audio-Video Call Room Integration
└── Module 6: In-App AI Career Coach & Mock Interview Practice (PRD AI-01, AI-02)

Phase 2: Company HR & Interview Pipeline
├── Module 7: Flutter Web HR Portal (Job Posting & JD AI Importer)
├── Module 8: Interviewer Availability Calendar & Slot Generator (interview_slots)
├── Module 9: Multi-Stage Interview Pipeline Management (L1/L2/L3)
└── Module 10: Candidate Scorecards, Decision Workflows, Offer Letters

Phase 3: Administrative Scale & Intelligence
├── Module 11: Super Admin Duplicate Resolution & Fraud Monitoring
├── Module 12: Call Recording with Consent Management
└── Module 13: Enterprise HR AI Assistant & Post-Rejection Nurture Engine (PRD AI-03, INT-06)
```
