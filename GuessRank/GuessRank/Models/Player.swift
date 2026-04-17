import Foundation

struct Player: Identifiable, Codable {
    let id: String
    var name: String
    var score: Int
    let order: Int

    init(id: String = UUID().uuidString, name: String, score: Int = 0, order: Int) {
        self.id = id
        self.name = name
        self.score = score
        self.order = order
    }
}
