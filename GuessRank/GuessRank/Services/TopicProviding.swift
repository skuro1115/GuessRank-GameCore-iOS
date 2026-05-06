import Foundation

protocol TopicProviding {
    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty, excluding: Set<String>) -> [Topic]
}

extension TopicProviding {
    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic] {
        pickTopics(count: count, genre: genre, difficulty: difficulty, excluding: [])
    }
}
