# Backend API Quick Reference - iOS UX Upgrade

**TL;DR for Backend Devs:** New iOS UX needs 4 new endpoints + enhancements to existing ones.

---

## 🚀 New Endpoints Needed

### 1. User Preferences (HIGH PRIORITY)
**Status:** ✅ Implemented in backend API (2025-10-16)
```
POST   /v1/user/preferences   - Save onboarding preferences
GET    /v1/user/preferences   - Retrieve user preferences
```

**What it does:** Stores when user wants to plan (morning/evening), notification prefs, timezone

**When it's called:** During onboarding (screen 3) and settings updates

**Response time:** <100ms (p95)

---

### 2. Smart List Classification (HIGH PRIORITY)
**Status:** ✅ Implemented in backend API (2025-10-16)
```
POST   /v1/items/classify     - Classify item text → list type
```

**What it does:** AI analyzes "Call dentist" → suggests "Watch" list

**When it's called:** Every time user types in Quick Capture

**Response time:** <500ms (p95) - CRITICAL for UX

**Example:**
```json
Request:  { "text": "Call dentist about appointment" }
Response: { "suggestedListType": "watch", "confidence": 0.87 }
```

---

### 3. User Insights (MEDIUM PRIORITY)
**Status:** ✅ Implemented in backend API (2026-01-12)
```
GET    /v1/user/insights      - Analytics & personalization data
```

**What it does:** "You complete 20% more on Tuesdays" type insights

**When it's called:** Dashboard load, planning wizard

**Response time:** <400ms (p95)

**Example:**
```json
{
  "completionPatterns": {
    "bestDayOfWeek": "Tuesday",
    "bestTimeOfDay": "morning",
    "averageCompletionRate": 0.78,
    "streak": 12
  },
  "listHealth": {
    "todo": { "count": 8, "staleItems": 2 },
    "watch": { "count": 5, "avgDwellTime": 3.2 },
    "later": { "count": 12, "staleItems": 7 }
  },
  "suggestions": [
    {
      "type": "insight",
      "message": "You complete more on Tuesdays — plan deep work then.",
      "actionable": true
    },
    {
      "type": "warning",
      "message": "Later list is piling up (7 older ideas). Time for a prune?",
      "actionable": true
    }
  ]
}
```

---

## 🔧 Enhanced Endpoints

### 4. Focus Card Generation (EXISTING - ENHANCE)
```
POST   /v1/focus-card/generate
```

**Status:** ✅ Suggestion-only response implemented (2026-01-12)

**What's new:**
- Smarter item selection (consider due dates, calendar)
- Auto-generate theme based on item content
- Estimate energy budget from calendar density
- Generate success metric automatically
- Return AI suggestion payload (no DB writes) so clients can preview before saving

**Why:** Planning wizard goes from 4 steps → 2 steps (user just accepts AI suggestions)

**Response shape:**
```json
{
  "suggestedItems": ["item-123", "item-456"],
  "theme": "Clear the critical follow-ups",
  "energyBudget": "medium",
  "successMetric": "Complete 2 priority follow-ups",
  "reasoning": {
    "itemSelection": "Prioritised tasks with deadlines in the next 48 hours.",
    "themeRationale": "Shared phrasing across chosen items signalled follow-up work.",
    "energyEstimate": "Calendar density of 210 minutes informed the medium energy call."
  }
}
```

---

## 📊 Database Changes

```sql
-- Add to users table
ALTER TABLE users ADD COLUMN planning_time VARCHAR(20) DEFAULT 'evening';
ALTER TABLE users ADD COLUMN planning_hour INTEGER DEFAULT 19;
ALTER TABLE users ADD COLUMN notifications_enabled BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN timezone VARCHAR(50) DEFAULT 'UTC';
ALTER TABLE users ADD COLUMN onboarding_version VARCHAR(10) DEFAULT '3.0';
```

---

## 🤖 ML Model Requirements

### Item Classification Model

**Input:** Text string (e.g., "Call dentist about appointment")

**Output:**
- List type (todo/watch/later)
- Confidence score (0.0-1.0)

**Training Data Needed:**
- Existing user items labeled by list type
- User corrections when they override AI suggestion

**Accuracy Target:** >75% (user agrees with suggestion)

**Classification Logic:**
- **Todo:** "finish", "complete", "write", "send" + no dependencies
- **Watch:** "call", "follow up", "wait for" + external dependency
- **Later:** "research", "explore", "consider" + non-urgent

---

## 🔔 Notification Scheduling

**New Background Job Needed:**

```typescript
// Run daily for all users
function schedulePlanningReminders() {
  users.forEach(user => {
    const prefs = getUserPreferences(user.id);

    if (!prefs.notificationsEnabled) return;

    // Schedule at user's preferred time in their timezone
    const localTime = convertToTimezone(
      { hour: prefs.planningHour, minute: 0 },
      prefs.timezone
    );

    scheduleNotification({
      userId: user.id,
      time: localTime,
      message: "Ready to plan tomorrow? 🎯",
      deepLink: "andre://plan-tomorrow"
    });
  });
}
```

---

## 📈 Analytics Events to Track

```typescript
// Onboarding
'onboarding_started'
'onboarding_screen_viewed' // { screenIndex, screenName, timeSpent }
'onboarding_completed'
'onboarding_skipped'

// Quick Capture
'item_classified' // { suggestedListType, confidence, userAgreed }
'classification_overridden' // When user changes AI suggestion

// Planning
'planning_started'
'ai_suggestions_used' // { itemCount, customizedTheme }
'planning_completed' // { completionTimeSeconds }
```

---

## ⚡ Performance Budgets

| Endpoint | P95 Target | Fallback Strategy |
|----------|------------|-------------------|
| /items/classify | <500ms | Default to "todo" |
| /focus-card/generate | <800ms | Show empty state |
| /user/insights | <400ms | Cache last result |

---

## 🚦 Rollout Plan

### Phase 1: Backend (Week 1)
- [ ] Deploy new endpoints to staging
- [ ] Run contract tests
- [ ] Feature flag OFF in production

### Phase 2: iOS Beta (Week 2)
- [ ] iOS app submitted to App Store
- [ ] Enable for 10% of users
- [ ] Monitor error rates & performance
- [ ] Ramp to 100% over 3 days

### Phase 3: Monitor (Week 3+)
- [ ] Track ML model accuracy
- [ ] Retrain model with user feedback
- [ ] A/B test different algorithms

---

## 🆘 Rollback Triggers

**Disable feature flag if:**
- Error rate >1%
- Response time p95 >2x target
- ML classification accuracy <60%
- User complaints >5% of actives

---

## 🔗 Dependencies

**Must Have Before iOS Launch:**
1. ✅ POST /v1/user/preferences
2. ✅ GET /v1/user/preferences
3. ✅ POST /v1/items/classify (even if simple heuristic)
4. ✅ Notification scheduler job

**Nice to Have:**
5. ⚠️ Enhanced focus card generation
6. ⚠️ GET /v1/user/insights
7. ⚠️ ML model (can start with rule-based)

---

## 📞 Questions?

- **Detailed Spec:** See `ios-ux-upgrade-backend-requirements.md`
- **Slack:** #andre-ux-upgrade
- **iOS Team:** [Your Name]
- **Backend Lead:** [Backend Lead]

---

**Status:** ✅ iOS implementation started (Phase 1 onboarding complete)
**Backend Status:** ⏳ Waiting on implementation
**Target Production Date:** Week 2 (pending backend)
