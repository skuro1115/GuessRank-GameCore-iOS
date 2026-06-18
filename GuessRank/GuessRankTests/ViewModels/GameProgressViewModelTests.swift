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

    // MARK: - Topic history integration

    func test_ターン完了でTopicHistoryStoreに記録される() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let history = TopicHistoryStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], history: history)
        let topic = try XCTUnwrap(vm.currentTopic)

        XCTAssertFalse(history.playedIds.contains(topic.id))

        completeTurn(vm: vm, correctAnswer: true)

        XCTAssertTrue(history.playedIds.contains(topic.id), "ターン完了でお題IDが履歴に記録されるべき")
    }

    func test_履歴にあるお題は初期Topicから除外される() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let history = TopicHistoryStore(directory: tempDir)
        // モックの全Topic IDのうち、最初の5件を「プレイ済み」として登録
        let allMockIds = Set((1...20).map { "mock_\($0)" })
        let played = Set(["mock_1", "mock_2", "mock_3", "mock_4", "mock_5"])
        history.record(played)

        let vm = makeViewModel(playerNames: ["A", "B", "C"], cycleCount: 3, history: history)
        // totalTurns = 9
        let initialIds = Set(vm.session.turns.map { $0.topic.id })

        XCTAssertTrue(initialIds.isSubset(of: allMockIds.subtracting(played)),
                     "履歴にあるIDは選ばれるべきでない")
    }

    func test_passTopicは履歴にあるお題を選ばない() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let history = TopicHistoryStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], history: history)

        // セッション内で使われている&使ったお題IDをすべて履歴に登録（モックは20件、totalTurns=2）
        // pass後の候補が履歴により制限されることを確認
        let inSessionIds = Set(vm.session.turns.map { $0.topic.id })
        // 残りのモックIDのうち1件以外を全部履歴に
        let remaining = Set((1...20).map { "mock_\($0)" }).subtracting(inSessionIds)
        let toBlock = remaining.dropLast() // 1つだけ候補を残す
        history.record(toBlock)

        let originalId = vm.currentTopic?.id
        vm.passTopic()

        // pass後は inSession でも履歴済みでもないIDが選ばれるべき
        if let newId = vm.currentTopic?.id, newId != originalId {
            XCTAssertFalse(toBlock.contains(newId), "履歴にあるIDが選ばれてしまった")
            XCTAssertFalse(inSessionIds.contains(newId), "セッション内で使ったIDが選ばれてしまった")
        }
    }

    // MARK: - Topic block integration

    func test_blockCurrentTopicでブロックストアに登録される() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        let topic = try XCTUnwrap(vm.currentTopic)

        vm.blockCurrentTopic(reason: .boring)

        XCTAssertTrue(feedback.isBlocked(topic.id))
        XCTAssertEqual(feedback.blockedEntries.first?.blockReason, .boring)
    }

    func test_blockCurrentTopicでお題が差し替わる() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        let originalId = try XCTUnwrap(vm.currentTopic?.id)

        vm.blockCurrentTopic(reason: nil)

        XCTAssertNotEqual(vm.currentTopic?.id, originalId, "ブロック後はお題が差し替わる")
    }

    func test_ブロック済みお題は初期Topicから除外される() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let blockedIds = Set(["mock_1", "mock_2", "mock_3"])
        for id in blockedIds {
            feedback.block(id, reason: .inappropriate)
        }

        let vm = makeViewModel(playerNames: ["A", "B", "C"], cycleCount: 3, feedback: feedback)
        let initialIds = Set(vm.session.turns.map { $0.topic.id })

        XCTAssertTrue(initialIds.isDisjoint(with: blockedIds), "ブロック済みは選ばれない")
    }

    func test_rankingInputフェーズではblockできない() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        vm.startTargetInput()

        let countBefore = feedback.blockedEntries.count
        vm.blockCurrentTopic(reason: .other)

        XCTAssertEqual(feedback.blockedEntries.count, countBefore, "showTopic 以外ではブロックできない")
    }

    // MARK: - Topic like integration

    func test_toggleLikeCurrentTopicでlike登録される() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        let topic = try XCTUnwrap(vm.currentTopic)

        XCTAssertFalse(vm.isCurrentTopicLiked)
        vm.toggleLikeCurrentTopic()

        XCTAssertTrue(feedback.isLiked(topic.id))
        XCTAssertTrue(vm.isCurrentTopicLiked)
    }

    func test_toggleLikeCurrentTopicは2回でunlike() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        let topic = try XCTUnwrap(vm.currentTopic)

        vm.toggleLikeCurrentTopic()
        vm.toggleLikeCurrentTopic()

        XCTAssertFalse(feedback.isLiked(topic.id))
        XCTAssertFalse(vm.isCurrentTopicLiked)
    }

    func test_likeしてもお題は差し替わらない() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let feedback = TopicFeedbackStore(directory: tempDir)
        let vm = makeViewModel(playerNames: ["A", "B"], feedback: feedback)
        let originalId = try XCTUnwrap(vm.currentTopic?.id)

        vm.toggleLikeCurrentTopic()

        XCTAssertEqual(vm.currentTopic?.id, originalId, "likeはお題を差し替えない")
    }

    // MARK: - Hard mode

    func test_ハードモード_ターゲット入力初期値は空配列() throws {
        let vm = makeHardViewModel(playerNames: ["A", "B"])
        XCTAssertEqual(vm.currentTopic?.playMode, .hard)

        vm.startTargetInput()

        XCTAssertEqual(vm.rankingInput, [], "ハードモードは選択前の空状態で開始")
    }

    func test_ハードモード_canSubmitRankingは3要素揃わないとfalse() {
        let vm = makeHardViewModel(playerNames: ["A", "B"])
        vm.startTargetInput()
        vm.uncoverInput()

        XCTAssertFalse(vm.canSubmitRanking)

        // 1つ選択
        vm.rankingInput = [vm.currentTopic!.choices[0]]
        XCTAssertFalse(vm.canSubmitRanking)

        // 2つ選択
        vm.rankingInput = Array(vm.currentTopic!.choices.prefix(2))
        XCTAssertFalse(vm.canSubmitRanking)

        // 3つ揃ったら true
        vm.rankingInput = Array(vm.currentTopic!.choices.prefix(3))
        XCTAssertTrue(vm.canSubmitRanking)
    }

    func test_ハードモード_未完了状態でsubmitしても進まない() {
        let vm = makeHardViewModel(playerNames: ["A", "B"])
        vm.startTargetInput()
        vm.uncoverInput()
        vm.rankingInput = []  // 未完成

        vm.submitRanking()

        if case .rankingInput(let index, let covered) = vm.phase {
            XCTAssertEqual(index, 0, "未完成 submit ではフェーズが進まない")
            XCTAssertFalse(covered)
        } else {
            XCTFail("ターゲット入力フェーズに留まるべき")
        }
    }

    func test_ハードモード_完全一致ゴールデンパス() throws {
        let vm = makeHardViewModel(playerNames: ["A", "B"])
        let topic = try XCTUnwrap(vm.currentTopic)
        XCTAssertEqual(topic.choices.count, 6)

        let target3 = Array(topic.choices.prefix(3))

        // ターゲット入力: 上位3つ
        vm.startTargetInput()
        vm.uncoverInput()
        vm.rankingInput = target3
        vm.submitRanking()

        // 予想者B: 完全一致
        vm.uncoverInput()
        vm.rankingInput = target3
        vm.submitRanking()

        XCTAssertEqual(vm.phase, .showResult)
        let turn = try XCTUnwrap(vm.currentTurn)
        XCTAssertTrue(turn.isCompleted)
        XCTAssertEqual(turn.correctRanking, target3)
        XCTAssertEqual(turn.answers.first?.score, 100)
    }

    // MARK: - Seed-fixing (再現可能なお題抽選)

    func test_同じseedのVMは同じ初期お題になる() {
        let a = makeSeededViewModel(seed: 555)
        let b = makeSeededViewModel(seed: 555)
        XCTAssertNotNil(a.currentTopic)
        XCTAssertEqual(a.currentTopic?.id, b.currentTopic?.id)
    }

    func test_同じseedのVMはpassTopic後も同じお題になる() {
        // passTopic でも保持した RNG が同一に進むため、差し替え結果まで一致する。
        let a = makeSeededViewModel(seed: 555)
        let b = makeSeededViewModel(seed: 555)
        a.passTopic()
        b.passTopic()
        XCTAssertNotNil(a.currentTopic)
        XCTAssertEqual(a.currentTopic?.id, b.currentTopic?.id)
    }

    // MARK: - Topic pin (お題固定)

    func test_お題固定_初回ターンが固定お題になる() {
        let vm = makePinnedViewModel(pinnedId: "mock_7")
        XCTAssertEqual(vm.currentTopic?.id, "mock_7", "固定したお題が初回ターンに出る")
    }

    func test_お題固定_存在しないIDは無視され通常抽選になる() {
        let vm = makePinnedViewModel(pinnedId: "does_not_exist")
        XCTAssertNotNil(vm.currentTopic, "未知の ID でもクラッシュせず通常抽選のまま")
    }

    func test_お題固定_プレイモード不一致のお題は無視される() {
        let normalMocks = (1...10).map { i in
            Fixtures.topic(id: "mock_\(i)", question: "Q\(i)", choices: ["A\(i)", "B\(i)", "C\(i)"])
        }
        let hard = Topic(
            id: "hard_x",
            question: "HQ",
            choices: ["a", "b", "c", "d", "e", "f"],
            genre: .random,
            difficulty: .normal,
            playMode: .hard
        )
        let provider = MockTopicProvider(topics: normalMocks + [hard])
        // normal ゲームに hard お題を固定しようとしても無視される
        let vm = makePinnedViewModel(pinnedId: "hard_x", provider: provider)
        XCTAssertNotEqual(vm.currentTopic?.id, "hard_x", "プレイモード不一致は差し込まれない")
        XCTAssertEqual(vm.currentTopic?.playMode, .normal)
    }

    func test_お題固定_抽選に含まれても重複しない() {
        // totalTurns = 9。固定お題が抽選結果にもあった場合に2回出ないこと。
        let vm = makePinnedViewModel(pinnedId: "mock_3", playerNames: ["A", "B", "C"], cycleCount: 3)
        var seenIds: [String] = []
        while vm.session.status != .completed {
            if let id = vm.currentTopic?.id { seenIds.append(id) }
            completeTurn(vm: vm, correctAnswer: true)
            vm.advanceToNextTurn()
        }
        XCTAssertEqual(seenIds.first, "mock_3", "初回は固定お題")
        XCTAssertEqual(seenIds.filter { $0 == "mock_3" }.count, 1, "固定お題が重複出題されない")
    }

    func test_お題固定なし_pinnedNilなら通常抽選() {
        let vm = makeViewModel(playerNames: ["A", "B", "C"])
        XCTAssertNotNil(vm.currentTopic, "pinnedTopicId 未指定でも通常どおり抽選される")
    }

    // MARK: - デバッグ表示用の再現状態

    func test_appliedPinnedTopicId_成功時に記録される() {
        let vm = makePinnedViewModel(pinnedId: "mock_7")
        XCTAssertEqual(vm.appliedPinnedTopicId, "mock_7")
    }

    func test_appliedPinnedTopicId_未知IDではnil() {
        let vm = makePinnedViewModel(pinnedId: "does_not_exist")
        XCTAssertNil(vm.appliedPinnedTopicId, "無視された固定はデバッグ表示にも出さない")
    }

    func test_appliedPinnedTopicId_固定なしならnil() {
        let vm = makeViewModel(playerNames: ["A", "B"])
        XCTAssertNil(vm.appliedPinnedTopicId)
    }

    func test_activeTopicSeed_シード指定時に保持される() {
        let vm = makeSeededViewModel(seed: 999)
        XCTAssertEqual(vm.activeTopicSeed, 999)
    }

    func test_activeTopicSeed_シードなしならnil() {
        let vm = makeViewModel(playerNames: ["A", "B"])
        XCTAssertNil(vm.activeTopicSeed)
    }

    // MARK: - Helpers

    private func makePinnedViewModel(
        pinnedId: String,
        playerNames: [String] = ["A", "B", "C"],
        cycleCount: Int = 1,
        provider: MockTopicProvider = MockTopicProvider()
    ) -> GameProgressViewModel {
        let config = Fixtures.config(cycleCount: cycleCount, playerCount: playerNames.count)
        let session = GameSession(config: config, players: Fixtures.players(playerNames))
        return GameProgressViewModel(
            session: session,
            topicProvider: provider,
            pinnedTopicId: pinnedId
        )
    }

    private func makeSeededViewModel(
        seed: UInt64,
        playerNames: [String] = ["A", "B", "C"],
        cycleCount: Int = 1
    ) -> GameProgressViewModel {
        let config = Fixtures.config(cycleCount: cycleCount, playerCount: playerNames.count)
        let session = GameSession(config: config, players: Fixtures.players(playerNames))
        return GameProgressViewModel(
            session: session,
            topicProvider: MockTopicProvider(),
            topicSeed: seed
        )
    }

    private func makeViewModel(
        playerNames: [String],
        cycleCount: Int = 1,
        history: TopicHistoryStore? = nil,
        feedback: TopicFeedbackStore? = nil
    ) -> GameProgressViewModel {
        let config = Fixtures.config(
            cycleCount: cycleCount,
            playerCount: playerNames.count
        )
        let players = Fixtures.players(playerNames)
        let session = GameSession(config: config, players: players)
        return GameProgressViewModel(
            session: session,
            topicProvider: MockTopicProvider(),
            topicHistory: history,
            topicFeedback: feedback
        )
    }

    private func makeHardViewModel(
        playerNames: [String],
        cycleCount: Int = 1
    ) -> GameProgressViewModel {
        let config = GameConfig(
            genre: .random,
            difficulty: .normal,
            cycleCount: cycleCount,
            playerCount: playerNames.count,
            playMode: .hard
        )
        let players = Fixtures.players(playerNames)
        let session = GameSession(config: config, players: players)
        // 6-choice mock topics for hard mode
        let hardTopics = (1...10).map { i in
            Topic(
                id: "hard_mock_\(i)",
                question: "HQ\(i)",
                choices: ["a\(i)", "b\(i)", "c\(i)", "d\(i)", "e\(i)", "f\(i)"],
                genre: .random,
                difficulty: .normal,
                playMode: .hard
            )
        }
        return GameProgressViewModel(
            session: session,
            topicProvider: MockTopicProvider(topics: hardTopics)
        )
    }

    private func makeTempDir() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm_history_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
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
