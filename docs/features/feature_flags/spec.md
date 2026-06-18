# 機能フラグ (Feature Flags) — 仕様

## 概要

機能のON/OFFを宣言的に切り替える基盤。WIP機能を main にマージしつつリリース版で隠蔽したり、開発者モード（[dev_mode](../dev_mode/spec.md)）の出口として利用する。

## 解決順序

1. **ユーザー実行時上書き** — `UserDefaults` に保存される値（あれば優先）
2. **ビルド構成デフォルト** — DEBUG / RELEASE で異なる初期値

> launch-time（起動引数）と remote（サーバー配信）レイヤは現時点で **未実装**。Firebase 統合と同時に検討する。

## 現在のフラグ

| key | DEBUG default | RELEASE default | 用途 |
|---|---|---|---|
| `devModeEnabled` | true | false | dev_mode 全体の親フラグ |
| `quickStartEnabled` | true | false | QuickStart プリセット表示（dev_mode 配下） |
| `dataResetEnabled` | true | false | データリセット Menu の表示（dev_mode 配下） |
| `fastModeEnabled` | false | false | 高速モード（4x）の有効化（dev_mode 配下） |
| `debugOverlayEnabled` | false | false | ゲーム進行画面のデバッグオーバーレイ（dev_mode 配下） |
| `seedFixEnabled` | false | false | シード固定（お題抽選の再現）（dev_mode 配下） |
| `topicPinEnabled` | false | false | お題固定（初回ターンのお題 ID 指定）（dev_mode 配下） |

> RELEASE デフォルトは全フラグ false（配信版で開発者機能を完全非表示）。DEBUG でも `fastModeEnabled` 等は明示 ON 前提で false。

新フラグ追加時は `FeatureFlag` 列挙体に case を追加し、`debugDefault` / `releaseDefault` を実装する。

## API

```swift
enum FeatureFlag: String, CaseIterable { ... }

@Observable
final class FeatureFlagStore {
    init(defaults: UserDefaults = .standard)
    func isEnabled(_ flag: FeatureFlag) -> Bool
    func setEnabled(_ flag: FeatureFlag, _ value: Bool)
    func reset(_ flag: FeatureFlag)
    func resetAll()
    func hasOverride(_ flag: FeatureFlag) -> Bool
}
```

SwiftUI から:

```swift
@Environment(\.featureFlags) private var featureFlags

if featureFlags.isEnabled(.devModeEnabled) { ... }
```

## 関連モデル / 実装

- `FeatureFlag`（Service）— 列挙体定義
- `FeatureFlagStore`（Service）— `@Observable` で永続化と公開
- `FeatureFlagEnvironment`（Views）— `EnvironmentValues` 拡張
- `GuessRankApp`（@State 1個で生成 → `.environment(\.featureFlags, ...)` で全 View に注入）

## 永続化

`UserDefaults` キー: `feature_flag.{rawValue}`

## 将来拡張 (Out of scope)

- **launch-time 引数** — Xcode Scheme から `-FeatureFlagFoo YES` 等で QA 起動時固定。実装は `ProcessInfo.processInfo.arguments` を読む追加層
- **remote layer** — サーバー配信されるフラグ JSON のフェッチ + キャッシュ + TTL。Firebase 統合と同時に
- **A/B 配信** — 母集団分割。remote 層が前提
- **設定 UI** — 実行時にユーザーが切り替えるトグル画面（dev_mode 内に置く想定）
