import Foundation
@testable import GuessRankCore

enum Fixtures {
    static func player(id: String = UUID().uuidString, name: String, order: Int = 0) -> Player {
        Player(id: id, name: name, order: order)
    }

    static func players(_ names: [String]) -> [Player] {
        names.enumerated().map { idx, name in
            Player(id: "p\(idx)", name: name, order: idx)
        }
    }

    static func config(
        genre: Genre = .random,
        difficulty: Difficulty = .normal,
        cycleCount: Int = 1,
        playerCount: Int = 3
    ) -> GameConfig {
        GameConfig(
            genre: genre,
            difficulty: difficulty,
            cycleCount: cycleCount,
            playerCount: playerCount
        )
    }

    static func topic(
        id: String = "topic_1",
        question: String = "好きな食べ物は？",
        choices: [String] = ["寿司", "ラーメン", "カレー"],
        genre: Genre = .food,
        difficulty: Difficulty = .normal
    ) -> Topic {
        Topic(
            id: id,
            question: question,
            choices: choices,
            genre: genre,
            difficulty: difficulty
        )
    }

    static func session(
        config: GameConfig? = nil,
        playerNames: [String] = ["A", "B", "C"]
    ) -> GameSession {
        let cfg = config ?? self.config(playerCount: playerNames.count)
        let players = players(playerNames)
        return GameSession(config: cfg, players: players)
    }
}
