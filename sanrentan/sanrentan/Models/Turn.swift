import Foundation

struct Turn: Identifiable, Codable {
    let id: String
    let turnIndex: Int
    let questionerId: String
    let topic: Topic
    var correctRanking: [String]
    var answers: [Answer]
    var isCompleted: Bool

    init(
        id: String = UUID().uuidString,
        turnIndex: Int,
        questionerId: String,
        topic: Topic,
        correctRanking: [String] = [],
        answers: [Answer] = [],
        isCompleted: Bool = false
    ) {
        self.id = id
        self.turnIndex = turnIndex
        self.questionerId = questionerId
        self.topic = topic
        self.correctRanking = correctRanking
        self.answers = answers
        self.isCompleted = isCompleted
    }
}
