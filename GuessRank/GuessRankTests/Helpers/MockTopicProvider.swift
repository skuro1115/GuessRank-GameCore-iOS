import Foundation
@testable import GuessRankCore

struct MockTopicProvider: TopicProviding {
    let topics: [Topic]

    init(topics: [Topic]? = nil) {
        self.topics = topics ?? [
            Fixtures.topic(id: "mock_1", question: "Q1", choices: ["A", "B", "C"]),
            Fixtures.topic(id: "mock_2", question: "Q2", choices: ["X", "Y", "Z"]),
            Fixtures.topic(id: "mock_3", question: "Q3", choices: ["D", "E", "F"]),
            Fixtures.topic(id: "mock_4", question: "Q4", choices: ["G", "H", "I"]),
            Fixtures.topic(id: "mock_5", question: "Q5", choices: ["J", "K", "L"]),
            Fixtures.topic(id: "mock_6", question: "Q6", choices: ["M", "N", "O"]),
        ]
    }

    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic] {
        Array(topics.prefix(count))
    }
}
