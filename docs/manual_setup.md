# 手動セットアップ手順

このドキュメントは **コードでは完結しない、ユーザーが外部で操作する必要がある作業** をまとめたチェックリストです。各 future 機能を実装する前に、対応する手動作業が必要かここで確認してください。

> ロードマップと優先順位は [future/roadmap.md](future/roadmap.md) を参照

---

## ✅ 既に対応済み

- [x] Apple Developer アカウント
- [x] App Store Connect でのアプリ登録
- [x] バンドル ID / 証明書 / プロビジョニングプロファイル
- [x] サポートサイト（[support.html](support.html)）公開
- [x] プライバシーポリシー（support.html 内、ローカル運用前提）

---

## 🔧 現時点で実装に必要な手動作業

**いまブロックしている作業は無し。** すべての MVP+1 機能は手動セットアップなしで実装可能。

---

## ⏳ 将来機能のために必要な手動作業

### Firebase 統合（Phase 2 — multiplayer / topic FB upload / remote topics の前提）

| 作業 | 場所 | 備考 |
|---|---|---|
| Firebase プロジェクト作成 | https://console.firebase.google.com | iOS アプリを追加。バンドル ID を一致させる |
| `GoogleService-Info.plist` をダウンロード | Firebase Console | `GuessRank/GuessRank/` 配下に配置（**.gitignore に追加すること**） |
| Firebase iOS SDK を SPM で追加 | Xcode Project | 必要なモジュール: `FirebaseAuth` / `FirebaseFirestore` / `FirebaseAnalytics` |
| Anonymous Authentication を有効化 | Firebase Console → Authentication | サインイン方法 → 匿名 をオン |
| Firestore データベースを作成 | Firebase Console → Firestore | ロケーションは `asia-northeast1`（東京）推奨 |
| Firestore セキュリティルール初期設定 | Firebase Console | 匿名認証ユーザーが自分のFB書き込みのみ許可するルール（実装時に提示） |
| Cloud Storage（任意） | Firebase Console | リモートお題 JSON 配信用。または別途 S3/GitHub Pages でも可 |

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
