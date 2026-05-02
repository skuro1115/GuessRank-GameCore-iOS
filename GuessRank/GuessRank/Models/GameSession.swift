import Foundation

enum SessionStatus: String, Codable {
    case setup
    case inProgress
    case completed
}

struct GameSession: Codable {
    let id: String
    let config: GameConfig
    var players: [Player]
    var currentTurnIndex: Int
    let totalTurns: Int
    var status: SessionStatus
    var turns: [Turn]

    init(config: GameConfig, players: [Player]) {
        self.id = UUID().uuidString
        self.config = config
        self.players = players
        self.currentTurnIndex = 0
        self.totalTurns = config.totalTurns
        self.status = .inProgress
        self.turns = []
    }

    var currentTargetPlayer: Player {
        let index = currentTurnIndex % players.count
        return players[index]
    }

    var guessingPlayers: [Player] {
        players.filter { $0.id != currentTargetPlayer.id }
    }

    var isLastTurn: Bool {
        currentTurnIndex >= totalTurns - 1
    }
}
