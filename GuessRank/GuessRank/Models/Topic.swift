import Foundation

struct Topic: Identifiable, Codable {
    let id: String
    let question: String
    let choices: [String]
    let genre: Genre
    let difficulty: Difficulty
    let playMode: PlayMode

    init(
        id: String,
        question: String,
        choices: [String],
        genre: Genre,
        difficulty: Difficulty,
        playMode: PlayMode = .normal
    ) {
        self.id = id
        self.question = question
        self.choices = choices
        self.genre = genre
        self.difficulty = difficulty
        self.playMode = playMode
    }

    private enum CodingKeys: String, CodingKey {
        case id, question, choices, genre, difficulty, playMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        question = try container.decode(String.self, forKey: .question)
        choices = try container.decode([String].self, forKey: .choices)
        genre = try container.decode(Genre.self, forKey: .genre)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        playMode = try container.decodeIfPresent(PlayMode.self, forKey: .playMode) ?? .normal
    }
}
