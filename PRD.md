# Product Requirements Document (PRD)

## HR Connect Pro / Career Connect

|  |  |
| --- | --- |
| **Version** | 0.1 (Draft for review) |
| **Date** | 1 October 2026 |
| **Status** | Draft. Items marked **\[TBC\]** need confirmation |
| **Related** | BRD v0.1, SRS (next) |

---

## 1. Purpose

This document describes **what** the product must do and **why**. It is the base for the SRS (technical detail) and for the build plan. It is written in simple language so founders, designers, developers, and testers can all use it.

## 2. Problem and Vision

**Problem.** Today a candidate searches, applies, waits, and follows up. Companies get many weak applications and lose time scheduling. Candidates who fail an interview get no clear next step.

**Vision.** A hiring marketplace where a candidate can go from **discover job, to match, to interview slot, to feedback, to offer** with the least waiting. Candidates can also get help from **career experts** at any point.

**Product promise.** "Find a job that fits you, book the interview yourself, and get expert help when you need it."

## 3. Goals and Non-Goals

**Goals**

1. Cut the time from job discovery to a qualified interview.
2. Give candidates clear, explained job matches (never a mystery score).
3. Let candidates book expert help in a few taps.
4. Give companies a simple way to schedule, run, and track interviews.
5. Keep trust high: privacy, security, and human-made hiring decisions.

**Non-goals (for now)**

- Full applicant tracking system (ATS) for large enterprises
- Online courses, paid assessments, or recruitment-agency tools
- Building our own video infrastructure
- Automatic hiring or rejection decisions by AI

## 4. Users

| User | Main need | Main actions |
| --- | --- | --- |
| **Candidate** | Find the right job and reach an interview fast | Sign up, upload resume, see matches, book interview, book expert, view feedback and offer |
| **Expert** | Earn by guiding candidates | Create profile, set availability, take sessions, get paid |
| **Company HR / Recruiter** | Fill roles quickly with good people | Post jobs, set interview slots, review candidates, move rounds, make offers |
| **Interviewer / Hiring Manager** | Interview and decide fairly | See assigned candidates, run interview, submit scorecard |
| **Admin (Super Admin)** | Keep the platform safe and healthy | Verify companies and experts, review duplicates, handle abuse, view reports and audit logs |

## 5. Scope and Phases

> The recommended order starts with the strength of a career guidance business: candidates and experts. **\[TBC with founders\]**

| Phase | Focus | Main features |
| --- | --- | --- |
| **Phase 1** | Candidates + Experts + basic jobs | Candidate sign-up, resume parsing, profile completion, job list with match reasons, expert marketplace, booking, audio/video session, payments, AI career assistant, interview preparation |
| **Phase 2** | Companies + interview flow | Company registration and verification, JD parsing, interview slot setup, Schedule Interview, scorecards, L1/L2/L3 pipeline, offers, reschedule, notifications, HR web dashboard |
| **Phase 3** | Scale and trust | Duplicate review workflow, admin tools, recording with consent, HR AI assistant, analytics, alternative-job suggestions after rejection |

## 6. Key User Journeys

**J1. Candidate to interview.** Sign up and verify, upload resume, confirm profile, see matched jobs with reasons, tap **Schedule Interview**, pick a slot, confirm, get reminders, join the interview.

**J2. Candidate to expert.** Tap **Call an Expert** (from a job or the Experts tab), choose expert, pick slot, pay, join audio/video call, rate the session.

**J3. Reschedule.** Candidate asks to reschedule with a reason and a preferred slot. HR approves, rejects, or suggests another slot. Both sides are notified.

**J4. After rejection.** Candidate gets respectful feedback, similar jobs, skill suggestions, interview preparation, and an expert option.

**J5. Company hiring.** HR registers and is verified, uploads a job description, reviews AI-read details, publishes, sets slots, interviews, advances candidates, and creates an offer.

## 7. Functional Requirements

Priority: **M** = Must, **S** = Should, **C** = Could.

### 7.1 Accounts and Access

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| ACC-01 | Sign up with mobile OTP and email verification | 1 | M |
| ACC-02 | Google Sign-In (Apple Sign-In on iOS) | 1 | S |
| ACC-03 | Role-based access: Candidate, Expert, Company Admin, HR Admin, Recruiter, Hiring Manager, Interviewer, Super Admin | 1 | M |
| ACC-04 | Session and device management; refresh tokens rotate | 1 | M |
| ACC-05 | One person, one account: check verified phone and email first; extra signals added later | 1 | M |
| ACC-06 | If a possible duplicate is found, show a recover-account message. Never silently create a second account and never block permanently without human review | 1 | M |
| ACC-07 | Admin duplicate-review screen | 3 | S |

### 7.2 Candidate Profile

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| CAN-01 | Upload resume (PDF, DOC, DOCX); store the original securely | 1 | M |
| CAN-02 | AI extracts name, contact, skills, experience, projects, certifications, and more into structured fields | 1 | M |
| CAN-03 | Show "Your resume completed X% of your profile" and ask only for missing must-have fields (location, salary, notice period, work preference, availability) | 1 | M |
| CAN-04 | AI never invents data; uncertain fields are marked "please confirm" | 1 | M |
| CAN-05 | Career Graph links skills, experience, jobs, interviews, feedback, expert sessions, and offers | 1 | S |
| CAN-06 | Candidate can view data, manage consent, view sessions, export data, and request deletion | 1 | M |

### 7.3 Jobs and Matching

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| JOB-01 | Job lists: Recommended, Recent, Near Me, High Match, Interview Available Now, Expert Help Available | 1 | M |
| JOB-02 | Job card shows company, role, location, salary (if given), experience, match %, interview availability | 1 | M |
| JOB-03 | Match % always comes with reasons and gaps (for example: matched Java, Spring Boot; gap: Kubernetes) | 1 | M |
| JOB-04 | Matching uses rules first (location, experience, salary, notice), then skills and meaning | 1 | M |
| JOB-05 | Company can upload a JD or create a job by hand; AI fills fields; HR reviews and edits before publishing | 2 | M |

### 7.4 Interview Scheduling

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| SCH-01 | Company defines interviewer, type, duration, dates, times, timezone, stage, and meeting method | 2 | M |
| SCH-02 | Candidate picks an open slot in a few steps | 2 | M |
| SCH-03 | No double booking; timezone-aware | 2 | M |
| SCH-04 | Company can set rules for who may self-book (for example, minimum match % or a slot cap per job) | 2 | M |
| SCH-05 | Reschedule needs reason, remarks, and preferred slot; company policy decides auto, HR approval, or escalation; all changes are logged | 2 | M |
| SCH-06 | Repeated rescheduling raises a review flag, never an automatic rejection | 2 | S |

### 7.5 Interviews and Feedback

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| INT-01 | Company can set stages per job: L1, L2, L3/Technical, Coding, System Design, Managerial, Final HR, Offer | 2 | M |
| INT-02 | Candidate sees current status of every stage | 2 | M |
| INT-03 | Interview room uses a third-party SDK: audio, video, chat; screen share where supported | 2 | M |
| INT-04 | Interviewer submits a scorecard (skills, communication, problem solving, role knowledge, recommendation, comments) | 2 | M |
| INT-05 | AI may summarize feedback; a human makes the decision | 2 | M |
| INT-06 | Rejected candidates get kind feedback, similar jobs, preparation help, and an expert option; interviewer comments stay private unless the company allows sharing | 3 | M |
| INT-07 | Recording only with clear notice and consent; store consent, retention, and access rules | 3 | S |
| INT-08 | Offer creation and candidate view of offer | 2 | M |

### 7.6 Expert Marketplace

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| EXP-01 | Expert onboarding with credential verification by admin | 1 | M |
| EXP-02 | Expert profile: domain, years of experience, price, rating, sessions completed, availability | 1 | M |
| EXP-03 | Domains: Java, Python, .NET, React, DevOps, AWS, Data, AI/ML, QA, Cybersecurity, Product, BA, Leadership, others | 1 | M |
| EXP-04 | Candidate books audio or video session from a slot | 1 | M |
| EXP-05 | Payment through licensed aggregator escrow (Razorpay Route / Cashfree Split); 20% baseline platform commission; automated nodal settlement after completed session; automated tiered refund policy (100% >24h, 50% 4–24h, 0% <4h, 100% on expert cancellation/no-show) | 1 | M |
| EXP-06 | Rating and feedback after session | 1 | S |
| EXP-07 | Conflict of interest guard: an expert cannot be booked for a company where they are an active, verified employee | 1 | M |

### 7.7 AI Assistants

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| AI-01 | Career assistant answers using only the candidate's own approved data (jobs, skill gaps, "why was I not a match?") | 1 | S |
| AI-02 | Interview preparation: technical, coding, behavioral, and mock questions based on profile, job, and stage | 1 | S |
| AI-03 | HR assistant for questions such as "interviews today" or "pending feedback"; high-impact actions need confirmation | 3 | C |

### 7.8 Notifications, Admin, and Audit

| ID | Requirement | Phase | Pri |
| --- | --- | --- | --- |
| NOT-01 | Push, email, and in-app notifications for scheduling, reminders, changes, reschedule, feedback, next round, offer, expert booking | 2 | M |
| ADM-01 | Admin can manage candidates, companies, experts, jobs, interviews, reports, verification, abuse, and settings | 2 | M |
| ADM-02 | Company verification statuses: Verified, Pending, Rejected; free email domains are not treated as verified | 2 | M |
| AUD-01 | Audit log for sign-in, role changes, scheduling changes, feedback, offers, document access, and AI actions | 1 | M |

## 8. AI Rules

AI must **never**: invent resume or company details, invent feedback, make final hiring decisions, reject anyone only because of a score, show private data to the wrong person, or skip permission checks. AI output that enters the database uses fixed formats and is stored with an event record so it can be reviewed.

## 9. Non-Functional Requirements

- **Security & Regulatory Compliance:** encrypted traffic (TLS 1.3), rate limiting, input checks, virus scan on uploads, signed short-lived links for documents (15m TTL), least-privilege access, secrets kept out of code. Third-party marketplace payouts comply with RBI Payment Aggregator escrow/nodal rules; live 1-on-1 expert sessions comply with Apple App Store Guideline 3.1.3(d) peer-service exemptions.
- **Privacy:** consent first; candidate data not publicly searchable; company data isolated; follows India DPDP Act 2023 (30-day soft-delete grace period, downloadable data archive).
- **Performance:** main screens load in under 3 seconds on a normal mobile network; slot booking confirms in under 2 seconds (Redis lock).
- **Reliability:** target 99.5% uptime for MVP; daily backups.
- **Usability:** candidate bottom tabs: Home, Jobs, Interviews, Experts, Profile; book an interview in 4 taps or fewer from a job card.
- **Compatibility:** Android and iOS (Flutter); responsive web for HR and admin.

## 10. Success Metrics

| Metric | Why it matters | Target |
| --- | --- | --- |
| Time from profile complete to first interview booked | Core promise | \[TBD\] |
| Profile completion after resume upload | Low friction | \[TBD\] |
| Match click-through and booking rate | Match quality | \[TBD\] |
| Expert sessions per month and repeat rate | Revenue and value | \[TBD\] |
| Interview no-show and reschedule rate | Smooth operations | \[TBD\] |
| Time to hire (Phase 2) | Company value | \[TBD\] |
| Candidate and company satisfaction (CSAT / NPS) | Trust | \[TBD\] |

## 11. Assumptions and Dependencies

**Assumptions:** India is the first market; the team already has some candidates and experts; paid third-party services are budgeted.

**Dependencies:** video SDK, OTP/SMS provider, payment gateway, AI model provider, push/email provider, Apple and Google developer accounts.