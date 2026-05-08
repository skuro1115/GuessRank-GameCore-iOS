# 分析機能 — 仕様

> ゲームルール全体は [game_rules.md](../../game_rules.md) を参照

## 概要

1ゲーム完了時のスナップショットを4つの軸で可視化する。終了画面から `相性分析` と `お題分析` の2画面に遷移できる。

## 解析項目

すべて単一ゲームの `GameSessionSnapshot` に対する集計（**累計・横断分析は実装しない**）。

### 相性分析 (`CompatibilityAnalyticsView`)

| 項目 | 関数 | 内容 |
|---|---|---|
| 最も気が合うコンビ | `bestMatchPair(snapshot:)` | 双方向の平均スコアが最大のペア |
| 推測理解度マトリクス | `pairwiseScores(snapshot:)` | （予想者 → ターゲット）ごとの平均スコア |
| 読まれやすさ | `predictability(snapshot:)` | プレイヤーが「ターゲット」だった時の被予測平均スコア。閾値で `わかりやすい人 / ふつう / 謎の人` のラベル付け |

### お題分析 (`TopicAnalyticsView`)

| 項目 | 関数 | 内容 |
|---|---|---|
| サプライズランキング | `surpriseRanking(snapshot:)` | ターン平均スコア昇順。`surpriseIndex = 100 - averageScore` |

## 動線

```
EndView（終了画面）
  ├─ NavigationLink「相性分析」 → CompatibilityAnalyticsView
  └─ NavigationLink「お題分析」 → TopicAnalyticsView
```

## 関連モデル / 実装

- `AnalyticsService`（Service / 純粋関数集合）
- `CompatibilityAnalyticsView` / `TopicAnalyticsView`（Views/AnalyticsView.swift）
- `EndView`（NavigationLink で接続）
- `GameSessionSnapshot`（入力データ）

## 将来拡張 (Out of scope)

- **累計分析（ジャンル傾向 / スコア推移）** — 当初の Phase 2 設計案にあったが、検討の結果 **不要判断**。複数ゲーム横断の player identity（名前一致）の不安定性と、パーティーゲームという性質上ユーザーが見る価値が低いため。
- **価値観可視化のグラフ表示** — 将来検討（必要性が出てから）
