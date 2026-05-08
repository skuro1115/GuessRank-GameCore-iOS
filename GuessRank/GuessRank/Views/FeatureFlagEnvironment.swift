import SwiftUI

private struct FeatureFlagStoreKey: EnvironmentKey {
    static let defaultValue: FeatureFlagStore = .init()
}

extension EnvironmentValues {
    /// 全 View からアクセス可能な FeatureFlagStore。`GuessRankApp` がインスタンスを注入する。
    var featureFlags: FeatureFlagStore {
        get { self[FeatureFlagStoreKey.self] }
        set { self[FeatureFlagStoreKey.self] = newValue }
    }
}
