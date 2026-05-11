# GuessRank ドキュメント一覧

このファイルはプロジェクトドキュメントの **中央マップ** です。
すべてのドキュメントはここからリンクされ、SSOT（Single Source of Truth）として管理されます。

---

## SSOT ルール

1. **同じ情報を2箇所以上に書かない** — 必ずリンクで参照する
2. **定義の場所を1つに決める** — データは `data_model.md`、画面仕様は各 feature の `ui.md`、優先順位は `future/roadmap.md`
3. **矛盾が生じたら定義元を正とする**
4. **削除・変更時はリンク元も確認する**

---

## ディレクトリ構成

```
docs/
├── index.md              この中央マップ
├── data_model.md         データモデル定義（SSOT）
├── manual_setup.md       手動セットアップ手順
├── support.html          公開サポートページ（プライバシーポリシー）
│
├── product/              プロダクトコンテキスト（WHAT）
├── architecture/         技術アーキテクチャ（HOW）
├── features/             各機能の実装仕様
├── future/               計画中・保留中の機能
└── meta/                 プロセス記録・開発ログ
```

---

## トップレベル（クロスカット）

| ファイル | 内容 |
|---|---|
| [data_model.md](data_model.md) | データモデル定義（SSOT） |
| [manual_setup.md](manual_setup.md) | 手動セットアップ手順（Firebase / AdMob / IAP 等） |
| [support.html](support.html) | 公開サポートページ・プライバシーポリシー |

## product/ — プロダクトコンテキスト

ユーザーと体験に関する SSOT。「**何を作っているか**」「**誰のためか**」。

| ファイル | 内容 |
|---|---|
| [product/overview.md](product/overview.md) | プロジェクト概要・コンセプト・KPI |
| [product/scope.md](product/scope.md) | MVP スコープ（やること / やらないこと） |
| [product/game_rules.md](product/game_rules.md) | ゲームルール全体 |
| [product/personas.md](product/personas.md) | ペルソナ定義 |
| [product/brand.md](product/brand.md) | ブランドカラー・フォント・キャッチコピー |

## architecture/ — 技術アーキテクチャ

「**どう作るか**」の技術判断。

| ファイル | 内容 |
|---|---|
| [architecture/overview.md](architecture/overview.md) | 技術スタック・依存方向・設計原則 |
| [architecture/state_management.md](architecture/state_management.md) | 状態管理設計・通信状態とゲーム状態の分離 |
| [architecture/naming.md](architecture/naming.md) | 命名規則 |
| [architecture/file_structure.md](architecture/file_structure.md) | ディレクトリ構成・画面フロー |

## features/ — 機能仕様

各機能は最低 `spec.md` を持つ。`ui.md` / `qa.md` は UI または検証が必要な機能のみ。`tasks.md` は実装中のみ任意。

| 機能 | 状態 | 主なドキュメント |
|---|---|---|
| [communication_settings/](features/communication_settings/) | MVP | spec, ui, qa, tasks |
| [game_settings/](features/game_settings/) | MVP | spec, ui, qa, tasks |
| [game_progress/](features/game_progress/) | MVP | spec, ui, qa, tasks |
| [end_screen/](features/end_screen/) | MVP | spec, ui, qa, tasks |
| [topic_history/](features/topic_history/) | 実装済み | spec, ui, qa |
| [topic_feedback/](features/topic_feedback/) | 実装済み | spec, ui, qa |
| [play_modes/](features/play_modes/) | 実装済み | spec, ui, qa |
| [analytics/](features/analytics/) | 実装済み | spec |
| [feature_flags/](features/feature_flags/) | 実装済み | spec |
| [dev_mode/](features/dev_mode/) | 実装済み | spec |
| [_template/](features/_template/) | テンプレ | spec, ui, qa, tasks |

> spec のみの機能は UI が他機能内に組み込み（dev_mode は game_settings 内、feature_flags は環境注入）または UI 要素を持たない（analytics は単体画面だが内容は単純）ため。

## future/ — 計画中・保留

| ファイル | 内容 |
|---|---|
| [future/roadmap.md](future/roadmap.md) | **優先順位ロードマップ（SSOT・依存関係・着手順）** |
| [future/multiplayer_design.md](future/multiplayer_design.md) | 複数台通信設計（ネット / Bluetooth） |
| [future/monetization.md](future/monetization.md) | 課金設計 |
| [future/remote_topics.md](future/remote_topics.md) | お題リモート配信（保留中） |

## meta/ — プロセス記録

| ファイル | 内容 |
|---|---|
| [meta/development_log.md](meta/development_log.md) | AI 駆動開発の編集履歴と新人エンジニア向けガイド |

---

## 新機能を追加するとき

1. `features/_template/` をコピーして `features/{feature_name}/` を作成
2. 最低 `spec.md` を埋める。UI を伴うなら `ui.md`、検証ケースが多いなら `qa.md` も
3. **この index.md の features 表に追加する**
4. 関連する `future/roadmap.md` のエントリを「実装済み」へ移動

## AI 連携ガイド

| やりたいこと | 渡すファイル |
|---|---|
| 全体把握 | `index.md` + `product/overview.md` + `product/scope.md` |
| データ設計 | `data_model.md` + 対象 feature の `spec.md` |
| UI 実装 | 対象 feature の `ui.md` + `spec.md` |
| テスト作成 | 対象 feature の `qa.md` + `spec.md` |
| アーキテクチャ相談 | `architecture/` 全体 |
| 優先順位判断 | `future/roadmap.md` + `manual_setup.md` |

## 初見の読み順

1. `product/overview.md` — プロジェクトの目的を理解
2. `product/scope.md` — MVP 範囲を把握
3. `data_model.md` — データ構造を理解
4. `architecture/overview.md` — 技術構成を確認
5. 各 feature の `spec.md` → `ui.md` の順で読む
