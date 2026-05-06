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
        rankingInput = initialRanking(for: topic)
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
            rankingInput = initialRanking(for: topic)
            phase = .rankingInput(playerIndex: nextPlayerIndex, isCovered: true)
        } else {
            phase = .showResult
        }
    }

    /// 入力初期値: ノーマルは選択肢そのまま並べた状態（ドラッグで並び替える）。
    /// ハードは未選択（空配列）から開始し、ユーザーが3つを選んでスロットに入れる。
    private func initialRanking(for topic: Topic) -> [String] {
        switch topic.playMode {
        case .normal:
            return topic.choices
        case .hard:
            return []
        }
    }
}
