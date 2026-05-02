import Foundation
@testable import GuessRankCore

struct MockTopicProvider: TopicProviding {
    let topics: [Topic]

    init(topics: [Topic]? = nil) {
        self.topics = topics ?? (1...20).map { i in
            Fixtures.topic(id: "mock_\(i)", question: "Q\(i)", choices: ["A\(i)", "B\(i)", "C\(i)"])
        }
    }

    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic] {
        Array(topics.shuffled().prefix(count))
    }
}
