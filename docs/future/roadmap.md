# Future 機能 ロードマップ

`docs/future/` の各機能の **優先順位** と **依存関係** を整理する。優先順位は「ユーザー価値」「実装コスト」「他機能の前提となるか」「手動セットアップでブロックされていないか」の総合判断。

> 手動セットアップ要件は [manual_setup.md](../manual_setup.md) を参照
> プロジェクト全体のフェーズは [project_overview.md](../project_overview.md) を参照

---

## 優先順位サマリ

| # | 機能 | 規模 | ユーザー価値 | 開発ROI | 手動セットアップ | 状態 |
|---|---|---|---|---|---|---|
| **1** | [feature_flags.md](feature_flags.md) — 機能フラグ基盤 | S | — | 高（dev_mode を解放） | 不要 | **着手中** |
| **2** | [dev_mode.md](dev_mode.md) — 開発者モード（QuickStart 等） | M | — | **非常に高** | 不要 | 1 後 |
| 3 | analytics_design.md — 累計分析（ジャンル傾向・スコア推移） | M | 中 | 中 | 不要 | 待機 |
| 4 | [remote_topics.md](remote_topics.md) — お題リモート配信 | M | 高 | 中 | ホスティング選定 | 待機 |
| 5 | Firebase 基盤 + Topic FB アップロード | S（基盤後） | 中 | 中 | Firebase プロジェクト | 待機 |
| 6 | [monetization.md](monetization.md) — AdMob + 広告削除 IAP | M | — | 中 | AdMob / IAP 設定 | 待機 |
| 7 | [multiplayer_design.md](multiplayer_design.md) — 複数台通信 | XL | 非常に高 | 低 | Firebase 必須 | 後段 |

---

## 各機能の優先付け根拠

### #1 feature_flags（機能フラグ基盤）

**選定理由**:
- 規模が小さく単独で完結
- dev_mode 含む複数機能の **前提** になる
- リリース版に WIP 機能を main へマージしながら隠蔽できるため、ブランチ滞留が減る
- 手動セットアップ完全不要

**スコープ**: ビルド時 + 起動時 + 実行時の3層をカバー。リモート層は #5 と同時導入（後段）

### #2 dev_mode（最小: QuickStart のみ）

**選定理由**:
- QA / スクリーンショット / 不具合再現に大きな時間ロスが発生している
- App Store 用スクショの量産に直接効く
- feature_flags（#1）の最初の利用者として相互検証になる
- DEBUG ビルド限定で配布リスクなし

**最初のスコープ**: クイックスタート（ダミープレイヤー4名 + デフォルト設定でゲーム開始）のみ
**後続 PR**: デバッグオーバーレイ・お題固定・データリセット・状態スナップショットを段階追加

### #3 累計分析（ジャンル傾向 / スコア推移）

**選定理由**:
- 現状 `AnalyticsService` は1ゲーム単位のみ。「友達の価値観がわかる」コアコンセプトを **複数ゲーム横断** で深める
- 既存 `GameHistoryStore` を拡張する形で実装可能（保持期間延長）
- 手動セットアップ不要

**ブロッカー**: 履歴の保持期間を2日→30日（または90日）に延ばす設計判断が必要

### #4 remote_topics（お題リモート配信）

**選定理由**:
- 旬なお題・季節お題を配信できる → リテンション向上
- 静的 JSON ホスティングなら無料で運用可能（GitHub Pages 等）
- アプリアップデートなしでお題を増やせる

**ブロッカー**: ホスティング先の選定。GitHub Pages 推奨（無料・既存リポ流用可）

### #5 Firebase 基盤 + Topic FB アップロード

**選定理由**:
- multiplayer / AdMob / リモート機能の前提
- 一度入れると以降の機能の追加コストが下がる
- 単独でも Topic FB をリモート集計できる価値あり

**ブロッカー**: Firebase プロジェクト作成・`GoogleService-Info.plist` 取得（[manual_setup.md](../manual_setup.md)）

### #6 monetization（AdMob + 広告削除 IAP）

**選定理由**:
- ユーザーベースが育ってからでなければ収益はほぼゼロ
- Firebase が入っていれば AdMob 統合の追加コストは小
- 広告削除 IAP は AdMob の後ろにしか作れない

**ブロッカー**: AdMob アカウント・IAP 商品設定（[manual_setup.md](../manual_setup.md)）
**前提**: ユーザーベースの存在 / Firebase 統合済み

### #7 multiplayer

**選定理由**:
- アプリの上限価値を一気に引き上げる最大機能
- ただし **規模が桁違い** に大きい（複数 PR 必須）
- ローカル基盤の安定が前提

**ブロッカー**: Firebase 統合済 / アーキテクチャ追加設計

---

## 依存関係グラフ

```
feature_flags ──┬─→ dev_mode (QuickStart → overlay → reset → ...)
                ├─→ analytics_experiment (任意)
                └─→ remote_topics の段階的展開（任意）

Firebase 統合 ──┬─→ Topic FB アップロード
                ├─→ multiplayer
                └─→ AdMob（Firebase Analytics 連携）─→ 広告削除 IAP

remote_topics ── (独立、ホスティング次第)

累計分析 ── (独立、ローカル完結)
```

---

## 次の3 PR の予定

1. **本 PR (`feat/feature-flags-and-dev-quickstart`)**: feature_flags 基盤 + dev_mode 最小（QuickStart）
2. **次 PR**: 累計分析（ジャンル傾向 / スコア推移）— ローカル完結
3. **次々 PR**: remote_topics スキャフォールド — ホスティング不要部分まで

Firebase / AdMob は **手動セットアップ完了後** に別ブランチで対応。

---

## 優先順位の見直し基準

以下のいずれかが起きたら見直す:

- **ユーザーベースが急増** → AdMob 優先度上昇
- **TestFlight ベータ募集** → multiplayer 前倒し検討
- **イベント / 季節商戦** → remote_topics 前倒し
- **アプリ容量の問題** → bundled topics の代わりに remote_topics
