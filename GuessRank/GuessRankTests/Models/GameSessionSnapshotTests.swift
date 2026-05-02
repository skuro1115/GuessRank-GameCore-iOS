import XCTest
@testable import GuessRankCore

final class GameSessionSnapshotTests: XCTestCase {
    func test_sortedResultsはスコア降順() {
        var session = Fixtures.session(playerNames: ["A", "B", "C"])
        session.players[0].score = 50
        session.players[1].score = 100
        session.players[2].score = 20
        let snapshot = GameSessionSnapshot(from: session)

        let sorted = snapshot.sortedResults
        XCTAssertEqual(sorted.map { $0.name }, ["B", "A", "C"])
    }

    func test_winnerは最高スコアのプレイヤー() {
        var session = Fixtures.session(playerNames: ["A", "B"])
        session.players[0].score = 30
        session.players[1].score = 100
        let snapshot = GameSessionSnapshot(from: session)

        XCTAssertEqual(snapshot.winner?.name, "B")
    }

    func test_perfectMatchCountは完全一致の回数() {
        let topic = Fixtures.topic()
        var session = Fixtures.session(playerNames: ["A", "B"])
        let turn1 = Turn(
            turnIndex: 0, targetPlayerId: "p0", topic: topic,
            correctRanking: ["寿司", "ラーメン", "カレー"],
            answers: [
                Answer(playerId: "p1", ranking: ["寿司", "ラーメン", "カレー"], score: 100),
            ],
            isCompleted: true
        )
        let turn2 = Turn(
            turnIndex: 1, targetPlayerId: "p1", topic: topic,
            correctRanking: ["寿司", "ラーメン", "カレー"],
            answers: [
                Answer(playerId: "p0", ranking: ["寿司", "ラーメン", "カレー"], score: 100),
            ],
            isCompleted: true
        )
        session.turns = [turn1, turn2]
        let snapshot = GameSessionSnapshot(from: session)

        XCTAssertEqual(snapshot.perfectMatchCount(for: "p1"), 1)
        XCTAssertEqual(snapshot.perfectMatchCount(for: "p0"), 1)
    }

    func test_bestTurnは最高スコアのターン() {
        let topic = Fixtures.topic()
        var session = Fixtures.session(playerNames: ["A", "B"])
        let turn0 = Turn(
            turnIndex: 0, targetPlayerId: "p0", topic: topic,
            correctRanking: topic.choices,
            answers: [Answer(playerId: "p1", ranking: topic.choices, score: 50)],
            isCompleted: true
        )
        let turn1 = Turn(
            turnIndex: 1, targetPlayerId: "p1", topic: topic,
            correctRanking: topic.choices,
            answers: [Answer(playerId: "p0", ranking: topic.choices, score: 100)],
            isCompleted: true
        )
        session.turns = [turn0, turn1]
        let snapshot = GameSessionSnapshot(from: session)

        let best = snapshot.bestTurn(for: "p1")
        XCTAssertEqual(best?.turnIndex, 0)
        XCTAssertEqual(best?.score, 50)

        let bestA = snapshot.bestTurn(for: "p0")
        XCTAssertEqual(bestA?.score, 100)
    }

    func test_totalPerfectMatchesは全プレイヤーの完全一致合計() {
        let topic = Fixtures.topic()
        var session = Fixtures.session(playerNames: ["A", "B", "C"])
        let turn = Turn(
            turnIndex: 0, targetPlayerId: "p0", topic: topic,
            correctRanking: topic.choices,
            answers: [
                Answer(playerId: "p1", ranking: topic.choices, score: 100),
                Answer(playerId: "p2", ranking: ["X", "Y", "Z"], score: 0),
            ],
            isCompleted: true
        )
        session.turns = [turn]
        let snapshot = GameSessionSnapshot(from: session)

        XCTAssertEqual(snapshot.totalPerfectMatches(), 1)
    }

    func test_Codable準拠() throws {
        let session = Fixtures.session(playerNames: ["A", "B"])
        let snapshot = GameSessionSnapshot(from: session)
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(GameSessionSnapshot.self, from: data)

        XCTAssertEqual(decoded.id, snapshot.id)
        XCTAssertEqual(decoded.players.count, 2)
        XCTAssertEqual(decoded.totalTurns, snapshot.totalTurns)
    }
}
