# 将来拡張参考資料: 複数台通信設計

> この文書はPhase 2以降の参考資料です。MVP実装には含まれません。

## 概要

1台共有のローカルモードから、複数台での同時プレイに拡張する設計。

## 通信モード

### ネットワーク通信（Phase 2）

- Firebase Firestore によるリアルタイム同期
- ホストがルームを作成、ゲストが参加
- ホストのみがゲーム設定を変更可能

#### ルーム管理

- ルームコード（6桁）で参加
- ホストが開始ボタンを押すとゲーム開始
- 接続断時のリカバリ

### Bluetooth通信（Phase 3）

- 近距離通信、オフライン対戦
- 実装コストが高いため後回し

## アーキテクチャへの影響

### 状態同期

- ゲーム状態をFirestoreのドキュメントとして管理
- ホストが状態を更新、ゲストはリスニング
- 回答はゲストが直接書き込み

### UIの分岐

| 項目 | ローカル | 複数台 |
|---|---|---|
| 入力方式 | 端末回し | 各自の端末 |
| 覗き見防止 | PassDeviceScreen | 不要 |
| 結果表示 | 同一端末 | 全端末同期表示 |

> UIは分岐、ゲームロジック・スコア計算は共通

## データモデル追加（Phase 2）

| モデル | フィールド | 説明 |
|---|---|---|
| Room | id, code, hostId, playerIds, status | ルーム管理 |
| GameSession | connectionMode | 通信モード |
| GameSession | hostId | ホストプレイヤーID |

---

## Firebase SDK 構成（multiplayer 着手時）

ローカル運用フェーズ（Topic FB アップロード）で導入する基本4モジュール（FirebaseAuth / FirebaseFirestore / FirebaseAnalytics / FirebaseCrashlytics — [manual_setup.md](../manual_setup.md) 参照）に加え、multiplayer 着手と同時に **以下を追加** する想定。

### 必須

| モジュール | 用途 | 追加しないとどうなるか |
|---|---|---|
| **FirebaseAppCheck** | 不正クライアント対策。匿名認証のみだと誰でも Firestore に書き込めるため、AppCheck で正規アプリ経由のリクエストのみ許可する | 荒らし・スパム・スクリプト botでルームが汚染される |
| **FirebaseFunctions** | サーバーサイドロジック:<br>・ルーム作成のアトミック処理（コード重複回避）<br>・ホスト譲渡 / 離脱クリーンアップ<br>・お題抽選のサーバー側決定（クライアント改竄防止）<br>・スコア計算の改竄検知 | クライアント信頼ゼロにできず、不正スコア提出やルーム破壊を防げない |

### 強く推奨

| モジュール | 用途 |
|---|---|
| **FirebasePerformance** | リアルタイム同期の遅延がそのまま体験悪化に直結。Firestore クエリと往復レイテンシの分布を継続観測 |
| **FirebaseMessaging (FCM)** | リエンゲージメント:<br>・「友達がルームを作成」<br>・「あなたのターンです」<br>・リテンション向上の主要ツール |

### 任意 / 保留

| モジュール | 用途 |
|---|---|
| FirebaseRemoteConfig | feature_flags のリモート層と兼用可（[features/feature_flags/spec.md](../features/feature_flags/spec.md) 参照）。multiplayer の段階的ロールアウトや緊急停止スイッチに |
| FirebaseStorage | プロフィール画像 / カスタムお題の共有時のみ。基本不要 |
| FirebaseDatabase (Realtime DB) | Firestore で代替済み。**追加しない** |

---

## マニュアルセットアップ追加（multiplayer 着手時）

[manual_setup.md](../manual_setup.md) の Firebase セクションに以下が増える:

| 作業 | 場所 | 備考 |
|---|---|---|
| AppCheck の App Attest 設定 | Firebase Console → AppCheck | iOS は **App Attest 推奨**（iOS 14+）。DeviceCheck は古い端末向けフォールバック |
| Functions の Node.js プロジェクト初期化 | ローカル CLI: `firebase init functions` | TypeScript 推奨 |
| FCM 用 APNs 認証キー登録 | Apple Developer Keys + Firebase Console → Cloud Messaging | `.p8` キーをアップロード（チーム単位で1個でOK） |
| Firestore セキュリティルール multiplayer 拡張 | Firebase Console | ルームメンバーのみ書き込み可、ホストのみ状態更新可 等 |
| Blaze プラン移行（成長時） | Firebase Console | 無料枠超過時。クレジットカード必要 |

---

## コスト見積もり（multiplayer 時）

Firebase 無料枠（Spark プラン）月次:
- Firestore: 50,000 read / 20,000 write / 1GB storage / 1GB transfer
- Functions: 125,000 呼び出し / 40,000 GB秒
- AppCheck / Crashlytics / Analytics: 無料

### multiplayer の典型負荷（推定）

- 1試合 ≈ 6人 × 18ターン × 数 read/write/操作 → 約 200 read + 50 write
- 月 1000 試合まで無料枠で十分余裕

→ MVP〜初期成長期は **無料枠で運用可能**。スケール時に Blaze プランに移行して BigQuery 連携で詳細分析を有効化。
