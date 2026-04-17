import Foundation

struct Topic: Identifiable, Codable {
    let id: String
    let question: String
    let choices: [String]
    let genre: Genre
    let difficulty: Difficulty
}
