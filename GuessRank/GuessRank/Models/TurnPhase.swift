import Foundation

enum TurnPhase: Equatable {
    case showTopic
    case rankingInput(playerIndex: Int, isCovered: Bool)
    case showResult
}
