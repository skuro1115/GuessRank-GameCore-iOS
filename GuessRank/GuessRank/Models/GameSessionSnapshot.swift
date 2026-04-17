import Foundation

struct GameSessionSnapshot: Codable {
    let id: String
    let config: GameConfig
    let players: [Player]
    let turns: [Turn]
    let totalTurns: Int

    var sortedResults: [Player] {
        players.sorted { $0.score > $1.score }
    }

    var winner: Player? { sortedResults.first }

    func perfectMatchCount(for playerId: String) -> Int {
        turns.flatMap { $0.answers }
            .filter { $0.playerId == playerId && $0.score == 100 }
            .count
    }

    func bestTurn(for playerId: String) -> (turnIndex: Int, score: Int)? {
        let playerAnswers = turns.compactMap { turn -> (Int, Int)? in
            guard let answer = turn.answers.first(where: { $0.playerId == playerId }) else { return nil }
            return (turn.turnIndex, answer.score)
        }
        return playerAnswers.max(by: { $0.1 < $1.1 })
    }

    func totalPerfectMatches() -> Int {
        turns.flatMap { $0.answers }.filter { $0.score == 100 }.count
    }

    init(from session: GameSession) {
        self.id = session.id
        self.config = session.config
        self.players = session.players
        self.turns = session.turns
        self.totalTurns = session.totalTurns
    }
}
