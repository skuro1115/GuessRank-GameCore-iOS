import XCTest
@testable import GuessRankCore

final class AnalyticsServiceTests: XCTestCase {
    // Helper: 3人で2ターンのスナップショットを作成
    private func makeSnapshot() -> GameSessionSnapshot {
        let topic = Fixtures.topic()
        var session = Fixtures.session(playerNames: ["A", "B", "C"])

        // Turn 0: A が出題、B=100点(完全一致)、C=20点
        let turn0 = Turn(
            turnIndex: 0, questionerId: "p0", topic: topic,
            correctRanking: topic.choices,
            answers: [
                Answer(playerId: "p1", ranking: topic.choices, score: 100),
                Answer(playerId: "p2", ranking: [topic.choices[2], topic.choices[0], topic.choices[1]], score: 20),
            ],
            isCompleted: true
        )

        // Turn 1: B が出題、A=50点、C=0点
        let turn1 = Turn(
            turnIndex: 1, questionerId: "p1", topic: topic,
            correctRanking: topic.choices,
            answers: [
                Answer(playerId: "p0", ranking: topic.choices, score: 50),
                Answer(playerId: "p2", ranking: [topic.choices[1], topic.choices[2], topic.choices[0]], score: 0),
            ],
            isCompleted: true
        )

        session.turns = [turn0, turn1]
        return GameSessionSnapshot(from: session)
    }

    // MARK: - Pairwise Scores

    func test_pairwiseScoresはペア別平均スコアを返す() {
        let snapshot = makeSnapshot()
        let pairs = AnalyticsService.pairwiseScores(snapshot: snapshot)

        // B→A (B が A の出題時に 100 点)
        let bToA = pairs.first { $0.fromPlayer.id == "p1" && $0.toPlayer.id == "p0" }
        XCTAssertEqual(bToA?.averageScore, 100)

        // A→B (A が B の出題時に 50 点)
        let aToB = pairs.first { $0.fromPlayer.id == "p0" && $0.toPlayer.id == "p1" }
        XCTAssertEqual(aToB?.averageScore, 50)

        // C→A (C が A の出題時に 20 点)
        let cToA = pairs.first { $0.fromPlayer.id == "p2" && $0.toPlayer.id == "p0" }
        XCTAssertEqual(cToA?.averageScore, 20)

        // C→B (C が B の出題時に 0 点)
        let cToB = pairs.first { $0.fromPlayer.id == "p2" && $0.toPlayer.id == "p1" }
        XCTAssertEqual(cToB?.averageScore, 0)
    }

    // MARK: - Best Match Pair

    func test_bestMatchPairは双方向平均が最大のペアを返す() {
        let snapshot = makeSnapshot()
        let best = AnalyticsService.bestMatchPair(snapshot: snapshot)

        XCTAssertNotNil(best)
        // A-B ペア: (B→A=100 + A→B=50) / 2 = 75
        // A-C ペア: (C→A=20 + A→C=なし) → C has no turn as questioner in this data... wait
        // Actually A-B: mutual = (100 + 50) / 2 = 75
        // A-C: (20 + 0) / 2 = 10 (C→A=20, A hasn't answered C's turn)
        // B-C: (0 + 0) / 2 = 0

        // Wait, let me reconsider. In this test data:
        // Turn 0: A is questioner. B answers 100, C answers 20
        // Turn 1: B is questioner. A answers 50, C answers 0
        // C never has a turn as questioner, so no one answers C's turn
        // So: A→B = 50 (A answered B's turn 50), B→A = 100 (B answered A's turn 100)
        // A→C doesn't exist (C never asked), C→A = 20
        // B→C doesn't exist, C→B = 0

        // Best match: A-B with (50 + 100) / 2 = 75
        let ids = Set([best!.playerA.id, best!.playerB.id])
        XCTAssertEqual(ids, Set(["p0", "p1"]))
        XCTAssertEqual(best!.mutualScore, 75)
    }

    func test_bestMatchPairは2人未満ならnil() {
        var session = Fixtures.session(playerNames: ["A"])
        session.turns = []
        let snapshot = GameSessionSnapshot(from: session)

        XCTAssertNil(AnalyticsService.bestMatchPair(snapshot: snapshot))
    }

    // MARK: - Predictability

    func test_predictabilityは出題者としての被予測平均を返す() {
        let snapshot = makeSnapshot()
        let results = AnalyticsService.predictability(snapshot: snapshot)

        // A が出題: B=100, C=20 → 平均60
        let predA = results.first { $0.player.id == "p0" }
        XCTAssertEqual(predA?.averageScoreAgainst, 60)

        // B が出題: A=50, C=0 → 平均25
        let predB = results.first { $0.player.id == "p1" }
        XCTAssertEqual(predB?.averageScoreAgainst, 25)
    }

    func test_predictabilityのラベルが正しい() {
        XCTAssertEqual(PlayerPredictability(player: Fixtures.player(name: "X", order: 0), averageScoreAgainst: 80).label, "わかりやすい人")
        XCTAssertEqual(PlayerPredictability(player: Fixtures.player(name: "X", order: 0), averageScoreAgainst: 40).label, "ふつう")
        XCTAssertEqual(PlayerPredictability(player: Fixtures.player(name: "X", order: 0), averageScoreAgainst: 10).label, "謎の人")
    }

    // MARK: - Surprise Ranking

    func test_surpriseRankingはサプライズ指数降順() {
        let snapshot = makeSnapshot()
        let ranking = AnalyticsService.surpriseRanking(snapshot: snapshot)

        XCTAssertEqual(ranking.count, 2)
        // Turn 1: A=50, C=0 → avg=25, surprise=75
        // Turn 0: B=100, C=20 → avg=60, surprise=40
        XCTAssertEqual(ranking[0].turnIndex, 1)
        XCTAssertEqual(ranking[0].surpriseIndex, 75)
        XCTAssertEqual(ranking[1].turnIndex, 0)
        XCTAssertEqual(ranking[1].surpriseIndex, 40)
    }

    func test_surpriseRankingはお題名を含む() {
        let snapshot = makeSnapshot()
        let ranking = AnalyticsService.surpriseRanking(snapshot: snapshot)

        XCTAssertFalse(ranking[0].question.isEmpty)
    }

    func test_空ターンのスナップショットは空配列() {
        var session = Fixtures.session(playerNames: ["A", "B"])
        session.turns = []
        let snapshot = GameSessionSnapshot(from: session)

        XCTAssertTrue(AnalyticsService.surpriseRanking(snapshot: snapshot).isEmpty)
        XCTAssertTrue(AnalyticsService.pairwiseScores(snapshot: snapshot).isEmpty)
        XCTAssertTrue(AnalyticsService.predictability(snapshot: snapshot).isEmpty)
    }
}
