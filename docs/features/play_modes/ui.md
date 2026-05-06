# プレイモード — UI

## モード選択（`GameSettingsView`）

ゲーム設定画面の「ゲーム設定」カード内に segmented picker で配置。

```
プレイモード               [ ノーマル | ハード ]
{shortDescription}
```

`shortDescription` はモードに応じて変化:
- ノーマル: 「選択肢3つ・全順位を当てる」
- ハード: 「選択肢6つ・上位3つを当てる」

## お題画面（`TopicView`）

選択肢の表示はモードで切り替える。

| モード | レイアウト |
|---|---|
| normal | 縦方向 1 列 × 3 段、A/B/C ラベル + 大きな choiceColor |
| hard   | 2 列 × 3 段の `LazyVGrid`、A〜F ラベル + 6 色 |

長押しコンテキストメニュー（ブロック機能）はどちらでも有効。

## 入力画面（`RankingInputView`）

```swift
if topic.playMode == .hard {
    HardRankingEditor(...)
} else {
    RankingEditor(...)
}
```

### ハードモードの `HardRankingEditor`

```
+----------------+   +----------------+   +----------------+
|    1位        |   |    2位        |   |    3位        |
|  (空 or 選択)  |   |  (空 or 選択)  |   |  (空 or 選択)  |
+----------------+   +----------------+   +----------------+

[A] choice1   [B] choice2
[C] choice3   [D] choice4
[E] choice5   [F] choice6
```

#### 操作

| 操作 | 動作 |
|---|---|
| 未選択の choice タップ | 次の空きスロットに入る（最大3つまで） |
| 選択済みの choice タップ | スロットから外れる |
| 埋まったスロットタップ | そのスロットの選択を外す |
| 全スロット埋まった状態で未選択 choice タップ | no-op（disabled、半透明） |

#### 「決定」ボタン

`viewModel.canSubmitRanking` が `false` の間は disabled（灰色背景）。3スロット全て埋まると有効化。

### ノーマルモードの `RankingEditor`

既存実装のまま（ドラッグで並び替え）。
