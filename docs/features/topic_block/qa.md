# お題ブロック — テスト観点

## ストア単体（`TopicBlockStoreTests`）

- [x] 新規 `block(_:)` で `blockedIds` に反映される
- [x] 同一IDの再ブロックは重複せず、理由が更新される
- [x] `unblock(_:)` で除外される
- [x] 未登録IDの `unblock` でクラッシュしない
- [x] `clearAll()` で全件削除
- [x] 永続化: 別インスタンスを生成しても復元される
- [x] `isBlocked(_:)` で判定できる
- [x] 理由 `nil` でブロックできる
- [x] 空文字IDはブロックされない

## ViewModel 連携（`GameProgressViewModelTests`）

- [x] `blockCurrentTopic(reason:)` でブロックストアに登録される
- [x] `blockCurrentTopic` でお題が差し替わる
- [x] ブロック済みお題は新規セッションの初期 Topic から除外される
- [x] `rankingInput` フェーズでは `blockCurrentTopic` が no-op となる
