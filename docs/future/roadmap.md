# Future 機能 ロードマップ

`docs/future/` の各機能の **優先順位** と **依存関係** を整理する。優先順位は「ユーザー価値」「実装コスト」「他機能の前提となるか」「手動セットアップでブロックされていないか」の総合判断。

> 手動セットアップ要件は [manual_setup.md](../manual_setup.md) を参照
> プロジェクト全体のフェーズは [product/overview.md](../product/overview.md) を参照

---

## ✅ 完了済み（features/ に移動済）

| 機能 | features/ |
|---|---|
| 機能フラグ基盤 | [features/feature_flags/](../features/feature_flags/) |
| 開発者モード（QuickStart のみ） | [features/dev_mode/](../features/dev_mode/) |
| 分析機能（相性・お題サプライズ） | [features/analytics/](../features/analytics/) |

---

## 優先順位サマリ（着手予定）

| # | 機能 | 規模 | ユーザー価値 | 開発ROI | 手動セットアップ | 状態 |
|---|---|---|---|---|---|---|
| **1** | dev_mode 拡張（オーバーレイ / リセット / スナップショット 等） | M | — | 高 | 不要 | 次着手 |
| **2** | Firebase 基盤 + Topic FB アップロード | S | 中 | 中（multiplayer の前提） | Firebase プロジェクト | 待機 |
| **3** | [multiplayer_design.md](multiplayer_design.md) — 複数台通信 | XL | 非常に高 | 低 | Firebase 必須 | 待機 |
| **4** | [monetization.md](monetization.md) — AdMob + 広告削除 IAP | M | — | 中 | AdMob / IAP 設定 | 待機 |
| 保留 | [remote_topics.md](remote_topics.md) — お題リモート配信 | M | 高 | 中 | ホスティング選定 | **保留** |
| 不要 | ~~累計分析（ジャンル傾向 / スコア推移）~~ | — | — | — | — | **不要判断** |

---

## 各機能の優先付け根拠

### #1 dev_mode 拡張

**選定理由**:
- QuickStart で開発体験は改善したが、**スクリーンショット撮影 / バグ再現** にはまだ不足
- すでに feature_flags 基盤があるので、各機能の追加コストは小さく分割しやすい
- 手動セットアップ完全不要

**最小スライス候補**: デバッグオーバーレイ → データリセット → 状態スナップショット → お題固定 / シード固定 → アニメ速度

### #2 Firebase 基盤 + Topic FB アップロード

**選定理由**:
- multiplayer / monetization の **前提**
- 一度入れると以降の機能の追加コストが下がる
- 単独でも Topic FB をリモート集計できる価値あり

**ブロッカー**: Firebase プロジェクト作成・`GoogleService-Info.plist` 取得（[manual_setup.md](../manual_setup.md)）

### #3 multiplayer

**選定理由**:
- アプリの上限価値を一気に引き上げる最大機能
- ただし **規模が桁違い** に大きい（複数 PR 必須）
- ローカル基盤の安定が前提

**ブロッカー**: Firebase 統合済 / アーキテクチャ追加設計
**実装計画**: [multiplayer_design.md](multiplayer_design.md) を参照（Firestore でルーム管理・状態同期）

### #4 monetization（AdMob + 広告削除 IAP）

**選定理由**:
- ユーザーベースが育ってからでなければ収益はほぼゼロ
- Firebase が入っていれば AdMob 統合の追加コストは小
- 広告削除 IAP は AdMob の後ろにしか作れない

**ブロッカー**: AdMob アカウント・IAP 商品設定（[manual_setup.md](../manual_setup.md)）
**前提**: ユーザーベースの存在 / Firebase 統合済み

---

## 保留 / 不要の判断

### 保留: remote_topics

**保留理由**: 当面はバンドル内蔵お題で十分との判断。お題不足やユーザー要望が顕在化したら再開。

**着手時の前提**: ホスティング先選定（GitHub Pages 推奨・無料・既存リポ流用可）

### 不要: 累計分析

**判断**: 当初 Phase 2 で計画されていたが不要判断:
- 複数ゲーム横断の player identity が不安定（プレイヤー名が毎回ぶれる前提のパーティーゲーム）
- 1ゲーム単位の分析（[features/analytics/](../features/analytics/)）で十分な価値を提供している
- 累計分析の保持と表示が、シンプルな party game の体験を逆に複雑にする

---

## 依存関係グラフ

```
✅ feature_flags ──┬─→ ✅ dev_mode (QuickStart)
                  └─→ #1 dev_mode 拡張 (overlay / reset / snapshot ...)

#2 Firebase 統合 ──┬─→ Topic FB アップロード（FBの集計・改善）
                   ├─→ #3 multiplayer
                   └─→ #4 AdMob（Firebase Analytics 連携）─→ 広告削除 IAP

(remote_topics: 保留)
(累計分析: 不要)
```

---

## 優先順位の見直し基準

以下のいずれかが起きたら見直す:

- **ユーザーベースが急増** → AdMob 優先度上昇
- **TestFlight ベータ募集** → multiplayer 前倒し検討
- **イベント / 季節商戦・お題不足** → remote_topics 復活
- **アプリ容量の問題** → bundled topics の代わりに remote_topics
