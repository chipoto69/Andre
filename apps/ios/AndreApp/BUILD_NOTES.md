# Build Notes

## Important: iOS-Only Package

This Swift Package is **iOS 17+ only**. It cannot be built for macOS using `swift build` because it uses iOS-specific APIs.

## How to Build

### Option 1: Xcode (Recommended)

```bash
open Package.swift
```

Then in Xcode:
1. Select "Any iOS Device" or an iOS simulator as the destination
2. Press Cmd+B to build
3. Use Canvas (Cmd+Option+Enter) to preview components

### Option 2: xcodebuild Command Line

```bash
xcodebuild -scheme AndreApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Option 3: Create Xcode Project

Generate an Xcode project file:

```bash
# This will create AndreApp.xcodeproj
swift package generate-xcodeproj

# Then open it
open AndreApp.xcodeproj
```

## Why Not `swift build`?

The `swift build` command defaults to building for macOS. Since this package uses:
- `@Observable` (iOS 17+)
- `@Environment(\.dismiss)` (iOS 15+)
- SwiftUI iOS components
- UIKit bridges

...it can only be built for iOS targets.

## Platform Requirements

```swift
platforms: [
    .iOS(.v17)  // iOS 17+ required
]
```

### APIs Requiring iOS 17+
- `@Observable` macro
- Enhanced SwiftUI modifiers
- Modern async/await patterns

### APIs Requiring iOS 15+
- `@Environment(\.dismiss)`
- `.task` modifier
- `.refreshable` modifier

## Development Workflow

1. **Open in Xcode**
   ```bash
   open Package.swift
   ```

2. **Select iOS Destination**
   - Choose "Any iOS Device" or
   - Choose an iOS Simulator (iPhone 15, etc.)

3. **Build and Preview**
   - Press Cmd+B to build
   - Open any View file
   - Press Cmd+Option+Enter for Canvas
   - Click "Resume" to see live preview

4. **Run Tests**
   - Press Cmd+U in Xcode
   - Or use: `xcodebuild test -scheme AndreApp -destination 'platform=iOS Simulator,name=iPhone 15'`

## Creating an iOS App Target

To create a full iOS app (not just a package):

1. **Create New Xcode Project**
   ```
   File > New > Project
   Choose: iOS > App
   Name: Andre
   ```

2. **Add Package as Dependency**
   ```
   File > Add Package Dependencies
   Select: Local package
   Choose: /path/to/AndreApp
   ```

3. **Use in App**
   ```swift
   import AndreApp
   import SwiftUI

   @main
   struct AndreApp: App {
       var body: some Scene {
           WindowGroup {
               AndreRootView()
           }
       }
   }
   ```

## Verifying Build

To verify the package structure is correct:

```bash
# Check package structure
swift package describe

# Resolve dependencies
swift package resolve

# Show build configuration
swift package show-dependencies
```

These commands work even though `swift build` doesn't (they don't actually build for a platform).

## Continuous Integration

For CI/CD, use `xcodebuild` instead of `swift build`:

```bash
# Build
xcodebuild \
    -scheme AndreApp \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    build

# Test
xcodebuild \
    -scheme AndreApp \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    test
```

## Common Errors

### Error: "'now' is only available in macOS 12 or newer"

**Cause:** Running `swift build` which targets macOS by default.

**Solution:** Use Xcode or `xcodebuild` with iOS destination.

### Error: "'Observable()' is only available in macOS 14.0 or newer"

**Cause:** Same as above - building for wrong platform.

**Solution:** Always specify iOS destination.

### Error: "Cannot preview in this file"

**Cause:** Xcode can't find iOS simulator.

**Solution:**
1. Open Xcode settings
2. Go to Platforms
3. Ensure iOS platform is installed
4. Restart Xcode

## Summary

✅ **Do:** Use Xcode with iOS destination
✅ **Do:** Use `xcodebuild` with `-destination 'platform=iOS Simulator'`
✅ **Do:** Preview components in Xcode Canvas

❌ **Don't:** Use `swift build` (targets macOS)
❌ **Don't:** Try to build for macOS
❌ **Don't:** Use command-line Swift REPL

This is an **iOS-only package** by design, following Apple's Human Interface Guidelines and using iOS-specific features like SwiftUI previews, UIKit integration, and iOS 17+ APIs.
