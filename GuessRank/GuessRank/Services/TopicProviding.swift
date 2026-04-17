import Foundation

protocol TopicProviding {
    func pickTopics(count: Int, genre: Genre, difficulty: Difficulty) -> [Topic]
}
