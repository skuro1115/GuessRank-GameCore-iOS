# 通信設定 — 実装タスク

## 依存関係

- 前提: なし（最初の画面）
- 後続: game_settings

## タスク一覧

| # | タスク | 担当レイヤー | 状態 | 依存 |
|---|---|---|---|---|
| T-01 | ConnectionMode enum定義 | Model | 未着手 | — |
| T-02 | CommunicationSettingsScreen実装 | View | 未着手 | T-01 |
| T-03 | 画面遷移実装 | View | 未着手 | T-02 |
| T-04 | QA実施 | QA | 未着手 | T-03 |

## 完了条件

- [ ] ローカルモードが選択できる
- [ ] 次へで game_settings 画面に遷移する
- [ ] 未実装モードは disabled 表示
- [ ] qa.md のテストケースがすべてパス
