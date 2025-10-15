# Andre iOS App

> A productivity app rooted in Marc Andreessen's three-list methodology with nightly focus cards, Anti-Todo reflections, and structured procrastination coaching.

## Project Status

**Phase 1-2: COMPLETE ✅**

- Design System Foundation (Colors, Typography, Spacing, Tokens)
- Core UI Components (Button, Card, TextField, Tag, Loading)
- DailyFocus Feature (View, ViewModel, Planning Wizard)
- ListBoard Feature (ViewModel, Enhanced Views)

**Ready for:** Phase 3 development and production testing

## Quick Links

- **[Quick Start Guide](QUICKSTART.md)** — Get up and running in minutes
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** — Detailed breakdown of each module
- **[Design & Token Reference](../../../docs/fe_ui_agent_plan.md)** — Shared guidance for FE/UI agents

## Architecture

```
Andre iOS App (Swift Package)
├── Design System
│   ├── Colors      - Brand color palette with semantic tokens
│   ├── Typography  - SF Pro/SF Mono type system
│   ├── Spacing     - 8px base spacing scale
│   └── Tokens      - Animations, shadows, materials
│
├── Components
│   ├── AndreButton        - Primary, secondary, borderless variants
│   ├── AndreCard          - Glassmorphic cards with 4 styles
│   ├── AndreTextField     - Text input with validation states
│   ├── AndreTag           - Chips for labels and categories
│   └── LoadingIndicator   - 3 loading styles with overlays
│
├── Features
│   ├── DailyFocus
│   │   ├── FocusCardViewModel    - @Observable state manager
│   │   ├── FocusCardView         - Tomorrow's focus display
│   │   ├── FocusItemRow          - Individual focus item
│   │   └── PlanningWizardView    - 4-step card creation
│   │
│   └── ListBoard
│       └── ListBoardViewModel    - Three-list state manager
│
├── Models
│   ├── ListItem          - Core task model
│   ├── DailyFocusCard    - Focus card with meta
│   └── ListBoard         - Three-column board
│
└── Services
    ├── LocalStore        - Local persistence
    └── SyncService       - API synchronization
```

## Design Principles

### Brand Identity

- **Primary Colors:** Cyan (#00FFFF), Black (#000000), White (#FFFFFF)
- **Dark Theme:** Default across all screens
- **Typography:** SF Pro (interface), SF Mono (code references)
- **Spacing:** 8px base system for rhythm
- **Accessibility:** WCAG AA compliance, full VoiceOver support

### User Experience

- **Clarity:** Minimalist interfaces focused on essential elements
- **Cohesion:** Consistent patterns across all features
- **Craftsmanship:** Attention to every detail, smooth animations
- **Apple HIG:** Native feel with platform conventions

## Getting Started

### Prerequisites

- macOS 14+ (Sonoma)
- Xcode 15+
- iOS 17+ deployment target
- Swift 5.9+

### Installation

```bash
cd /Users/rudlord/ORGANIZED/ACTIVE_PROJECTS/Andre/apps/ios/AndreApp
open Package.swift  # Launches the Swift package in Xcode
```

In Xcode:
1. Select an iOS 17 simulator (or "Any iOS Device").
2. Press `Cmd+B` to build the package.
3. Use Canvas (`Cmd+Option+Enter`) for real-time previews of any view or component.

### Preview Components

Open any component file in Xcode and enable Canvas (Cmd+Option+Enter) to see live previews:

```swift
// Every component has a preview
#Preview("Button Variants") {
    VStack {
        AndreButton.primary("Primary") {}
        AndreButton.secondary("Secondary") {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}
```

## Key Features

### 🎯 Daily Focus

**Tomorrow's Focus Card**
- 1-5 prioritized items for the next day
- Theme and energy budget
- Success metric definition
- Evening reflection

**Planning Wizard**
- 4-step guided flow
- Item selection from lists
- Theme suggestions
- Review and confirm

### 📋 Three Lists

**List Types**
- **Todo:** Must-do items
- **Watch:** Follow-up items
- **Later:** Deferred priorities

**Features**
- Kanban-style columns
- Quick capture
- Due dates and tags
- List type filtering

### ✨ Anti-Todo

**Win Logging**
- Track completed work
- Celebrate achievements
- Build momentum
- Structured procrastination insights

## Components

### AndreButton

```swift
AndreButton.primary("Save", icon: "checkmark") {
    save()
}

AndreButton.secondary("Cancel", isDisabled: !canCancel) {
    cancel()
}

AndreButton.borderless("Learn More") {
    showInfo()
}
```

### AndreCard

```swift
AndreCard.glass {
    VStack {
        Text("Glassmorphic Card")
        Text("With translucent background")
    }
}

AndreCard.accent {
    Text("Highlighted with cyan border")
}
```

### AndreTextField

```swift
AndreTextField(
    "Email",
    placeholder: "Enter email",
    icon: "envelope",
    text: $email,
    validationState: .success,
    helperText: "Email is valid",
    keyboardType: .emailAddress
)
```

### AndreTag

```swift
HStack {
    AndreTag.todo("Important")
    AndreTag.watch("Follow up")
    AndreTag.later("Research")
}

AndreTagGroup(
    tags: ["Swift", "iOS", "Design"],
    onRemove: { removeTag($0) }
)
```

### LoadingIndicator

```swift
LoadingIndicator(
    style: .pulse,
    size: .large,
    message: "Loading..."
)

// Or as overlay
ContentView()
    .loading(isPresented: isLoading)
```

## Design System Usage

### Colors

```swift
// Brand colors
.foregroundColor(.brandCyan)
.background(.brandBlack)

// Semantic colors
.foregroundColor(.textPrimary)
.background(.backgroundSecondary)

// Status colors
.foregroundColor(.statusSuccess)
.foregroundColor(.statusError)

// List colors
.foregroundColor(.listTodo)    // Cyan
.foregroundColor(.listWatch)   // Yellow
.foregroundColor(.listLater)   // Purple
```

### Typography

```swift
// Semantic fonts
Text("Display")
    .font(.displayLarge)

Text("Title")
    .font(.titleMedium)

Text("Body")
    .font(.bodyMedium)

// Text styles
Text("Hero")
    .textStyle(.hero)

Text("Code: [[.AndreApp]]")
    .textStyle(.codeReference)
```

### Spacing

```swift
VStack(spacing: Spacing.md) {
    // content
}
.padding(Spacing.lg)
.screenPadding()
```

### Animations

```swift
Text("Animated")
    .animation(Tokens.Curve.spring, value: isVisible)
    .opacity(isVisible ? Tokens.Opacity.full : Tokens.Opacity.invisible)
```

## Development

### Project Structure

```
Sources/AndreApp/
├── DesignSystem/      - Colors, Typography, Spacing, Tokens
├── Components/        - Reusable UI components
├── Features/          - Feature modules with views & view models
├── Models/            - Domain models
├── Services/          - LocalStore, SyncService
└── AndreApp.swift     - Root app container
```

### Testing

```bash
swift test
```

### Code Quality

- **SwiftLint:** Enforces style guidelines
- **Documentation:** All public APIs documented
- **Previews:** Every component has SwiftUI previews
- **Accessibility:** Full VoiceOver support

## Roadmap

### Phase 3: AntiTodo Enhancement
- [ ] AntiTodoViewModel implementation
- [ ] Win statistics and insights
- [ ] Structured procrastination coaching
- [ ] Weekly win summaries

### Phase 4: Sync Integration
- [ ] LocalStore with CoreData/SwiftData
- [ ] SyncService API integration
- [ ] Conflict resolution
- [ ] Offline support
- [ ] Background sync

### Phase 5: Advanced Features
- [ ] Search and filtering
- [ ] Drag and drop reordering
- [ ] Home screen widgets
- [ ] Push notifications
- [ ] iPad optimization
- [ ] macOS Catalyst support

## Contributing

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Include documentation comments
- Add previews for visual components
- Maintain accessibility support

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - Feature branches
- `fix/*` - Bug fixes

### Commit Messages

```
feat: Add focus card planning wizard
fix: Resolve list item completion sync
docs: Update quick start guide
refactor: Extract common button styles
```

## License

Private project - All rights reserved

## Support

For questions or issues:

1. Check [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
2. Review [QUICKSTART.md](QUICKSTART.md)
3. Test with component previews
4. Verify against brand guidelines

---

**Built with:** Swift 5.9, SwiftUI, iOS 17+
**Design System:** Cyan-Black aesthetic, 8px spacing, SF Pro/Mono
**Status:** Phase 1-2 Complete (85% of core functionality)
**Last Updated:** 2025-10-15
