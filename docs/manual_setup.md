# 手動セットアップ手順

このドキュメントは **コードでは完結しない、ユーザー（人間）が外部で操作する必要がある作業** をまとめたチェックリストです。Claude / AI には実行できないので、各タスクは手動で進める必要があります。

> ロードマップと優先順位は [future/roadmap.md](future/roadmap.md) を参照

---

## 🚦 現在の優先順位

ロードマップ次フェーズ（Firebase / multiplayer / 広告）に進むためのブロッカー。**並行で進めると AI 側の実装と噛み合います**。

### 🔴 今すぐ着手推奨（次フェーズの起点）

| # | タスク | 所要時間 | アンブロックする機能 |
|---|---|---|---|
| 1 | **Firebase プロジェクト作成** | 10分 | Topic FB アップロード / multiplayer / AdMob |
| 2 | **iOS アプリを Firebase に追加** | 5分 | 同上 |
| 3 | **`GoogleService-Info.plist` 取得** | 1分 | 同上 |
| 4 | **Anonymous Authentication 有効化** | 1分 | Topic FB アップロード（匿名 ID） |
| 5 | **Firestore データベース作成（asia-northeast1）** | 3分 | Topic FB アップロード / multiplayer |

→ 5タスク合計 **20分程度**。完了したら声かけてください。AI 側で `GoogleService-Info.plist` を `.gitignore` 追加 + Firebase SDK の SPM 統合をします。

### 🟡 余裕があれば

| タスク | 所要時間 | アンブロックする機能 |
|---|---|---|
| AdMob アカウント作成 | 5分 | 広告 / 広告削除 IAP |
| Paid Apps Agreement に同意（App Store Connect） | 銀行・税情報入力で数日 | IAP 全般 |

### 🟢 まだ着手しなくて OK（実装と同時で間に合う）

- App Store Connect 栄養ラベル更新（Firebase / AdMob 追加時に同時対応）
- Required Reasons API 宣言（Firebase 統合 PR で対応）
- プライバシーポリシー（support.html）の更新（同上）
- IAP 商品作成（広告削除 IAP 実装時）
- AdMob 広告ユニット作成（AdMob 実装時）

---

## ✅ 既に対応済み

- [x] Apple Developer アカウント
- [x] App Store Connect でのアプリ登録
- [x] バンドル ID / 証明書 / プロビジョニングプロファイル
- [x] サポートサイト（[support.html](support.html)）公開
- [x] プライバシーポリシー（support.html 内、ローカル運用前提）

---

## 🔧 現時点で実装に必要な手動作業

**いまブロックしている作業は無し。** dev_mode 拡張系（オーバーレイ・お題固定・スナップショット）は全て AI 側で完結可能。

---

## ⏳ 将来機能のために必要な手動作業

### Firebase 統合（Phase 2 — multiplayer / topic FB upload / remote topics の前提）

#### ステップ詳細

1. **プロジェクト作成** — [https://console.firebase.google.com](https://console.firebase.google.com) → 「プロジェクトを作成」
   - プロジェクト名: `GuessRank`（任意）
   - Google Analytics: 有効化推奨（後で AdMob 連携で利用）
2. **iOS アプリ追加** — プロジェクトトップ → iOS+ アイコン
   - バンドル ID: `shion.GuessRank`（既存と一致させる）
   - 「アプリを登録」 → `GoogleService-Info.plist` をダウンロード
   - **配置はまだしないでください。AI 側で `.gitignore` 追加と同時に行います。**
3. **Anonymous Authentication 有効化** — 左メニュー Authentication → Sign-in method → 匿名 → 有効
4. **Firestore データベース作成** — 左メニュー Firestore Database → データベースの作成
   - モード: **本番環境モード**（後で AI 側でルールを書きます）
   - ロケーション: `asia-northeast1`（東京）
5. **（任意）Firebase Hosting / Storage** — リモートお題配信用（保留中なので不要）

#### AI 側で実施する作業

ユーザーが上記5ステップを完了して `GoogleService-Info.plist` を渡してくれたら、以下を実装:

| 作業 | 内容 |
|---|---|
| `.gitignore` に追加 | `GoogleService-Info.plist` を漏らさない |
| ファイル配置 | `GuessRank/GuessRank/` 配下に配置 |
| Firebase iOS SDK を SPM で追加 | `FirebaseAuth` / `FirebaseFirestore` / `FirebaseAnalytics` |
| Firestore セキュリティルール | 匿名認証ユーザーが自分のFB書き込みのみ許可するルール |
| `FeedbackUploader` 実装 | TopicFeedbackStore のエントリを Firestore に flush |

### AdMob 統合（Phase 3 — ads / IAP の前提）

| 作業 | 場所 | 備考 |
|---|---|---|
| AdMob アカウント作成 | https://admob.google.com | 既存の Google アカウントで可 |
| アプリを AdMob に登録 | AdMob Console | Firebase プロジェクトに紐付け推奨（eCPM最適化） |
| 広告ユニット作成（バナー / インタースティシャル / リワード） | AdMob Console | ユニットIDを取得 |
| App Tracking Transparency 文言準備 | docs/support.html / Info.plist | iOS 14.5+ 必須（`NSUserTrackingUsageDescription`） |
| 広告審査用テスト広告ID で動作確認 | コード | 本番IDに切り替える前に必須 |

### App Store Connect — 課金（IAP）（Phase 3）

| 作業 | 場所 | 備考 |
|---|---|---|
| Paid Apps Agreement に同意 | App Store Connect → Agreements | 銀行口座・税情報の入力が必要 |
| IAP 商品を作成 | App Store Connect → アプリ → App 内課金 | 例: `com.guessrank.removeads`（非消費型） |
| 商品の表示名・説明・価格を設定 | App Store Connect | 各国通貨で個別設定可 |
| サンドボックステスター作成 | App Store Connect → Users | 検証用 |
| StoreKit 設定ファイル（`.storekit`）作成 | Xcode | ローカル動作確認用 |

### App Store Connect — プライバシー栄養ラベル更新

第三者 SDK を入れた瞬間に **必ず** 更新が必要。

| 作業 | タイミング |
|---|---|
| プライバシー栄養ラベル更新 | Firebase / AdMob 追加時 |
| Required Reasons API 宣言 | Firebase の特定 API 利用時（[Apple ドキュメント](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)） |
| プライバシーポリシー（support.html）更新 | 同上。データ種別・保持期間・第三者 SDK・ATT を反映 |

### リモートお題配信（Phase 2）

静的 JSON を配信する場合は手動セットアップが軽い。

| 作業 | 選択肢 | 備考 |
|---|---|---|
| ホスティング決定 | Firebase Hosting / Storage / GitHub Pages / Cloudflare Pages / S3 | GitHub Pages が無料で簡単 |
| ドメイン / URL 確定 | 上記サービス | アプリ側で URL をハードコードまたはリモート設定 |
| お題 JSON フォーマット確定 | docs/future/remote_topics.md を実装時にスキーマ化 | バージョン管理を含める |

---

## 🚫 当面不要

- マイグレーションサーバー（端末ローカル運用のため）
- プッシュ通知（用途なし）
- マップ系 API（位置情報利用なし）
- Sign in with Apple（アカウント機能を作らないため）

---

## チェックポイント

新しい future 機能の実装を開始する前に、必ず以下を確認:

1. このドキュメントの該当セクションの作業が完了しているか
2. プライバシーポリシー / 栄養ラベルの更新タスクを把握しているか
3. ロードマップ（[future/roadmap.md](future/roadmap.md)）で前提機能が完了しているか
