# 開発者モード (Dev Mode) — 仕様

## 概要

開発・QA・スクリーンショット作成時の検証速度を上げる開発者向け機能群。表示は [機能フラグ](../feature_flags/spec.md) で制御し、リリース版では既定で全て非表示。

## 表示条件

```
親フラグ devModeEnabled が true
  └─ GameSettingsView 末尾に「開発者」セクションが出現
        └─ 子フラグ quickStartEnabled が true なら QuickStart 行が出現
```

DEBUG ビルドでは両フラグとも初期値 `true`（ユーザー上書きなし時）、RELEASE ビルドでは初期値 `false`。

## 実装済み機能

### QuickStart（クイックスタート）

ダミープレイヤーを流し込み、即時にゲームを開始する。子フラグ `quickStartEnabled` が ON のときのみ表示。

| プリセット | 人数 | サイクル | プレイモード |
|---|---|---|---|
| 標準 4人 | 4 | 1 | normal |
| ハード 4人 | 4 | 1 | hard |
| ソロ 2人 | 2 | 1 | normal |

ダミー名は `["A", "B", "C", "D", "E", "F"]` の先頭から人数分。タップで `viewModel.applyQuickStartPreset(_:)` → `onStart()`。

### データリセット

子フラグ `dataResetEnabled` が ON のときのみ表示。Menu (`リセット…`) を開いて以下を選択:

| 項目 | 動作 |
|---|---|
| お題履歴 | `TopicHistoryStore.clear()` |
| お題FB（ブロック+面白い） | `TopicFeedbackStore.clearAll()` |
| ゲーム履歴 | `GameHistoryStore.clearAll()` |
| 全データ（destructive） | 上記3つを順に実行 |

各項目は確認アラート（`リセット` / `キャンセル`）を経由してから実行。誤タップ防止。

### 高速モード（4x）

子フラグ `fastModeEnabled` の Toggle を開発者セクションに直接表示。ON で結果アニメーションとトースト遅延を 1/4 に短縮。

実装は `FeatureFlagStore.scaledDuration(_:)` を呼び出す方式:

- `TurnResultView.scheduleReveals` の各 phase delay
- `TopicView` のフィードバックトースト（1.5秒 → 0.375秒）

> SwiftUI の `.spring()` / `.easeOut(duration:)` 自体は今回スケールしていない（duration が複数箇所に分散しているため、第一スライスでは効果の大きい sleep / dispatch delay のみを対象とした）。

### デバッグオーバーレイ

子フラグ `debugOverlayEnabled` の Toggle を開発者セクションに直接表示。ON でゲーム進行画面（`GameProgressView`）の右上に半透明の小パネルが現れ、以下を表示する:

| 行 | 内容 |
|---|---|
| `turn N/M` | 現在ターン / 総ターン数 |
| `phase: …` | `showTopic` / `rankingInput(index, covered/uncovered)` / `showResult` |
| `input: 名前` | 現在の入力プレイヤー（`rankingInput` フェーズのみ） |
| `topic: id` | 現お題の ID（再現テスト用） |
| `last best: N` | 直近完了ターンの最高スコア |

`.allowsHitTesting(false)` で、UI 操作は一切妨げない。

### シード固定

子フラグ `seedFixEnabled` の Toggle を開発者セクションに直接表示。ON のときシード入力フィールド（数値）が現れ、その値で**お題抽選を再現可能**にする。同じシードなら毎回まったく同じお題・同じ順序になるため、スクリーンショット撮影やバグ再現に使う。

仕組みは RNG 注入方式:

- `TopicProviding.pickTopics(..., using: inout some RandomNumberGenerator)` が抽選の唯一の要件。システム乱数を使う簡便版（再現性なし）を extension で提供し、通常の呼び出し元はそのまま。
- `SeededRandomNumberGenerator`（SplitMix64）が決定的な乱数系列を生成。`seed 0` でも偏らない。
- `TopicRandomNumberGenerator` は seed があれば決定的、なければシステム乱数にフォールバックするラッパー。
- `GameProgressViewModel` が 1 ゲーム分この RNG を**保持**し、初回抽選と `passTopic` の差し替えで同じ系列を進める（差し替え結果まで再現する）。
- シード値は `FeatureFlagStore.topicSeed`（`UserDefaults` 永続化）に保存。`seedFixEnabled` が OFF なら `effectiveTopicSeed` は `nil` を返し、抽選は非再現のシステム乱数に戻る。

> シードは `Int` で保存し、抽選には `UInt64(bitPattern:)` で渡す（負値も往復可能）。お題プールやブロック/履歴による除外集合が変われば、同じシードでも結果は変わる（除外集合は抽選の入力の一部）。

### お題固定

子フラグ `topicPinEnabled` の Toggle を開発者セクションに直接表示。ON のときお題 ID 入力フィールド（文字列）が現れ、その ID のお題を**初回ターンに固定**する。スクリーンショット撮影や特定お題でのバグ再現で、毎回必ず既知のお題から始められる。

シード固定が「抽選順序の再現」なのに対し、お題固定は「個別お題の直接指定」。両者は併用可能（初回は固定お題、2 ターン目以降はシード順で再現）。

仕組み:

- `TopicProviding.topic(withId:)` が ID から `Topic?` を返す（`TopicService` は内蔵プール、テストは注入プールを線形検索）。
- `GameProgressViewModel.init(pinnedTopicId:)` が抽選後に `applyPinnedTopic(_:)` を呼び、指定お題を `topics[0]` へ差し込む。
- **プレイモード不一致**（例: ハードお題をノーマルゲームに）の ID は無視する。ランクスロット数が崩れるのを防ぐため。
- 抽選結果に同じお題が含まれていれば**重複させず**先頭へ移動する。
- お題 ID は `FeatureFlagStore.pinnedTopicId`（`UserDefaults` 永続化）に保存。`topicPinEnabled` が OFF、空文字、空白のみのときは `effectivePinnedTopicId` が `nil` を返し、初回ターンも通常抽選に戻る。

> 固定するのは初回ターンのみ。`passTopic` で固定お題をパスすれば通常の差し替えに従う（固定の押し付けはしない）。全ターンの個別指定は将来拡張。

## 動線

```
GameSettingsView
└─ Spacer の後・「ゲームを始める」ボタンの直上
   └─ 紫系背景の「開発者」セクション
        ├─ 「クイックスタート」ラベル + 横並びプリセットボタン  (quickStartEnabled)
        ├─ 「データ」 [リセット…] Menu                        (dataResetEnabled)
        ├─ 「高速モード（4x）」 Toggle                         (fastModeEnabled の binding)
        ├─ 「デバッグオーバーレイ」 Toggle                     (debugOverlayEnabled の binding)
        ├─ 「シード固定」 Toggle + シード入力フィールド        (seedFixEnabled の binding / topicSeed)
        └─ 「お題固定」 Toggle + お題ID入力フィールド          (topicPinEnabled の binding / pinnedTopicId)

GameProgressView
└─ .overlay(alignment: .topTrailing) で DebugOverlay (debugOverlayEnabled が ON のとき)
```

紫系背景で本来の操作と視覚的に分離。

## 関連モデル / 実装

- `QuickStartPreset`（ViewModel/GameSetupViewModel.swift）— プリセット定義
- `GameSetupViewModel.applyQuickStartPreset(_:)` — 状態流し込み
- `GameSettingsView.developerSection`（@ViewBuilder）— セクション UI
- `GameSettingsView.devToggle(_:label:)` — フラグ Toggle の薄いラッパー
- `GameSettingsView.DataResetTarget`（private enum）— リセット対象種別
- `FeatureFlagStore.scaledDuration(_:)` — 高速モード時の遅延短縮ヘルパー
- `DebugOverlay`（Views/DebugOverlay.swift）— ゲーム進行画面のオーバーレイ
- `GameProgressView.overlay`（topTrailing）— DebugOverlay の差し込み
- `SeededRandomNumberGenerator` / `TopicRandomNumberGenerator`（Services/SeededRandomNumberGenerator.swift）— 決定的乱数とそのラッパー
- `TopicProviding.pickTopics(..., using:)` — RNG 注入版の抽選要件
- `TopicProviding.topic(withId:)` — ID からお題を引く（お題固定用）
- `FeatureFlagStore.topicSeed` / `.effectiveTopicSeed` — シード値の永続化と有効値解決
- `FeatureFlagStore.pinnedTopicId` / `.effectivePinnedTopicId` — 固定お題 ID の永続化と有効値解決
- `GameProgressViewModel.init(topicSeed:)` — シードからゲーム単位の RNG を生成
- `GameProgressViewModel.init(pinnedTopicId:)` / `applyPinnedTopic(_:)` — 固定お題の初回ターン差し込み

## 将来拡張 (Out of scope)

`docs/future/roadmap.md` の優先順位に従い、後続 PR で段階追加する:

- **全ターンお題固定** — 初回だけでなく各ターンのお題を ID リストで個別指定する
- **状態スナップショット** — `GameSession` の JSON エクスポート / インポート
- **アニメーション速度の網羅対応** — 現状は sleep / dispatch delay のみ。SwiftUI `.spring()` / `.animation(.easeOut(duration:))` の duration もスケールできるようにする
- **オーバーレイの拡張** — タップで折りたたみ、抽選で除外されたお題と理由表示、HapticsService 呼び出しイベント表示など
- **TestFlight ベータ向け隠し動線** — ロゴ N回タップ等で配信版でも開放
