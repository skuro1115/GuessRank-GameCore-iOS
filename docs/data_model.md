# データモデル定義

このファイルがデータ構造の **SSOT（Single Source of Truth）** です。

---

## Player（プレイヤー）

| プロパティ | 型 | 説明 |
|---|---|---|
| id | String | 一意識別子 |
| name | String | プレイヤー名 |
| score | Int | 累計スコア |
| order | Int | プレイヤー順番（0始まり） |

---

## GameConfig（ゲーム設定）

| プロパティ | 型 | 説明 |
|---|---|---|
| theme | String | テーマ名 |
| difficulty | Difficulty | 難易度（easy / normal / hard） |
| cycleCount | Int | サイクル数 |
| playerCount | Int | 人数 |

### Difficulty enum

| 値 | 説明 |
|---|---|
| easy | 簡単 |
| normal | 普通 |
| hard | 難しい |

> サイクル数の定義: 1サイクル = 全員が1回ずつ出題。総ターン数 = サイクル数 × 人数

---

## GameSession（ゲームセッション）

| プロパティ | 型 | 説明 |
|---|---|---|
| id | String | 一意識別子 |
| config | GameConfig | ゲーム設定 |
| players | [Player] | プレイヤー一覧 |
| currentTurnIndex | Int | 現在のターン番号（0始まり） |
| totalTurns | Int | 総ターン数（cycleCount × playerCount） |
| status | SessionStatus | セッション状態 |
| turns | [Turn] | ターン履歴 |

### SessionStatus enum

| 値 | 説明 |
|---|---|
| setup | 設定中 |
| inProgress | ゲーム進行中 |
| completed | 完了 |

---

## Turn（ターン）

| プロパティ | 型 | 説明 |
|---|---|---|
| id | String | 一意識別子 |
| turnIndex | Int | ターン番号 |
| questionerId | String | 出題者のPlayer.id |
| topic | String | お題 |
| answers | [Answer] | 回答一覧 |
| isCompleted | Bool | このターンが完了したか |

---

## Answer（回答）

| プロパティ | 型 | 説明 |
|---|---|---|
| playerId | String | 回答者のPlayer.id |
| ranking | [String] | 順位予想（アイテムの並び順） |
| score | Int | このターンで獲得したスコア |

---

## 状態遷移

```
setup → inProgress → completed
```

- `setup`: プレイヤー登録・ゲーム設定中
- `inProgress`: ゲーム進行中（ターン消化中）
- `completed`: 全ターン完了

---

## スコア計算（MVP）

> 詳細なスコアロジックは [features/game_progress/spec.md](features/game_progress/spec.md) を参照

基本方針:
- 出題者が設定した正解順位と回答者の予想の一致度でスコアを決定
- 完全一致で最高得点、部分一致で部分点

---

## 将来拡張フィールド（MVP未実装）

| モデル | フィールド | 用途 | Phase |
|---|---|---|---|
| Player | odaiStats | 出題傾向の分析データ | Phase 2 |
| GameSession | connectionMode | 通信モード | Phase 2 |
| GameSession | hostId | ホストプレイヤーID | Phase 2 |
| Answer | matchRate | 一致率（分析用） | Phase 2 |
