# GuessRank

お題に対する順位予想パーティーゲーム。出題者の好みの1位・2位・3位を当てよう。

## 開発環境

| 項目 | バージョン |
|---|---|
| Xcode | 26.2+ |
| Swift | 5.0 |
| iOS | 26.2+ |
| macOS（テスト実行） | 14.0+ |

## ビルド

```bash
# Xcode で開いてビルド
open GuessRank/GuessRank.xcodeproj
# Cmd+R でシミュレータ起動

# CLI からビルド
cd GuessRank
xcodebuild -project GuessRank.xcodeproj -scheme GuessRank \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## テスト

Models / Services / ViewModels の純粋ロジックを Swift Package Manager でテストします。

```bash
cd GuessRank
swift test
```

> Views（SwiftUI 依存）はテスト対象外です。

## ディレクトリ構成

```
GuessRank/
├── README.md
├── CLAUDE.md                       # AI 連携時のプロジェクトルール
├── docs/                           # ドキュメント（SSOT）
│   ├── index.md                    #   中央マップ
│   ├── data_model.md               #   データモデル定義（SSOT）
│   ├── manual_setup.md             #   手動セットアップ手順
│   ├── support.html                #   公開サポート・プライバシーポリシー
│   ├── product/                    #   プロダクトコンテキスト（overview / scope / game_rules / personas / brand）
│   ├── architecture/               #   技術アーキテクチャ
│   ├── features/                   #   各機能の spec / ui / qa / tasks
│   ├── future/                     #   計画中・保留中の機能
│   └── meta/                       #   開発プロセスログ
│
└── GuessRank/                      # iOS アプリ（Xcode プロジェクト）
    ├── GuessRank.xcodeproj
    ├── Package.swift               #   テスト用 SPM マニフェスト
    ├── GuessRank/                   #   アプリソース
    │   ├── Models/                  #     データモデル（依存なし）
    │   ├── Services/                #     ビジネスロジック（純粋関数）
    │   ├── ViewModels/              #     状態管理（@Observable）
    │   └── Views/                   #     SwiftUI 画面
    └── GuessRankTests/             #   ユニットテスト（SPM）
        ├── Helpers/
        ├── Models/
        ├── Services/
        └── ViewModels/
```

## アーキテクチャ

MVVM + 責務分離。詳細は [docs/architecture/](docs/architecture/) を参照。

```
View → ViewModel → Service
                 → Model
```

- **Model**: 純粋データ構造（Codable、依存なし）
- **Service**: ビジネスロジック（純粋関数、テスト容易）
- **ViewModel**: UI 状態管理（@Observable）
- **View**: SwiftUI（ViewModel のみ参照）

## ドキュメント

入口は [docs/index.md](docs/index.md)（全文書の中央マップ）。

| ドキュメント | 内容 |
|---|---|
| [docs/index.md](docs/index.md) | ドキュメント中央マップ・SSOT ルール |
| [docs/product/game_rules.md](docs/product/game_rules.md) | ゲームルール全体 |
| [docs/data_model.md](docs/data_model.md) | データモデル定義（SSOT） |
| [docs/features/game_progress/spec.md](docs/features/game_progress/spec.md) | ゲーム進行の仕様・画面名 |
| [docs/product/personas.md](docs/product/personas.md) | ペルソナ定義（ユウキ / サキ / タケシ） |
| [docs/future/roadmap.md](docs/future/roadmap.md) | 優先順位ロードマップ |
