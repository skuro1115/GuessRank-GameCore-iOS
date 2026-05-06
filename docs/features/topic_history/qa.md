# お題履歴 — テスト観点

## ストア単体（`TopicHistoryStoreTests`）

- [x] `record(_ id:)` で `playedIds` に追加される
- [x] 同一IDの再 record で重複しない
- [x] `record(_ ids:)` のシーケンス版で一括追加できる
- [x] `clear()` で全件削除される
- [x] 永続化: 別インスタンスを生成しても復元される
- [x] `clear()` 後の永続化: 別インスタンスでも空
- [x] 空文字IDは記録されない

## ViewModel 連携（`GameProgressViewModelTests`）

- [x] ターン完了で現在のお題IDが履歴に記録される
- [x] 履歴にあるお題IDは新規セッションの初期 Topic から除外される
- [x] `passTopic` 時も履歴にあるお題IDは候補から除外される

## TopicService 連携（`TopicServiceTests`）

- [x] `excluding` で指定したIDは選ばれない
- [x] `excluding` 空はデフォルトのフィルタなし挙動と等価
- [x] 全候補が除外されてもフォールバックでお題を返す
