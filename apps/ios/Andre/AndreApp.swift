import SwiftUI
import AndreApp

@main
struct Andre: App {
    var body: some Scene {
        WindowGroup {
            AndreRootView()
                .preferredColorScheme(.dark)
        }
    }
}
