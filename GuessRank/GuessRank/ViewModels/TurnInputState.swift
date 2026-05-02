import Foundation
import Observation

@Observable
class TurnInputState {
    var phase: TurnPhase = .showTopic
    var rankingInput: [String] = []
    private(set) var currentTopic: Topic?

    func loadTopic(_ topic: Topic) {
        currentTopic = topic
        phase = .showTopic
    }

    func startTargetInput() {
        guard let topic = currentTopic else { return }
        rankingInput = topic.choices
        phase = .rankingInput(playerIndex: 0, isCovered: true)
    }

    func uncoverInput() {
        if case .rankingInput(let index, true) = phase {
            phase = .rankingInput(playerIndex: index, isCovered: false)
        }
    }

    func moveToNextInput(afterPlayerIndex current: Int, guesserCount: Int) {
        let nextPlayerIndex = current + 1
        let totalInputPlayers = 1 + guesserCount

        if nextPlayerIndex < totalInputPlayers {
            guard let topic = currentTopic else { return }
            rankingInput = topic.choices
            phase = .rankingInput(playerIndex: nextPlayerIndex, isCovered: true)
        } else {
            phase = .showResult
        }
    }
}
