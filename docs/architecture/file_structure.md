# ディレクトリ構成

## MVP構成

```
GuessRank/
├── docs/                          # ドキュメント（この中）
├── GuessRank/
│   ├── GuessRankApp.swift        # エントリポイント
│   │
│   ├── Models/                    # データモデル
│   │   ├── Player.swift
│   │   ├── GameConfig.swift
│   │   ├── GameSession.swift
│   │   ├── Turn.swift
│   │   └── Answer.swift
│   │
│   ├── ViewModels/                # ViewModel（状態管理）
│   │   ├── GameSetupViewModel.swift
│   │   └── GameProgressViewModel.swift
│   │
│   ├── Views/                     # 画面
│   │   ├── CommunicationSettingsView.swift
│   │   ├── GameSettingsView.swift
│   │   ├── PlayerSetupView.swift
│   │   ├── GameProgressView.swift
│   │   ├── PassDeviceView.swift
│   │   ├── AnswerInputView.swift
│   │   ├── TurnResultView.swift
│   │   └── EndView.swift
│   │
│   ├── Services/                  # ビジネスロジック
│   │   └── ScoreService.swift
│   │
│   └── Utils/                     # ユーティリティ
│       └── RankingUtils.swift
│
├── GuessRankTests/               # テスト
│   ├── Models/
│   ├── ViewModels/
│   └── Services/
│
└── GuessRank.xcodeproj
```

## 拡張ルール

- ファイル数が **15以上** になったら Feature-First 構成に移行を検討

### Feature-First 構成（将来）

```
GuessRank/
├── Features/
│   ├── GameSetup/
│   │   ├── Models/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── GameProgress/
│   │   ├── Models/
│   │   ├── Views/
│   │   └── ViewModels/
│   └── ...
├── Shared/
│   ├── Models/
│   ├── Services/
│   └── Utils/
└── GuessRankApp.swift
```

## 画面フロー

```
CommunicationSettingsView
        ↓
GameSettingsView
        ↓
PlayerSetupView
        ↓
GameProgressView ←──────────────┐
        ↓                       │
   PassDeviceView               │
        ↓                       │
   AnswerInputView              │
        ↓                       │
   TurnResultView ──────────────┘ (次ターンへ)
        ↓ (最終ターン)
   EndView
        ↓ (再戦)
   GameSettingsView
```
