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

ダミープレイヤーを流し込み、即時にゲームを開始する。

| プリセット | 人数 | サイクル | プレイモード |
|---|---|---|---|
| 標準 4人 | 4 | 1 | normal |
| ハード 4人 | 4 | 1 | hard |
| ソロ 2人 | 2 | 1 | normal |

ダミー名は `["A", "B", "C", "D", "E", "F"]` の先頭から人数分。タップで `viewModel.applyQuickStartPreset(_:)` → `onStart()`。

## 動線

```
GameSettingsView
└─ Spacer の後・「ゲームを始める」ボタンの直上
   └─ 紫系背景の「開発者」セクション
        └─ 「クイックスタート」ラベル + 横並びプリセットボタン
```

紫系背景で本来の操作と視覚的に分離。

## 関連モデル / 実装

- `QuickStartPreset`（ViewModel/GameSetupViewModel.swift）— プリセット定義
- `GameSetupViewModel.applyQuickStartPreset(_:)` — 状態流し込み
- `GameSettingsView.developerSection`（@ViewBuilder）— セクション UI

## 将来拡張 (Out of scope)

`docs/future/roadmap.md` の優先順位に従い、後続 PR で段階追加する:

- **デバッグオーバーレイ** — ターン番号 / フェーズ / 現入力プレイヤー / スコア内訳の半透明表示
- **お題固定** — topic ID 指定で抽選バイパス（再現テスト・スクショ撮影）
- **アニメーション速度** — 4x 等で結果アニメーションを早送り
- **シード固定** — お題抽選とローテーションの再現可能化
- **データリセット** — 履歴 / フィードバック / セッション / UserDefaults を選択リセット
- **状態スナップショット** — `GameSession` の JSON エクスポート / インポート
- **TestFlight ベータ向け隠し動線** — ロゴ N回タップ等で配信版でも開放
