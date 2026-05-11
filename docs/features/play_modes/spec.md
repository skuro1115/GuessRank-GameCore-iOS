# プレイモード — 仕様

> ゲームルール全体は [game_rules.md](../../product/game_rules.md) を参照

## 概要

ゲーム設定で **プレイモード** を切り替えると、選択肢数と回答方式が変わる。MVP には `normal`（3択全順位）と `hard`（6択上位3つ）の2モードを実装する。

## モード一覧

| モード | 選択肢数 | 予想する数 | 入力方式 | 備考 |
|---|---|---|---|---|
| ノーマル（normal） | 3 | 3つ全ての順位 | ドラッグで並び替え | デフォルト |
| ハード（hard） | 6 | 上位3つを順位付き | タップで6つから3つ選択 | |

## ビジネスルール

1. プレイモードは `GameConfig.playMode` で保持し、セッション開始時に固定される
2. お題は `Topic.playMode` を持ち、ゲーム設定の `playMode` と一致するもののみ選出される
3. ノーマルモードのターゲット入力は選択肢を全て並べ替える形式（`rankingInput.count == 3`）
4. ハードモードのターゲット入力は6つから3つを選んで順位付けする形式（`rankingInput.count == 3`、選択値は6つの中の任意の3つ）
5. スコア計算は両モード共通: 1〜3位の各位置で正解と一致した数で 100 / 50 / 20 / 0 点を付与

## 制約

- ハードモードでは「決定」ボタンは3スロット全てが埋まるまで disabled
- お題変更（パス）でも同じモードのお題のみ選ばれる
- お題プールの `playMode` と `GameConfig.playMode` の不一致は `TopicService` の事前フィルタで防ぐ

## 状態遷移

```
GameSettingsView でモード選択 → GameSession.config.playMode 確定
    ↓
TopicService.pickTopics(playMode:) でモード一致のみ抽出
    ↓
TurnInputState.startTargetInput() で
    normal → rankingInput = topic.choices（3要素）
    hard   → rankingInput = []（空、ユーザーが選択）
    ↓
RankingInputView が playMode によって RankingEditor / HardRankingEditor を切替
    ↓
canSubmitRanking で完了判定 → submitRanking() で次フェーズへ
```

## データ

### PlayMode enum

| 値 | choiceCount | rankSlotCount |
|---|---|---|
| normal | 3 | 3 |
| hard | 6 | 3 |

### Codable 互換性

旧バージョンの JSON（`playMode` フィールド未指定）は `.normal` にフォールバックする。`GameConfig` と `Topic` の両方でこの後方互換を保つ。

## 関連モデル / 実装

> データモデルの定義は [data_model.md](../../data_model.md) を参照

- `PlayMode`（Model）: モード列挙型
- `GameConfig.playMode`: セッション設定
- `Topic.playMode`: お題のモード分類
- `TopicService.pickTopics(..., playMode:, excluding:)`: モードでフィルタ
- `GameProgressViewModel.canSubmitRanking`: ハードモードでの3要素制約判定
- `TurnInputState.initialRanking(for:)`: モード別の入力初期化
- `RankingInputView`: モードで Editor を切替
- `HardRankingEditor`（View）: 6択→3スロットのタップ式選択
- `RankingEditor`（View）: 3択ドラッグ並び替え（既存）
- `GameSetupViewModel.playMode` + `GameSettingsView`: モードピッカー

## 将来拡張

- Phase 2: 選択肢数を動的に拡張（4〜N）
- Phase 2: モードごとの難易度別お題セット
- Phase 2: モードごとの最高スコア記録（ハードは現状ノーマルと共通スコア計算）
