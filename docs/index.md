# GuessRank ドキュメント一覧

このファイルはプロジェクトドキュメントの **中央マップ** です。
すべてのドキュメントはここからリンクされ、SSOT（Single Source of Truth）として管理されます。

---

## SSOT ルール

1. **同じ情報を2箇所以上に書かない** — 必ずリンクで参照する
2. **定義の場所を1つに決める** — データモデルは `data_model.md`、画面仕様は各featureの `ui.md`
3. **矛盾が生じたら定義元を正とする**
4. **削除・変更時はリンク元も確認する**

---

## ドキュメント構成

### プロジェクトレベル

| ファイル | 内容 |
|---|---|
| [project_overview.md](project_overview.md) | プロジェクトビジョン・KPI・ロードマップ |
| [scope.md](scope.md) | MVPスコープ（やること / やらないこと） |
| [data_model.md](data_model.md) | データモデル定義（SSOT） |
| [manual_setup.md](manual_setup.md) | 手動セットアップ手順（Firebase / AdMob / IAP 等） |

### アーキテクチャ

| ファイル | 内容 |
|---|---|
| [architecture/overview.md](architecture/overview.md) | 技術スタック・アーキテクチャ概要 |
| [architecture/state_management.md](architecture/state_management.md) | 状態管理設計・通信状態とゲーム状態の分離 |
| [architecture/naming.md](architecture/naming.md) | 命名規則 |
| [architecture/file_structure.md](architecture/file_structure.md) | ディレクトリ構成 |

### 機能仕様（Features）

各機能は `spec.md` / `ui.md` / `qa.md` / `tasks.md` の4ファイルで構成されます。

| 機能 | 概要 | Phase |
|---|---|---|
| [features/communication_settings/](features/communication_settings/) | 通信設定（MVPではローカルのみ） | MVP |
| [features/game_settings/](features/game_settings/) | ゲーム設定（テーマ・難易度・サイクル・人数） | MVP |
| [features/game_progress/](features/game_progress/) | ゲーム進行（ターン・出題・入力・結果・スコア） | MVP |
| [features/end_screen/](features/end_screen/) | 終了画面（最終順位・再戦） | MVP |
| [features/topic_history/](features/topic_history/) | お題履歴・重複回避 | 実装済み |
| [features/topic_feedback/](features/topic_feedback/) | お題フィードバック（ブロック / 面白い / エクスポート） | 実装済み |
| [features/play_modes/](features/play_modes/) | プレイモード（normal / hard） | 実装済み |
| [features/analytics/](features/analytics/) | 分析機能（相性・お題サプライズ） | 実装済み |
| [features/feature_flags/](features/feature_flags/) | 機能フラグ基盤（ビルド時 / 実行時） | 実装済み |
| [features/dev_mode/](features/dev_mode/) | 開発者モード（QuickStart 他、DEBUG限定） | 実装済み |
| [features/_template/](features/_template/) | 新機能追加用テンプレート | — |

### プロセス・ガイド

| ファイル | 内容 |
|---|---|
| [ai_driven_development_log.md](ai_driven_development_log.md) | AI駆動開発の編集履歴と新人エンジニア向けガイド |

### 将来拡張（Future）

> 優先順位と着手予定は [future/roadmap.md](future/roadmap.md) を参照

| ファイル | 内容 |
|---|---|
| [future/roadmap.md](future/roadmap.md) | **優先順位ロードマップ（依存関係 / 着手順）** |
| [future/multiplayer_design.md](future/multiplayer_design.md) | 複数台通信設計（ネット / Bluetooth） |
| [future/monetization.md](future/monetization.md) | 課金設計 |
| [future/remote_topics.md](future/remote_topics.md) | お題リモート配信（保留中） |

---

## 新機能を追加するとき

1. `features/_template/` をコピーして `features/{feature_name}/` を作成
2. `spec.md` にビジネスルールを記述
3. `ui.md` に画面レイアウト・表示項目・操作を記述
4. `qa.md` にテストケースを記述
5. `tasks.md` に実装タスクを記述
6. **このファイル（index.md）の機能一覧に追加する**

---

## AI連携ガイド

| やりたいこと | 渡すファイル |
|---|---|
| 全体把握 | `index.md` + `project_overview.md` + `scope.md` |
| データ設計 | `data_model.md` + 対象featureの `spec.md` |
| UI実装 | 対象featureの `ui.md` + `spec.md` |
| テスト作成 | 対象featureの `qa.md` + `spec.md` |
| アーキテクチャ相談 | `architecture/` 全体 |

---

## 初見の読み順

1. `project_overview.md` — プロジェクトの目的を理解
2. `scope.md` — MVP範囲を把握
3. `data_model.md` — データ構造を理解
4. `architecture/overview.md` — 技術構成を確認
5. 各featureの `spec.md` → `ui.md` の順で読む
