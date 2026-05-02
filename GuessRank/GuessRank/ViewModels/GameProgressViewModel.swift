import Foundation
import Observation

@Observable
class GameProgressViewModel {
    static let maxPassesPerGame = 3

    private(set) var session: GameSession
    private(set) var inputState = TurnInputState()
    private var topics: [Topic] = []
    private var spareTopics: [Topic] = []
    private(set) var passesRemaining: Int = maxPassesPerGame

    // MARK: - Convenience accessors

    var phase: TurnPhase { inputState.phase }
    var currentTopic: Topic? { inputState.currentTopic }
    var rankingInput: [String] {
        get { inputState.rankingInput }
        set { inputState.rankingInput = newValue }
    }

    var questioner: Player { session.currentQuestioner }
    var respondents: [Player] { session.respondents }
    var turnLabel: String { "ターン \(session.currentTurnIndex + 1) / \(session.totalTurns)" }
    var isLastTurn: Bool { session.isLastTurn }

    var currentInputPlayer: Player? {
        switch phase {
        case .showTopic, .showResult:
            nil
        case .rankingInput(let playerIndex, _):
            playerIndex == 0 ? questioner : respondents[playerIndex - 1]
        }
    }

    var isQuestionerInput: Bool {
        if case .rankingInput(0, _) = phase { return true }
        return false
    }

    var currentTurn: Turn? { session.turns.last }
    var sortedResults: [Player] { session.players.sorted { $0.score > $1.score } }

    // MARK: - Init

    var canPass: Bool {
        passesRemaining > 0 && !spareTopics.isEmpty && phase == .showTopic
    }

    init(session: GameSession, topicProvider: TopicProviding = TopicService()) {
        self.session = session
        let allPicked = topicProvider.pickTopics(
            count: session.totalTurns + Self.maxPassesPerGame,
            genre: session.config.genre,
            difficulty: session.config.difficulty
        )
        self.topics = Array(allPicked.prefix(session.totalTurns))
        self.spareTopics = Array(allPicked.dropFirst(session.totalTurns))
        loadTopic()
    }

    // MARK: - Actions (delegate to InputState / GameEngine)

    func startQuestionerInput() {
        inputState.startQuestionerInput()
    }

    func uncoverInput() {
        inputState.uncoverInput()
    }

    func submitRanking() {
        guard case .rankingInput(let playerIndex, false) = phase else { return }

        if playerIndex == 0 {
            GameEngine.applyQuestionerRanking(ranking: rankingInput, to: &session)
        } else {
            let respondent = respondents[playerIndex - 1]
            _ = GameEngine.applyRespondentAnswer(
                ranking: rankingInput,
                respondent: respondent,
                session: &session
            )
        }

        inputState.moveToNextInput(
            afterPlayerIndex: playerIndex,
            respondentCount: respondents.count
        )

        if case .showResult = phase {
            GameEngine.completeTurn(session: &session)
        }
    }

    func passTopic() {
        guard canPass, let spare = spareTopics.first else { return }
        spareTopics.removeFirst()
        passesRemaining -= 1

        // Replace current topic and turn
        let topicIndex = session.currentTurnIndex
        topics[topicIndex] = spare
        session.turns.removeLast()

        inputState.loadTopic(spare)
        let turn = Turn(
            turnIndex: session.currentTurnIndex,
            questionerId: session.currentQuestioner.id,
            topic: spare
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
            questionerId: session.currentQuestioner.id,
            topic: topic
        )
        session.turns.append(turn)
    }
}
