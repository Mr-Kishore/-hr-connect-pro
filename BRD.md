# Business Requirements Document (BRD)

## HR Connect Pro / Career Connect

|  |  |
| --- | --- |
| **Version** | 0.1 (Draft for review) |
| **Date** | 1 October 2026 |
| **Status** | Draft. Items marked **\[TBC\]** or **\[TBD\]** need business input |
| **Related** | PRD v0.1, SRS (next) |

---

## 1. Executive Summary

We are a career guidance startup. We want to build **HR Connect Pro / Career Connect**, a platform that connects **candidates, companies, interviewers, and career experts**. Candidates find matched jobs, book interviews directly, and get expert help. Companies fill roles faster with less scheduling effort.

The platform will be built in phases. The first phase uses our existing strength (career guidance and experts) to reach users and revenue early. Later phases add company hiring tools.

## 2. Business Problem and Opportunity

**Problems today**

- Candidates apply and wait, often with no reply or feedback.
- Companies spend a lot of time screening and scheduling.
- Rejected candidates are left without direction.
- Quality career guidance is hard to find and hard to book.

**Opportunity.** Combine job discovery, instant interview booking, and paid expert guidance in one place. Existing job portals focus on listings and applications (for example, Naukri and LinkedIn), and expert-session platforms focus on mentoring (for example, Topmate). Few products connect all of these in one flow. **\[Competitor review to be completed\]**

## 3. Business Objectives

| # | Objective | Measure (proposed) |
| --- | --- | --- |
| BO-1 | Launch a working MVP that real users can use | MVP live by \[TBD date\] |
| BO-2 | Earn early revenue from expert sessions | \[TBD\] paid sessions per month by month \[TBD\] |
| BO-3 | Prove that candidates will self-book interviews | \[TBD\]% of matched candidates book a slot |
| BO-4 | Sign pilot companies | \[TBD\] verified companies by end of Phase 2 |
| BO-5 | Reduce time from job discovery to interview | Target: \[TBD\] days or less |
| BO-6 | Build trust through privacy, safety, and fair hiring | Zero serious data incidents; complaint rate below \[TBD\] |

## 4. Scope

**In scope (Phases 1 to 3):** candidate app (Android, iOS), expert marketplace with payments, AI resume and job reading, explainable matching, interview scheduling and pipeline, scorecards, offers, notifications, HR and admin web dashboard, audit logs, privacy controls.

**Out of scope for now:** courses and learning content, paid assessments, recruitment agency tools, large-enterprise ATS integration, salary intelligence, international expansion, our own video infrastructure, automatic AI hiring decisions.

## 5. Stakeholders

| Stakeholder | Interest |
| --- | --- |
| Founders / Management | Business success, funding story, budget control |
| Product owner | Scope, priorities, user value |
| Development team | Clear requirements and stable scope |
| Candidates | Faster interviews, fair treatment, useful guidance |
| Experts | Fair income, simple tools |
| Partner companies / HR | Quality candidates, less scheduling work |
| Interviewers | Clear schedules and simple feedback forms |
| Admin / Support team | Safe platform, easy review tools |
| Legal / Compliance advisor | Data protection, payments, consent |

## 6. Business Requirements

| ID | Business requirement | Priority |
| --- | --- | --- |
| BR-01 | The platform must let candidates register securely and keep one account per person. | Must |
| BR-02 | The platform must turn a resume into a usable profile with little manual work, and never invent data. | Must |
| BR-03 | The platform must show jobs with an explained match, not a bare score. | Must |
| BR-04 | The platform must let candidates book career experts for audio or video sessions and pay online. | Must |
| BR-05 | The platform must record each expert session for payout and commission, and support later payouts to experts. | Must |
| BR-06 | The platform must let verified companies post jobs and offer interview slots. | Must |
| BR-07 | The platform must let candidates book, and ask to reschedule, interviews, with company control over the rules. | Must |
| BR-08 | The platform must support multi-round interviews, structured feedback, and offers, with humans making all hiring decisions. | Must |
| BR-09 | The platform must verify companies and experts before they are shown as trusted. | Must |
| BR-10 | The platform must protect personal and company data and give candidates control (consent, export, deletion). | Must |
| BR-11 | The platform must notify users on key events (booking, reminders, changes, results, offers). | Must |
| BR-12 | The platform must give admins tools for verification, duplicate review, abuse handling, and reports. | Must |
| BR-13 | The platform must keep an audit trail of sensitive actions. | Must |
| BR-14 | The platform should give rejected candidates next steps: similar jobs, preparation, and expert help. | Should |
| BR-15 | The platform should offer AI help for candidates and HR, within strict permission and safety rules. | Should |
| BR-16 | The platform should provide hiring and marketplace reports for management and companies. | Could |

## 7. Business Model (Baseline)

| Revenue source | How it works | Phase |
| --- | --- | --- |
| **Expert session commission** | Candidate pays; platform retains a baseline 20% commission; expert receives 80% via nodal payout | 1 |
| **Company plans** | Subscription or pay-per-interview / pay-per-hire for job posting and scheduling tools | 2 |
| **Premium candidate services** | Advanced mock interview simulations, stage-specific AI preparation, or priority features | 2 to 3 |
| **Featured jobs / employer branding** | Companies pay for visibility | 3 |

*Commission % baseline:* **20%** platform fee (configurable per category/expert tier). Company plans and tiers finalized prior to Phase 2 launch.

## 8. Business Rules

1. Only verified companies can publish jobs. Free email domains (Gmail, Yahoo) do not count as verified company identity.
2. A company decides how candidates may book (open booking, minimum match %, or approval) and sets slot caps per job.
3. Interviewer comments are private unless the company explicitly allows sharing.
4. Recording happens only with clear notice and dual-party consent.
5. AI can suggest and summarize, but humans make all final hiring decisions.
6. A suspected duplicate account goes to review; it is never blocked permanently by software alone.
7. An expert must not advise a candidate for a company where they have an active conflict of interest (e.g., currently employed at the target hiring company).
8. **Refunds and cancellations for expert sessions**:
   - 100% refund if cancelled >24 hours before session start time.
   - 50% refund if cancelled between 4 and 24 hours before session start time.
   - Non-refundable if cancelled <4 hours before session start time.
   - 100% full refund automatically issued if expert cancels or fails to attend (no-show).
9. **Interview Rescheduling**: Candidates can request a maximum of 2 reschedules per interview round; further requests require HR escalation to prevent interview slot hoarding.

## 9. Compliance and Legal Considerations

*(To be confirmed by a legal advisor.)*

- **Data protection:** India Digital Personal Data Protection Act 2023 (consent, purpose limits, deletion rights). Other countries will need separate review.
- **Payments & Escrow:** Under Reserve Bank of India (RBI) Payment Aggregator (PA) guidelines, customer funds for third-party payouts must not be held in proprietary company accounts. All marketplace transactions utilize licensed PA nodal/escrow routing (e.g., Razorpay Route / Cashfree Split) with automated settlement upon verified session delivery.
- **Mobile App Store Guidelines:** 1-on-1 real-time live consultations qualify as peer-to-peer real-time personal services under Apple App Store Guideline 3.1.3(d), exempt from Apple In-App Purchase (IAP) 30% digital fee deductions when booked for live interaction.
- **Recording and consent:** Clear notice, consent records, and retention limits.
- **Fair hiring:** Automated matching can be seen as high-risk in some regions. Keep matches explainable and review for bias.
- **Terms and policies:** Terms of use, privacy policy, expert agreement, company agreement, refund policy.

## 10. Assumptions and Constraints

**Assumptions**

- India is the first market.
- We already have, or can quickly gather, some candidates and experts.
- Pilot companies can be found through our network.
- Budget covers third-party services (video, OTP/SMS, payments, AI usage, push/email, Apple and Google accounts).

**Constraints**

- Small team and limited budget **\[TBD\]**.
- Mobile apps will use Flutter for Android and iOS.
- iOS release needs a Mac and a paid Apple Developer account.
- Third-party service pricing and limits can change.

## 11. Business Risks and Responses

| Risk | Impact | Response |
| --- | --- | --- |
| Scope is too large | Delay, cost overrun | Phased delivery, fixed scope per phase, change-request process |
| Few companies at launch | Few jobs, weak candidate value | Pilot companies, partner jobs, start with expert revenue |
| Interviewers overloaded by self-booking | Companies leave | Booking rules, slot caps, match thresholds |
| Wrong duplicate detection | Real users blocked | Human review, recovery path |
| Data breach or misuse | Legal and trust damage | Security controls, audits, least-privilege access |
| Poor expert quality or conflicts | Brand damage | Verification, ratings, conflict rules |
| Payment or payout issues | Financial and legal risk | Established partner, clear policies |
| Bias or opaque AI | Unfair outcomes, regulation | Explainable matches, human decisions, audit records |

## 12. Success Criteria

The first release is a business success when:

1. Real candidates complete sign-up and profile with little manual work.
2. Real expert sessions are booked, completed, and paid, with correct commission records.
3. At least \[TBD\] pilot companies run real interviews through the platform (Phase 2).
4. No serious security or privacy incident occurs.
5. Users and companies rate the experience at or above \[TBD\].

## 13. Indicative Timeline and Budget

| Phase | Content | Duration | Cost |
| --- | --- | --- | --- |
| Phase 0 | Architecture, database design, API design, user flows, security plan | \[TBD\] | \[TBD\] |
| Phase 1 | Candidates, experts, payments, AI profile and prep | \[TBD\] | \[TBD\] |
| Phase 2 | Companies, scheduling, interviews, offers, notifications, HR web | \[TBD\] | \[TBD\] |
| Phase 3 | Duplicate review, recording, HR AI, analytics | \[TBD\] | \[TBD\] |

Estimates should be set after Phase 0, when the architecture is approved.

## 14. Approval

| Name | Role | Decision | Date |
| --- | --- | --- | --- |
|  | Founder / Management |  |  |
|  | Product Owner |  |  |
|  | Technical Lead |  |  |