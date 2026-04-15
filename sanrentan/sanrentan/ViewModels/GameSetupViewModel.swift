import Foundation
import Observation

@Observable
class GameSetupViewModel {
    var genre: Genre = .random
    var difficulty: Difficulty = .normal
    var cycleCount: Int = 1
    var playerCount: Int = 3
    var playerNames: [String] = ["", "", ""]

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
        playerNames.count == playerCount
            && playerNames.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            && Set(playerNames.map { $0.trimmingCharacters(in: .whitespaces) }).count == playerCount
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

    func buildSession() -> GameSession {
        let config = GameConfig(
            genre: genre,
            difficulty: difficulty,
            cycleCount: cycleCount,
            playerCount: playerCount
        )
        let players = playerNames.enumerated().map { index, name in
            Player(name: name.trimmingCharacters(in: .whitespaces), order: index)
        }
        return GameSession(config: config, players: players)
    }

    /// Reset config for replay, keeping player names
    func resetForReplay() {
        // playerNames and playerCount are preserved
        // config settings are preserved so players can adjust if needed
    }
}
