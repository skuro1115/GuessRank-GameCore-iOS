import Foundation

// MARK: - Result types

struct PairScore {
    let guesser: Player
    let target: Player
    let averageScore: Double
}

struct BestMatch {
    let playerA: Player
    let playerB: Player
    let mutualScore: Double
}

struct PlayerPredictability {
    let player: Player
    let averageScoreAgainst: Double

    var label: String {
        if averageScoreAgainst >= 60 { return "わかりやすい人" }
        if averageScoreAgainst >= 30 { return "ふつう" }
        return "謎の人"
    }
}

struct TurnSurprise {
    let turnIndex: Int
    let question: String
    let averageScore: Double
    let surpriseIndex: Double // 100 - averageScore
}

// MARK: - Analytics Service

enum AnalyticsService {
    /// ペア別の平均スコア: 予想者 が ターゲット の出題ターンで取ったスコアの平均
    static func pairwiseScores(snapshot: GameSessionSnapshot) -> [PairScore] {
        var results: [PairScore] = []
        let players = snapshot.players

        for target in players {
            let targetTurns = snapshot.turns.filter { $0.targetPlayerId == target.id }
            for guesser in players where guesser.id != target.id {
                let scores = targetTurns.compactMap { turn in
                    turn.answers.first { $0.playerId == guesser.id }?.score
                }
                guard !scores.isEmpty else { continue }
                let avg = Double(scores.reduce(0, +)) / Double(scores.count)
                results.append(PairScore(guesser: guesser, target: target, averageScore: avg))
            }
        }
        return results
    }

    /// 最も気が合うコンビ: 双方向の平均スコアが最大のペア
    static func bestMatchPair(snapshot: GameSessionSnapshot) -> BestMatch? {
        let pairs = pairwiseScores(snapshot: snapshot)
        let players = snapshot.players
        guard players.count >= 2 else { return nil }

        var bestMatch: BestMatch?
        var bestScore: Double = -1

        for i in 0..<players.count {
            for j in (i + 1)..<players.count {
                let a = players[i]
                let b = players[j]
                let aToB = pairs.first { $0.guesser.id == a.id && $0.target.id == b.id }?.averageScore ?? 0
                let bToA = pairs.first { $0.guesser.id == b.id && $0.target.id == a.id }?.averageScore ?? 0
                let mutual = (aToB + bToA) / 2

                if mutual > bestScore {
                    bestScore = mutual
                    bestMatch = BestMatch(playerA: a, playerB: b, mutualScore: mutual)
                }
            }
        }
        return bestMatch
    }

    /// 読まれやすさ: ターゲットとしての被予測平均スコア
    static func predictability(snapshot: GameSessionSnapshot) -> [PlayerPredictability] {
        snapshot.players.compactMap { player in
            let targetTurns = snapshot.turns.filter { $0.targetPlayerId == player.id }
            let allScores = targetTurns.flatMap { $0.answers.map { $0.score } }
            guard !allScores.isEmpty else { return nil }
            let avg = Double(allScores.reduce(0, +)) / Double(allScores.count)
            return PlayerPredictability(player: player, averageScoreAgainst: avg)
        }
    }

    /// サプライズ指数: 全予想者の平均スコアが低いターン順
    static func surpriseRanking(snapshot: GameSessionSnapshot) -> [TurnSurprise] {
        snapshot.turns.compactMap { turn in
            guard !turn.answers.isEmpty else { return nil }
            let avg = Double(turn.answers.map { $0.score }.reduce(0, +)) / Double(turn.answers.count)
            return TurnSurprise(
                turnIndex: turn.turnIndex,
                question: turn.topic.question,
                averageScore: avg,
                surpriseIndex: 100 - avg
            )
        }
        .sorted { $0.surpriseIndex > $1.surpriseIndex }
    }
}
