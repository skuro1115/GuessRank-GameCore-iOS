import Foundation
import Observation

@Observable
class GameSetupViewModel {
    static let maxNameLength = 12

    var genre: Genre = .random
    var difficulty: Difficulty = .normal
    var cycleCount: Int = 1
    var playerCount: Int = 3
    var playerNames: [String] = ["", "", ""]
    var playMode: PlayMode = .normal

    var totalTurns: Int { cycleCount * playerCount }
    var estimatedSeconds: Int { totalTurns * 30 }

    var estimatedTimeText: String {
        let minutes = estimatedSeconds / 60
        let seconds = estimatedSeconds % 60
        if seconds > 0 {
            return "約\(minutes)分\(seconds)秒"
        }
        return "約\(minutes)分"
    }

    var canStartGame: Bool {
        let trimmed = playerNames.map { sanitize($0) }
        return trimmed.count == playerCount
            && trimmed.allSatisfy { !$0.isEmpty }
            && Set(trimmed).count == playerCount
    }

    func updatePlayerCount(_ count: Int) {
        playerCount = count
        while playerNames.count < count {
            playerNames.append("")
        }
        while playerNames.count > count {
            playerNames.removeLast()
        }
    }

    func sanitize(_ name: String) -> String {
        let cleaned = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        return String(cleaned.prefix(Self.maxNameLength))
    }

    func buildSession() -> GameSession {
        let config = GameConfig(
            genre: genre,
            difficulty: difficulty,
            cycleCount: cycleCount,
            playerCount: playerCount,
            playMode: playMode
        )
        let players = playerNames.enumerated().map { index, name in
            Player(name: sanitize(name), order: index)
        }
        return GameSession(config: config, players: players)
    }

    func resetForReplay() {
        // playerNames, playerCount, config settings are preserved
    }

    /// 開発者モードのクイックスタート用プリセット。
    /// ダミープレイヤー名を流し込み、デフォルト設定で即時にゲームを開始できる状態にする。
    /// `QuickStartPreset` を渡すことで人数・モードを切り替え可能。
    func applyQuickStartPreset(_ preset: QuickStartPreset = .standard4P) {
        let count = preset.playerCount
        playerCount = count
        playerNames = Array(QuickStartPreset.dummyNames.prefix(count))
        cycleCount = preset.cycleCount
        genre = preset.genre
        difficulty = preset.difficulty
        playMode = preset.playMode
    }
}

/// クイックスタート用のプリセット定義。
struct QuickStartPreset: Identifiable, Sendable {
    let id: String
    let displayName: String
    let playerCount: Int
    let cycleCount: Int
    let genre: Genre
    let difficulty: Difficulty
    let playMode: PlayMode

    static let dummyNames = ["A", "B", "C", "D", "E", "F"]

    static let standard4P = QuickStartPreset(
        id: "standard_4p",
        displayName: "標準 4人",
        playerCount: 4,
        cycleCount: 1,
        genre: .random,
        difficulty: .normal,
        playMode: .normal
    )

    static let hard4P = QuickStartPreset(
        id: "hard_4p",
        displayName: "ハード 4人",
        playerCount: 4,
        cycleCount: 1,
        genre: .random,
        difficulty: .normal,
        playMode: .hard
    )

    static let solo2P = QuickStartPreset(
        id: "solo_2p",
        displayName: "ソロ 2人",
        playerCount: 2,
        cycleCount: 1,
        genre: .random,
        difficulty: .normal,
        playMode: .normal
    )

    static let allPresets: [QuickStartPreset] = [.standard4P, .hard4P, .solo2P]
}

