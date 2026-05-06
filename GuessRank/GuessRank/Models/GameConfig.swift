import Foundation

enum Genre: String, Codable, CaseIterable {
    case food
    case hobby
    case school
    case love
    case personality
    case hypothetical
    case random

    var displayName: String {
        switch self {
        case .food: "食べ物"
        case .hobby: "趣味"
        case .school: "学生あるある"
        case .love: "恋愛"
        case .personality: "性格・価値観"
        case .hypothetical: "もしも"
        case .random: "ランダム"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy
    case normal
    case hard

    var displayName: String {
        switch self {
        case .easy: "かんたん"
        case .normal: "ふつう"
        case .hard: "むずかしい"
        }
    }
}

struct GameConfig: Codable {
    var genre: Genre
    var difficulty: Difficulty
    var cycleCount: Int
    var playerCount: Int
    var playMode: PlayMode

    var totalTurns: Int { cycleCount * playerCount }
    var estimatedSeconds: Int { totalTurns * 30 }

    init(
        genre: Genre,
        difficulty: Difficulty,
        cycleCount: Int,
        playerCount: Int,
        playMode: PlayMode = .normal
    ) {
        self.genre = genre
        self.difficulty = difficulty
        self.cycleCount = cycleCount
        self.playerCount = playerCount
        self.playMode = playMode
    }

    private enum CodingKeys: String, CodingKey {
        case genre, difficulty, cycleCount, playerCount, playMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        genre = try container.decode(Genre.self, forKey: .genre)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        cycleCount = try container.decode(Int.self, forKey: .cycleCount)
        playerCount = try container.decode(Int.self, forKey: .playerCount)
        playMode = try container.decodeIfPresent(PlayMode.self, forKey: .playMode) ?? .normal
    }
}
