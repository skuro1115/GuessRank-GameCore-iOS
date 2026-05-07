import SwiftUI

@main
struct GuessRankApp: App {
    @State private var featureFlags = FeatureFlagStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.featureFlags, featureFlags)
        }
    }
}
