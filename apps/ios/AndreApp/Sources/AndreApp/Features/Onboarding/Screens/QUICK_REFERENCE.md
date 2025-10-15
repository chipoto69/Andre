# Feature Tour Screens - Quick Reference Guide

## Screen Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ONBOARDING FLOW                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Phase 1: Introduction (Screens 1-3)                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Welcome    │ -> │   Problem    │ -> │  Solution    │  │
│  │   Screen     │    │   Screen     │    │   Screen     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                               │
│  Phase 2: Feature Tour (Screens 4-7) ✨ NEW                 │
│  ┌──────────────┐    ┌──────────────┐                       │
│  │    Lists     │ -> │    Focus     │ ->                    │
│  │  Tab Tour    │    │  Tab Tour    │                       │
│  └──────────────┘    └──────────────┘                       │
│                                                               │
│  ┌──────────────┐    ┌──────────────┐                       │
│  │   Switch     │ -> │     Wins     │                       │
│  │  Tab Tour    │    │  Tab Tour    │                       │
│  └──────────────┘    └──────────────┘                       │
│                                                               │
│  Phase 3: Ritual Instructions (Screens 8-11) 🚧 TODO        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Evening    │ -> │   Morning    │ -> │    Weekly    │  │
│  │   Ritual     │    │   Ritual     │    │    Review    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                               │
│  ┌──────────────┐                                            │
│  │  Reflection  │ -> [Start Using App]                      │
│  │   Prompts    │                                            │
│  └──────────────┘                                            │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Screen 4: Lists Tab Tour

**File**: `ListsTabTourScreen.swift`

### Visual Structure
```
┌─────────────────────────────────────┐
│         Your Three Lists            │
│   Everything captured in three      │
│      simple categories              │
├─────────────────────────────────────┤
│                                     │
│  ┌────────────────────────────┐    │
│  │ 🔵 Todo                    │    │
│  │ Active tasks for this week │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ 🟡 Watch                   │    │
│  │ Items to monitor           │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ 🟣 Later                   │    │
│  │ Deferred priorities        │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ ✅ Everything captured.    │    │
│  │    Nothing forgotten.      │    │
│  └────────────────────────────┘    │
│                                     │
│        [Continue →]                 │
└─────────────────────────────────────┘
```

### Key Elements
- 3 list cards with color-coded icons
- Horizontal slide-in animation
- Cyan accent footer

---

## Screen 5: Focus Tab Tour

**File**: `FocusTabTourScreen.swift`

### Visual Structure
```
┌─────────────────────────────────────┐
│     Tomorrow's Focus Card           │
│   Plan tonight. Execute tomorrow.   │
├─────────────────────────────────────┤
│                                     │
│  ┌────────────────────────────┐    │
│  │ Tomorrow                   │    │
│  │ Deep Work Day      [⚡High]│    │
│  ├────────────────────────────┤    │
│  │ ① Complete API integration │    │
│  │ ② Review design mockups    │    │
│  │ ③ Team sync meeting        │    │
│  └────────────────────────────┘    │
│                                     │
│  🌙 Plan tomorrow tonight           │
│  🎯 Choose 3-5 priority items       │
│  ⚡ Set your theme and energy       │
│  🏆 Define success for the day      │
│                                     │
│  ┌────────────────────────────┐    │
│  │ ✨ Know exactly what        │    │
│  │    deserves attention       │    │
│  └────────────────────────────┘    │
│                                     │
│        [Continue →]                 │
└─────────────────────────────────────┘
```

### Key Elements
- Glass card focus preview
- 4 feature points with icons
- Numbered focus items
- Energy badge

---

## Screen 6: Switch Tab Tour

**File**: `SwitchTabTourScreen.swift`

### Visual Structure
```
┌─────────────────────────────────────┐
│          🔀 (large icon)            │
│   Structured Procrastination        │
│   Smart task switching when         │
│      deep work stalls               │
├─────────────────────────────────────┤
│                                     │
│  ┌────────────────────────────┐    │
│  │ 💡 Strategic Breaks        │    │
│  │ When you're stuck, switch  │    │
│  │ to a productive alternative│    │
│  │ "Redirect your energy"     │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Review design feedback [85%]│   │
│  │ From Watch list         🟡  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Organize project files  [72%]│  │
│  │ From Later list         🟣  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Quick code cleanup      [68%]│  │
│  │ Momentum builder        🔵  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌────────────────────────────┐    │
│  │ 🔄 Switch tasks            │    │
│  │    productively.           │    │
│  │    Keep momentum.          │    │
│  └────────────────────────────┘    │
│                                     │
│        [Continue →]                 │
└─────────────────────────────────────┘
```

### Key Elements
- Large branch icon with animation
- 3 suggestion cards with scores
- Circular progress indicators
- Strategic breaks concept

---

## Screen 7: Wins Tab Tour

**File**: `WinsTabTourScreen.swift`

### Visual Structure
```
┌─────────────────────────────────────┐
│          ✨ (large icon)            │
│        Track Your Wins              │
│   Celebrate progress, build         │
│          momentum                    │
├─────────────────────────────────────┤
│                                     │
│  ┌────────────────────────────┐    │
│  │ 🏆 The Anti-Todo           │    │
│  │ Log what you actually      │    │
│  │ accomplished               │    │
│  │ "The secret to productivity│    │
│  │  is recognizing your wins" │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ ✅ Shipped new feature     │    │
│  │    2 hours ago             │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ ✅ Reviewed design feedback│    │
│  │    3 hours ago             │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ ✅ Completed code review   │    │
│  │    5 hours ago             │    │
│  └────────────────────────────┘    │
│                                     │
│  ┌────────────────────────────┐    │
│  │ 📈 Why Track Wins?         │    │
│  │ ✓ See proof of progress   │    │
│  │ ✓ Build confidence         │    │
│  │ ✓ Recognize patterns       │    │
│  │ ✓ Combat imposter syndrome │    │
│  └────────────────────────────┘    │
│                                     │
│        [Get Started ✓]              │
└─────────────────────────────────────┘
```

### Key Elements
- Sparkles with gradient background
- 3 win entries with timestamps
- Green checkmarks
- Benefits list
- Anti-Todo concept quote

---

## Color Reference

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Todo | Cyan | #00FFFF | Active tasks |
| Watch | Yellow | #FFD60A | Monitor items |
| Later | Purple | #BF5AF2 | Deferred tasks |
| Wins | Green | #00FF00 | Checkmarks, success |
| Accent | Cyan | #00FFFF | Primary actions |
| Background | Black | #000000 | Screen background |

---

## Icon Reference

| Screen | Main Icon | Secondary Icons |
|--------|-----------|-----------------|
| Lists | - | circle.fill, eye.fill, clock.fill |
| Focus | target | moon.stars.fill, bolt.fill, checkmark.seal.fill |
| Switch | arrow.triangle.branch | lightbulb.fill, arrow.clockwise |
| Wins | sparkles | trophy.fill, checkmark, chart.line.uptrend.xyaxis |

---

## Animation Timing

```swift
// Base pattern for all screens
.onAppear {
    withAnimation(Tokens.Curve.easeOut.delay(0.2)) {
        isAnimating = true
    }
}

// Stagger delays
Header:     0.2s (base)
Element 1:  0.3s (+0.1s)
Element 2:  0.4s (+0.1s)
Element 3:  0.5s (+0.1s)
Footer:     0.6s (+0.1s)
CTA:        0.7s (+0.1s)
```

---

## Component Reuse Matrix

| Component | Lists | Focus | Switch | Wins |
|-----------|-------|-------|--------|------|
| AndreCard (elevated) | ✅ | ✅ | ✅ | ✅ |
| AndreCard (glass) | - | ✅ | ✅ | ✅ |
| AndreCard (accent) | ✅ | ✅ | ✅ | ✅ |
| AndreButton (primary) | ✅ | ✅ | ✅ | ✅ |
| AndreButton (borderless) | ✅ | ✅ | ✅ | ✅ |
| Custom component | ListTypeCard | FocusItemPreview, FeaturePointRow | SuggestionPreviewCard | WinEntryPreview, BenefitPoint |

---

## Skip Functionality

All tour screens support optional skip button:

```swift
ListsTabTourScreen(
    onContinue: { /* Next screen */ },
    onSkip: { /* Jump to app */ }  // Optional
)
```

Toolbar skip button appears in top-right when `onSkip` is provided.

---

## Preview Support

### Test Individual Screens
```swift
#Preview("Lists Tab Tour Only") {
    NavigationStack {
        ListsTabTourScreen(onContinue: {}, onSkip: {})
    }
}
```

### Test Complete Flow
```swift
#Preview("All Seven Screens") {
    OnboardingScreensPreview()  // Swipeable TabView
}
```

---

## Integration Checklist

- [x] Create ListsTabTourScreen.swift
- [x] Create FocusTabTourScreen.swift
- [x] Create SwitchTabTourScreen.swift
- [x] Create WinsTabTourScreen.swift
- [x] Update OnboardingScreensPreview.swift
- [x] Add all preview variations
- [ ] Integrate with OnboardingViewModel
- [ ] Add to main onboarding flow
- [ ] Test navigation transitions
- [ ] Verify skip functionality
- [ ] Test accessibility features

---

## Next Phase: Ritual Screens (8-11)

Suggested structure based on established patterns:

1. **Evening Ritual Screen**
   - Moon icon, planning wizard preview
   - Focus card creation steps

2. **Morning Ritual Screen**
   - Sun icon, review yesterday's wins
   - Today's focus card display

3. **Weekly Review Screen**
   - Calendar icon, list maintenance
   - Archive/organize workflow

4. **Reflection Prompts Screen**
   - Thought bubble icon, journaling
   - Daily/weekly prompts

All should follow same animation and component patterns established in tour screens.
