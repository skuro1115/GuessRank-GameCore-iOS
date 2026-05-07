# 将来拡張参考資料: 機能フラグ（Feature Flags）

> この文書はPhase 2以降の参考資料です。MVP実装には含まれません。

## 概要

機能のON/OFFを宣言的に切り替える仕組み。WIP機能を main ブランチに統合しつつリリース版では非公開にしたり、ベータ機能の段階的ロールアウト、開発者向け機能（→ [dev_mode.md](dev_mode.md)）の隠蔽などに利用する。

## 背景・動機

- 大きな機能をブランチで長期間隔離するとコンフリクトが膨らむ。フラグでガードして main にマージしたい
- DEBUG / RELEASE / TestFlight ベータ で挙動を変えたいケースが今後増える（dev mode、リモートお題、課金まわりなど）
- 後の A/B テスト・サーバー側遠隔操作の足がかりにする
- 「開発中の機能を一時的に隠す」「審査前に新規機能を OFF にしてリスクを下げる」運用ニーズに応える

## フラグの種類

4 つのレイヤを想定。下に行くほど切り替え粒度が細かくなり、運用コストも上がる。

| レイヤ | 切り替え粒度 | 例 | 配信タイミング |
|---|---|---|---|
| ビルド時（compile-time）| ビルド設定 | `#if DEBUG` で dev mode 同梱判定 | 再ビルド必要 |
| 起動時（launch-time）| プロセス単位 | 起動引数 `-FixedTopicID xxx` で QA 用シード固定 | アプリ再起動 |
| 実行時（runtime）| ユーザー操作 | 設定画面のトグル「ベータ機能」 | 即時反映 |
| リモート（remote）| 配信単位 | サーバーから feature flag JSON を取得 | フェッチ後 |

MVP 拡張時はビルド時 + 実行時の 2 段で十分。リモートは [remote_topics.md](remote_topics.md) と同じ配信基盤に乗せる前提で後段。

## 機能要件

### フラグレジストリ

- フラグ定義を 1 ファイルに集約（例: `Services/FeatureFlag.swift`）。文字列リテラル散在を防ぐ
- 各フラグは `key`・`defaultValue`・`scope`（build / launch / runtime / remote）・`description` を持つ
- 未知のフラグキーへの参照はコンパイルエラーにする（enum で表現）

### 値の取得

- SwiftUI からは `@Environment(\.featureFlags)` 相当で読み取れる API を提供
- ViewModel / Service からは DI 済みの `FeatureFlagStore` 経由
- 評価結果はホットリロードのため `@Observable` で公開（実行時フラグの即時反映用）

### 永続化

- runtime フラグは `UserDefaults` に保存（既存 `TopicFeedbackStore` などと同じ方針）
- launch フラグは `ProcessInfo.processInfo.arguments` から読む（Xcode Scheme で管理）
- remote フラグは将来検討（キャッシュ + TTL + フォールバック）

### 開発者向けフラグの隠蔽

- リリースビルドでは開発者セクションごと `#if DEBUG` でコンパイル除外
- TestFlight ビルド向けに「設定画面のロゴ 7 回タップで開発者メニュー出現」のような隠し動線も検討（Apple の慣例）

## 想定する初期フラグ

| キー | スコープ | 用途 | 関連ドキュメント |
|---|---|---|---|
| `devModeEnabled` | build + runtime | 開発者メニューの表示 | [dev_mode.md](dev_mode.md) |
| `quickStartEnabled` | runtime (DEBUG) | ダミープレイヤー即時投入 | [dev_mode.md](dev_mode.md) |
| `debugOverlayEnabled` | runtime (DEBUG) | ゲーム進行画面のデバッグ表示 | [dev_mode.md](dev_mode.md) |
| `remoteTopicsEnabled` | runtime + remote | リモートお題機能 | [remote_topics.md](remote_topics.md) |
| `analyticsExperimentEnabled` | runtime | 分析画面のベータ表示 | [analytics_design.md](analytics_design.md) |

## 設計上の検討事項

- **デフォルト値の扱い**: フラグ未設定時はリリース版の挙動（基本 OFF）に倒す
- **フラグの寿命**: 「永続フラグ」と「短命フラグ（リリース後 N 週で削除）」を区別し、定期的に整理
- **観測性**: どのフラグが有効化されているかをログ / About 画面に出力できるようにする（不具合報告時の再現性確保）
- **テスト戦略**: フラグ別の挙動を unit test で網羅。`FeatureFlagStore` は protocol 化して mock 注入

## 影響範囲

- **新規**: `Services/FeatureFlag.swift`, `Services/FeatureFlagStore.swift`, `Views/DeveloperSettingsView.swift`（DEBUG 限定）
- **GuessRankApp**: 起動時のフラグ読み込み・Environment 注入
- **GameSettingsView**: 開発者セクションへの導線（DEBUG ビルドのみ）
- **既存 ViewModel / Service**: フラグ参照箇所をフラグキー経由に置き換え（散在防止）
