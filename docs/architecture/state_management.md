# 状態管理設計

## 状態の分離（重要）

通信状態とゲーム状態は **必ず分離する**。混ぜると将来の通信対応で崩壊する。

### A. 通信状態（ConnectionState）

MVP では最小限だが、構造だけ用意しておく。

| プロパティ | 型 | MVP |
|---|---|---|
| mode | ConnectionMode | local 固定 |
| isHost | bool | true 固定 |
| connectedPlayers | List\<String\> | — |

### B. ゲーム状態（GameState）

ゲーム進行に関するすべての状態。

| プロパティ | 型 | 説明 |
|---|---|---|
| session | GameSession | 現在のセッション |
| currentPhase | TurnPhase | ターン内のフェーズ |
| inputBuffer | Map | 入力中の一時データ |

### TurnPhase enum

1ターン内の進行フェーズ（Swift enum で定義）:

```swift
enum TurnPhase {
    case showQuestioner
    case showTopic
    case collectAnswers
    case showResult
}
// showQuestioner → showTopic → collectAnswers → showResult → (next turn or end)
```

| 値 | 説明 |
|---|---|
| showQuestioner | 出題者表示 |
| showTopic | お題表示 |
| collectAnswers | 回答収集中（端末回し） |
| showResult | ターン結果表示 |

## 状態遷移図（ゲーム全体）

```
[通信設定] → [ゲーム設定] → [プレイヤー入力]
                                    ↓
                              [ゲーム開始]
                                    ↓
                            ┌─ [出題者表示] ←──────┐
                            ↓                      │
                        [お題表示]                  │
                            ↓                      │
                      [回答収集]                    │
                       (端末回し)                   │
                            ↓                      │
                      [結果表示]                    │
                            ↓                      │
                     {最終ターン?} ─ No ───────────┘
                            │ Yes
                            ↓
                        [終了画面]
                            ↓
                     {再戦?} ─ Yes → [ゲーム設定]
                            │ No
                            ↓
                        [アプリ終了]
```

## ローカルモード：端末回しの状態

回答収集フェーズでは、プレイヤーごとに端末を回す。

```
[次の人に渡してください] → [入力画面] → [確認画面] → [送信完了]
         ↓                                              ↓
    (端末を渡す)                                   {全員入力済み?}
                                                    Yes → [結果表示]
                                                    No  → [次の人に渡してください]
```

### 覗き見防止ルール

1. 入力画面はシンプルに（他人の回答を見せない）
2. 確認画面を必ず挟む
3. 入力確定後は即座に「次の人に渡してください」画面に遷移

## プレイヤー状態管理

各プレイヤーについて追跡する情報:

| 状態 | 型 | 説明 |
|---|---|---|
| isCurrentPlayer | bool | 現在の操作対象か |
| hasAnswered | bool | 今ターンで入力済みか |
| isQuestioner | bool | 今ターンの出題者か |
