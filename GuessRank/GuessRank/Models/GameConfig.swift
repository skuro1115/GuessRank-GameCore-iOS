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

    var totalTurns: Int { cycleCount * playerCount }
    var estimatedSeconds: Int { totalTurns * 30 }
}
