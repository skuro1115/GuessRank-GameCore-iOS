import XCTest
@testable import GuessRankCore

/// Golden path tests for GameProgressViewModel.
/// Validates full turn flow: showTopic → questioner input → guesser inputs → showResult → next turn.
final class GameProgressViewModelTests: XCTestCase {
    // MARK: - Initial state

    func test_初期状態はshowTopicフェーズ() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        XCTAssertEqual(vm.phase, .showTopic)
    }

    func test_初期Topicがロードされている() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        XCTAssertNotNil(vm.currentTopic)
    }

    func test_初期currentTurnが生成されている() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        XCTAssertEqual(vm.session.turns.count, 1)
        XCTAssertEqual(vm.session.turns[0].turnIndex, 0)
    }

    func test_初期questionerは1人目() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        XCTAssertEqual(vm.targetPlayer.name, "A")
        XCTAssertEqual(vm.guessingPlayers.map { $0.name }, ["B", "C"])
    }

    // MARK: - Phase transitions

    func test_startTargetInputでターゲット入力フェーズに遷移() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        vm.startTargetInput()

        if case .rankingInput(let index, let covered) = vm.phase {
            XCTAssertEqual(index, 0)
            XCTAssertTrue(covered)
        } else {
            XCTFail("rankingInput(0, true) であるべき")
        }
        XCTAssertEqual(vm.currentInputPlayer?.name, "A")
        XCTAssertTrue(vm.isTargetInput)
    }

    func test_uncoverInputでカバーが外れる() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        vm.startTargetInput()
        vm.uncoverInput()

        if case .rankingInput(let index, let covered) = vm.phase {
            XCTAssertEqual(index, 0)
            XCTAssertFalse(covered)
        } else {
            XCTFail("rankingInput(0, false) であるべき")
        }
    }

    func test_startTargetInputでrankingInputがchoicesで初期化() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        vm.startTargetInput()

        XCTAssertEqual(vm.rankingInput.count, 3)
        XCTAssertEqual(vm.rankingInput, vm.currentTopic?.choices)
    }

    // MARK: - Golden path: full turn

    func test_ゴールデンパス_1ターン完走() throws {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        let topic = try XCTUnwrap(vm.currentTopic)
        let correctRanking = topic.choices // A は選択肢の順番そのままで設定

        // 1. ターゲット入力開始 → uncover → submit
        vm.startTargetInput()
        vm.uncoverInput()
        vm.rankingInput = correctRanking
        vm.submitRanking()

        // 次は予想者B
        guard case .rankingInput(let bIndex, let bCovered) = vm.phase else {
            return XCTFail("rankingInput(1, true) であるべき")
        }
        XCTAssertEqual(bIndex, 1)
        XCTAssertTrue(bCovered)
        XCTAssertEqual(vm.currentInputPlayer?.name, "B")
        XCTAssertFalse(vm.isTargetInput)

        // 2. 予想者B: uncover → 完全一致で submit
        vm.uncoverInput()
        vm.rankingInput = correctRanking
        vm.submitRanking()

        // 次は予想者C
        guard case .rankingInput(let cIndex, _) = vm.phase else {
            return XCTFail("rankingInput(2, true) であるべき")
        }
        XCTAssertEqual(cIndex, 2)
        XCTAssertEqual(vm.currentInputPlayer?.name, "C")

        // 3. 予想者C: uncover → 完全に外れて submit
        vm.uncoverInput()
        vm.rankingInput = [correctRanking[1], correctRanking[2], correctRanking[0]] // 全ずれ
        vm.submitRanking()

        // 結果フェーズへ
        XCTAssertEqual(vm.phase, .showResult)

        // スコア検証: B=100, C=0
        let turn = try XCTUnwrap(vm.currentTurn)
        XCTAssertTrue(turn.isCompleted)
        XCTAssertEqual(turn.answers.count, 2)
        XCTAssertEqual(turn.correctRanking, correctRanking)

        let bAnswer = try XCTUnwrap(turn.answers.first { $0.playerId == "p1" })
        XCTAssertEqual(bAnswer.score, 100)

        let cAnswer = try XCTUnwrap(turn.answers.first { $0.playerId == "p2" })
        XCTAssertEqual(cAnswer.score, 0)

        // 累計スコア検証
        XCTAssertEqual(vm.session.players.first { $0.id == "p1" }?.score, 100)
        XCTAssertEqual(vm.session.players.first { $0.id == "p2" }?.score, 0)
    }

    func test_次ターンへ進むとquestionerがローテーション() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"], cycleCount: 2)

        // 1ターン目完走
        completeTurn(vm: vm, correctAnswer: true)

        // advance
        vm.advanceToNextTurn()

        XCTAssertEqual(vm.phase, .showTopic)
        XCTAssertEqual(vm.session.currentTurnIndex, 1)
        XCTAssertEqual(vm.targetPlayer.name, "B")
    }

    func test_最終ターン完了でcompletedに遷移() {
        let vm = makeViewModel(playerNames: ["A", "B"], cycleCount: 1)
        // totalTurns = 2

        // Turn 0: 完走
        completeTurn(vm: vm, correctAnswer: true)
        vm.advanceToNextTurn()

        // Turn 1: 完走
        completeTurn(vm: vm, correctAnswer: true)
        vm.advanceToNextTurn()

        XCTAssertEqual(vm.session.status, .completed)
    }

    func test_sortedResultsはスコア降順() {
        // B=完全一致(100点), C=全外れ(0点) で1ターン完走 → A=ターゲット(0点)
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        guard let topic = vm.currentTopic else { return XCTFail("topic がない") }
        let correct = topic.choices

        vm.startTargetInput()
        vm.uncoverInput()
        vm.rankingInput = correct
        vm.submitRanking()

        // B: 完全一致
        vm.uncoverInput()
        vm.rankingInput = correct
        vm.submitRanking()

        // C: 全外れ
        vm.uncoverInput()
        vm.rankingInput = [correct[1], correct[2], correct[0]]
        vm.submitRanking()

        let sorted = vm.sortedResults
        XCTAssertEqual(sorted.first?.name, "B", "100点の B が1位であるべき")
        XCTAssertEqual(sorted.first?.score, 100)
    }

    // MARK: - Pass topic（場を円滑にするためのオプション、回数無制限）

    func test_passTopicでお題が変わる() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        let originalQuestion = vm.currentTopic?.question

        vm.passTopic()

        XCTAssertNotEqual(vm.currentTopic?.question, originalQuestion, "パス後はお題が変わるべき")
        XCTAssertEqual(vm.phase, .showTopic, "パス後もshowTopicフェーズ")
    }

    func test_passTopicは回数制限なしで複数回使える() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])

        vm.passTopic()
        XCTAssertTrue(vm.canPass, "1回目のパス後もcanPassはtrue")

        vm.passTopic()
        XCTAssertTrue(vm.canPass, "2回目のパス後もcanPassはtrue")
    }

    func test_showTopic以外のフェーズではcanPassがfalse() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        vm.startTargetInput()

        XCTAssertFalse(vm.canPass, "rankingInputフェーズではパス不可")
    }

    // MARK: - Helpers

    private func makeViewModel(
        playerNames: [String],
        cycleCount: Int = 1
    ) -> GameProgressViewModel {
        let config = Fixtures.config(
            cycleCount: cycleCount,
            playerCount: playerNames.count
        )
        let players = Fixtures.players(playerNames)
        let session = GameSession(config: config, players: players)
        return GameProgressViewModel(session: session, topicProvider: MockTopicProvider())
    }

    /// 1ターンを完走させるヘルパー。correctAnswer=true なら全員が正解で100点、false なら全員外れ。
    private func completeTurn(vm: GameProgressViewModel, correctAnswer: Bool) {
        guard let topic = vm.currentTopic else { return }
        let correctRanking = topic.choices

        // ターゲット入力
        vm.startTargetInput()
        vm.uncoverInput()
        vm.rankingInput = correctRanking
        vm.submitRanking()

        // 全予想者入力
        for _ in vm.guessingPlayers {
            vm.uncoverInput()
            if correctAnswer {
                vm.rankingInput = correctRanking
            } else {
                vm.rankingInput = [correctRanking[1], correctRanking[2], correctRanking[0]]
            }
            vm.submitRanking()
        }
    }
}
