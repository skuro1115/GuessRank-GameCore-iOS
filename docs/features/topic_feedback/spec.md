# お題フィードバック — 仕様

> ゲームルール全体は [game_rules.md](../../game_rules.md) を参照

## 概要

お題に対するユーザーFBを統一管理する。FBは2種類：

- **ブロック**: 不適切・つまらないと感じたお題を以降のゲームで除外
- **面白い (like)**: 面白いと感じたお題を記録（ゲーム選定には影響しない）

設定画面から個別／一括で解除でき、JSONファイルとしてエクスポートできる。

## ビジネスルール

### 共通

1. お題画面（`showTopic` フェーズ）右上の `👍` / `⋯` ボタンから操作
2. `showTopic` 以外のフェーズでは操作は no-op
3. FBは永続化（Documents 配下の `topic_feedback.json`）
4. 旧 `topic_blocks.json`（リネーム前形式）は初回起動時に自動マイグレーション
5. 同一お題に対し block と like は独立して共存可能

### ブロック

1. 理由は任意（不適切 / つまらない / その他 / 理由なし）
2. ブロック実行時、現在のお題は即座に別のお題に差し替えられる（`passTopic` を内部で呼ぶ）
3. ブロックされたお題IDは新規セッションの初期 Topic 候補から除外される
4. お題変更（パス）時もブロック対象は除外される
5. 同一IDの再ブロックは重複させない（最新の理由・日時で上書き）
6. フィルタ後の候補が空になる場合は、ゲーム継続のため除外を無視してフォールバック選出する

### 面白い (like)

1. トグル動作（タップで登録／再タップで解除）
2. **お題は差し替えない**（記録のみで対象お題でそのまま遊べる）
3. 同一IDの重複登録はしない
4. 今後のゲーム選定には影響しない（純粋に記録）

### エクスポート

1. 設定画面「データエクスポート」セクションの ShareLink から書き出し
2. ファイル名: `guessrank_feedback_YYYY-MM-DD.json`
3. 形式: pretty-printed JSON、日時は ISO8601、`entries` は `topicId` / `kind` / `blockReason` / `recordedAt` を含む
4. **送信機能は持たない** — iOS標準 ShareSheet 経由でユーザーが任意の宛先に共有
5. FBが0件の時はセクションごと非表示

## データ

### TopicFeedback

| プロパティ | 型 | 説明 |
|---|---|---|
| topicId | String | 対象のお題ID |
| kind | TopicFeedbackKind | `block` / `like` |
| blockReason | TopicBlockReason? | ブロック理由（kind=block のみ） |
| recordedAt | Date | 記録日時 |

### TopicFeedbackKind enum

| 値 | 説明 |
|---|---|
| block | ブロック |
| like | 面白い |

### TopicBlockReason enum

| 値 | 表示名 |
|---|---|
| inappropriate | 不適切 |
| boring | つまらない |
| other | その他 |

## 状態遷移

```
showTopic フェーズ
    ├─ 👍 タップ → like 登録（お題はそのまま）
    │   └─ 再タップ → like 解除
    └─ ⋯ Menu → 理由を選択
        └─ ブロックストアに登録 → passTopic → 別のお題が選ばれる
```

## 関連モデル / 実装

> データモデルの定義は [data_model.md](../../data_model.md) を参照

- `TopicFeedbackStore`（Service）: 永続化と CRUD（block/like 統一）
- `TopicFeedback`（Model）: 永続化レコード
- `GameProgressViewModel.blockCurrentTopic(reason:)`: ブロック登録 + お題差し替え
- `GameProgressViewModel.toggleLikeCurrentTopic()`: like トグル（お題は維持）
- `GameProgressViewModel.isCurrentTopicLiked`: 現在お題のlike状態
- `TopicView`: 質問テキスト右上の `👍` ボタンと `⋯` Menu
- `TopicSettingsView`: ブロック・likeの一覧、解除、エクスポート

## 将来拡張

- リモート集計（Phase 2 の Firebase 導入時に `FeedbackUploader` を追加）
- 集計データを元に「面白いお題」を判定して優先選出
