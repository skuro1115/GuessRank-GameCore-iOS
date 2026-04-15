import Foundation
import Observation

@Observable
class GameProgressViewModel {
    private(set) var session: GameSession
    private(set) var phase: TurnPhase = .showTopic
    private var topics: [Topic] = []

    // Current turn state
    private(set) var currentTopic: Topic?
    var rankingInput: [String] = []

    var questioner: Player { session.currentQuestioner }
    var respondents: [Player] { session.respondents }
    var turnLabel: String { "ターン \(session.currentTurnIndex + 1) / \(session.totalTurns)" }
    var isLastTurn: Bool { session.isLastTurn }

    /// The player whose turn it is to input (questioner or respondent)
    var currentInputPlayer: Player? {
        switch phase {
        case .showTopic, .showResult:
            nil
        case .rankingInput(let playerIndex, _):
            if playerIndex == 0 {
                questioner
            } else {
                respondents[playerIndex - 1]
            }
        }
    }

    /// Whether the current input is for the questioner (setting correct ranking)
    var isQuestionerInput: Bool {
        if case .rankingInput(0, _) = phase { return true }
        return false
    }

    init(session: GameSession) {
        self.session = session
        self.topics = TopicService.pickTopics(
            count: session.totalTurns,
            genre: session.config.genre,
            difficulty: session.config.difficulty
        )
        loadTopic()
    }

    // MARK: - Phase transitions

    func startQuestionerInput() {
        guard let topic = currentTopic else { return }
        rankingInput = topic.choices
        phase = .rankingInput(playerIndex: 0, isCovered: true)
    }

    func uncoverInput() {
        if case .rankingInput(let index, true) = phase {
            phase = .rankingInput(playerIndex: index, isCovered: false)
        }
    }

    func submitRanking() {
        guard case .rankingInput(let playerIndex, false) = phase else { return }

        if playerIndex == 0 {
            // Questioner submitted correct ranking
            session.turns[session.turns.count - 1].correctRanking = rankingInput
            moveToNextInput(afterPlayerIndex: 0)
        } else {
            // Respondent submitted answer
            let respondentIndex = playerIndex - 1
            let respondent = respondents[respondentIndex]
            let correctRanking = session.turns.last?.correctRanking ?? []
            let score = ScoreService.calculateScore(correct: correctRanking, answer: rankingInput)
            let answer = Answer(playerId: respondent.id, ranking: rankingInput, score: score)

            session.turns[session.turns.count - 1].answers.append(answer)
            if let idx = session.players.firstIndex(where: { $0.id == respondent.id }) {
                session.players[idx].score += score
            }

            moveToNextInput(afterPlayerIndex: playerIndex)
        }
    }

    func advanceToNextTurn() {
        session.currentTurnIndex += 1
        if session.currentTurnIndex >= session.totalTurns {
            session.status = .completed
        } else {
            loadTopic()
            phase = .showTopic
        }
    }

    var currentTurn: Turn? {
        session.turns.last
    }

    var sortedResults: [Player] {
        session.players.sorted { $0.score > $1.score }
    }

    // MARK: - Private

    private func moveToNextInput(afterPlayerIndex current: Int) {
        let nextPlayerIndex = current + 1
        // playerIndex 0 = questioner, 1..n = respondents
        let totalInputPlayers = 1 + respondents.count

        if nextPlayerIndex < totalInputPlayers {
            guard let topic = currentTopic else { return }
            rankingInput = topic.choices
            phase = .rankingInput(playerIndex: nextPlayerIndex, isCovered: true)
        } else {
            session.turns[session.turns.count - 1].isCompleted = true
            phase = .showResult
        }
    }

    private func loadTopic() {
        let topicIndex = session.currentTurnIndex
        guard topicIndex < topics.count else { return }

        let topic = topics[topicIndex]
        currentTopic = topic

        let turn = Turn(
            turnIndex: session.currentTurnIndex,
            questionerId: session.currentQuestioner.id,
            topic: topic
        )
        session.turns.append(turn)
    }
}
