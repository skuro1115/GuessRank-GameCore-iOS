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

## 動線

```
GameSettingsView
└─ Spacer の後・「ゲームを始める」ボタンの直上
   └─ 紫系背景の「開発者」セクション
        ├─ 「クイックスタート」ラベル + 横並びプリセットボタン  (quickStartEnabled)
        ├─ 「データ」 [リセット…] Menu                        (dataResetEnabled)
        ├─ 「高速モード（4x）」 Toggle                         (fastModeEnabled の binding)
        └─ 「デバッグオーバーレイ」 Toggle                     (debugOverlayEnabled の binding)

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

## 将来拡張 (Out of scope)

`docs/future/roadmap.md` の優先順位に従い、後続 PR で段階追加する:

- **お題固定** — topic ID 指定で抽選バイパス（再現テスト・スクショ撮影）
- **シード固定** — お題抽選とローテーションの再現可能化
- **状態スナップショット** — `GameSession` の JSON エクスポート / インポート
- **アニメーション速度の網羅対応** — 現状は sleep / dispatch delay のみ。SwiftUI `.spring()` / `.animation(.easeOut(duration:))` の duration もスケールできるようにする
- **オーバーレイの拡張** — タップで折りたたみ、抽選で除外されたお題と理由表示、HapticsService 呼び出しイベント表示など
- **TestFlight ベータ向け隠し動線** — ロゴ N回タップ等で配信版でも開放
