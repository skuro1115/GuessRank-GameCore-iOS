# お題フィードバック — テスト観点

## ストア単体（`TopicFeedbackStoreTests`）

### Block

- [x] 新規 `block(_:reason:)` で `blockedIds` に反映される
- [x] 同一IDの再ブロックは重複せず、理由が更新される
- [x] `unblock(_:)` で除外される
- [x] 未登録IDの `unblock` でクラッシュしない
- [x] `clearBlocks()` でブロックのみ削除（like は残る）
- [x] `clearAll()` で全件削除
- [x] 永続化: 別インスタンスを生成しても復元される
- [x] `isBlocked(_:)` で判定できる
- [x] 理由 `nil` でブロックできる
- [x] 空文字IDはブロックされない

### Like

- [x] 新規 `like(_:)` で `likedIds` に反映される
- [x] 同一IDの再 like は重複しない
- [x] `unlike(_:)` で除外される
- [x] 同一お題に block と like を独立して共存できる
- [x] 空文字IDは like されない

### マイグレーション

- [x] 旧 `topic_blocks.json`（リネーム前形式）から `topic_feedback.json` に自動変換され、旧ファイルは削除される

## ViewModel 連携（`GameProgressViewModelTests`）

### Block

- [x] `blockCurrentTopic(reason:)` でブロックストアに登録される
- [x] `blockCurrentTopic` でお題が差し替わる
- [x] ブロック済みお題は新規セッションの初期 Topic から除外される
- [x] `rankingInput` フェーズでは `blockCurrentTopic` が no-op となる

### Like

- [x] `toggleLikeCurrentTopic` で like 登録される
- [x] `toggleLikeCurrentTopic` を2回呼ぶと unlike される
- [x] `toggleLikeCurrentTopic` ではお題は差し替わらない（block と挙動が異なる）

## エクスポート（手動確認）

- [ ] FB 0件時はエクスポートセクションが非表示
- [ ] FB がある状態で ShareSheet が開く
- [ ] ファイル名が `guessrank_feedback_YYYY-MM-DD.json`
- [ ] JSON の内容が pretty-printed で、`topicId` / `kind` / `blockReason` / `recordedAt` を含む
- [ ] 機種変更想定: メールやAirDropで他端末に送れる
