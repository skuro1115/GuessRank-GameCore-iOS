import XCTest
@testable import GuessRankCore

final class GameSessionTests: XCTestCase {
    func test_初期ステータスはinProgress() {
        let session = Fixtures.session(playerNames: ["A", "B", "C"])
        XCTAssertEqual(session.status, .inProgress)
    }

    func test_初期currentTurnIndexは0() {
        let session = Fixtures.session()
        XCTAssertEqual(session.currentTurnIndex, 0)
    }

    func test_totalTurnsはconfigから導出() {
        let config = Fixtures.config(cycleCount: 2, playerCount: 3)
        let session = GameSession(config: config, players: Fixtures.players(["A", "B", "C"]))
        XCTAssertEqual(session.totalTurns, 6)
    }

    func test_currentQuestionerは0番目プレイヤー() {
        let session = Fixtures.session(playerNames: ["A", "B", "C"])
        XCTAssertEqual(session.currentQuestioner.name, "A")
    }

    func test_currentQuestionerは順番にローテーション() {
        var session = Fixtures.session(playerNames: ["A", "B", "C"])

        // Turn 0: A
        XCTAssertEqual(session.currentQuestioner.name, "A")

        // Turn 1: B
        session.currentTurnIndex = 1
        XCTAssertEqual(session.currentQuestioner.name, "B")

        // Turn 2: C
        session.currentTurnIndex = 2
        XCTAssertEqual(session.currentQuestioner.name, "C")

        // Turn 3: A (2巡目の最初)
        session.currentTurnIndex = 3
        XCTAssertEqual(session.currentQuestioner.name, "A")
    }

    func test_respondentsは出題者を除く全員() {
        let session = Fixtures.session(playerNames: ["A", "B", "C"])
        let respondentNames = session.respondents.map { $0.name }
        XCTAssertEqual(respondentNames, ["B", "C"])
    }

    func test_respondentsはローテーションで正しく変わる() {
        var session = Fixtures.session(playerNames: ["A", "B", "C"])
        session.currentTurnIndex = 1
        let respondentNames = session.respondents.map { $0.name }
        XCTAssertEqual(respondentNames, ["A", "C"])
    }

    func test_isLastTurnは最終ターンインデックスでtrue() {
        let config = Fixtures.config(cycleCount: 1, playerCount: 3) // totalTurns = 3
        var session = GameSession(config: config, players: Fixtures.players(["A", "B", "C"]))

        session.currentTurnIndex = 0
        XCTAssertFalse(session.isLastTurn)

        session.currentTurnIndex = 1
        XCTAssertFalse(session.isLastTurn)

        session.currentTurnIndex = 2
        XCTAssertTrue(session.isLastTurn, "最終ターン(index=2, totalTurns=3)はtrue")
    }

    func test_Codable準拠() throws {
        let session = Fixtures.session(playerNames: ["A", "B"])
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(GameSession.self, from: data)

        XCTAssertEqual(decoded.id, session.id)
        XCTAssertEqual(decoded.players.count, 2)
        XCTAssertEqual(decoded.status, .inProgress)
    }
}
