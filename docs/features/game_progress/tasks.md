# ゲーム進行 — 実装タスク

## 依存関係

- 前提: game_settings（プレイヤー・設定データ）
- 後続: end_screen（最終結果表示）

## タスク一覧

| # | タスク | 担当レイヤー | 状態 | 依存 |
|---|---|---|---|---|
| T-01 | GameSession / Turn / Answer モデル定義 | Model | 未着手 | — |
| T-02 | スコア計算ロジック（純粋関数） | Service | 未着手 | T-01 |
| T-03 | GameProgressViewModel実装 | ViewModel | 未着手 | T-01, T-02 |
| T-04 | GameProgressScreen（ターン開始）実装 | View | 未着手 | T-03 |
| T-05 | TopicScreen（お題表示）実装 | View | 未着手 | T-03 |
| T-06 | PassDeviceScreen（端末回し）実装 | View | 未着手 | T-03 |
| T-07 | AnswerInputScreen（回答入力）実装 | View | 未着手 | T-03 |
| T-08 | AnswerConfirmScreen（回答確認）実装 | View | 未着手 | T-07 |
| T-09 | TurnResultScreen（ターン結果）実装 | View | 未着手 | T-03 |
| T-10 | 画面遷移フロー結合 | View | 未着手 | T-04〜T-09 |
| T-11 | お題データ準備 | Data | 未着手 | — |
| T-12 | QA実施 | QA | 未着手 | T-10, T-11 |

## 完了条件

- [ ] ターン進行が正しくローテーションする
- [ ] 端末回しで覗き見防止が機能する
- [ ] スコア計算が正しい
- [ ] 全ターン完了後に終了画面へ遷移する
- [ ] qa.md のテストケースがすべてパス
