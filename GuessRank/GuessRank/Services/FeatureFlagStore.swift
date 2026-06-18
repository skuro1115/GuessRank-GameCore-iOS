import Foundation
import Observation

/// `FeatureFlag` の現在値を解決し、実行時の変更を `UserDefaults` に永続化する。
///
/// 解決順序は以下:
/// 1. ユーザーが実行時に設定した上書き値（永続化される）
/// 2. ビルド構成のデフォルト値（DEBUG / RELEASE）
///
/// 起動時引数（launch-time args）からの上書きは将来層として未実装。
/// 詳細設計は `docs/future/feature_flags.md` を参照。
@Observable
final class FeatureFlagStore {
    private let defaults: UserDefaults
    private var overrides: [FeatureFlag: Bool] = [:]

    /// シード固定（`seedFixEnabled`）時にお題抽選へ渡すシード値。
    /// 変更は `UserDefaults` に永続化され、`seedFixEnabled` が OFF のときは無視される。
    var topicSeed: Int {
        didSet { defaults.set(topicSeed, forKey: Self.topicSeedKey) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.topicSeed = defaults.integer(forKey: Self.topicSeedKey)
        loadOverrides()
    }

    /// 指定フラグが有効か。
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        if let override = overrides[flag] { return override }
        return Self.buildDefault(for: flag)
    }

    /// 実行時に値を上書きし `UserDefaults` に永続化する。
    func setEnabled(_ flag: FeatureFlag, _ value: Bool) {
        overrides[flag] = value
        defaults.set(value, forKey: Self.userDefaultsKey(for: flag))
    }

    /// 上書きを破棄してビルドデフォルトに戻す。
    func reset(_ flag: FeatureFlag) {
        overrides.removeValue(forKey: flag)
        defaults.removeObject(forKey: Self.userDefaultsKey(for: flag))
    }

    /// 全フラグの上書きを破棄する（テスト・QA 用）。
    func resetAll() {
        for flag in FeatureFlag.allCases {
            reset(flag)
        }
    }

    /// このフラグが現在「上書きされているか」を返す。設定 UI でデフォルトとの差分表示に使う。
    func hasOverride(_ flag: FeatureFlag) -> Bool {
        overrides[flag] != nil
    }

    // MARK: - Animation speed

    /// 高速モードが有効なら 4.0、そうでなければ 1.0。
    var animationSpeedMultiplier: Double {
        isEnabled(.fastModeEnabled) ? 4.0 : 1.0
    }

    /// 与えられた秒数を `animationSpeedMultiplier` で割った値を返す（高速モード時に短縮）。
    /// アニメーション・遅延の指定箇所で利用する。
    func scaledDuration(_ seconds: Double) -> Double {
        seconds / animationSpeedMultiplier
    }

    // MARK: - Topic seed (シード固定)

    /// シード固定が有効なら `topicSeed`、無効なら `nil`。
    /// `nil` のときお題抽選はシステム乱数（非再現）にフォールバックする。
    var effectiveTopicSeed: UInt64? {
        guard isEnabled(.seedFixEnabled) else { return nil }
        return UInt64(bitPattern: Int64(topicSeed))
    }

    static func buildDefault(for flag: FeatureFlag) -> Bool {
        #if DEBUG
        return flag.debugDefault
        #else
        return flag.releaseDefault
        #endif
    }

    private func loadOverrides() {
        for flag in FeatureFlag.allCases {
            let key = Self.userDefaultsKey(for: flag)
            if defaults.object(forKey: key) != nil {
                overrides[flag] = defaults.bool(forKey: key)
            }
        }
    }

    private static func userDefaultsKey(for flag: FeatureFlag) -> String {
        "feature_flag.\(flag.rawValue)"
    }

    private static let topicSeedKey = "dev.topic_seed"
}
