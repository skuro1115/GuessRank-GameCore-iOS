# 命名規則

## ファイル命名

| 種類 | パターン | 例 |
|---|---|---|
| Model | `{ModelName}.swift` | `Player.swift`, `GameSession.swift` |
| ViewModel | `{Feature}ViewModel.swift` | `GameProgressViewModel.swift` |
| View | `{Feature}View.swift` | `GameSettingsView.swift` |
| Service | `{ServiceName}Service.swift` | `ScoreService.swift` |
| Util | `{Purpose}Utils.swift` | `RankingUtils.swift` |

## クラス命名

| 種類 | パターン | 例 |
|---|---|---|
| Model | `PascalCase` | `Player`, `GameSession`, `Turn` |
| ViewModel | `{Feature}ViewModel` | `GameProgressViewModel` |
| View | `{Feature}View` | `GameSettingsView` |
| Component View | `{Purpose}{View種}` | `ScoreCard`, `PlayerRow` |
| Service | `{Service名}Service` | `ScoreService` |
| Enum | `PascalCase` | `Difficulty`, `SessionStatus` |

## プロパティ命名

| ルール | 例 |
|---|---|
| camelCase | `playerCount`, `currentTurnIndex` |
| bool は is / has 接頭辞 | `isCompleted`, `hasAnswered` |
| コレクションは複数形 | `players`, `turns`, `answers` |
| 数量は count / total 接頭辞 | `cycleCount`, `totalTurns` |
| ID は id 接尾辞 | `playerId`, `targetPlayerId` |

## ディレクトリ・機能命名

| 場面 | 規則 | 例 |
|---|---|---|
| ディレクトリ | snake_case | `game_progress/`, `end_screen/` |
| コード内 | PascalCase | `GameProgress`, `EndScreen` |
| ドキュメント | snake_case | `game_progress/spec.md` |
