# プレイモード — テスト観点

## PlayMode enum（`PlayModeTests`）

- [x] `choiceCount`: normal=3, hard=6
- [x] `rankSlotCount`: 両モードとも 3
- [x] `displayName` 表示文字列
- [x] Codable で往復できる

## GameConfig（`GameConfigTests`）

- [x] `playMode` のデフォルトは `.normal`
- [x] `.hard` を指定して構築できる
- [x] Codable で `playMode` 付きで往復できる
- [x] 旧 JSON（`playMode` フィールド無し）は `.normal` にフォールバック

## TopicService（`TopicServiceTests`）

- [x] お題の `choices.count` は `playMode.choiceCount` と一致する
- [x] `playMode: .normal` 指定でハードモードのお題は除外される
- [x] `playMode: .hard` 指定でノーマルモードのお題は除外される（hard は 6 択）
- [x] `totalTopicCount` は `allTopics.count` と一致

## ViewModel（`GameProgressViewModelTests`）

- [x] ハードモードでターゲット入力初期値は空配列
- [x] `canSubmitRanking` は3要素揃わないと false
- [x] 未完了状態で submit してもフェーズが進まない
- [x] ハードモード完全一致のゴールデンパス（target=top3, guesser=top3 → 100点）

## 手動テスト観点（UI）

- [ ] ゲーム設定画面で normal/hard を切替できる
- [ ] hard 選択時は 6 つの choice カードが TopicView に表示される
- [ ] hard 入力画面で choice タップで上位 3 スロットが順番に埋まる
- [ ] 4 つ目を選ぼうとしても受け付けない（disabled, opacity 0.5）
- [ ] スロットタップで該当 choice の選択が外れる
- [ ] 「決定」ボタンは 3 スロット全埋まりまで disabled
- [ ] TurnResultView でハード結果（6 色 / A〜F ラベル）が崩れない
