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
| genre | Genre | ジャンル（お題データプールのフィルタ条件） |
| difficulty | Difficulty | 難易度（お題データプールのフィルタ条件） |
| cycleCount | Int | サイクル数 |
| playerCount | Int | 人数 |
| playMode | PlayMode | プレイモード（normal=3択 / hard=6択上位3つ） |

### Genre enum

| 値 | 説明 |
|---|---|
| food | 食べ物 |
| hobby | 趣味 |
| random | ランダム（全ジャンル混合） |

### Difficulty enum

| 値 | 説明 |
|---|---|
| easy | 簡単 |
| normal | 普通 |
| hard | 難しい |

### PlayMode enum

| 値 | 選択肢数 | 予想する数 | 入力方式 |
|---|---|---|---|
| normal | 3 | 全順位（3つ） | ドラッグで並び替え |
| hard | 6 | 上位3つ（順位付き） | タップで6→3選択 |

> サイクル数の定義: 1サイクル = 全員が1回ずつ出題。総ターン数 = サイクル数 × 人数

---

## Topic（お題）

アプリ内蔵のデータプール。各ターンでランダムに1問選出される。

| プロパティ | 型 | 説明 |
|---|---|---|
| id | String | 一意識別子 |
| question | String | 質問文（例:「昼に食べたいのは？」） |
| choices | [String] | 選択肢（normal=3, hard=6） |
| genre | Genre | ジャンル |
| difficulty | Difficulty | 難易度 |
| playMode | PlayMode | このお題が属するモード（normal / hard） |

> お題はプレイヤーが入力するものではなく、データプールからランダムに選出される

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
| targetPlayerId | String | ターゲットのPlayer.id |
| topicId | String | お題のTopic.id |
| answers | [Answer] | 回答一覧 |
| isCompleted | Bool | このターンが完了したか |

---

## Answer（回答）

| プロパティ | 型 | 説明 |
|---|---|---|
| playerId | String | 予想者のPlayer.id |
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
- ターゲットが設定した正解順位と予想者の予想の一致度でスコアを決定
- 完全一致で最高得点、部分一致で部分点

---

## 将来拡張フィールド（MVP未実装）

| モデル | フィールド | 用途 | Phase |
|---|---|---|---|
| Player | odaiStats | 出題傾向の分析データ | Phase 2 |
| GameSession | connectionMode | 通信モード | Phase 2 |
| GameSession | hostId | ホストプレイヤーID | Phase 2 |
| Answer | matchRate | 一致率（分析用） | Phase 2 |
