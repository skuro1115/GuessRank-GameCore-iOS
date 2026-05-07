import Foundation

/// アプリ内機能のON/OFFを宣言的に切り替える列挙体。
/// 値のデフォルトはビルド構成（DEBUG / RELEASE）に依存し、実行時上書きは `FeatureFlagStore` が担う。
///
/// 詳細設計は `docs/future/feature_flags.md` を参照。
enum FeatureFlag: String, CaseIterable, Identifiable, Sendable {
    /// 開発者モード全体の出口。OFF の場合 dev_mode 配下の機能はすべて非表示・無効。
    case devModeEnabled
    /// クイックスタート（ダミープレイヤー注入での即時ゲーム開始）の有効化。
    case quickStartEnabled

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .devModeEnabled: "開発者モード"
        case .quickStartEnabled: "クイックスタート"
        }
    }

    var summary: String {
        switch self {
        case .devModeEnabled:
            "ON で設定画面に開発者セクションが表示されます。"
        case .quickStartEnabled:
            "ダミープレイヤーで即時にゲームを開始するボタンを表示します。"
        }
    }

    /// DEBUG ビルド時のデフォルト値。Xcode 経由でのローカル実行時に適用される。
    var debugDefault: Bool {
        switch self {
        case .devModeEnabled: true
        case .quickStartEnabled: true
        }
    }

    /// RELEASE ビルド時のデフォルト値。TestFlight / App Store 配信時に適用される。
    var releaseDefault: Bool {
        switch self {
        case .devModeEnabled: false
        case .quickStartEnabled: false
        }
    }
}
