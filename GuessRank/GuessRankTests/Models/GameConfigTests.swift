import XCTest
@testable import GuessRankCore

final class GameConfigTests: XCTestCase {
    func test_totalTurnsはcycleCount掛けるplayerCount() {
        let config = GameConfig(genre: .random, difficulty: .normal, cycleCount: 2, playerCount: 4)
        XCTAssertEqual(config.totalTurns, 8)
    }

    func test_totalTurnsは1サイクル3人なら3() {
        let config = GameConfig(genre: .random, difficulty: .normal, cycleCount: 1, playerCount: 3)
        XCTAssertEqual(config.totalTurns, 3)
    }

    func test_estimatedSecondsはtotalTurns掛ける30() {
        let config = GameConfig(genre: .random, difficulty: .normal, cycleCount: 2, playerCount: 3)
        // totalTurns = 6, estimatedSeconds = 6 * 30 = 180
        XCTAssertEqual(config.estimatedSeconds, 180)
    }

    func test_minimum構成2人1サイクル() {
        let config = GameConfig(genre: .random, difficulty: .normal, cycleCount: 1, playerCount: 2)
        XCTAssertEqual(config.totalTurns, 2)
        XCTAssertEqual(config.estimatedSeconds, 60)
    }

    func test_Codable準拠() throws {
        let config = GameConfig(genre: .food, difficulty: .hard, cycleCount: 3, playerCount: 5)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(GameConfig.self, from: data)

        XCTAssertEqual(decoded.genre, .food)
        XCTAssertEqual(decoded.difficulty, .hard)
        XCTAssertEqual(decoded.cycleCount, 3)
        XCTAssertEqual(decoded.playerCount, 5)
    }
}
