import Foundation
@testable import GuessRankCore

struct MockTopicProvider: TopicProviding {
    let topics: [Topic]

    init(topics: [Topic]? = nil) {
        self.topics = topics ?? (1...20).map { i in
            Fixtures.topic(id: "mock_\(i)", question: "Q\(i)", choices: ["A\(i)", "B\(i)", "C\(i)"])
        }
    }

    func pickTopics(
        count: Int,
        genre: Genre,
        difficulty: Difficulty,
        playMode: PlayMode,
        excluding: Set<String>
    ) -> [Topic] {
        let modeFiltered = topics.filter { $0.playMode == playMode }
        let pool: [Topic]
        if modeFiltered.isEmpty {
            // Mock fallback so legacy tests that don't set up hard topics still work.
            pool = topics
        } else {
            pool = modeFiltered
        }
        let filtered = pool.filter { !excluding.contains($0.id) }
        let final = filtered.isEmpty ? pool : filtered
        return Array(final.shuffled().prefix(count))
    }
}
