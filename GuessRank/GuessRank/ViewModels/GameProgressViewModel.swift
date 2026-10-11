import Foundation
import Observation

@Observable
class GameProgressViewModel {
    private(set) var session: GameSession
    private(set) var inputState = TurnInputState()
    private var topics: [Topic] = []
    private var usedTopicIds: Set<String> = []
    private let topicProvider: TopicProviding
    private let topicHistory: TopicHistoryStore?
    private let topicFeedback: TopicFeedbackStore?
    /// お題抽選用の RNG。`topicSeed` が与えられれば決定的、なければシステム乱数。
    /// 初回抽選と `passTopic` の差し替えで同じ系列を進めるため保持する。
    private var topicRNG: TopicRandomNumberGenerator

    /// このゲームで実際に使われた固定シード（なければ `nil`）。デバッグオーバーレイ表示用。
    let activeTopicSeed: UInt64?
    /// 初回ターンへ実際に差し込まれた固定お題 ID（適用されなければ `nil`）。
    /// 不正 ID / プレイモード不一致で無視された場合も `nil`。デバッグオーバーレイ表示用。
    private(set) var appliedPinnedTopicId: String?

    // MARK: - Convenience accessors

    var phase: TurnPhase { inputState.phase }
    var currentTopic: Topic? { inputState.currentTopic }
    var rankingInput: [String] {
        get { inputState.rankingInput }
        set { inputState.rankingInput = newValue }
    }

    var targetPlayer: Player { session.currentTargetPlayer }
    var guessingPlayers: [Player] { session.guessingPlayers }
    var turnLabel: String { "ターン \(session.currentTurnIndex + 1) / \(session.totalTurns)" }
    var isLastTurn: Bool { session.isLastTurn }

    var currentInputPlayer: Player? {
        switch phase {
        case .showTopic, .showResult:
            nil
        case .rankingInput(let playerIndex, _):
            playerIndex == 0 ? targetPlayer : guessingPlayers[playerIndex - 1]
        }
    }

    var isTargetInput: Bool {
        if case .rankingInput(0, _) = phase { return true }
        return false
    }

    var currentTurn: Turn? { session.turns.last }
    var sortedResults: [Player] { session.players.sorted { $0.score > $1.score } }

    // MARK: - Init

    var canPass: Bool {
        phase == .showTopic
    }

    /// 「決定」ボタンを押せるか。ノーマルは常に true（並び替え結果が常に3要素）。
    /// ハードは選択された3スロットが全て埋まっていることが条件。
    var canSubmitRanking: Bool {
        guard case .rankingInput(_, false) = phase else { return false }
        let needed = currentTopic?.playMode.rankSlotCount ?? 3
        return rankingInput.count == needed && rankingInput.allSatisfy { !$0.isEmpty }
    }

    init(
        session: GameSession,
        topicProvider: TopicProviding = TopicService(),
        topicHistory: TopicHistoryStore? = nil,
        topicFeedback: TopicFeedbackStore? = nil,
        topicSeed: UInt64? = nil,
        pinnedTopicId: String? = nil
    ) {
        self.session = session
        self.topicProvider = topicProvider
        self.topicHistory = topicHistory
        self.topicFeedback = topicFeedback
        self.topicRNG = TopicRandomNumberGenerator(seed: topicSeed)
        self.activeTopicSeed = topicSeed
        var excluded: Set<String> = topicHistory?.playedIds ?? []
        if let blocked = topicFeedback?.blockedIds {
            excluded.formUnion(blocked)
        }
        self.topics = topicProvider.pickTopics(
            count: session.totalTurns,
            genre: session.config.genre,
            difficulty: session.config.difficulty,
            playMode: session.config.playMode,
            excluding: excluded,
            using: &topicRNG
        )
        applyPinnedTopic(pinnedTopicId)
        loadTopic()
    }

    /// dev_mode「お題固定」用。指定 ID のお題を初回ターン（`topics[0]`）に差し込む。
    /// プレイモードが一致しない ID（例: ハードお題をノーマルゲームに）は無視する。
    /// 抽選結果に同じお題が含まれていれば重複させず先頭へ移動する。
    private func applyPinnedTopic(_ pinnedId: String?) {
        guard let pinnedId,
              let pinned = topicProvider.topic(withId: pinnedId),
              pinned.playMode == session.config.playMode
        else { return }
        appliedPinnedTopicId = pinned.id
        if topics.first?.id == pinned.id { return }
        topics.removeAll { $0.id == pinned.id }
        topics.insert(pinned, at: 0)
        topics = Array(topics.prefix(session.totalTurns))
    }

    // MARK: - Actions

    func startTargetInput() {
        inputState.startTargetInput()
    }

    func uncoverInput() {
        inputState.uncoverInput()
    }

    func submitRanking() {
        guard case .rankingInput(let playerIndex, false) = phase else { return }
        guard canSubmitRanking else { return }

        if playerIndex == 0 {
            GameEngine.applyTargetRanking(ranking: rankingInput, to: &session)
        } else {
            let guesser = guessingPlayers[playerIndex - 1]
            _ = GameEngine.applyGuesserAnswer(
                ranking: rankingInput,
                guesser: guesser,
                session: &session
            )
        }

        inputState.moveToNextInput(
            afterPlayerIndex: playerIndex,
            guesserCount: guessingPlayers.count
        )

        if case .showResult = phase {
            GameEngine.completeTurn(session: &session)
            if let topicId = currentTopic?.id {
                topicHistory?.record(topicId)
            }
        }
    }

    /// 現在のお題をブロック登録してから次のお題に差し替える。
    /// `phase == .showTopic` のときのみ実行可能（出題前の差し替えだけを許可）。
    func blockCurrentTopic(reason: TopicBlockReason? = nil) {
        guard canPass, let current = currentTopic else { return }
        topicFeedback?.block(current.id, reason: reason)
        passTopic()
    }

    /// 現在のお題に「面白い」FBを付ける／外す（出題前のみ）。
    /// 同じお題にFBが付いていても続行できるよう、ここではお題を差し替えない。
    func toggleLikeCurrentTopic() {
        guard canPass, let current = currentTopic, let store = topicFeedback else { return }
        if store.isLiked(current.id) {
            store.unlike(current.id)
        } else {
            store.like(current.id)
        }
    }

    var isCurrentTopicLiked: Bool {
        guard let id = currentTopic?.id else { return false }
        return topicFeedback?.isLiked(id) ?? false
    }

    func passTopic() {
        guard canPass else { return }

        if let current = currentTopic {
            usedTopicIds.insert(current.id)
        }

        var excluded = usedTopicIds.union(topics.map { $0.id })
        if let history = topicHistory {
            excluded.formUnion(history.playedIds)
        }
        if let feedback = topicFeedback {
            excluded.formUnion(feedback.blockedIds)
        }
        let candidates = topicProvider.pickTopics(
            count: 1,
            genre: session.config.genre,
            difficulty: session.config.difficulty,
            playMode: session.config.playMode,
            excluding: excluded,
            using: &topicRNG
        )

        guard let replacement = candidates.first, !excluded.contains(replacement.id) else { return }

        let topicIndex = session.currentTurnIndex
        topics[topicIndex] = replacement
        session.turns.removeLast()

        inputState.loadTopic(replacement)
        let turn = Turn(
            turnIndex: session.currentTurnIndex,
            targetPlayerId: session.currentTargetPlayer.id,
            topic: replacement
        )
        session.turns.append(turn)
    }

    func advanceToNextTurn() {
        GameEngine.advanceToNextTurn(session: &session)
        if session.status != .completed {
            loadTopic()
        }
    }

    func snapshot() -> GameSessionSnapshot {
        GameSessionSnapshot(from: session)
    }

    // MARK: - Private

    private func loadTopic() {
        let topicIndex = session.currentTurnIndex
        guard topicIndex < topics.count else { return }

        let topic = topics[topicIndex]
        inputState.loadTopic(topic)

        let turn = Turn(
            turnIndex: session.currentTurnIndex,
            targetPlayerId: session.currentTargetPlayer.id,
            topic: topic
        )
        session.turns.append(turn)
    }
}
