# 画面インデックス

`design-explore`（デザイン探索レビュー・ハーネス）で使う画面の対応表。
**画面キー**を `/design-explore <画面キー>` に渡すとその画面のデザイン案が生成される。

## 使い方

- 画面キーが分からないときは `/design-explore` を引数なしで起動すると、この表から候補一覧が提示される。
- 「対応 View」は採用デザインを実装するときに変更する SwiftUI ファイル（`GuessRank/GuessRank/Views/` 配下）。
- 「ui.md」はその画面の確定仕様。採用案は最終的にここへ反映する。

## 探索対象の画面

| 画面キー | 日本語名 | 対応 View | ui.md | 主な状態 |
|---|---|---|---|---|
| `end_screen` | 結果発表画面 | `EndView.swift` | `docs/features/end_screen/ui.md` | 通常 / 同点 |
| `game_settings` | ゲーム設定画面 | `GameSettingsView.swift` | `docs/features/game_settings/ui.md` | 通常 / 開発者セクション |
| `topic_board` | お題ボード | `TopicView.swift` | `docs/features/game_progress/ui.md` | お題表示 / FBボタン付き |
| `player_call` | プレイヤーコール（覗き見防止） | `CoverView.swift` | `docs/features/game_progress/ui.md` | ターゲット / 予想者 |
| `ranking_input` | ランキング入力 | `RankingInputView.swift`（＋ `RankingEditor.swift` / `HardRankingEditor.swift`） | `docs/features/game_progress/ui.md` | ノーマル / ハード |
| `turn_result` | ターンリザルト | `TurnResultView.swift` | `docs/features/game_progress/ui.md` | 正誤リビール演出 |
| `game_clear` | ゲームクリア（優勝演出） | `GameClearView.swift` | （専用 ui.md なし）`docs/features/game_progress/ui.md` 参照 | 優勝演出 |
| `topic_settings` | お題管理シート | `TopicSettingsView.swift` | `docs/features/topic_history/ui.md` | ジャンル選択 / 履歴 |
| `play_modes` | プレイモード選択（設定内） | `GameSettingsView.swift` | `docs/features/play_modes/ui.md` | ノーマル / ハード picker |
| `topic_feedback` | お題フィードバック（お題画面内） | `TopicView.swift` | `docs/features/topic_feedback/ui.md` | FBボタン |
| `analytics` | 分析画面 | `AnalyticsView.swift` | （ui.md 未整備） | 相性 / お題分析 |
| `history_list` | ゲーム履歴一覧 | `HistoryListView.swift` | （ui.md 未整備） | 一覧 |
| `history_detail` | ゲーム履歴詳細 | `HistoryDetailView.swift` | （ui.md 未整備） | 詳細 |
| `rules` | ルール説明 | `RulesView.swift` | （ui.md 未整備） | 説明 |
| `cover` | カバー / 起動 | `CoverView.swift` | （ui.md 未整備） | — |

## 備考

- `communication_settings`（CommunicationSettingsScreen）は仕様（`docs/features/communication_settings/ui.md`）はあるが、対応する View が未実装。実装時に対応付けを更新すること。
- `DebugOverlay.swift` / `FeatureFlagEnvironment.swift` は開発補助・環境注入用で、デザイン探索の対象外。
- ui.md 未整備の画面（analytics / history_* / rules 等）を探索する場合は、探索と同時に ui.md を起こすか、既存 View の実装を入力にする。
