# お題履歴・重複回避 — 仕様

> ゲームルール全体は [game_rules.md](../../game_rules.md) を参照

## 概要

プレイ済みのお題IDを端末ローカルに永続化し、次回以降のゲームで重複しないように自動的に除外する。設定画面から履歴を一括リセット可能。

## ビジネスルール

1. ターンが完了（`isCompleted = true`）した時点で、そのターンのお題IDを履歴に記録する
2. 新規セッション開始時、履歴に存在するお題IDは候補から除外する
3. お題変更（パス）時も履歴・ブロック・セッション内既出を全て除外して候補を選ぶ
4. フィルタ後の候補が空になる場合は、ゲームを止めないため除外を無視してフォールバック選出する
5. リセット操作は設定画面の「お題管理」シートから明示的な確認ダイアログを経て実行される

## 制約

- 履歴は永続化（Documents 配下の JSON ファイル）
- 履歴データの内容は単純な `[topicId: String]`（追加メタデータなし）
- 同一お題IDを複数回記録しても重複しない（Set）

## 状態遷移

```
ターン完了 → 履歴に topic.id を追加 → persist
リセット操作 → 確認ダイアログ → 全削除 → persist
```

## 関連モデル / 実装

> データモデルの定義は [data_model.md](../../data_model.md) を参照

- `TopicHistoryStore`（Service）: 永続化と CRUD
- `TopicProviding.pickTopics(..., excluding:)`: 履歴IDを除外パラメータとして受け取る
- `GameProgressViewModel`: ターン完了時に `topicHistory?.record(_:)` を呼ぶ
- `TopicSettingsView`: リセット UI（ゲーム設定画面のギアアイコンから開く）

## 通知

- 全お題プレイ済み（`playedCount >= TopicService.totalTopicCount`）の場合、`TopicSettingsView` 上部に警告バナーを表示する
- 残数が少ない（`max(5, total/20)` 以下）場合は黄色の注意バナーを表示する

## 将来拡張

- Phase 2: お題ごとの最終プレイ日時を保持し、古いものから優先的に再選出する
- Phase 2: ジャンル別の進捗・枯渇通知（現状は全体プールに対する通知のみ）
