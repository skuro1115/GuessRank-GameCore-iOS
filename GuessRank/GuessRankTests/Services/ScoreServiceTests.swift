import XCTest
@testable import GuessRankCore

final class ScoreServiceTests: XCTestCase {
    // MARK: - calculateScore

    func test_完全一致は100点() {
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["A", "B", "C"]
        )
        XCTAssertEqual(score, 100)
    }

    func test_2つ一致は50点() {
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["A", "B", "X"]
        )
        XCTAssertEqual(score, 50)
    }

    func test_1つ一致は20点() {
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["A", "X", "Y"]
        )
        XCTAssertEqual(score, 20)
    }

    func test_不一致は0点() {
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["X", "Y", "Z"]
        )
        XCTAssertEqual(score, 0)
    }

    func test_順位を入れ替えた完全外れは1つも一致しない() {
        // 同じ要素だが順位が全てずれているケース
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["B", "C", "A"]
        )
        XCTAssertEqual(score, 0)
    }

    func test_長さ不一致は0点() {
        let score = ScoreService.calculateScore(
            correct: ["A", "B", "C"],
            answer: ["A", "B"]
        )
        XCTAssertEqual(score, 0)
    }

    func test_空配列同士は0点() {
        let score = ScoreService.calculateScore(correct: [], answer: [])
        XCTAssertEqual(score, 0)
    }

    // MARK: - matchDescription

    func test_matchDescription_100点は完全一致() {
        XCTAssertEqual(ScoreService.matchDescription(100), "完全一致!")
    }

    func test_matchDescription_50点は2つ一致() {
        XCTAssertEqual(ScoreService.matchDescription(50), "2つ一致")
    }

    func test_matchDescription_20点は1つ一致() {
        XCTAssertEqual(ScoreService.matchDescription(20), "1つ一致")
    }

    func test_matchDescription_0点は不一致() {
        XCTAssertEqual(ScoreService.matchDescription(0), "不一致")
    }
}
