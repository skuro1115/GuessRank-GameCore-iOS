import Foundation

enum GameEngine {
    static func applyTargetRanking(
        ranking: [String],
        to session: inout GameSession
    ) {
        session.turns[session.turns.count - 1].correctRanking = ranking
    }

    static func applyGuesserAnswer(
        ranking: [String],
        guesser: Player,
        session: inout GameSession
    ) -> Answer {
        let correctRanking = session.turns.last?.correctRanking ?? []
        let score = ScoreService.calculateScore(correct: correctRanking, answer: ranking)
        let answer = Answer(playerId: guesser.id, ranking: ranking, score: score)

        session.turns[session.turns.count - 1].answers.append(answer)
        if let idx = session.players.firstIndex(where: { $0.id == guesser.id }) {
            session.players[idx].score += score
        }
        return answer
    }

    static func completeTurn(session: inout GameSession) {
        session.turns[session.turns.count - 1].isCompleted = true
    }

    static func advanceToNextTurn(session: inout GameSession) {
        session.currentTurnIndex += 1
        if session.currentTurnIndex >= session.totalTurns {
            session.status = .completed
        }
    }
}
