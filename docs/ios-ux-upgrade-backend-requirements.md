# iOS UX Upgrade - Backend Integration Requirements

**Version:** 1.0
**Date:** 2025-10-15
**Author:** iOS Team
**Status:** Phase 1 Implementation

---

## Executive Summary

The iOS app is undergoing a comprehensive UX upgrade following iOS 26 best practices. This document outlines all backend changes, API requirements, and data model updates needed to support the new user experience.

**Key Changes:**
- Streamlined 3-screen onboarding (from 12 screens)
- Smart Quick Capture with AI list detection
- User preference storage for personalization
- Enhanced planning workflow (4 steps → 2 steps)
- Contextual intelligence features

---

## 1. Onboarding Changes

### 1.1 Overview
**Old Flow:** 12 screens with complex state tracking
**New Flow:** 3 screens with minimal data collection

### 1.2 User Preferences API

**Status:** ✅ Implemented in backend API (2025-10-16)

**New Endpoint Required:**
```http
POST /v1/user/preferences
PUT /v1/user/preferences
GET /v1/user/preferences
```

**Request/Response Schema:**
```typescript
interface UserPreferences {
  userId: string;
  planningTime: 'morning' | 'evening' | 'custom';
  planningHour?: number; // 0-23, only if planningTime === 'custom'
  notificationsEnabled: boolean;
  timezone: string; // IANA timezone (e.g., 'America/New_York')
  onboardingCompletedAt: string; // ISO 8601 timestamp
  onboardingVersion: string; // e.g., '3.0' for new flow
}
```

**Example Request:**
```json
{
  "planningTime": "evening",
  "planningHour": 19,
  "notificationsEnabled": true,
  "timezone": "America/Los_Angeles",
  "onboardingCompletedAt": "2025-10-15T20:30:00Z",
  "onboardingVersion": "3.0"
}
```

**Business Logic:**
- Store preferences in user profile
- Use `planningTime` + `planningHour` to schedule notification reminders
- `timezone` ensures correct local time for notifications
- Track `onboardingVersion` for analytics and feature flagging

### 1.3 Migration Notes
- Existing users have no preferences → Use smart defaults:
  - `planningTime: 'evening'`
  - `planningHour: 19` (7 PM)
  - `notificationsEnabled: true`
  - Infer timezone from IP or previous session data

---

## 2. Smart Quick Capture

### 2.1 Overview
**Old Behavior:** User manually selects list type (Todo/Watch/Later)
**New Behavior:** AI analyzes text and auto-suggests list type

### 2.2 Smart List Detection API

**Status:** ✅ Implemented in backend API (2025-10-16)

**New Endpoint Required:**
```http
POST /v1/items/classify
```

**Purpose:** Analyze item text and suggest appropriate list type

**Request Schema:**
```typescript
interface ClassifyItemRequest {
  text: string; // The item text to classify
  userId: string; // For personalized ML model
  context?: {
    currentTime: string; // ISO 8601
    recentItems?: string[]; // Last 5 items for context
  };
}
```

**Response Schema:**
```typescript
interface ClassifyItemResponse {
  suggestedListType: 'todo' | 'watch' | 'later';
  confidence: number; // 0.0 to 1.0
  reasoning?: string; // Optional explanation (for debugging)
  alternatives?: Array<{
    listType: 'todo' | 'watch' | 'later';
    confidence: number;
  }>;
}
```

**Example Request:**
```json
{
  "text": "Call dentist about appointment",
  "userId": "user-123",
  "context": {
    "currentTime": "2025-10-15T14:30:00Z"
  }
}
```

**Example Response:**
```json
{
  "suggestedListType": "watch",
  "confidence": 0.87,
  "reasoning": "Waiting for external party (dentist office)",
  "alternatives": [
    { "listType": "todo", "confidence": 0.10 },
    { "listType": "later", "confidence": 0.03 }
  ]
}
```

### 2.3 Classification Rules (ML Model Guidelines)

**Todo:** Tasks the user can complete immediately
- Keywords: "finish", "complete", "write", "send", "review"
- Action verbs with no dependencies
- Example: "Finish project proposal"

**Watch:** Tasks waiting on others or future events
- Keywords: "call", "follow up", "check", "wait for", "schedule"
- Involves coordination with others
- Example: "Follow up with Sarah on partnership"

**Later:** Research, ideas, or deferred priorities
- Keywords: "research", "explore", "consider", "look into", "maybe"
- Non-urgent exploratory tasks
- Example: "Research calendar integration options"

### 2.4 Fallback Behavior
- If `confidence < 0.6`, show all 3 options to user
- If API fails, default to Todo and allow manual override
- Cache classifications locally for offline mode

### 2.5 Performance Requirements
- Response time: <500ms (p95)
- Availability: >99.5%
- Rate limit: 100 requests/minute per user

---

## 3. Planning Wizard Optimization

### 3.1 Overview
**Old Flow:** 4 steps (Select Items → Theme → Success → Review)
**New Flow:** 2 screens (Smart Selection → Optional Customization)

### 3.2 AI-Powered Planning Suggestions

**Enhanced Endpoint:**
```http
POST /v1/focus-card/generate
```

**Request Schema:**
```typescript
interface GenerateFocusCardRequest {
  userId: string;
  targetDate: string; // ISO 8601 date (e.g., '2025-10-16')
  availableItems?: Array<{
    id: string;
    title: string;
    listType: 'todo' | 'watch' | 'later';
    dueAt?: string;
    priority?: number;
  }>;
  context?: {
    calendarEvents?: Array<{
      title: string;
      startTime: string;
      endTime: string;
    }>;
    historicalCompletionRate?: number;
    averageEnergyLevel?: 'low' | 'medium' | 'high';
  };
}
```

**Response Schema:**
```typescript
interface GenerateFocusCardResponse {
  suggestedItems: string[]; // Array of item IDs (1-5 items)
  theme: string; // AI-generated theme
  energyBudget: 'low' | 'medium' | 'high';
  successMetric: string; // AI-generated success criterion
  reasoning: {
    itemSelection: string; // Why these items?
    themeRationale: string; // Why this theme?
    energyEstimate: string; // Why this energy level?
  };
}
```

**Example Response:**
```json
{
  "suggestedItems": ["item-abc-123", "item-def-456", "item-ghi-789"],
  "theme": "Ship critical Q4 deliverables",
  "energyBudget": "high",
  "successMetric": "Complete project proposal and send to stakeholders",
  "reasoning": {
    "itemSelection": "Selected items with approaching deadlines and high impact",
    "themeRationale": "Multiple items relate to Q4 goals and external deadlines",
    "energyEstimate": "Calendar shows morning deep work blocks available"
  }
}
```

### 3.3 Business Logic Requirements

**Item Selection Algorithm:**
1. Prioritize items with approaching due dates (next 3 days)
2. Balance across list types (prefer 2-3 Todo, 1-2 Watch/Later)
3. Consider historical completion patterns (what user actually completes)
4. Limit to 3-5 items total (sweet spot: 4 items)

**Theme Generation:**
- Analyze common themes across selected items
- Use natural language (user-friendly, not technical)
- Keep concise (max 50 characters)
- Examples:
  - "Focus on launching new features"
  - "Clear communication blockers"
  - "Make progress on research initiatives"

**Energy Budget Estimation:**
- Parse calendar data for meeting density
- Consider historical patterns (morning person vs. evening person)
- Factor in day of week (Monday = higher energy typically)
- Default to `medium` if insufficient data

**Success Metric Generation:**
- Concrete, measurable outcome
- Related to selected items
- Positive framing
- Examples:
  - "Ship the API design document"
  - "Complete at least 3 of 4 planned items"
  - "Unblock the team on two critical decisions"

---

## 4. User Preferences & Personalization

### 4.1 Notification Scheduling

**New Background Job Required:**

```typescript
// Pseudocode for notification scheduler
function scheduleUserPlanningReminder(user: User) {
  const prefs = getUserPreferences(user.id);

  if (!prefs.notificationsEnabled) return;

  let scheduledTime: Time;

  if (prefs.planningTime === 'morning') {
    scheduledTime = { hour: 8, minute: 0 }; // 8 AM local
  } else if (prefs.planningTime === 'evening') {
    scheduledTime = { hour: 19, minute: 0 }; // 7 PM local
  } else {
    scheduledTime = { hour: prefs.planningHour, minute: 0 };
  }

  // Convert to user's timezone
  const localTime = convertToTimezone(scheduledTime, prefs.timezone);

  // Schedule daily notification
  scheduleNotification({
    userId: user.id,
    time: localTime,
    message: "Ready to plan tomorrow? 🎯",
    actionUrl: "andre://plan-tomorrow",
    recurring: 'daily'
  });
}
```

**Notification Content:**
```typescript
interface PlanningReminderNotification {
  title: string; // "Ready to plan tomorrow?"
  body: string; // "Take 2 minutes to set your focus"
  actionButton: string; // "Plan Now"
  deepLink: string; // "andre://plan-tomorrow"
  category: 'planning-reminder';
}
```

### 4.2 Contextual Intelligence

**New Endpoint:**
```http
GET /v1/user/insights
```

**Purpose:** Provide contextual insights for smarter UX

**Response Schema:**
```typescript
interface UserInsights {
  completionPatterns: {
    bestDayOfWeek: string; // e.g., "Tuesday"
    bestTimeOfDay: 'morning' | 'afternoon' | 'evening';
    averageCompletionRate: number; // 0.0 to 1.0
    streak: number; // days
  };
  listHealth: {
    todo: { count: number; staleItems: number };
    watch: { count: number; avgDwellTime: number }; // days
    later: { count: number; staleItems: number };
  };
  suggestions: Array<{
    type: 'insight' | 'warning' | 'encouragement';
    message: string;
    actionable: boolean;
  }>;
}
```

**Example Response:**
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
      "message": "You complete 20% more items on Tuesdays - plan accordingly",
      "actionable": true
    },
    {
      "type": "warning",
      "message": "Watch items stay 3 days on average - consider moving some to Todo or Later",
      "actionable": true
    },
    {
      "type": "encouragement",
      "message": "12-day streak! You're building serious momentum 🔥",
      "actionable": false
    }
  ]
}
```

---

## 5. Data Model Updates

### 5.1 User Table

**Add Columns:**
```sql
ALTER TABLE users ADD COLUMN planning_time VARCHAR(20) DEFAULT 'evening';
ALTER TABLE users ADD COLUMN planning_hour INTEGER DEFAULT 19;
ALTER TABLE users ADD COLUMN notifications_enabled BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN timezone VARCHAR(50) DEFAULT 'UTC';
ALTER TABLE users ADD COLUMN onboarding_version VARCHAR(10) DEFAULT '3.0';
ALTER TABLE users ADD COLUMN onboarding_completed_at TIMESTAMP;
```

### 5.2 Analytics Events

**New Events to Track:**
```typescript
// Onboarding analytics
interface OnboardingEvent {
  event: 'onboarding_started' | 'onboarding_screen_viewed' | 'onboarding_completed' | 'onboarding_skipped';
  userId: string;
  timestamp: string;
  properties: {
    screenIndex?: number; // 0, 1, 2
    screenName?: string; // 'value_prop', 'demo', 'personalization'
    timeSpent?: number; // seconds
    version: string; // '3.0'
  };
}

// Quick Capture analytics
interface QuickCaptureEvent {
  event: 'quick_capture_opened' | 'item_classified' | 'classification_overridden';
  userId: string;
  timestamp: string;
  properties: {
    itemText?: string;
    suggestedListType?: string;
    actualListType?: string;
    confidence?: number;
    userAgreed?: boolean;
  };
}

// Planning Wizard analytics
interface PlanningWizardEvent {
  event: 'planning_started' | 'ai_suggestions_used' | 'planning_completed';
  userId: string;
  timestamp: string;
  properties: {
    itemCount?: number;
    usedAiSuggestions?: boolean;
    customizedTheme?: boolean;
    completionTimeSeconds?: number;
  };
}
```

---

## 6. API Performance Requirements

### 6.1 Response Time Targets

| Endpoint | P50 | P95 | P99 |
|----------|-----|-----|-----|
| POST /v1/items/classify | 200ms | 500ms | 1000ms |
| POST /v1/focus-card/generate | 300ms | 800ms | 1500ms |
| GET /v1/user/preferences | 50ms | 100ms | 200ms |
| GET /v1/user/insights | 150ms | 400ms | 800ms |

### 6.2 Availability Targets

- **Overall:** 99.9% uptime
- **ML Endpoints:** 99.5% (graceful degradation if down)
- **Notification Delivery:** 99% within 1 minute of scheduled time

### 6.3 Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| POST /v1/items/classify | 100 req | 1 minute |
| POST /v1/focus-card/generate | 20 req | 5 minutes |
| GET /v1/user/insights | 60 req | 1 minute |

---

## 7. Testing Requirements

### 7.1 Contract Tests

Create contract tests for all new endpoints:

```typescript
// Example: Item classification contract
describe('POST /v1/items/classify', () => {
  it('should return valid list type suggestion', async () => {
    const response = await request(app)
      .post('/v1/items/classify')
      .send({
        text: 'Call dentist about appointment',
        userId: 'test-user-123'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('suggestedListType');
    expect(['todo', 'watch', 'later']).toContain(response.body.suggestedListType);
    expect(response.body.confidence).toBeGreaterThanOrEqual(0);
    expect(response.body.confidence).toBeLessThanOrEqual(1);
  });

  it('should handle low confidence scenarios', async () => {
    const response = await request(app)
      .post('/v1/items/classify')
      .send({
        text: 'xyz', // Ambiguous text
        userId: 'test-user-123'
      });

    expect(response.status).toBe(200);
    if (response.body.confidence < 0.6) {
      expect(response.body.alternatives).toBeDefined();
      expect(response.body.alternatives.length).toBeGreaterThan(0);
    }
  });
});
```

### 7.2 Load Testing

**Scenarios to Test:**
1. **Onboarding Spike:** 1000 new users completing onboarding simultaneously
2. **Evening Planning Rush:** 50% of users planning between 7-8 PM local time
3. **Quick Capture Burst:** User adding 10 items in rapid succession

**Expected Performance:**
- No degradation in response times during peak hours
- Queue depth for notifications < 100 items
- ML model inference time < 200ms (p95)

### 7.3 ML Model Validation

**Classification Accuracy Requirements:**
- Overall accuracy: >75% (user agrees with suggestion)
- High confidence (>0.8) accuracy: >90%
- Fallback rate (confidence <0.6): <20% of requests

**Monitoring:**
- Track user override rate (when they change suggested list type)
- A/B test classification algorithms
- Retrain model monthly with new data

---

## 8. Migration Plan

### 8.1 Phased Rollout

**Phase 1: Backend Deployment (Week 1)**
- Deploy new endpoints to staging
- Run contract tests
- Load test with synthetic data
- Deploy to production (feature-flagged off)

**Phase 2: iOS App Deployment (Week 2)**
- Submit iOS app update to App Store
- Enable feature flag for 10% of users (beta)
- Monitor analytics and error rates
- Gradually increase to 100% over 3 days

**Phase 3: Migration (Week 3)**
- Existing users see old onboarding on first login after update
- New users see new 3-screen onboarding
- Prompt existing users to set preferences in settings

### 8.2 Rollback Strategy

**If Issues Detected:**
1. **Disable feature flag** → All users see old UX
2. **Fix issues** in new endpoints
3. **Re-enable for 10%** → Validate fix
4. **Gradually re-ramp** to 100%

**Rollback Triggers:**
- Error rate >1%
- Response time p95 >2x target
- User complaints >5% of daily actives
- Notification delivery <95%

---

## 9. Developer Checklist

### Backend Developer Tasks

#### Onboarding (Priority: HIGH)
- [ ] Create `UserPreferences` database model
- [ ] Implement `POST /v1/user/preferences` endpoint
- [ ] Implement `GET /v1/user/preferences` endpoint
- [ ] Add migration for new user table columns
- [ ] Write contract tests for preferences endpoints
- [ ] Set up notification scheduler job
- [ ] Configure timezone handling

#### Smart Quick Capture (Priority: HIGH)
- [ ] Research/select ML classification model
- [ ] Train initial model on sample data
- [ ] Implement `POST /v1/items/classify` endpoint
- [ ] Set up model inference infrastructure
- [ ] Add classification accuracy monitoring
- [ ] Implement caching for common phrases
- [ ] Write contract tests for classification endpoint
- [ ] Load test classification under peak load

#### Planning Wizard AI (Priority: MEDIUM)
- [ ] Enhance existing `POST /v1/focus-card/generate` endpoint
- [ ] Implement item selection algorithm
- [ ] Implement theme generation logic
- [ ] Implement energy budget estimation
- [ ] Implement success metric generation
- [ ] Add calendar integration parsing
- [ ] Write contract tests for generation endpoint
- [ ] Add reasoning/explanation fields

#### Contextual Intelligence (Priority: MEDIUM)
- [ ] Implement `GET /v1/user/insights` endpoint
- [ ] Build completion pattern analysis
- [ ] Build list health metrics
- [ ] Generate actionable suggestions
- [ ] Write contract tests for insights endpoint

#### Analytics (Priority: LOW)
- [ ] Set up new event tracking schema
- [ ] Implement onboarding events
- [ ] Implement quick capture events
- [ ] Implement planning wizard events
- [ ] Create analytics dashboard

#### Infrastructure (Priority: HIGH)
- [ ] Set up feature flags for gradual rollout
- [ ] Configure rate limiting
- [ ] Set up monitoring alerts
- [ ] Configure error tracking
- [ ] Set up performance dashboards

---

## 10. API Examples

### Complete Quick Capture Flow

```typescript
// 1. User types: "Call dentist about appointment"
// 2. iOS app calls classification endpoint

POST /v1/items/classify
{
  "text": "Call dentist about appointment",
  "userId": "user-abc-123",
  "context": {
    "currentTime": "2025-10-15T14:30:00Z"
  }
}

// 3. Backend responds with suggestion
{
  "suggestedListType": "watch",
  "confidence": 0.87,
  "reasoning": "Waiting for external party to respond"
}

// 4. iOS app shows suggestion to user, user accepts

POST /v1/lists
{
  "title": "Call dentist about appointment",
  "listType": "watch",
  "status": "planned",
  "createdAt": "2025-10-15T14:30:00Z",
  "classificationUsed": true,
  "classificationConfidence": 0.87
}

// 5. Backend creates item and returns canonical version
{
  "id": "item-xyz-789",
  "title": "Call dentist about appointment",
  "listType": "watch",
  "status": "planned",
  "createdAt": "2025-10-15T14:30:00Z",
  "updatedAt": "2025-10-15T14:30:00Z"
}
```

### Complete Planning Flow

```typescript
// 1. User opens planning wizard for tomorrow
// 2. iOS app requests AI suggestions

POST /v1/focus-card/generate
{
  "userId": "user-abc-123",
  "targetDate": "2025-10-16",
  "availableItems": [
    { "id": "item-1", "title": "Finish project proposal", "listType": "todo", "dueAt": "2025-10-17" },
    { "id": "item-2", "title": "Review PR from Sarah", "listType": "todo" },
    { "id": "item-3", "title": "Research calendar APIs", "listType": "later" },
    { "id": "item-4", "title": "Follow up on partnership", "listType": "watch" }
  ],
  "context": {
    "calendarEvents": [
      { "title": "Team standup", "startTime": "2025-10-16T09:00:00Z", "endTime": "2025-10-16T09:30:00Z" },
      { "title": "Client call", "startTime": "2025-10-16T14:00:00Z", "endTime": "2025-10-16T15:00:00Z" }
    ],
    "historicalCompletionRate": 0.75
  }
}

// 3. Backend generates smart suggestions
{
  "suggestedItems": ["item-1", "item-2", "item-4"],
  "theme": "Ship critical deliverables",
  "energyBudget": "medium",
  "successMetric": "Complete project proposal and review PR",
  "reasoning": {
    "itemSelection": "Prioritized due date and dependencies",
    "themeRationale": "Focus on shipping and unblocking others",
    "energyEstimate": "Moderate meeting load allows focused work"
  }
}

// 4. User accepts or customizes, then creates focus card

PUT /v1/focus-card
{
  "date": "2025-10-16",
  "items": [
    { "id": "item-1", "title": "Finish project proposal", "listType": "todo" },
    { "id": "item-2", "title": "Review PR from Sarah", "listType": "todo" },
    { "id": "item-4", "title": "Follow up on partnership", "listType": "watch" }
  ],
  "meta": {
    "theme": "Ship critical deliverables",
    "energyBudget": "medium",
    "successMetric": "Complete project proposal and review PR"
  },
  "usedAiSuggestions": true
}
```

---

## 11. Questions for Backend Team

1. **ML Infrastructure:** Do we have existing ML model serving infrastructure, or do we need to set this up?
2. **Calendar Integration:** Is calendar data already available in the API, or do we need to add this?
3. **Notification System:** What notification provider are we using? (e.g., FCM, APNs, custom)
4. **Feature Flags:** Do we have a feature flag system in place?
5. **Timeline:** What's the realistic timeline for Phase 1 backend deployment?

---

## 12. Contact & Support

**iOS Team Lead:** [Your Name]
**Backend Team Lead:** [Backend Lead Name]
**Slack Channel:** #andre-ux-upgrade
**Documentation:** `/docs/ios-ux-upgrade-*`

**Next Sync Meeting:** [Schedule]
**Status Updates:** Daily in #andre-ux-upgrade

---

**Document Version History:**
- v1.0 (2025-10-15): Initial requirements document
