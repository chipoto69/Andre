# Andre iOS App - Quick Start Guide

## Setup (5 Minutes)

### 1. Navigate to the iOS app directory

```bash
cd /Users/rudlord/ORGANIZED/ACTIVE_PROJECTS/Andre/apps/ios/AndreApp
```

### 2. Open in Xcode & build

```bash
open Package.swift
```

Then press `Cmd+B` in Xcode to build (ensure an iOS 17 destination is selected).

## Viewing Components (Xcode)

### See All Components in Preview

1. Open any component file in Xcode:
   - `Sources/AndreApp/Components/AndreButton.swift`
   - `Sources/AndreApp/Components/AndreCard.swift`
   - etc.

2. Open the Canvas (Cmd+Option+Enter)

3. Click "Resume" in the preview pane

4. Interact with the components live!

### Preview the Full App

1. Open `Sources/AndreApp/AndreApp.swift`
2. Look for the `#Preview` at the bottom
3. Open Canvas to see the full app

## Testing the Design System

### Try Different Colors

```swift
import SwiftUI

struct ColorTestView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Primary Cyan")
                .foregroundColor(.brandCyan)

            Text("Success Green")
                .foregroundColor(.statusSuccess)

            Text("Todo Blue")
                .foregroundColor(.listTodo)
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    ColorTestView()
}
```

### Test Typography

```swift
struct TypographyTestView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Display Large")
                .font(.displayLarge)

            Text("Title Medium")
                .font(.titleMedium)

            Text("Body Text")
                .font(.bodyMedium)

            Text("Code: [[.AndreApp]]")
                .textStyle(.codeReference)
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
}
```

### Test Components

```swift
struct ComponentTestView: View {
    @State private var text = ""

    var body: some View {
        VStack(spacing: Spacing.lg) {
            AndreButton.primary("Primary Button") {
                print("Tapped!")
            }

            AndreCard.glass {
                Text("Glassmorphic Card")
                    .foregroundColor(.textPrimary)
            }

            AndreTextField(
                "Email",
                placeholder: "Enter email",
                icon: "envelope",
                text: $text
            )

            HStack {
                AndreTag.todo("Todo")
                AndreTag.watch("Watch")
                AndreTag.later("Later")
            }
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
}
```

## Building Features

### Creating a New View with Design System

```swift
import SwiftUI

struct MyNewView: View {
    @State private var viewModel = MyViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    Text("My Feature")
                        .font(.displayMedium)
                        .foregroundColor(.textPrimary)

                    // Content card
                    AndreCard.elevated {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Card Title")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)

                            Text("Card description text")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // Action button
                    AndreButton.primary("Take Action", icon: "checkmark") {
                        // Handle action
                    }
                }
                .screenPadding()
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("My Feature")
        }
    }
}

#Preview {
    MyNewView()
}
```

### Using the FocusCard Feature

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FocusCardView()
                .tabItem {
                    Label("Focus", systemImage: "target")
                }

            // Your other tabs
        }
        .tint(.brandCyan)
    }
}
```

## Common Patterns

### Loading State

```swift
struct MyView: View {
    @State private var isLoading = false

    var body: some View {
        VStack {
            // Your content
        }
        .loading(isPresented: isLoading, message: "Loading...")
    }
}
```

### Empty State

```swift
@ViewBuilder
private var emptyState: some View {
    AndreCard.glass {
        VStack(spacing: Spacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.brandCyan.opacity(0.5))

            Text("No items yet")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)

            AndreButton.primary("Add First Item") {
                // Handle action
            }
        }
        .padding(Spacing.xl)
    }
}
```

### Form Layout

```swift
struct FormView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var notes = ""

    var body: some View {
        VStack(spacing: Spacing.lg) {
            AndreTextField(
                "Name",
                placeholder: "Enter name",
                icon: "person",
                text: $name
            )

            AndreTextField(
                "Email",
                placeholder: "Enter email",
                icon: "envelope",
                text: $email,
                keyboardType: .emailAddress
            )

            AndreTextArea(
                "Notes",
                placeholder: "Add notes...",
                text: $notes
            )

            AndreButton.primary("Submit") {
                submitForm()
            }
        }
        .screenPadding()
    }
}
```

## Design System Cheat Sheet

### Colors
```swift
.brandCyan          // Primary accent
.brandBlack         // Primary background
.brandWhite         // Primary text (dark mode)
.backgroundPrimary  // Main background
.backgroundSecondary // Card background
.textPrimary        // Main text
.textSecondary      // Secondary text
.statusSuccess      // Success green
.statusError        // Error red
.listTodo           // Todo cyan
.listWatch          // Watch yellow
.listLater          // Later purple
```

### Typography
```swift
.displayLarge       // 40pt, semibold
.titleLarge         // 24pt, bold
.bodyMedium         // 15pt, regular (default)
.labelSmall         // 11pt, medium
.codeMedium         // 15pt, monospaced
```

### Spacing
```swift
Spacing.xs          // 8px
Spacing.sm          // 12px
Spacing.md          // 16px
Spacing.lg          // 24px
Spacing.xl          // 32px
Spacing.xxl         // 48px
```

### Layout Sizes
```swift
LayoutSize.cornerRadiusSmall    // 4px
LayoutSize.cornerRadiusMedium   // 8px
LayoutSize.cornerRadiusLarge    // 12px
LayoutSize.iconMedium           // 24px
LayoutSize.buttonHeightMedium   // 44px
```

### Animations
```swift
Tokens.Curve.spring        // Bouncy animation
Tokens.Curve.easeOut       // Appearing elements
Tokens.Duration.normal     // 0.3s
```

## Troubleshooting

### Build Errors

**Error:** Cannot find 'AndreButton' in scope

**Solution:** Make sure you've activated the new app file:
```bash
mv Sources/AndreApp/AndreApp.old.swift Sources/AndreApp/AndreApp.backup.swift
mv Sources/AndreApp/AndreAppNew.swift Sources/AndreApp/AndreApp.swift
swift build
```

**Error:** Module 'AndreApp' has no member named 'X'

**Solution:** Clean build folder and rebuild:
```bash
swift package clean
swift build
```

### Preview Issues

**Issue:** Preview not showing

**Solution:**
1. Make sure Canvas is open (Cmd+Option+Enter)
2. Click "Resume" in preview pane
3. Try restarting Xcode if stuck

**Issue:** Preview showing errors

**Solution:**
1. Check that all imports are present
2. Verify the preview code is at the bottom of the file
3. Try simplifying the preview temporarily

### Runtime Issues

**Issue:** Colors not showing correctly

**Solution:** Make sure you're importing SwiftUI and using the color extensions:
```swift
import SwiftUI

Text("Test")
    .foregroundColor(.brandCyan)  // ✅ Correct
    // .foregroundColor(Color.cyan)  // ❌ Wrong
```

**Issue:** Fonts not applying

**Solution:** Use the design system fonts:
```swift
Text("Title")
    .font(.titleLarge)  // ✅ Correct
    // .font(.title)  // ❌ Wrong (system font)
```

## Next Steps

1. **Explore Components** - Open each component file and see the previews
2. **Build a Test View** - Create a simple view using the design system
3. **Try the Features** - Test FocusCardView and ListBoardView
4. **Customize** - Adjust colors/spacing if needed for your specific use case
5. **Read the Docs** - Check IMPLEMENTATION_SUMMARY.md for details

## Resources

- **Implementation Summary:** `IMPLEMENTATION_SUMMARY.md`
- **Brand Guidelines:** `/Users/rudlord/ORGANIZED/ACTIVE_PROJECTS/ARSENAL/BRAND/Unified Design Guidelines for macOS iOS Web.md`
- **Project Plan:** `claude.md`
- **Apple HIG:** https://developer.apple.com/design/human-interface-guidelines

## Getting Help

If you encounter issues:

1. Check the implementation summary for detailed documentation
2. Look at the preview code in each component file
3. Verify you're using the design system correctly
4. Check that LocalStore and SyncService stubs are in place

Happy building! 🚀
