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
}
