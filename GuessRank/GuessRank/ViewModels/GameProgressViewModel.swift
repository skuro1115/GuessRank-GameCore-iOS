import Foundation
import Observation

@Observable
class GameProgressViewModel {
    private(set) var session: GameSession
    private(set) var inputState = TurnInputState()
    private var topics: [Topic] = []
    private var usedTopicIds: Set<String> = []
    private let topicProvider: TopicProviding

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

    init(session: GameSession, topicProvider: TopicProviding = TopicService()) {
        self.session = session
        self.topicProvider = topicProvider
        self.topics = topicProvider.pickTopics(
            count: session.totalTurns,
            genre: session.config.genre,
            difficulty: session.config.difficulty
        )
        loadTopic()
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
        }
    }

    func passTopic() {
        guard canPass else { return }

        if let current = currentTopic {
            usedTopicIds.insert(current.id)
        }

        let allUsed = usedTopicIds.union(topics.map { $0.id })
        let candidates = topicProvider.pickTopics(
            count: 10,
            genre: session.config.genre,
            difficulty: session.config.difficulty
        ).filter { !allUsed.contains($0.id) }

        guard let replacement = candidates.first else { return }

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
