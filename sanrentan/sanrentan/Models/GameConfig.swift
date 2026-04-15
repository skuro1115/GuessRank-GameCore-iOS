import Foundation

enum Genre: String, Codable, CaseIterable {
    case food
    case hobby
    case random

    var displayName: String {
        switch self {
        case .food: "食べ物"
        case .hobby: "趣味"
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
