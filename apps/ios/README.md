## Andre iOS App

This module houses the SwiftUI foundation for the Andre mobile experience. It is packaged as a Swift Package to enable preview-driven development before generating the full Xcode project.

### Structure
- `Package.swift` — SwiftPM manifest targeting iOS 17.
- `Sources/AndreApp` — Feature folders for the Focus card ritual, list board, and Anti-Todo ledger.
- `Services/` — Local persistence and network sync abstractions.
- `Tests/` — Placeholder unit tests to keep the target wired into CI.

### Next steps
1. Generate an Xcode project (`xcodebuild -create-xcframework` or `swift package generate-xcodeproj` if required) after front-end designs land.
2. Implement real storage via SwiftData/CoreData and wire to `LocalStore`.
3. Connect `SyncService` to the Fastify API once endpoints stabilize.
4. Add accessibility modifiers, dynamic type support, and haptic feedback.
