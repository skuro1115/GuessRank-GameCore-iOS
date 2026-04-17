import Foundation

struct Answer: Codable {
    let playerId: String
    let ranking: [String]
    var score: Int
}
