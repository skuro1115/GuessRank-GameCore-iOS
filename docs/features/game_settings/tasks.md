# ゲーム設定 — 実装タスク

## 依存関係

- 前提: communication_settings（画面遷移元）
- 後続: game_progress（ゲーム開始）

## タスク一覧

| # | タスク | 担当レイヤー | 状態 | 依存 |
|---|---|---|---|---|
| T-01 | GameConfig / Player / Difficulty モデル定義 | Model | 未着手 | — |
| T-02 | GameSetupViewModel実装（設定状態管理） | ViewModel | 未着手 | T-01 |
| T-03 | GameSettingsScreen実装 | View | 未着手 | T-02 |
| T-04 | PlayerSetupScreen実装 | View | 未着手 | T-02 |
| T-05 | バリデーションロジック実装 | ViewModel | 未着手 | T-02 |
| T-06 | QA実施 | QA | 未着手 | T-03, T-04, T-05 |

## 完了条件

- [ ] テーマ・難易度・サイクル数・人数が設定できる
- [ ] プレイヤー名を人数分入力できる
- [ ] バリデーションが動作する
- [ ] ゲーム進行画面へ遷移できる
- [ ] qa.md のテストケースがすべてパス
