# Exemplos de Specs: Boa vs. Ruim

These examples use the "Email Notifications" feature to illustrate the difference.

---

## ❌ Spec Ruim — Score: 32/100

```markdown
# Spec: Notifications

## O que vamos fazer
Implement email notifications for users when something important happens.

## Requisitos
- The system must send emails
- Emails must look good
- User must be able to disable notifications
- It must be fast

## Technical notes
Usar SendGrid ou SES. Talvez usar fila SQS.
```

### Why it's bad:

| Problema | Impacto |
|---------|---------|
| "when something important happens" — what is important? | Dev will implement what he thinks is right, not what the business wants |
| "emails should be pretty" — not testable | No acceptance criteria possible |
| "must be quick" — no number | Bug: email takes 5min, dev thinks it's ok |
| Non-goals ausentes | Scope creep: "e o SMS? e o push notification?" |
| Edge cases missing | What happens if the email bounces? If the user deactivated? |
| Mixing spec with technical decision (SendGrid/SES/SQS) | Couples the “what” with the “how” unnecessarily |
| No Requirement ID | Impossible to track which requirement a PR implemented |

---

## ✅ Spec Boa — Score: 87/100

```markdown
# Spec: Email Notifications — Account Activity

**Version:** 1.0 | **Status:** Approved | **Date:** 2025-01-15

## 1. Summary
Send transactional email notifications to users when relevant events
account changes occur, with granular control of notification preferences.

## 2. Context and Motivation
**Issue:** Users miss important actions (e.g. new comment, payment processed)
because they only find out when accessing the app. Result: late engagement and task abandonment.
**Evidence:** 68% of inactive users cited "I didn't know there was anything waiting"
na pesquisa de churn de Dez/2024.
**Why now:** Hired email platform (SendGrid), viable integration in 1 sprint.

## 3. Goals
- [ ] G-01: Users receive email in < 2 min after trigger event
- [ ] G-02: Open rate ≥ 25% (benchmark: 21% in the industry)
- [ ] G-03: 100% of users can disable notifications in ≤ 3 clicks

## 4. Non-Goals
- NG-01: Push notifications (mobile) — future release
- NG-02: Notifications by SMS — outside the 2025 roadmap
- NG-03: E-mails de marketing / newsletter — escopo do time de Growth
- NG-04: Support multiple email addresses per user

## 5. Users
**Primary:** User with an active account, any plan.
**Current journey:** User needs to log into the app to see if there is any news.
**Future journey:** User receives email with summary of the event and direct link to the action.

## 6. Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-----------|-----------|-------------------|
| RF-01 | The system should send email when a comment is added to a user item | Must | Email received in < 2 minutes in 95% of cases (test with 100 sends) |
| RF-02 | The system should send an email when a payment is processed (success or failure) | Must | Email received in < 2 min; includes value, date and status |
| RF-03 | The user must be able to disable each type of notification individually in Settings > Notifications | Must | Toggle persists after logout/login; deactivated email is not sent |
| RF-04 | The system must include a "cancel all notifications" link in the footer of every email | Must | Link works without login; redirects to confirmation page |
| RF-05 | The system must group notifications of the same type in daily digest when there are > 5 events in 1h | Should | User receives 1 email with a list of 5+ events, not 5+ separate emails |

### Main Flow (RF-01)
1. User B comments on User A's item
2. System detects event `comment.created`
3. System checks if User A has RF-01 activated (default: active)
4. System sends an email to User A with: name of the commenter, excerpt of the comment (max. 200 characters), direct link to the item
5. Result: User A receives email in < 2 min

## 7. Non-Functional Requirements
| ID | Requisito | Target |
|----|-----------|--------|
| RNF-01 | Send latency | P95 < 2min after event |
| RNF-02 | Delivery rate | ≥ 98% (excluding permanent bounces) |
| RNF-03 | Security | Unsubscribe links with unique and signed token |

## 11. Edge Cases

| ID | Scenario | Trigger | Behavior |
|----|---------|---------|---------------|
| EC-01 | Invalid email/permanent bounce | SendGrid returns hard bounce | Disable sending to this email; notify user in-app |
| EC-02 | User disabled notifications | `user.notifications.comments = false` | Does not send; does not record error |
| EC-03 | SendGrid unavailable | Timeout or error 5xx | Retry with backoff: 1min, 5min, 30min. After 3 failures: log in and alert team |
| EC-04 | User deleted account before sending | User ID not found in queue | Discard silently; log in for audit |
| EC-05 | Same event triggers 2x | Duplicity bug | Deduplicate by event_id with TTL of 1h |

## 14. Open Questions
| # | Question | Impact | Deadline |
|---|---------|---------|-------|
| OQ-01 | ⚠️ ABERTO: Daily digest (RF-05) — what is the shipping time? User timezone or UTC? | Medium | 01/20 |
```

### Why it’s good:

| Strong point | Benefit |
|------------|-----------|
| Each requirement has an ID, priority and acceptance criteria | QA writes tests straight from the table |
| Explicit non-goals (4 items) | Team knows exactly what to refuse |
| Edge cases cover external failures | Dev implements retry without asking |
| Numerical metrics (< 2min, ≥ 25%) | Success is verifiable |
| Open Question flagged with `⚠️ ABERTO:` | Visible, not silent ambiguity |
| Main flow step by step | LLM implements without guesswork |

---

## 🔶 Average Spec — Score: 63/100

```markdown
# Spec: Login with Google

## Objective
Allow users to sign in using their Google account.

## Requisitos
- RF-01: Add "Sign in with Google" button on login screen
- RF-02: User should be redirected to OAuth from Google
- RF-03: After authentication, create user session
- RF-04: If the email already exists in the system, log in to the existing account
- RF-05: If the email does not exist, create a new account automatically

## Fora do escopo
- Login with Facebook/Apple for now

## Edge Cases
- What if the user cancels the flow OAuth?
- What if Google is down?
```

### What's good:
- Requisitos numerados ✅
- Non-goals presentes ✅
- Edge cases identified (but no response) ⚠️

### What's missing (-37 points):
- Edge cases without defined behavior — "what if?" no response (-10)
- No acceptance criteria in the requirements (-7)
- Missing security section (OAuth data, tokens) (-8)
- No success metrics (-7)
- RF-03 "create session" — for how long? With what data? (-5)
